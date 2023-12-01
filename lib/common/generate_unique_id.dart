int _initialId = 0;

int generateUniqueId() {
  if (_initialId == 0) {
    _initialId = DateTime.now().millisecondsSinceEpoch;
  }
  return _initialId++;
}
