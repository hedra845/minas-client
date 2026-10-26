import 'package:flutter/widgets.dart';

class LocaleScope extends InheritedNotifier<ValueNotifier<Locale>> {
  const LocaleScope({
    super.key,
    required ValueNotifier<Locale> super.notifier,
    required super.child,
  });

  static ValueNotifier<Locale> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context');
    return scope!.notifier!;
  }
}
