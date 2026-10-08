abstract interface class PushTokenRegistrar {
  Future<void> registerCurrentDevice();
  void startTokenRefresh();
  void dispose();
}
