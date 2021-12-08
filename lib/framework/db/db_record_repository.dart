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
  Record? retrieveById(int id) {
    return id < _repository.length ? _repository[id] : null;
  }
}

class FirestoreRecordRepository implements RecordRepositoryInterface {
  final _tradesRef = FirebaseFirestore.instance.collection('trades').withConverter<Record>(
      fromFirestore: (snapshot, _) => Record.fromJson(snapshot.data()!),
      toFirestore: (record, _) => record.toJson(),
  );

  @override
  bool register(Record record) {
    // TODO: Error handling
    _tradesRef.add(record);

    return true;
  }

  @override
  Record? retrieveById(int id) {
    return null;
  }
}