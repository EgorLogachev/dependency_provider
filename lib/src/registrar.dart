import 'dart:async';

import 'provider.dart';
import 'manager.dart';

typedef Creator<T extends Object> = FutureOr<T> Function(
    DependenciesProvider dp);

abstract class DependenciesRegistrar {
  factory DependenciesRegistrar() => DependenciesManager();

  /// This method responsible for registration of dependency with specific type.
  /// [creator] - function that encapsulates the process of dependency creation.
  /// [tag] - optional argument that should be used in case you wanna register a few different dependencies of the same type.
  /// [lazy] - argument that defines when dependency will be created. If `true` it creates during first obtain() call, otherwise dependency will be created immediately during registration. Default `true`.
  /// [weak] - argument that defines dependency release strategy. If `true` dependency will be collected by garbage collector, as soon as all references to this dependency will be released, otherwise dependency lives in memory until [DependenciesRegistrar] exist in memory or [dispose] method will be called. Default `true`.
  /// PAY ATTENTION! If your [Creator] function returns [Future], so you have to use [obtainAsync] method to obtain dependency and [obtain] otherwise.
  void register<T extends Object>(
      Creator<T> creator, {
        dynamic tag,
        bool lazy = true,
        bool weak = true,
      });

  DependenciesProvider get provider;

  int get registeredInstancesNumber;

  int get createdInstancesNumber;

  void dispose();
}
