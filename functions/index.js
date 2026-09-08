/**
 * EFC push relay.
 *
 * The admin panel writes to Firestore; these functions watch those collections
 * and send the notification server-side. Browsers cannot send FCM directly —
 * the server key would be readable by anyone who views source.
 *
 * Deploy:  firebase deploy --only functions
 * Requires the Blaze plan.
 */

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const logger = require('firebase-functions/logger');

initializeApp();

const ANDROID_CHANNEL = 'efc_fight_alerts';

async function send({ topic, title, body, deepLink, imageUrl }) {
  const message = {
    topic,
    notification: { title, body, ...(imageUrl ? { imageUrl } : {}) },
    data: {
      deep_link: deepLink || '/',
      // Required so a notification tap routes into the Flutter app.
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: ANDROID_CHANNEL,
        color: '#D8342A',
        sound: 'default',
      },
    },
    apns: {
      payload: { aps: { sound: 'default', badge: 1 } },
    },
  };

  const id = await getMessaging().send(message);
  logger.info('Sent to topic', { topic, title, id });
  return id;
}

/** New article published from the admin panel. */
exports.onArticlePublished = onDocumentCreated('articles/{id}', async (event) => {
  const doc = event.data?.data();
  if (!doc || !doc.push) return;

  await send({
    topic: doc.topic || 'efc_news',
    title: doc.title,
    body: doc.standfirst || 'Tap to read on the EFC app.',
    deepLink: doc.deepLink || `/news/${event.params.id}`,
    imageUrl: doc.heroImageUrl || undefined,
  });
});

/** Result posted during an event. */
exports.onResultPosted = onDocumentCreated('results/{id}', async (event) => {
  const doc = event.data?.data();
  if (!doc || !doc.push) return;

  await send({
    topic: doc.topic || 'efc_live_results',
    title: doc.eventId ? doc.eventId.toUpperCase().replace('-', ' ') : 'EFC',
    body: doc.body || doc.title,
    deepLink: doc.deepLink || '/events',
  });
});

/** Standalone alert — ticket drops, schedule changes, reminders. */
exports.onAlertCreated = onDocumentCreated('alerts/{id}', async (event) => {
  const doc = event.data?.data();
  if (!doc) return;

  await send({
    topic: doc.topic || 'efc_all_events',
    title: doc.title,
    body: doc.body,
    deepLink: doc.deepLink || '/',
  });
});
