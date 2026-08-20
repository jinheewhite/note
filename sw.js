/* 판서노트 서비스워커
   Copyright (c) 2026 강진희. All rights reserved.

   앱 파일 하나가 3.5MB 입니다. 예전에는 열 때마다 그것을 서버에서 새로
   받은 뒤에야 화면을 보여 주었습니다(network-first). 그래서 전자칠판처럼
   느린 기기에서는 열기가 버거웠습니다.

   이제는 저장해 둔 것을 먼저 돌려주어 곧바로 열리게 하고, 새 파일은 뒤에서
   조용히 받아 다음 번을 준비합니다.

   새 판이 나왔는지는 version.json(18바이트)으로 따로 확인합니다. 그 파일만은
   절대 저장해 두지 않습니다 — 그것마저 묵으면 새 판을 영영 못 보게 됩니다. */
const CACHE = 'panseo-note-23.6';
const APP = './index.html';

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    try {
      const c = await caches.open(CACHE);
      await c.add(new Request(APP, { cache: 'reload' }));   /* 설치할 때 미리 받아 둡니다 */
    } catch (err) {}
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    for (const k of await caches.keys()) if (k !== CACHE) await caches.delete(k);
    await self.clients.claim();
  })());
});

self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;

  let url;
  try { url = new URL(req.url); } catch (err) { return; }
  if (url.origin !== location.origin) return;      /* 남의 집 파일은 건드리지 않습니다 */

  /* 버전 파일은 늘 서버에서 받습니다 */
  if (url.pathname.endsWith('version.json')) {
    e.respondWith((async () => {
      try { return await fetch(req, { cache: 'no-store' }); }
      catch (err) {
        const hit = await caches.match(req);
        return hit || new Response('{}', { headers: { 'Content-Type': 'application/json' } });
      }
    })());
    return;
  }

  const nav = req.mode === 'navigate';
  const key = nav ? APP : req;                     /* 주소창으로 들어오면 index.html 을 씁니다 */

  e.respondWith((async () => {
    const cached = await caches.match(key);
    if (cached) {
      /* 저장해 둔 것을 곧바로 돌려주고, 새 파일은 뒤에서 받아 둡니다.
         waitUntil 로 넘기므로 화면이 뜨는 것을 붙잡지 않습니다. */
      e.waitUntil((async () => {
        try {
          const fresh = await fetch(nav ? new Request(APP, { cache: 'reload' }) : req, { cache: 'no-store' });
          if (fresh && fresh.ok) (await caches.open(CACHE)).put(key, fresh.clone());
        } catch (err) {}
      })());
      return cached;
    }
    /* 저장해 둔 것이 없으면 받아서 쓰고, 다음을 위해 남겨 둡니다 */
    try {
      const fresh = await fetch(req);
      if (fresh && fresh.ok) (await caches.open(CACHE)).put(key, fresh.clone());
      return fresh;
    } catch (err) {
      const hit = await caches.match(APP);
      return hit || Response.error();
    }
  })());
});
