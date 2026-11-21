// The Cloud Functions for Firebase SDK
// to create Cloud Functions and set up triggers.
import * as functions from "firebase-functions/v1";

// The Firebase Admin SDK to access Firestore.
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

initializeApp();

// =============================================================================
// =============================================================================
// Initialization of user's documents when signing up
// =============================================================================
// =============================================================================
/**
 * Create public profile document and personal note document
 * when a user is created.
 */
// 2nd genの相当トリガー(firebase-functions/v2/identityのonUserCreated)は公式にはまだPreviewなので、
// 1st genのv1を使う。このためランタイムは1st genで選べるNode.js 22に留めている。
// 背景と見直しの期限は docs/adr/001-firebase-functions-node22.md を参照

export const onCreateUser = functions
  .region("asia-northeast2")
  .auth.user().onCreate(async (user) => {
    functions.logger.info(`User ID is ${user.uid}`);

    // Database instance
    const db = getFirestore();

    const batch = db.batch();

    // Create user's public profile.
    batch.create(db.collection("publicProfiles").doc(user.uid), {
      name: user.uid.slice(0, 5),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    // Create a user's personal note.
    batch.create(db.collection("personalNotes").doc(user.uid), {
      createdAt: FieldValue.serverTimestamp(),
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
