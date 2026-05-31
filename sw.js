// Bump CACHE version whenever you edit app files — old cache is cleared automatically.
const CACHE = 'elk-trainer-v1';
const SHELL = ['./','./index.html','./manifest.json','./sw.js','./icon.svg'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  // Never intercept GitHub API or data calls
  if (e.request.url.includes('api.github.com')) return;

  // Network-first for app shell so edits appear on next open when server is reachable;
  // fall back to cache when offline.
  e.respondWith(
    fetch(e.request).then(res => {
      if (res && res.status === 200 && res.type !== 'opaque') {
        caches.open(CACHE).then(c => c.put(e.request, res.clone()));
      }
      return res;
    }).catch(() =>
      caches.match(e.request).then(cached => cached || caches.match('./index.html'))
    )
  );
});
