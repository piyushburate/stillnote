import 'dart:async';

class SafeTimer {
  final Duration duration;
  Function()? action;
  Timer? _timer;

  SafeTimer(this.duration);

  void run(Function() action) {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _timer = Timer(duration, action);
  }
}
