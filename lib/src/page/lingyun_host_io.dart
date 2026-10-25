import 'dart:io' show Platform;

/// Whether this process is iOS, ignoring debugDefaultTargetPlatformOverride.
bool get lingyunProcessIsIOS => Platform.isIOS;
