import 'package:dependency_provider/dependency_provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> with Dependencies {
  final _routesMap =
      <String, Route Function(DependenciesProvider, RouteSettings)>{
    '/': (dp, settings) => MaterialPageRoute(
        builder: (_) => HomeScreen(api: dp.appApi, analytics: dp.analytics)),
    '/next': (dp, settings) =>
        MaterialPageRoute(builder: (_) => NextScreen(api: dp.appApi)),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sample Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return _routesMap[settings.name]?.call(provider, settings) ??
            MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
      },
    );
  }
}

class AppApi {
  AppApi(Network network);
}

class Analytics {
  Analytics(Network network);
}

class Network {
  Network(String baseUrl);
}

/// Dependencies Registration
class Dependencies {
  final _dr = DependenciesRegistrar()
    /// Few instances of the same type can be registered few times with different options with help of tag.
    ..register((dp) => Network('https://api.app.com'),
        tag: 'AppApi', weak: false)
    ..register((dp) => Network('https://api.analytics.com'),
        tag: 'Analytics', lazy: false)
    ..register((dp) => Analytics(dp.obtain<Network>(tag: 'Analytics')))
    ..register((dp) => AppApi(dp.obtain<Network>(tag: 'AppApi')));

  DependenciesProvider get provider => _dr.provider;

  void dispose() => _dr.dispose();
}

/// optional
extension AppDependencyProvider on DependenciesProvider {
  AppApi get appApi => obtain<AppApi>();

  Analytics get analytics => obtain<Analytics>();
}

class Screen extends StatelessWidget {
  final String name;
  final int color;

  const Screen({super.key, required this.name, required this.color, this.onTap});
  
  final Function(BuildContext)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => onTap?.call(context),
      child: Container(
        color: Color(color),
        child: Center(
          child: Text(name),
        ),
      ),
    );
    
  }
}

class HomeScreen extends Screen {
  HomeScreen({Key? key, required AppApi api, required Analytics analytics})
      : super(key: key, color: Colors.green.value, name: 'Home', onTap: (context) {
        Navigator.of(context).pushNamed('/next');
  });
}

class NextScreen extends Screen {
  NextScreen({Key? key, required AppApi api})
      : super(key: key, color: Colors.yellow.value, name: 'Next');
}
