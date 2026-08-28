const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

exports.onBookingCreated = functions.firestore
    .document('bookings/{bookingId}')
    .onCreate(async (snapshot, context) => {
        const newBooking = snapshot.data();
        const bookingId = context.params.bookingId;

        console.log('New booking created:', bookingId, newBooking);

        // Example logic to send a notification to the guide
        const guideId = newBooking.guideId;

        try {
            const guideSnapshot = await admin.firestore().collection('guides').doc(guideId).get();

            if (!guideSnapshot.exists) {
                console.log(`Guide with ID ${guideId} not found.`);
                return null;  // Early exit if guide doesn't exist
            }

            const guideData = guideSnapshot.data();
            const guideToken = guideData.fcmToken;  // Assuming the guide's FCM token is stored

            if (!guideToken) {
                console.log(`No FCM token found for guide with ID ${guideId}.`);
                return null;  // Early exit if FCM token is missing
            }

            const payload = {
                notification: {
                    title: 'New Booking!',
                    body: `You have a new booking for ${newBooking.date} ` +
                        `with ${newBooking.clientName}.`  // Example of line continuation
                }
            };


            // Send the notification to the guide
            const response = await admin.messaging().sendToDevice(guideToken, payload);
            console.log('Notification sent successfully:', response);

            return null;  // Successfully sent notification

        } catch (error) {
            console.error('Error sending notification:', error);
            throw new Error('Notification send failed');
        }
    });
