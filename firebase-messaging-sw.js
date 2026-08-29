/* Zoopaloola web push service worker — handles background FCM invites. */
importScripts("https://www.gstatic.com/firebasejs/12.17.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.17.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCIcTUM65KhCem-mG8H23oNnrM3K-jDSHQ",
  authDomain: "zoopaloola-online.firebaseapp.com",
  projectId: "zoopaloola-online",
  storageBucket: "zoopaloola-online.firebasestorage.app",
  messagingSenderId: "386401966312",
  appId: "1:386401966312:web:0e781cb13c98fd6dc3515d"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || "Zoopaloola";
  const body = payload.notification?.body || "You have a new game invite!";
  const data = payload.data || {};
  self.registration.showNotification(title, {
    body,
    icon: "./zoopaloola-boot-splash-v2.png",
    badge: "./zoopaloola-boot-splash-v2.png",
    data
  });
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const roomCode = event.notification.data?.roomCode || "";
  const target = roomCode ? `./?room=${encodeURIComponent(roomCode)}` : "./";
  event.waitUntil(clients.openWindow(target));
});
