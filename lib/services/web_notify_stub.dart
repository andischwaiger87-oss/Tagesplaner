// Nicht-Web: keine Browser-Benachrichtigungen nötig (native Plugin übernimmt).
bool get webNotificationsSupported => false;
String get webNotificationPermission => 'unsupported';
Future<String> requestWebNotificationPermission() async => 'unsupported';
Future<bool> showWebNotification(String title, String body) async => false;
bool get pwaCanInstall => false;
void pwaInstall() {}
