function onInstall(e){e.waitUntil(caches.open(CACHE_NAME).then(function n(e){return e.addAll(["/assets/application-f9ce3855fc4dfd0221b6fa336baa48d2.js","/assets/application-63238cb84f53b8a39338fd059cc0f095.css","/offline.html"])}))}function onActivate(e){console.log("[Serviceworker]","Activating!",e),e.waitUntil(caches.keys().then(function(e){return Promise.all(e.filter(function(e){return 0!==e.indexOf("v1")}).map(function(e){return caches["delete"](e)}))}))}console.log("[Service Worker] Hello world!");var CACHE_NAME="v1-cached-assets";self.addEventListener("install",onInstall),self.addEventListener("activate",onActivate);