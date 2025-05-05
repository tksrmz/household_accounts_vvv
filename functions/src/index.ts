// The Cloud Functions for Firebase SDK
// to create Cloud Functions and set up triggers.
import * as functions from "firebase-functions/v1";

// The Firebase Admin SDK to access Firestore.
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

admin.initializeApp();

// constants
// Database instance
const db = admin.firestore();

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
