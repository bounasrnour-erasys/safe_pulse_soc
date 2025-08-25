import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/users_page.dart';
import 'pages/analytics_page.dart';
import 'pages/settings_page.dart';
import 'pages/logout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafePulse SOC',
      theme: buildDarkTheme(),
      home: const SocShell(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SocShell extends StatefulWidget {
  const SocShell({super.key});

  @override
  State<SocShell> createState() => _SocShellState();
}

class _SocShellState extends State<SocShell> {
  int _index = 0;

  static const _titles = <String>[
    'Dashboard',
    'Users',
    'Analytics',
    'Settings',
    'Logout',
  ];

  static const _icons = <IconData>[
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.query_stats_rounded,
    Icons.settings_rounded,
    Icons.logout_rounded,
  ];

  final List<Widget> _pages = const <Widget>[
    DashboardPage(),
    UsersPage(),
    AnalyticsPage(),
    SettingsPage(),
    LogoutPage(),
  ];

  void _onSelect(int i) {
    setState(() => _index = i);
  }

  Drawer _buildDrawer(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(Icons.shield_moon_rounded, color: cs.primary, size: 28),
              title: const Text('SafePulse SOC', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Security Operations'),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, i) {
                  final selected = i == _index;
                  return ListTile(
                    leading: Icon(_icons[i]),
                    title: Text(_titles[i]),
                    selected: selected,
                    selectedColor: cs.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _onSelect(i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRail(BuildContext context, {required bool extended}) {
    return NavigationRail(
      extended: extended,
      labelType: extended ? null : NavigationRailLabelType.selected,
      selectedIndex: _index,
      leading: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_moon_rounded, size: 24),
            SizedBox(width: 8),
            Text('SafePulse', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      destinations: List.generate(
        _titles.length,
        (i) => NavigationRailDestination(
          icon: Icon(_icons[i]),
          selectedIcon: Icon(_icons[i]),
          label: Text(_titles[i]),
        ),
      ),
      onDestinationSelected: (i) => _onSelect(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isExtended = constraints.maxWidth >= 1200;
        final title = _titles[_index];

        if (isWide) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Row(
              children: [
                _buildRail(context, extended: isExtended),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_index]),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: _buildDrawer(context),
          body: _pages[_index],
        );
      },
    );
  }
}
