// Initialize Firebase Functions Test SDK
import tests from "firebase-functions-test";
const test = tests({
  databaseURL: "https://household-accounts-dev-15106.firebaseio.com",
  storageBucket: "household-accounts-dev-15106.firebasestorage.app",
  projectId: "household-accounts-dev-15106",
}, process.env.HOUSEHOLD_ACCOUNTS_DEV_SERVICE_ACCOUNT_KEY);

import * as admin from "firebase-admin/firestore";
import * as myFunctions from "../src/index";
import {
  afterAll,
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
} from "vitest";

describe("Cloud Functions", () => {
  afterAll(() => {
    test.cleanup();
  });

  describe("onCreateUser", () => {
    const testUid = "testUserId";
    const collections = [
      "publicProfiles",
      "personalNotes",
      "privateProfiles",
    ];
    const deleteTestDocuments = async () => {
      await Promise.all(collections.map((collection) =>
        admin.getFirestore()
          .doc(`${collection}/${testUid}`)
          .delete()
      ));
    };

    beforeEach(deleteTestDocuments);
    afterEach(deleteTestDocuments);

    it("should create publicProfiles, personalNotes, and privateProfiles documents",
      async () => {
        // [Arrange]
        // Wrap the function
        const wrapped = test.wrap(myFunctions.onCreateUser);
        // Create data passed to the function
        const user = test.auth.makeUserRecord({
          uid: testUid,
        });

        // [Act]
        // `await wrapped(user)` does not work so using `then` instead.
        return wrapped(user).then(() => {
          // [Assert]
          // Check if the documents were created
          return Promise.all(
            [
              // /publicProfiles/testUserId exists with the correct data
              {
                documentPath: `publicProfiles/${testUid}`,
                expectedData: {
                  name: "testU",
                  createdAt: expect.any(admin.Timestamp),
                  updatedAt: expect.any(admin.Timestamp),
                },
              },
              // /personalNotes/testUserId exists with the correct data
              {
                documentPath: `personalNotes/${testUid}`,
                expectedData: {
                  createdAt: expect.any(admin.Timestamp),
                },
              },
              // /privateProfiles/testUserId exists with the correct data
              {
                documentPath: `privateProfiles/${testUid}`,
                expectedData: {
                  sharedNote: null,
                },
              },
            ].map(async ({ documentPath, expectedData }) => {
              const doc = await admin.getFirestore().doc(documentPath).get();
              expect(doc.data()).toEqual(expectedData);
            })
          );
        });
      });
  });
});
