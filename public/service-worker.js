const CACHE_NAME = "solara-v2";

self.addEventListener("install", (event) => {
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  // Skip non-same-origin requests (fonts, analytics, etc.)
  if (!event.request.url.startsWith(self.location.origin)) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() =>
        caches.match(event.request).then((cached) => {
          if (cached) return cached;

          // Offline fallback for navigation requests
          if (event.request.mode === "navigate") {
            return new Response(
              `<!DOCTYPE html>
              <html><head><meta name="viewport" content="width=device-width,initial-scale=1">
              <title>Solara - Offline</title>
              <style>body{font-family:Inter,system-ui,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f9fafb;color:#374151;text-align:center}
              .c{max-width:320px}h1{font-size:1.25rem;margin-bottom:.5rem}p{font-size:.875rem;color:#6b7280}button{margin-top:1rem;padding:.5rem 1rem;background:#4f46e5;color:#fff;border:none;border-radius:.5rem;cursor:pointer;font-size:.875rem}</style></head>
              <body><div class="c"><h1>You're offline</h1><p>Solara needs a connection to sync your tasks and calendar.</p><button onclick="location.reload()">Retry</button></div></body></html>`,
              { headers: { "Content-Type": "text/html" } }
            );
          }

          return new Response("", { status: 503 });
        })
      )
  );
});
