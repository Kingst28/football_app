if (navigator.serviceWorker) {
  navigator.serviceWorker.register('<%= asset_path "application.js" %>', { scope: './' })
    .then(function(reg) {
      console.log('[Companion]', 'Service worker registered!');
    });
}
