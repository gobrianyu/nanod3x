/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");
const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

admin.initializeApp();

const corsHandler = cors({ origin: 'https://nanod3x.web.app' }); // Only allow requests from this domain

// Firebase Function to get a signed URL for image access
exports.getImage = functions.https.onRequest((req, res) => {
  corsHandler(req, res, () => {
    const filePath = req.query.filePath;

    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);

    file
      .getSignedUrl({
        action: 'read', 
        expires: '03-01-2500',  // Set expiration date for the signed URL
      })
      .then((signedUrls) => {
        const url = signedUrls[0];
        res.redirect(url);  // Redirect to the signed URL for the image
      })
      .catch((error) => {
        res.status(500).send("Error generating URL: " + error);
      });
  });
});