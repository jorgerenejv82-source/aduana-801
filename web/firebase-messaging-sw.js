importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAQYGDT-gGVONwcCDlcaYoY5WfqgNwWP00",
  authDomain: "aduana-801.firebaseapp.com",
  projectId: "aduana-801",
  storageBucket: "aduana-801.firebasestorage.app",
  messagingSenderId: "245622344505",
  appId: "1:245622344505:web:703841c95a307a153936e8"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message:', payload);
  const { title, body } = payload.notification;
  self.registration.showNotification(title, {
    body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  });
});
