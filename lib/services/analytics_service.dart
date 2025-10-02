import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  const AnalyticsEvent(this.name, [this.parameters = const <String, dynamic>{}]);

  final String name;
  final Map<String, dynamic> parameters;
}

class AnalyticsService extends ChangeNotifier {
  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];

  List<AnalyticsEvent> get events => List<AnalyticsEvent>.unmodifiable(_events);

  void recordEvent(String name, [Map<String, dynamic>? parameters]) {
    _events.add(AnalyticsEvent(name, parameters ?? const <String, dynamic>{}));
    notifyListeners();
  }

  void reset() {
    _events.clear();
    notifyListeners();
  }
}
