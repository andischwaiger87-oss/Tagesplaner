import 'dart:html' as html;
import 'dart:js' as js;

bool get webNotificationsSupported => html.Notification.supported;

String get webNotificationPermission =>
    html.Notification.supported ? (html.Notification.permission ?? 'default') : 'unsupported';

Future<String> requestWebNotificationPermission() async {
  if (!html.Notification.supported) return 'unsupported';
  try {
    return await html.Notification.requestPermission();
  } catch (_) {
    return 'denied';
  }
}

Future<bool> showWebNotification(String title, String body, {bool silent = false}) async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission != 'granted') return false;
  if (silent) {
    // Diskret: lautlose Browser-Benachrichtigung (Option "silent").
    try {
      js.JsObject(js.context['Notification'] as js.JsFunction, [
        title,
        js.JsObject.jsify({'body': body, 'icon': 'icons/Icon-192.png', 'silent': true}),
      ]);
      return true;
    } catch (_) {/* Rückfall unten */}
  }
  try {
    html.Notification(title, body: body, icon: 'icons/Icon-192.png');
    return true;
  } catch (_) {
    return false;
  }
}

// PWA-Installation ("App installieren") – vom index.html bereitgestellt.
bool get pwaCanInstall {
  try { return js.context['pwaCanInstall'] == true; } catch (_) { return false; }
}

void pwaInstall() {
  try { js.context.callMethod('pwaInstall'); } catch (_) {}
}

void openUrl(String url) {
  try { html.window.open(url, '_blank'); } catch (_) {}
}
