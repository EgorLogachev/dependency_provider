abstract class DependenciesProvider {
  /// This method returns dependency of a specified type.
  /// [tag] -  this argument should be defined if several dependencies of the same type was registered before.
  T obtain<T extends Object>({dynamic tag});

  /// This method returns Future with dependency of a specified type. PAY ATTENTION!!! This method have to be used if your [Creator] function returns [Future].
  /// [tag] -  this argument should be defined if several dependencies of the same type was registered before.
  Future<T> obtainAsync<T extends Object>({dynamic tag});
}
