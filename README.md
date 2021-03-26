ReflectorDispatcher implements [Dispatcher] by introspecting a class instance
using [package:reflectable]. package:reflectable allows you to invoke an instance's methods
by their string names.

Construct a [ReflectorDispatcher] with a class instance and its pre-built introspection data created when you build according to the directions in Reflectable.
ReflectorDispatcher.dispatch("someMethod") will return a Future of whatever
value it returns.

This is for JSON-RPC, so there are some restrictions. A method can only be invoked with 
positional or named parameters, not both. Optional parameters should work as expected. 

ReflectorDispatcher is mainly a wrapper around package:reflectable, as a replacement
for dart:mirrors, which is incompatible with Flutter.
For any method dispatched, Dispatcher returns either the return value of
the method or instances of one of three "Exception" classes. Most errors
will be corralled into these objects, so that runtime exceptions don't get
thrown, instead are returned in an orderly manner.

## Usage

A simple usage example:

```dart
import 'package:reflector_dispatcher/reflector_dispatcher.dart';
import 'package:reflectable/reflectable.dart';

/// this import does not exist until you run the builder
/// (presuming this is in an 'example' folder)
/// > pub run build_runner build example
/// or > flutter pub run build_runner build example
import 'reflector_dispatcher_example.reflectable.dart';

// Annotate with this class to enable reflection.
class Reflector extends Reflectable {
  const Reflector()
      : super(
            invokingCapability, // Request the capability to invoke methods.
            declarationsCapability); // needed for introspecting methods.
}

const reflectable = Reflector();

/// Look in test/reflector_dispatcher_test.dart for additional examples.

/// Make a class with the API we want. Something silly but instructive.
///
/// Hold count in Foo.
@reflectable
class Foo {
  num _count = 0;

  /// initialize with a count
  Foo(this._count);

  /// increment with an optional positional parameter
  void increment([num aNumber = 1]) => _count += aNumber;

  /// decrement with a required named parameter
  void decrement({required num aNumber}) => _count -= aNumber;

  /// get the current value of count
  num getCount() => _count;

  /// we decrement by 2 a lot.
  num goTwoLess() {
    _count -= 2;
    return _count;
  }
}

void main() async {
  // do this before using the ReflectorDispatcher
  initializeReflectable();

  /// make a dispatcher with an initialized instance of Foo class and its
  /// introspected data
  var dispatcher = ReflectorDispatcher(Foo(29), reflectable);

  /// dispatch a method with a parameter
  await dispatcher.dispatch('increment', 4);

  /// get the new value
  var c = await (dispatcher.dispatch('getCount'));
  printCount(c); // 33

  /// dispatch a method with a named parameter
  await dispatcher.dispatch('decrement', {'aNumber': 18});
  var d = await (dispatcher.dispatch('getCount'));
  printCount(d); // 15

  /// dispatch a method without a parameter
  await dispatcher.dispatch('increment');
  var e = await (dispatcher.dispatch('getCount'));
  printCount(e); // 16

  var f = await dispatcher.dispatch('goTwoLess');
  printCount(f); // 14
}

void printCount(num aCount) {
  print('the currentCount is $aCount');
}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jwashin/reflector_dispatcher
