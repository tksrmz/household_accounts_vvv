import 'dart:math';

import 'package:flutter/material.dart';
import 'package:household_accounts/util/extension/date_time.dart';
import 'package:provider/provider.dart';

import '../../feature/budget_analyzer/budget_analyzer_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../common_widget/loading.dart';
import '../util/custom_cycle.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

/// 予算タブの期間表示モード。
///
/// なぜ必要か: AC-006〜AC-010（暦月⇔月度の切替・月度の期間送り）を
/// 表現するため、表示中の期間を「暦月（従来通り）」か
/// 「月度（16日〜翌月15日サイクル）」かで切り替えられるようにする。
enum PeriodMode { calendar, customCycle }

class BudgetViewerPage extends StatelessWidget {
  const BudgetViewerPage({
    super.key,
    DateTime Function() now = DateTime.now,
    RetrieveBudgetStateUseCase? useCase,
  })  : _now = now,
        _useCase = useCase;

  /// 現在時刻の供給源。
  ///
  /// なぜ注入可能にするか: AC-006/007/010（「今日」基準の月度判定）を
  /// widgetテストで固定日付を使って検証できるようにするため
  /// （design.md セクション3「構造的制約」参照）。
  final DateTime Function() _now;

  /// 予算取得UseCase。
  ///
  /// なぜ注入可能にするか: get_it（`sl`）のグローバル状態に依存せず、
  /// widgetテストでテストダブルを直接渡せるようにするため。
  /// 未指定時は従来通り `sl` から解決する。
  final RetrieveBudgetStateUseCase? _useCase;

  @override
  Widget build(BuildContext context) {
    return _PageContents(
      singleOrPair: context.watch<SelectedNoteState>().value,
      now: _now,
      useCase: _useCase ?? sl<RetrieveBudgetStateUseCase>(),
    );
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({
    required SelectedNote singleOrPair,
    required DateTime Function() now,
    required RetrieveBudgetStateUseCase useCase,
  })  : _singleOrPair = singleOrPair,
        _now = now,
        _useCase = useCase;

  final SelectedNote _singleOrPair;
  final DateTime Function() _now;
  final RetrieveBudgetStateUseCase _useCase;

  @override
  State<_PageContents> createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
  late Future<ExceptionOr<RetrieveBudgetStateOutput>> _budgetFuture;
  late DateTime _date;
  PeriodMode _mode = PeriodMode.calendar;
  CustomCycle? _cycle;

  @override
  void initState() {
    super.initState();
    _date = widget._now();
    _setFuture();
  }

  @override
  void didUpdateWidget(_PageContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setFuture();
  }

  void _setFuture() {
    final DateTime begin;
    final DateTime end;
    switch (_mode) {
      case PeriodMode.calendar:
        begin = DateTime(_date.year, _date.month);
        end = begin.nextMonth();
        break;
      case PeriodMode.customCycle:
        begin = _cycle!.begin;
        end = _cycle!.end;
        break;
    }
    final sop = widget._singleOrPair;
    final repoId = context.read<UserInfo>().repoId(sop);
    _budgetFuture = widget._useCase(
      RetrieveBudgetStateInput(
        uid: repoId,
        begin: begin,
        end: end,
        recordRepository: selectExpenseRecordRepository(sop),
        categoryRepository: selectExpenseCategoryRepository(sop),
      ),
    );
  }

  /// 期間モードを切り替える。
  ///
  /// なぜ常に「今日基準」にリセットするか: AC-006/007の仕様上、
  /// モード切替時は保持中の表示期間を引き継がず、
  /// 常に「今日が属する期間」で再計算するため（design.md セクション2）。
  void _switchMode(PeriodMode newMode) {
    setState(() {
      _mode = newMode;
      if (newMode == PeriodMode.customCycle) {
        _cycle = CustomCycle.containing(widget._now());
      } else {
        _date = widget._now();
      }
      _setFuture();
    });
  }

  void _goToPreviousCycle() {
    setState(() {
      _cycle = _cycle!.previous();
      _setFuture();
    });
  }

  void _goToNextCycle() {
    // AC-010: 未来の月度へは移動できない
    if (_cycle!.isCurrent(widget._now())) {
      return;
    }
    setState(() {
      _cycle = _cycle!.next();
      _setFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<PeriodMode>(
            segments: const [
              ButtonSegment(value: PeriodMode.calendar, label: Text('暦月')),
              ButtonSegment(
                value: PeriodMode.customCycle,
                label: Text('月度'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selected) => _switchMode(selected.first),
          ),
        ),
        if (_mode == PeriodMode.customCycle)
          _PeriodNavigationWidget(
            label: _formatCycleLabel(_cycle!),
            onPreviousPressed: _goToPreviousCycle,
            onNextPressed: _goToNextCycle,
            disableNextButton: _cycle!.isCurrent(widget._now()),
          ),
        Expanded(
          child: FutureBuilder<ExceptionOr<RetrieveBudgetStateOutput>>(
            future: _budgetFuture,
            builder: (context, snapshot) {
              final hasConnected =
                  snapshot.connectionState == ConnectionState.done;
              if (hasConnected && snapshot.hasError) {
                return const Center(
                  child: Text('エラーが発生しました'),
                );
              }

              if (hasConnected && snapshot.hasData) {
                return snapshot.data!.fold(
                  (failure) => Center(
                    child: Text(failure.toString()),
                  ),
                  (output) {
                    return ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: output.states.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _BudgetListItem(
                            budgetState: output.states[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(
                            color: Colors.black,
                          );
                        });
                  },
                );
              }

              return const Center(
                child: LoadingWidget(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// [cycle] の表示ラベルを生成する。
///
/// 例: CustomCycle(2026, 7) → 「2026年7月度（6/16〜7/15）」
/// endは排他的境界（当月16日 00:00:00）のため、表示上の終了日は
/// その前日（必ず15日）になる。
String _formatCycleLabel(CustomCycle cycle) {
  final displayEnd = cycle.end.subtract(const Duration(days: 1));
  return '${cycle.year}年${cycle.month}月度'
      '（${cycle.begin.month}/${cycle.begin.day}〜${displayEnd.month}/${displayEnd.day}）';
}

/// 期間送りナビゲーション用Widget。
///
/// カレンダー画面の `_DateLabelWidget` と同様の「前後矢印＋ラベル」の
/// 構成を持つが、次ボタンの無効化フラグをbool引数で受け取る点が異なる
/// （design.md セクション2「期間ナビゲーションWidget」参照）。
class _PeriodNavigationWidget extends StatelessWidget {
  const _PeriodNavigationWidget({
    required String label,
    required VoidCallback onPreviousPressed,
    required VoidCallback onNextPressed,
    required bool disableNextButton,
  })  : _label = label,
        _onPreviousPressed = onPreviousPressed,
        _onNextPressed = onNextPressed,
        _disableNextButton = disableNextButton;

  final String _label;
  final VoidCallback _onPreviousPressed;
  final VoidCallback _onNextPressed;
  final bool _disableNextButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: _onPreviousPressed,
        ),
        Text(_label),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: _disableNextButton ? null : _onNextPressed,
        ),
      ],
    );
  }
}

class _BudgetListItem extends StatelessWidget {
  const _BudgetListItem({
    required BudgetState budgetState,
  }) : _budgetState = budgetState;

  final BudgetState _budgetState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(_budgetState.name),
            Spacer(),
            Text('${_budgetState.spentAmount} / ${_budgetState.totalAmount}円'),
          ],
        ),
        SizedBox(
          height: 20,
          width: double.infinity,
          child: Container(
            color: Colors.grey,
            child: Transform.scale(
              alignment: Alignment.centerLeft,
              scaleX: min(
                1.0, // avoiding scaleX from being larger than 1.0
                _budgetState.spentAmount / _budgetState.totalAmount,
              ),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
