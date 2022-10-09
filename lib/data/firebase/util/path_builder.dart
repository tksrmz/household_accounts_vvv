import '../../../util/constant/firebase_constant.dart';

/// Get path of personal property collection.
String getPersonalPropertyCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_PROPERTIES';

/// Get path of shared property collection.
String getSharedPropertyCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_PROPERTIES';

/// Get path of personal income category collection.
String getPersonalIncomeCategoryCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOME_CATEGORIES';

/// Get path of shared income category collection.
String getSharedIncomeCategoryCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_INCOME_CATEGORIES';

/// Get path of personal expense category collection.
String getPersonalExpenseCategoryCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES';

/// Get path of shared expense category collection.
String getSharedExpenseCategoryCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSE_CATEGORIES';

/// Get path of personal income record collection.
String getPersonalIncomeRecordCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_INCOMES';

/// Get path of shared income record collection.
String getSharedIncomeRecordCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_INCOMES';

/// Get path of personal expense record collection.
String getPersonalExpenseRecordCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_EXPENSES';

/// Get path of shared expense record collection.
String getSharedExpenseRecordCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_EXPENSES';

/// Get path of personal transfer record collection.
String getPersonalTransferRecordCollectionPath(String uid) =>
    '/$FIREBASE_COLLECTION_PERSONAL_NOTES/$uid/$FIREBASE_COLLECTION_TRANSFERS';

/// Get path of shared transfer record collection.
String getSharedTransferRecordCollectionPath(String pairId) =>
    '/$FIREBASE_COLLECTION_SHARED_NOTES/$pairId/$FIREBASE_COLLECTION_TRANSFERS';
