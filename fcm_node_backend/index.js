const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// ==========================================
// 1. Secure Firebase Admin Initialization
// ==========================================
try {
  // Using Base64 encoded JSON string to avoid multi-line string escaping issues in Render/Vercel
  if (!process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_BASE64 is not set in environment variables.');
  }

  // Decode the base64 string back to JSON
  const serviceAccountBuffer = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64');
  const serviceAccount = JSON.parse(serviceAccountBuffer.toString('utf8'));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized successfully.');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error.message);
}

// ==========================================
// 2. The API Endpoint: POST /send-notification
// ==========================================
app.post('/send-notification', async (req, res) => {
  try {
    const { deviceToken, title, body, data } = req.body;

    // Basic Validation
    if (!deviceToken || !title || !body) {
      return res.status(400).json({ 
        error: 'Missing required fields: deviceToken, title, or body.' 
      });
    }

    // Construct the FCM message payload
    const message = {
      token: deviceToken,
      notification: {
        title: title,
        body: body,
      },
      // Ensure data is string:string pairs if provided
      data: data || {}, 
    };

    // Dispatch the notification
    const response = await admin.messaging().send(message);
    
    return res.status(200).json({ 
      success: true, 
      message: 'Notification sent successfully', 
      messageId: response 
    });
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    return res.status(500).json({ 
      error: 'Failed to send notification', 
      details: error.message 
    });
  }
});

// Basic health check endpoint (useful for Render deployment checks)
app.get('/', (req, res) => {
  res.send('FCM Push Notification Server is running smoothly 🚀');
});

// ==========================================
// 3. Start the Server
// ==========================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
});
