import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/uc_repository.dart';

class InMemoryRecordRepository implements RecordRepositoryInterface {
  static final List<Record> _repository = [];

  @override
  bool register(Record record) {
    _repository.add(record);

    print('New record registered!');
    print('Id...${_repository.length - 1}');
    print('Date of input...${record.dateOfInput}');
    print('Date of record...${record.dateOfRecord}');
    print('Amount...${record.amount}');
    print('RecordType...${record.recordType}');
    print('Note...${record.note}');
    print('Category...${record.category}');

    return true;
  }

  @override
  Future<List<Record>> retrieveRecordsOf(DateTime begin, DateTime end) {
    bool Function(Record) withinTheRange = (record) =>
        record.dateOfRecord.compareTo(begin) >= 0 &&
        record.dateOfRecord.compareTo(end) < 0;

    return Future.value(List.of(_repository.where(withinTheRange))..sort());
  }

  @override
  Record? retrieveById(int id) {
    return id < _repository.length ? _repository[id] : null;
  }

  @override
  Future<void> deleteById(String id) async {
    _repository.removeAt(int.parse(id));
  }
}

class FirestoreRecordRepository implements RecordRepositoryInterface {
  final _tradesRef =
      FirebaseFirestore.instance.collection('trades').withConverter<Record>(
    fromFirestore: (snapshot, _) {
      final Map<String, dynamic> json = snapshot.data()!;

      // Add ID for entity.
      json['id'] = snapshot.id;

      // Convert from Firebase type to dart type.
      json['editedAt'] = (json['editedAt'] as Timestamp).toDate();
      json['tradingDate'] = (json['tradingDate'] as Timestamp).toDate();

      return Record.fromJson(json);
    },
    toFirestore: (record, _) {
      final json = record.toJson();

      // id property isn't needed in Firestore.
      json.remove('id');

      // Convert from dart type to Firebase type.
      json['editedAt'] = Timestamp.fromDate(json['editedAt'] as DateTime);
      json['tradingDate'] = Timestamp.fromDate(json['tradingDate'] as DateTime);

      return json;
    },
  );

  @override
  bool register(Record record) {
    // TODO: Error handling
    _tradesRef.add(record);

    return true;
  }

  @override
  Future<List<Record>> retrieveRecordsOf(DateTime begin, DateTime end) async {
    assert(
      begin.isBefore(end),
      '$begin is after or at the same moment as $end',
    );

    return _tradesRef
        .where('tradingDate', isGreaterThanOrEqualTo: begin)
        .where('tradingDate', isLessThan: end)
        .orderBy('tradingDate')
        .get()
        .then((snapshot) => snapshot.docs)
        .then((records) => List.of(records.map((e) => e.data())));
  }

  @override
  Record? retrieveById(int id) {
    return null;
  }

  @override
  Future<void> deleteById(String id) => _tradesRef
      .doc(id)
      .delete()
      .then((_) => print('$id has been deleted.'))
      .onError((error, stackTrace) => print(error));
}
