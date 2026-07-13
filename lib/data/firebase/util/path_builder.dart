import '../../../util/constant/firebase_constant.dart';

/// Get path of personal property collection.
String getPersonalPropertyCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionProperties';

/// Get path of shared property collection.
String getSharedPropertyCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionProperties';

/// Get path of personal income category collection.
String getPersonalIncomeCategoryCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionIncomeCategories';

/// Get path of shared income category collection.
String getSharedIncomeCategoryCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionIncomeCategories';

/// Get path of personal expense category collection.
String getPersonalExpenseCategoryCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionExpenseCategories';

/// Get path of shared expense category collection.
String getSharedExpenseCategoryCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionExpenseCategories';

/// Get path of personal income record collection.
String getPersonalIncomeRecordCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionIncomes';

/// Get path of shared income record collection.
String getSharedIncomeRecordCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionIncomes';

/// Get path of personal expense record collection.
String getPersonalExpenseRecordCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionExpenses';

/// Get path of shared expense record collection.
String getSharedExpenseRecordCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionExpenses';

/// Get path of personal transfer record collection.
String getPersonalTransferRecordCollectionPath(String uid) =>
    '/$firebaseCollectionPersonalNotes/$uid/$firebaseCollectionTransfers';

/// Get path of shared transfer record collection.
String getSharedTransferRecordCollectionPath(String pairId) =>
    '/$firebaseCollectionSharedNotes/$pairId/$firebaseCollectionTransfers';
