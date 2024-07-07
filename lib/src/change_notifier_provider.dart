import 'package:flutter/widgets.dart';

import 'listenable_provider.dart';
import 'provider.dart';
import 'proxy_provider.dart';

/// Listens to a [ChangeNotifier], expose it to its descendants and rebuilds
/// dependents whenever [ChangeNotifier.notifyListeners] is called.
///
/// Depending on whether you want to **create** or **reuse** a [ChangeNotifier],
/// you will want to use different constructors.
///
/// ## Creating a [ChangeNotifier]:
///
/// To create a value, use the default constructor. Creating the instance
/// inside `build` using `ChangeNotifierProvider.value` will lead to memory
/// leaks and potentially undesired side-effects.
///
/// See [this stackoverflow answer](https://stackoverflow.com/questions/52249578/how-to-deal-with-unwanted-widget-build)
/// which explains in further details why using the `.value` constructor to
/// create values is undesired.
///
/// - **DO** create a new [ChangeNotifier] inside `create`.
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => new MyChangeNotifier(),
///   child: ...
/// )
/// ```
///
/// - **DON'T** use `ChangeNotifierProvider.value` to create your
///   [ChangeNotifier].
///
/// ```dart
/// ChangeNotifierProvider.value(
///   value: new MyChangeNotifier(),
///   child: ...
/// )
/// ```
///
/// - **DON'T** create your [ChangeNotifier] from variables that can change over
///   the time.
///
///   In such situation, your [ChangeNotifier] would never be updated when the
///   value changes.
///
/// ```dart
/// int count;
///
/// ChangeNotifierProvider(
///   create: (_) => new MyChangeNotifier(count),
///   child: ...
/// )
/// ```
///
/// If you want to pass variables to your [ChangeNotifier], consider using
/// [ChangeNotifierProxyProvider].
///
/// ## Reusing an existing instance of [ChangeNotifier]:
///
/// If you already have an instance of [ChangeNotifier] and want to expose it,
/// you should use [ChangeNotifierProvider.value] instead of the default
/// constructor.
///
/// Failing to do so may dispose the [ChangeNotifier] when it is still in use.
///
/// - **DO** use [ChangeNotifierProvider.value] to provide an existing
///   [ChangeNotifier].
///
/// ```dart
/// MyChangeNotifier variable;
///
/// ChangeNotifierProvider.value(
///   value: variable,
///   child: ...
/// )
/// ```
///
/// - **DON'T** reuse an existing [ChangeNotifier] using the default constructor
///
/// ```dart
/// MyChangeNotifier variable;
///
/// ChangeNotifierProvider(
///   create: (_) => variable,
///   child: ...
/// )
/// ```
///
/// See also:
///
///   * [ChangeNotifier], which is listened by [ChangeNotifierProvider].
///   * [ChangeNotifierProxyProvider], to create and provide a [ChangeNotifier]
///     of variables from other providers.
///   * [ListenableProvider], similar to [ChangeNotifierProvider] but works with
///     any [Listenable].
class ChangeNotifierProvider<T extends ChangeNotifier?> extends ListenableProvider<T> {
  /// Creates a [ChangeNotifier] using `create` and automatically
  /// disposes it when [ChangeNotifierProvider] is removed from the widget tree.
  ///
  /// `create` must not be `null`.
  ChangeNotifierProvider({
    super.key,
    required super.create,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: _dispose,
        );

  /// Provides an existing [ChangeNotifier].
  ChangeNotifierProvider.value({
    super.key,
    required super.value,
    super.builder,
    super.child,
  }) : super.value();

  static void _dispose(BuildContext context, ChangeNotifier? notifier) {
    notifier?.dispose();
  }
}

/// {@template provider.changenotifierproxyprovider}
/// A [ChangeNotifierProvider] that builds and synchronizes a [ChangeNotifier]
/// with external values.
///
/// To understand better this variation of [ChangeNotifierProvider], we can
/// look into the following code using the original provider:
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (context) {
///     return MyChangeNotifier(
///       myModel: Provider.of<MyModel>(context, listen: false),
///     );
///   },
///   child: ...
/// )
/// ```
///
/// In this example, we built a `MyChangeNotifier` from a value coming from
/// another provider: `MyModel`.
///
/// This works as long as `MyModel` never changes. But if it somehow updates,
/// then our [ChangeNotifier] will never update accordingly.
///
/// To solve this issue, we could instead use this class, like so:
///
/// ```dart
/// ChangeNotifierProxyProvider<MyModel, MyChangeNotifier>(
///   create: (_) => MyChangeNotifier(),
///   update: (_, myModel, myNotifier) => myNotifier
///     ..update(myModel),
///   child: ...
/// );
/// ```
///
/// In that situation, if `MyModel` were to update, then `MyChangeNotifier` will
/// be able to update accordingly.
///
/// Notice how `MyChangeNotifier` doesn't receive `MyModel` in its constructor
/// anymore. It is now passed through a custom setter/method instead.
///
/// A typical implementation of such `MyChangeNotifier` could be:
///
/// ```dart
/// class MyChangeNotifier with ChangeNotifier {
///   void update(MyModel myModel) {
///     // Do some custom work based on myModel that may call `notifyListeners`
///   }
/// }
/// ```
///
/// - **DON'T** create the [ChangeNotifier] inside `update` directly.
///
///   This will cause your state to be lost when one of the values used updates.
///   It will also cause unnecessary overhead because it will dispose the
///   previous notifier, then subscribes to the new one.
///
///  Instead reuse the previous instance, and update some properties or call
///  some methods.
///
/// ```dart
/// ChangeNotifierProxyProvider<MyModel, MyChangeNotifier>(
///   // may cause the state to be destroyed involuntarily
///   update: (_, myModel, myNotifier) => MyChangeNotifier(myModel: myModel),
///   child: ...
/// );
/// ```
///
/// - **PREFER** using [ProxyProvider] when possible.
///
///   If the created object is only a combination of other objects, without
///   http calls or similar side-effects, then it is likely that an immutable
///   object built using [ProxyProvider] will work.
/// {@endtemplate}
class ChangeNotifierProxyProvider<T, R extends ChangeNotifier?> extends ListenableProxyProvider<T, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider0<R extends ChangeNotifier?> extends ListenableProxyProvider0<R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider0({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider2<T, T2, R extends ChangeNotifier?> extends ListenableProxyProvider2<T, T2, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider2({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider3<T, T2, T3, R extends ChangeNotifier?> extends ListenableProxyProvider3<T, T2, T3, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider3({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider4<T, T2, T3, T4, R extends ChangeNotifier?> extends ListenableProxyProvider4<T, T2, T3, T4, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider4({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider5<T, T2, T3, T4, T5, R extends ChangeNotifier?> extends ListenableProxyProvider5<T, T2, T3, T4, T5, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider5({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}

/// {@macro provider.changenotifierproxyprovider}
class ChangeNotifierProxyProvider6<T, T2, T3, T4, T5, T6, R extends ChangeNotifier?> extends ListenableProxyProvider6<T, T2, T3, T4, T5, T6, R> {
  /// Initializes [key] for subclasses.
  ChangeNotifierProxyProvider6({
    super.key,
    required Create<R> super.create,
    required super.update,
    super.lazy,
    super.builder,
    super.child,
  }) : super(
          dispose: ChangeNotifierProvider._dispose,
        );
}
