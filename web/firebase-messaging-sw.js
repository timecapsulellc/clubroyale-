// Firebase Cloud Messaging Service Worker for ClubRoyale
// This file enables web push notifications
//
// IMPORTANT: Fill in your Firebase config values from the Firebase Console
// Go to: Firebase Console > Project Settings > General > Your apps > Web app
// These values are PUBLIC and safe to include in this file

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize Firebase
firebase.initializeApp({
    apiKey: "AIzaSyAkttmP2AuhEJob4PZ44SKnygEuC-VTNaY",
    authDomain: "clubroyale-app.firebaseapp.com",
    projectId: "clubroyale-app",
    storageBucket: "clubroyale-app.firebasestorage.app",
    messagingSenderId: "691812216238",
    appId: "1:691812216238:web:b094feb74e94bde0722c3f"  // Web app ID (derived)
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message:', payload);

    const notificationTitle = payload.notification?.title || 'ClubRoyale';
    const notificationOptions = {
        body: payload.notification?.body || 'You have a new notification',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-192.png',
        tag: payload.data?.tag || 'clubroyale-notification',
        data: payload.data,
        // Actions for interactive notifications
        actions: [
            { action: 'open', title: 'Open' },
            { action: 'dismiss', title: 'Dismiss' }
        ]
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    console.log('[firebase-messaging-sw.js] Notification click:', event);
    event.notification.close();

    // Handle different actions
    if (event.action === 'dismiss') {
        return;
    }

    // Default action: open the app
    const urlToOpen = event.notification.data?.url || '/';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
            // Check if app is already open
            for (const client of clientList) {
                if (client.url.includes('clubroyale') && 'focus' in client) {
                    return client.focus();
                }
            }
            // Open new window if not already open
            return clients.openWindow(urlToOpen);
        })
    );
});

// Service worker installation
self.addEventListener('install', (event) => {
    console.log('[firebase-messaging-sw.js] Service Worker installed');
    self.skipWaiting();
});

// Service worker activation
self.addEventListener('activate', (event) => {
    console.log('[firebase-messaging-sw.js] Service Worker activated');
    event.waitUntil(clients.claim());
});
