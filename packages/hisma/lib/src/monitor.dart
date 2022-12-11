abstract class Monitor {
  Future<void> notifyCreation();
  Future<void> notifyStateChange();
}
