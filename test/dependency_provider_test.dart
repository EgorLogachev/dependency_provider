import 'package:dependency_provider/dependency_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class TestSingleDependencyObject {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestSingleDependencyObject && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class TestTaggedDependencyObject {
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestTaggedDependencyObject && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class NotRegisteredDepObject {}

class ImmediatelyCreatedObject {}

class TestWeakObject {}

class TestStrongObject {}

void main() {
  final dependenciesRegistrar = DependenciesRegistrar();
  final dependenciesProvider = dependenciesRegistrar.provider;

  /// `register method tests`
  test('register single instance test', () {
    expect(
          () {
        dependenciesRegistrar.register<TestSingleDependencyObject>((dm) => TestSingleDependencyObject());
      },
      returnsNormally,
    );
  });

  test('try to register other single instance of the same type', () {
    expect(
          () {
        dependenciesRegistrar.register<TestSingleDependencyObject>((dm) => TestSingleDependencyObject());
      },
      throwsUnsupportedError,
    );
  });

  test('try to register the instance of the same type with tag', () {
    expect(
          () {
        dependenciesRegistrar.register<TestSingleDependencyObject>(
              (dm) => TestSingleDependencyObject(),
          tag: 'second instance of TestSingleDependencyObject',
        );
      },
      throwsUnsupportedError,
    );
  });

  test('register instance with tag', () {
    expect(
          () {
        dependenciesRegistrar.register<TestTaggedDependencyObject>(
              (dm) => TestTaggedDependencyObject(),
          tag: 'first instance of TestTaggedDependencyObject',
        );
      },
      returnsNormally,
    );
  });

  test('try to register the same instance as single', () {
    expect(
          () {
        dependenciesRegistrar.register<TestTaggedDependencyObject>(
              (dm) => TestTaggedDependencyObject(),
        );
      },
      throwsStateError,
    );
  });

  test('try to register the same instance with the same tag', () {
    expect(
          () {
        dependenciesRegistrar.register<TestTaggedDependencyObject>(
              (dm) => TestTaggedDependencyObject(),
          tag: 'first instance of TestTaggedDependencyObject',
        );
      },
      throwsStateError,
    );
  });

  test('try to register the same instance with the other tag', () {
    expect(
          () {
        dependenciesRegistrar.register<TestTaggedDependencyObject>(
              (dm) => TestTaggedDependencyObject(),
          tag: 123,
        );
      },
      returnsNormally,
    );
  });

  /// `obtain` method tests
  test('check number of registered instances in dependency manager before first obtain', () {
    expect(dependenciesRegistrar.registeredInstancesNumber, equals(2));
  });

  test('check number of created instances in dependency manager before first obtain', () {
    expect(dependenciesRegistrar.createdInstancesNumber, equals(0));
  });

  test('try obtain single object', () {
    expect(dependenciesProvider.obtain<TestSingleDependencyObject>(), equals(TestSingleDependencyObject()));
  });

  test('check number of created instances in dependency manager after first obtain', () {
    expect(dependenciesRegistrar.createdInstancesNumber, equals(1));
  });

  test('try to check that obtaining of single instance of the same type always returns the same object', () {
    var dep1 = dependenciesProvider.obtain<TestSingleDependencyObject>();
    var dep2 = dependenciesProvider.obtain<TestSingleDependencyObject>();
    expect(identical(dep1, dep2), equals(true));
  });

  test('try obtain single object', () {
    expect(dependenciesProvider.obtain<TestSingleDependencyObject>(), equals(TestSingleDependencyObject()));
  });

  test('try obtain first object with tag', () {
    expect(
      dependenciesProvider.obtain<TestTaggedDependencyObject>(tag: 'first instance of TestTaggedDependencyObject'),
      equals(TestTaggedDependencyObject()),
    );
  });

  test('try obtain second object with tag', () {
    expect(
      dependenciesProvider.obtain<TestTaggedDependencyObject>(tag: 123),
      equals(TestTaggedDependencyObject()),
    );
  });

  test('check that first and second dependencies are different object', () {
    var dep1 = dependenciesProvider.obtain<TestTaggedDependencyObject>(tag: 'first instance of TestTaggedDependencyObject');
    var dep2 = dependenciesProvider.obtain<TestTaggedDependencyObject>(tag: 123);
    expect(identical(dep1, dep2), equals(false));
  });

  test('check number of created instances in dependency manager after first obtain', () {
    expect(dependenciesRegistrar.createdInstancesNumber, equals(2));
  });

  test('try to obtain not registered instance', () {
    expect(() => dependenciesProvider.obtain<NotRegisteredDepObject>(tag: 123), throwsStateError);
  });

  test('try to obtain registered with tag instance without tag', () {
    expect(() => dependenciesProvider.obtain<TestTaggedDependencyObject>(), throwsStateError);
  });

  test('try to obtain registered with tag instance with wrong tag', () {
    expect(() => dependenciesProvider.obtain<TestTaggedDependencyObject>(tag: 'asdfdsaf'), throwsStateError);
  });

  //immediately creation tests
  test('check that registration with flag lazy = false creates immediately', () {
    dependenciesRegistrar.register((dm) => ImmediatelyCreatedObject(), lazy: false, weak: false);
    expect(dependenciesRegistrar.createdInstancesNumber, equals(3));
    expect(dependenciesRegistrar.registeredInstancesNumber, equals(3));
  });

  //weak ref tests
  test('check that first and second dependencies are different object', () async {
    dependenciesRegistrar.register((dm) => TestWeakObject());
    int dep1Hash = dependenciesProvider.obtain<TestWeakObject>().hashCode;
    await Future(() {
      for (int i = 0; i < 1000; i++) {
        print(i);
      }
    });
    int dep2Hash = dependenciesProvider.obtain<TestWeakObject>().hashCode;
    expect(dep1Hash == dep2Hash, equals(false));
  });

  test('check that first and second dependencies are different object', () async {
    dependenciesRegistrar.register((dm) => TestStrongObject(), weak: false);
    int dep1Hash = dependenciesProvider.obtain<TestWeakObject>().hashCode;
    await Future(() {
      for (int i = 0; i < 1000; i++) {
        print(i);
      }
    });
    int dep2Hash = dependenciesProvider.obtain<TestWeakObject>().hashCode;
    expect(dep1Hash == dep2Hash, equals(true));
  });
}
