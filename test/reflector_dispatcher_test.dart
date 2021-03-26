@TestOn('vm')

import 'package:reflectable/reflectable.dart';
import 'package:reflector_dispatcher/reflector_dispatcher.dart';
import 'package:rpc_dispatcher/rpc_dispatcher.dart';
import 'package:rpc_exceptions/rpc_exceptions.dart';
import 'package:test/test.dart';

// the following file does not exist until generated by build_runner.
//
// > pub run build_runner build test
// or > flutter pub run build_runner build test
import 'reflector_dispatcher_test.reflectable.dart';

// Annotate with this class to enable reflection.
class Reflector extends Reflectable {
  const Reflector()
      : super(
            invokingCapability, // Request the capability to invoke methods.
            declarationsCapability); // needed for introspecting methods.
}

const introspected = Reflector();

@introspected
class Foo {
  String greetName;
  Foo([this.greetName = 'Stranger']);
  String hi() => 'Hi!';
  String hello() => 'Hello, $greetName!';
  String greet([String? name]) {
    var tmp = name ?? greetName;
    if (tmp == greetName) {
      return 'Hello, $tmp!';
    }
    return 'Hi, $tmp!';
  }

  num add(num a, num b) => a + b;
  num _privateAdd(num a, num b) => a + b;
  num subtract(num a, num b) => a - b;
  num subtractNamed({required num minuend, required num subtrahend}) =>
      minuend - subtrahend;
  dynamic throwError(num a, num b) {
    throw Zerr('you expected this!');
  }

  dynamic typeerror(dynamic a) {
    try {
      return a + 9;
    } on TypeError {
      throw RuntimeException('Cannot add string and number', -22, [a, 9]);
    }
  }

  num divzerotest(num a) {
    return a / 0;
  }

  num usePrivateAdd(num a, num b) {
    return _privateAdd(a, b);
  }
}

class Zerr implements Exception {
  String message;
  Zerr(this.message);
}

void main() {
  initializeReflectable();
  test('symbolize', () {
    expect(symbolizeKeys({'a': 1}), equals({Symbol('a'): 1}));
  });

  test('simple object', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('hi').then((dynamic value) => expect(value, equals('Hi!')));
  });

  test('simple object with param', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('greet', ['Mary']).then(
        (dynamic value) => expect(value, equals('Hi, Mary!')));
  });

  test('simple object initialized with param unused', () {
    var z = ReflectorDispatcher(Foo('Bar'), introspected);
    z.dispatch('greet', ['Mary']).then(
        (dynamic value) => expect(value, equals('Hi, Mary!')));
  });

  test('simple object initialized with param used', () {
    var z = ReflectorDispatcher(Foo('Bob'), introspected);
    z
        .dispatch('hello')
        .then((dynamic value) => expect(value, equals('Hello, Bob!')));
  });

  test('simple object without optional param', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z
        .dispatch('greet')
        .then((dynamic value) => expect(value, equals('Hello, Stranger!')));
  });

  test('simple addition', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('add', [3, 4]).then((dynamic value) => expect(value, equals(7)));
  });

  test('simple subtraction a b', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('subtract', [42, 23]).then(
        (dynamic value) => expect(value, equals(19)));
  });
  test('simple subtraction b a', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch(
        'subtract', [23, 42]).then((var value) => expect(value, equals(-19)));
  });

  test('named subtraction in order', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('subtractNamed', [], {'minuend': 23, 'subtrahend': 42}).then(
        (var value) => expect(value, equals(-19)));
  });

  test('named subtraction out of order', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('subtractNamed', [], {'subtrahend': 42, 'minuend': 23}).then(
        (var value) => expect(value, equals(-19)));
  });

  test('mixed nums', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('add', [3, 4.3]).then((var value) => expect(value, equals(7.3)));
  });

  test('method not found', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('zadd', [3, 4.3]).then(
        (dynamic value) => expect(value, TypeMatcher<MethodNotFoundException>()));

    ///#new isInstanceOf<MethodNotFound>()));
  });

  test('private method call', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('_privateAdd', [3, 4.3]).then(
        (dynamic value) => expect(value, TypeMatcher<MethodNotFoundException>()));
  });

  test('invalid parameters too many', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('add', [3, 5, 8]).then(

        // (dynamic value) => expect(value, TypeMatcher<InvalidParameters>()));
        (dynamic value) => expect(value, TypeMatcher<InvalidParametersException>()));
  });

  test('invalid parameters bad value', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('add', [3, 'hello']).then(
        (dynamic value) => expect(value, TypeMatcher<InvalidParametersException>()));
  });

  test('invalid parameters too few', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('add', [3]).then(
        (dynamic value) => expect(value, TypeMatcher<InvalidParametersException>()));
  });

  test('internal error', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('throwError', [3, 0]).then(
        (dynamic value) => expect(value, TypeMatcher<RuntimeException>()));
  });

  test('private method invocation', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('_private_add', [3, 4.3]).then(
        (dynamic value) => expect(value, TypeMatcher<MethodNotFoundException>()));
  });

  test('attempt property invocation', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z
        .dispatch('greet_name')
        .then((dynamic value) => expect(value, TypeMatcher<MethodNotFoundException>()));
  });

  test('catch TypeError in application code', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('typeerror', ['a']).then(
        (dynamic value) => expect(value, TypeMatcher<RuntimeException>()));
  });

  test('divide by zero', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch('divzerotest', [3]).then(
        (dynamic value) => expect(value, double.infinity));
  });

  test('zero over zero', () {
    var z = ReflectorDispatcher(Foo(), introspected);
    z.dispatch(
        'divzerotest', [0]).then((var value) => expect(value.isNaN, true));
  });
}