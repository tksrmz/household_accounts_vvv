// The Cloud Functions for Firebase SDK
// to create Cloud Functions and set up triggers.
import * as functions from "firebase-functions/v1";

// The Firebase Admin SDK to access Firestore.
import * as admin from "firebase-admin";
admin.initializeApp();

// constants
// Database instance
const db = admin.firestore();
// collection names
const PERSONAL_NOTES = "personalNotes";
// const SHARED_NOTES = "sharedNotes";
// const INCOMES = "incomes";
// const EXPENSES = "expenses";
// const TRANSFERS = "transfers";
// const MONTHLY_SUMMARY = "monthlySummary";
// const INCOME_CATEGORIES = "incomeCategories";
// const EXPENSE_CATEGORIES = "expenseCategories";

// type definitions
// type RecordType = "income" | "expense" | "transfer";

// =============================================================================
// =============================================================================
// Initialization of user's documents when signing up
// =============================================================================
// =============================================================================

/**
 * Create public profile document and personal note document
 * when a user is created.
 */
// onCreateUserに対応するイベントがcloud-functions/v2に見つからなかったのでv1を使う
export const onCreateUser = functions
  .region("asia-northeast2")
  .auth.user().onCreate(async (user) => {
    functions.logger.info(`User ID is ${user.uid}`);

    const batch = db.batch();

    // Create user's public profile.
    batch.create(db.collection("publicProfiles").doc(user.uid), {
      name: user.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Create a user's personal note.
    batch.create(db.collection(PERSONAL_NOTES).doc(user.uid), {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // We won't initialize subcollections that
    // are under the user's personal note,
    // as names of initial categories and properties
    // should be different based on the user's locale.
    // It's on the app side, not on the server side, that considering locales.

    // Create a user's private profile.
    batch.create(db.collection("privateProfiles").doc(user.uid), {
      sharedNote: null,
    });

    await batch.commit();
  });


// =============================================================================
// =============================================================================
// Property document update on writing record documents
// =============================================================================
// =============================================================================

// type PropRefPathAndDeltaAmount = {
//   propRefPath: string | admin.firestore.FieldPath,
//   deltaAmount: number,
// };
//
// /**
//  * Update property document(s) on create record.
//  * @param {functions.firestore.QueryDocumentSnapshot} change change
//  * @param {functions.EventContext} context context
//  * @param {Array} targets path to property ref and amount
//  */
// async function updatePropertyOnCreateRecord(
//     change: functions.firestore.QueryDocumentSnapshot,
//     context: functions.EventContext,
//     targets: Array<PropRefPathAndDeltaAmount>
// ): Promise<void> {
//   const uidAndRecordId = {
//     uid: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecordId,
//     ...{
//       data: change.data(),
//     },
//   });
//
//   // Use batch as multiple (not single) property documents may be updated.
//   const batch = db.batch();
//   targets.forEach((element) => {
//     batch.update(
//         change.get(element.propRefPath),
//         "amount",
//         admin.firestore.FieldValue.increment(element.deltaAmount)
//     );
//   });
//   await batch.commit();
// }
//
// /**
//  * Update property document(s) on update record.
//  * @param {functions.Change} change change
//  * @param {functions.EventContext} context context
//  * @param {Function} test if this returns true, update the property document
//  * @param {Array} targets path to property ref and amount
//  */
// async function updatePropertyOnUpdateRecord(
//     change: functions.Change<functions.firestore.QueryDocumentSnapshot>,
//     context: functions.EventContext,
//     test: (
//         before: functions.firestore.QueryDocumentSnapshot,
//         after: functions.firestore.QueryDocumentSnapshot
//     ) => boolean,
//     targets: Array<{
//       before: PropRefPathAndDeltaAmount,
//       after: PropRefPathAndDeltaAmount,
//     }>
// ): Promise<void> {
//   const uidAndRecordId = {
//     uid: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecordId,
//     ...{
//       before: change.before.data(),
//       after: change.after.data(),
//     },
//   });
//
//   if (!test(change.before, change.after)) {
//     functions.logger.info(
//         "Test failed. Property document will not be updated.",
//         uidAndRecordId
//     );
//     return;
//   }
//
//   functions.logger.info(
//       "Test passed. Update property document(s)",
//       uidAndRecordId
//   );
//   // When the referenced property doesn't change,
//   // this code requires twice as much write operations as
//   // code shown below.
//   //
//   // ```
//   // if (beforeDocument.property.ref == afterDocument.property.ref) {
//   //   // Write to beforeDocument.property.ref only onece.
//   // } else {
//   //   // Write to beforeDocument.property.ref once
//   //   // and afterDocument.property.ref once. (twice total)
//   // }
//   // ```
//   const batch = db.batch();
//   targets.forEach((element) => {
//     batch.update(
//         change.before.get(element.before.propRefPath),
//         "amount",
//         admin.firestore.FieldValue.increment(element.before.deltaAmount)
//     );
//     batch.update(
//         change.after.get(element.after.propRefPath),
//         "amount",
//         admin.firestore.FieldValue.increment(element.after.deltaAmount)
//     );
//   });
//   await batch.commit();
// }
//
// /**
//  * Update property document(s) on delete record.
//  * @param {functions.firestore.QueryDocumentSnapshot} change change
//  * @param {functions.EventContext} context context
//  * @param {Array} targets path to property ref and amount
//  */
// async function updatePropertyOnDeleteRecord(
//     change: functions.firestore.QueryDocumentSnapshot,
//     context: functions.EventContext,
//     targets: Array<PropRefPathAndDeltaAmount>
// ) {
//   const uidAndRecordId = {
//     uid: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecordId,
//     ...{
//       data: change.data(),
//     },
//   });
//
//   // Use batch as multiple (not single) property documents may be updated.
//   const batch = db.batch();
//   targets.forEach((element) => {
//     batch.update(
//         change.get(element.propRefPath),
//         "amount",
//         admin.firestore.FieldValue.increment(element.deltaAmount)
//     );
//   });
//   await batch.commit();
// }
//
// /**
//  * Update the amount of the referenced property
//  * when a income record is created.
//  */
// export const updatePersonalPropertyOnCreateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a income record is updated.
//  */
// export const updatePersonalPropertyOnUpdateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const propertyRef = "property.ref";
//           const beforeId: string = before.get(propertyRef).id;
//           const afterId: string = after.get(propertyRef).id;
//           const beforeAmount: number = before.get("amount");
//           const afterAmount: number = after.get("amount");
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeId: beforeId,
//                 beforeAmount: beforeAmount,
//                 afterId: afterId,
//                 afterAmount: afterAmount,
//               }
//           );
//           return beforeId !== afterId || beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "property.ref",
//               deltaAmount: -1 * change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "property.ref",
//               deltaAmount: change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a income record is deleted.
//  */
// export const updatePersonalPropertyOnDeleteIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a expense record is created.
//  */
// export const updatePersonalPropertyOnCreateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a expense record is updated.
//  */
// export const updatePersonalPropertyOnUpdateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const propertyRef = "property.ref";
//           const beforeId: string = before.get(propertyRef).id;
//           const afterId: string = after.get(propertyRef).id;
//           const beforeAmount: number = before.get("amount");
//           const afterAmount: number = after.get("amount");
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeId: beforeId,
//                 beforeAmount: beforeAmount,
//                 afterId: afterId,
//                 afterAmount: afterAmount,
//               }
//           );
//           return beforeId !== afterId || beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "property.ref",
//               deltaAmount: change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "property.ref",
//               deltaAmount: -1 * change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a expense record is deleted.
//  */
// export const updatePersonalPropertyOnDeleteExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
//
// /**
//  * Update the amount of the referenced property
//  * when a transfer record is created.
//  */
// export const updatePersonalPropertyOnCreateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "fromProperty.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//           {
//             propRefPath: "toProperty.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a transfer record is updated.
//  */
// export const updatePersonalPropertyOnUpdateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const fromPropRef = "fromProperty.ref";
//           const toPropRef = "toProperty.ref";
//
//           const beforeFromId: string = before.get(fromPropRef).id;
//           const beforeToId: string = before.get(toPropRef).id;
//           const beforeAmount: number = before.get("amount");
//
//           const afterFromId: string = after.get(fromPropRef).id;
//           const afterToId: string = after.get(toPropRef).id;
//           const afterAmount: number = after.get("amount");
//
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeFromId: beforeFromId,
//                 beforeToId: beforeToId,
//                 beforeAmount: beforeAmount,
//                 afterFromId: afterFromId,
//                 afterToId: afterToId,
//                 afterAmount: afterAmount,
//               }
//           );
//
//           return beforeFromId !== afterFromId ||
//           beforeToId !== afterToId ||
//           beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "fromProperty.ref",
//               deltaAmount: change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "fromProperty.ref",
//               deltaAmount: -1 * change.after.get("amount"),
//             },
//           },
//           {
//             before: {
//               propRefPath: "toProperty.ref",
//               deltaAmount: -1 * change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "toProperty.ref",
//               deltaAmount: change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
//  * Update the amount of the referenced property
//  * when a transfer record is deleted.
//  */
// export const updatePersonalPropertyOnDeleteTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "fromProperty.ref",
//             deltaAmount: change.get("amount"),
//           },
//           {
//             propRefPath: "toProperty.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
//
// /**
//  * Update the amount of the referenced property
//  * when a income record is created.
//  */
// export const updateSharedPropertyOnCreateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a income record is updated.
// */
// export const updateSharedPropertyOnUpdateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const propertyRef = "property.ref";
//           const beforeId: string = before.get(propertyRef).id;
//           const afterId: string = after.get(propertyRef).id;
//           const beforeAmount: number = before.get("amount");
//           const afterAmount: number = after.get("amount");
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeId: beforeId,
//                 beforeAmount: beforeAmount,
//                 afterId: afterId,
//                 afterAmount: afterAmount,
//               }
//           );
//           return beforeId !== afterId || beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "property.ref",
//               deltaAmount: -1 * change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "property.ref",
//               deltaAmount: change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a income record is deleted.
// */
// export const updateSharedPropertyOnDeleteIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a expense record is created.
// */
// export const updateSharedPropertyOnCreateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a expense record is updated.
// */
// export const updateSharedPropertyOnUpdateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const propertyRef = "property.ref";
//           const beforeId: string = before.get(propertyRef).id;
//           const afterId: string = after.get(propertyRef).id;
//           const beforeAmount: number = before.get("amount");
//           const afterAmount: number = after.get("amount");
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeId: beforeId,
//                 beforeAmount: beforeAmount,
//                 afterId: afterId,
//                 afterAmount: afterAmount,
//               }
//           );
//           return beforeId !== afterId || beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "property.ref",
//               deltaAmount: change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "property.ref",
//               deltaAmount: -1 * change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a expense record is deleted.
// */
// export const updateSharedPropertyOnDeleteExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "property.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
//
// /**
// * Update the amount of the referenced property
// * when a transfer record is created.
// */
// export const updateSharedPropertyOnCreateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onCreate(async (change, context) => await updatePropertyOnCreateRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "fromProperty.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//           {
//             propRefPath: "toProperty.ref",
//             deltaAmount: change.get("amount"),
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a transfer record is updated.
// */
// export const updateSharedPropertyOnUpdateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onUpdate(async (change, context) => await updatePropertyOnUpdateRecord(
//         change,
//         context,
//         (before, after) => {
//           const fromPropRef = "fromProperty.ref";
//           const toPropRef = "toProperty.ref";
//
//           const beforeFromId: string = before.get(fromPropRef).id;
//           const beforeToId: string = before.get(toPropRef).id;
//           const beforeAmount: number = before.get("amount");
//
//           const afterFromId: string = after.get(fromPropRef).id;
//           const afterToId: string = after.get(toPropRef).id;
//           const afterAmount: number = after.get("amount");
//
//           functions.logger.info(
//               "Property IDs referred to and amounts.",
//               {
//                 beforeFromId: beforeFromId,
//                 beforeToId: beforeToId,
//                 beforeAmount: beforeAmount,
//                 afterFromId: afterFromId,
//                 afterToId: afterToId,
//                 afterAmount: afterAmount,
//               }
//           );
//
//           return beforeFromId !== afterFromId ||
//        beforeToId !== afterToId ||
//        beforeAmount !== afterAmount;
//         },
//         [
//           {
//             before: {
//               propRefPath: "fromProperty.ref",
//               deltaAmount: change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "fromProperty.ref",
//               deltaAmount: -1 * change.after.get("amount"),
//             },
//           },
//           {
//             before: {
//               propRefPath: "toProperty.ref",
//               deltaAmount: -1 * change.before.get("amount"),
//             },
//             after: {
//               propRefPath: "toProperty.ref",
//               deltaAmount: change.after.get("amount"),
//             },
//           },
//         ]
//     ));
//
// /**
// * Update the amount of the referenced property
// * when a transfer record is deleted.
// */
// export const updateSharedPropertyOnDeleteTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onDelete(async (change, context) => await updatePropertyOnDeleteRecord(
//         change,
//         context,
//         [
//           {
//             propRefPath: "fromProperty.ref",
//             deltaAmount: change.get("amount"),
//           },
//           {
//             propRefPath: "toProperty.ref",
//             deltaAmount: -1 * change.get("amount"),
//           },
//         ]
//     ));
//
// // ==========================================================================
// // ==========================================================================
// // Monthly summary document update on writing record documents
// // ==========================================================================
// // ==========================================================================
//
// type MonthlySummaryInitialData = {
//   day: number;
//   type: RecordType;
//   amount: number;
// };
//
// type monthlySummaryContent = {
//   year: number;
//   month: number;
//   summary: object;
// };
//
// /**
//  * Create monthly summary document contents.
//  * @param {number} year
//  * @param {number} month
//  * @param {MonthlySummaryInitialData} initialData
//  * @return {monthlySummaryContent}
//  */
// function createMonthlySummaryContent(
//     year: number,
//     month: number,
//     initialData: MonthlySummaryInitialData
// ): monthlySummaryContent {
//   // Calculate number of days
//   let days: number;
//   switch (month) {
//     case 1:
//     case 3:
//     case 5:
//     case 7:
//     case 8:
//     case 10:
//     case 12:
//       days = 31;
//       break;
//
//     case 4:
//     case 6:
//     case 9:
//     case 11:
//       days = 30;
//       break;
//
//     case 2:
//       if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) {
//         days = 29;
//       } else {
//         days = 28;
//       }
//       break;
//
//     default:
//       throw new Error(`Invalid 'month' parameter(${month}).`);
//   }
//
//   let summary = {};
//   for (let i = 1; i <= days; i++) {
//     const setData = {
//       ["d" + i]: {
//         income: 0,
//         expense: 0,
//         transfer: 0,
//       },
//     };
//
//     if (i == initialData.day) {
//       setData["d" + i][initialData.type] = initialData.amount;
//     }
//
//     summary = Object.assign(summary, setData);
//   }
//
//   return {
//     year: year,
//     month: month,
//     summary: summary,
//   };
// }
//
// /**
//  * Update a monthly summary document on creation of records.
//  * If a document to be updated doesn't exist,
//  * create one instead of updating.
//  * @param {admin.firestore.QueryDocumentSnapshot} change
//  * @param {functions.EventContext} context
//  * @return {Promise<void>}
//  */
// async function writeMonthlySummaryOnCreateRecord(
//     change: admin.firestore.QueryDocumentSnapshot,
//     context: functions.EventContext
// ): Promise<void> {
//   const uidAndRecodId = {
//     id: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecodId,
//     ...{
//       data: change.data(),
//     },
//   });
//
//   const summaryCollectionRef = db
//       .collection(
//         `${PERSONAL_NOTES}/${context.params.uid}/${MONTHLY_SUMMARY}`);
//
//   const date: Date = (change.get("date") as admin.firestore.Timestamp)
//                      .toDate();
//   const year = date.getFullYear();
//   const month = date.getMonth() + 1;
//   const query = summaryCollectionRef
//       .where("year", "==", year)
//       .where("month", "==", month)
//       .limit(1);
//
//   await db.runTransaction(async (transaction) => {
//     const type: RecordType = change.get("type");
//     const day = date.getDate();
//     const amount: number = change.get("amount");
//
//     const snapshot = await transaction.get(query);
//     if (snapshot.empty) {
//       functions.logger.info(
//         "Create monthly summary document.",
//         uidAndRecodId);
//
//       transaction.create(
//           summaryCollectionRef.doc(),
//           createMonthlySummaryContent(year, month, {
//             day: day,
//             type: type,
//             amount: amount,
//           })
//       );
//       return;
//     }
//
//     functions.logger.info("Update monthly summary document", {
//       ...uidAndRecodId,
//       ...{
//         docId: snapshot.docs[0].id,
//       },
//     });
//     transaction.update(
//         snapshot.docs[0].ref,
//         new admin.firestore.FieldPath("summary", "d" + day, type),
//         admin.firestore.FieldValue.increment(amount)
//     );
//   });
// }
//
// /**
//  * Update the monthly summary on update of records.
//  * @param {functions.Change} change
//  * @param {functions.EventContext} context
//  * @return {Promise<void>}
//  */
// async function writeMonthlySummaryOnUpdateRecord(
//     change: functions.Change<functions.firestore.QueryDocumentSnapshot>,
//     context: functions.EventContext
// ): Promise<void> {
//   const uidAndRecodId = {
//     id: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecodId,
//     ...{
//       beforeData: change.before.data(),
//       afterData: change.after.data(),
//     },
//   });
//
//   const beforeDate: Date =
//     (change.before.get("date") as admin.firestore.Timestamp).toDate();
//   const beforeYear = beforeDate.getFullYear();
//   const beforeMonth = beforeDate.getMonth() + 1;
//   const beforeDay = beforeDate.getDate();
//   const beforeAmount: number = change.before.get("amount");
//
//   const afterDate: Date =
//     (change.after.get("date") as admin.firestore.Timestamp).toDate();
//   const afterYear = afterDate.getFullYear();
//   const afterMonth = afterDate.getMonth() + 1;
//   const afterDay = afterDate.getDate();
//   const afterAmount: number = change.after.get("amount");
//
//   if (beforeYear === afterYear &&
//     beforeMonth === afterMonth &&
//     beforeDay === afterDay &&
//     beforeAmount === afterAmount) {
//     functions.logger.info(
//         "Update of monthly summary is not required.",
//         uidAndRecodId
//     );
//     return;
//   }
//
//   functions.logger.info("Update monthly summary.", uidAndRecodId);
//   const summaryCollectionRef =
//     db.collection(
//       `${PERSONAL_NOTES}/${context.params.uid}/${MONTHLY_SUMMARY}`);
//   const beforeQuery = summaryCollectionRef
//       .where("year", "==", beforeYear)
//       .where("month", "==", beforeMonth)
//       .limit(1);
//   const afterQuery = summaryCollectionRef
//       .where("year", "==", afterYear)
//       .where("month", "==", afterMonth)
//       .limit(1);
//
//   await db.runTransaction(async (transaction) => {
//     // type (one of 'income', 'expense' or 'transfer') can't be changed
//     // as the security rules validate it.
//     const type: RecordType = change.before.get("type");
//
//     const beforeSnapshot = await transaction.get(beforeQuery);
//     const afterSnapshot = await transaction.get(afterQuery);
//
//     // Monthly summary document for beforeSnapshot should exist.
//     functions.logger.info("Update the old document.", {
//       ...uidAndRecodId,
//       ...{
//         oldDocumentId: beforeSnapshot.docs[0].id,
//       },
//     });
//     transaction.update(
//         beforeSnapshot.docs[0].ref,
//         new admin.firestore.FieldPath("summary", "d" + beforeDay, type),
//         admin.firestore.FieldValue.increment(-1 * beforeAmount)
//     );
//
//     if (afterSnapshot.empty) {
//       functions.logger.info(
//         "Create monthly summary document.",
//         uidAndRecodId);
//       transaction.create(
//           summaryCollectionRef.doc(),
//           createMonthlySummaryContent(afterYear, afterMonth, {
//             day: afterDay,
//             type: type,
//             amount: afterAmount,
//           })
//       );
//       return;
//     }
//
//     functions.logger.info("Update monthly summary document", {
//       ...uidAndRecodId,
//       ...{
//         docId: afterSnapshot.docs[0].id,
//       },
//     });
//     transaction.update(
//         afterSnapshot.docs[0].ref,
//         new admin.firestore.FieldPath("summary", "d" + afterDay, type),
//         admin.firestore.FieldValue.increment(afterAmount)
//     );
//   });
// }
//
// /**
//  * Update the monthly summary on deletion of records.
//  * @param {functions.firestore.QueryDocumentSnapshot} change
//  * @param {functions.EventContext} context
//  * @return {Promise<void>}
//  */
// async function writeMonthlySummaryOnDeleteRecord(
//     change: functions.firestore.QueryDocumentSnapshot,
//     context: functions.EventContext
// ): Promise<void> {
//   const uidAndRecodId = {
//     id: context.params.uid,
//     recordId: context.params.recordId,
//   };
//   functions.logger.info("Arguments information", {
//     ...uidAndRecodId,
//     ...{
//       data: change.data(),
//     },
//   });
//
//   const date: Date =
//     (change.get("date") as admin.firestore.Timestamp).toDate();
//   const year = date.getFullYear();
//   const month = date.getMonth() + 1;
//
//   const summaryCollectionRef =
//     db.collection(
//       `${PERSONAL_NOTES}/${context.params.uid}/${MONTHLY_SUMMARY}`);
//   const query = summaryCollectionRef
//       .where("year", "==", year)
//       .where("month", "==", month)
//       .limit(1);
//
//   await db.runTransaction(async (transaction) => {
//     const snapshot = await transaction.get(query);
//
//     // Monthly summary document should exist.
//     functions.logger.info("Update monthly summary document", {
//       ...uidAndRecodId,
//       ...{
//         docId: snapshot.docs[0].id,
//       },
//     });
//     const day = date.getDate();
//     const type: RecordType = change.get("type");
//     const amount: number = change.get("amount");
//     transaction.update(
//         snapshot.docs[0].ref,
//         new admin.firestore.FieldPath("summary", "d" + day, type),
//         admin.firestore.FieldValue.increment(-1 * amount)
//     );
//   });
// }
//
// /**
//  * On creation of income records,
//  * if corresponding monthly summary does not exist, create it .
//  * Otherwise, update the monthly summary.
//  */
// export const writePersonalMonthlySummaryOnCreateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
//  * Update the monthly summary on update of income records.
//  */
// export const writePersonalMonthlySummaryOnUpdateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
//  * Update the monthly summary on deletion of income records.
//  */
// export const writePersonalMonthlySummaryOnDeleteIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
//
// /**
//  * On creation of expense records,
//  * if corresponding monthly summary does not exist, create it .
//  * Otherwise, update the monthly summary.
//  */
// export const writePersonalMonthlySummaryOnCreateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
//  * Update the monthly summary on update of expense records.
//  */
// export const writePersonalMonthlySummaryOnUpdateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
//  * Update the monthly summary on deletion of expense records.
//  */
// export const writePersonalMonthlySummaryOnDeleteExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
//
// /**
//  * On creation of transfer records,
//  * if corresponding monthly summary does not exist, create it .
//  * Otherwise, update the monthly summary.
//  */
// export const writePersonalMonthlySummaryOnCreateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
//  * Update the monthly summary on update of transfer records.
//  */
// export const writePersonalMonthlySummaryOnUpdateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
//  * Update the monthly summary on deletion of transfer records.
//  */
// export const writePersonalMonthlySummaryOnDeleteTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${PERSONAL_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
//
// /**
//  * On creation of income records,
//  * if corresponding monthly summary does not exist, create it .
//  * Otherwise, update the monthly summary.
//  */
// export const writeSharedMonthlySummaryOnCreateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
// * Update the monthly summary on update of income records.
// */
// export const writeSharedMonthlySummaryOnUpdateIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
// * Update the monthly summary on deletion of income records.
// */
// export const writeSharedMonthlySummaryOnDeleteIncomeRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${INCOMES}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
//
// /**
// * On creation of expense records,
// * if corresponding monthly summary does not exist, create it .
// * Otherwise, update the monthly summary.
// */
// export const writeSharedMonthlySummaryOnCreateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
// * Update the monthly summary on update of expense records.
// */
// export const writeSharedMonthlySummaryOnUpdateExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
// * Update the monthly summary on deletion of expense records.
// */
// export const writeSharedMonthlySummaryOnDeleteExpenseRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${EXPENSES}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
//
// /**
// * On creation of transfer records,
// * if corresponding monthly summary does not exist, create it .
// * Otherwise, update the monthly summary.
// */
// export const writeSharedMonthlySummaryOnCreateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onCreate(async (change, context) =>
//       await writeMonthlySummaryOnCreateRecord(change, context));
//
// /**
// * Update the monthly summary on update of transfer records.
// */
// export const writeSharedMonthlySummaryOnUpdateTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onUpdate(async (change, context) =>
//       await writeMonthlySummaryOnUpdateRecord(change, context));
//
// /**
// * Update the monthly summary on deletion of transfer records.
// */
// export const writeSharedMonthlySummaryOnDeleteTransferRecord = functions
//     .region("asia-northeast2")
//     .firestore
//     .document(`${SHARED_NOTES}/{uid}/${TRANSFERS}/{recordId}`)
//     .onDelete(async (change, context) =>
//       await writeMonthlySummaryOnDeleteRecord(change, context));
