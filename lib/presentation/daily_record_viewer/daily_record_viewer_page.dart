import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../entity/record_entity.dart';
import '../../feature/category_retrieve/retrieve_categories_use_case.dart';
import '../../feature/record_deletion/delete_record_use_case.dart';
import '../../feature/record_retrieve/retrieve_daily_records_use_case.dart';
import '../../util/service_locator/main.dart';
import 'daily_record_viewer_state.dart';

class DailyRecordMinute extends StatelessWidget {
  const DailyRecordMinute({
    required int year,
    required int month,
    required int day,
    Key? key,
  })  : _year = year,
        _month = month,
        _day = day,
        super(key: key);

  final int _year;
  final int _month;
  final int _day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$_year/$_month/$_day'),
        ),
        body: ChangeNotifierProvider(
          create: (ctx) => DailyRecordModel(
            sl<RetrieveDailyRecordsUseCase>(),
            sl<DeleteRecordUseCaseNew>(),
            sl<RetrieveIncomeCategoriesUseCase>(),
            sl<RetrieveExpenseCategoriesUseCase>(),
          )
            ..loadRecords(_year, _month, _day)
            ..loadCategories(),
          child: _MinuteList(),
        ));
  }
}

class _MinuteList extends StatelessWidget {
  const _MinuteList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DailyRecordModel>();

    if (model.isLoading) {
      return const Text('loading');
    }

    final forEachAction =
        (List<Widget> children, Record record) => children.add(
              _MinuteItem(
                record: record,
                categoryName: model.categoryNameOf(record),
              ),
            );

    final minutes = <Widget>[];
    if (model.incomes.isNotEmpty) {
      minutes.add(const Text('INCOMES'));
      model.incomes.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    if (model.expenses.isNotEmpty) {
      minutes.add(const Text('EXPENSES'));
      model.expenses.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    if (model.transfer.isNotEmpty) {
      minutes.add(const Text('TRANSFER'));
      model.transfer.forEach(
        (element) => forEachAction(minutes, element),
      );
    }
    return minutes.isEmpty
        ? Center(child: Text('No record'))
        : Column(children: minutes);
  }
}

class _MinuteItem extends StatelessWidget {
  final Record _record;
  final String _categoryName;

  const _MinuteItem({
    Key? key,
    required Record record,
    required String categoryName,
  })  : _record = record,
        _categoryName = categoryName,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('${_record.note}@$_categoryName'),
        ),
        Text('${_record.amount} yen'),
        OutlinedButton(
          onPressed: () => context.read<DailyRecordModel>().deleteById(
                _record.id,
                _record.type,
              ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
