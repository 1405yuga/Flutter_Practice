import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 255, 0, 1.0)),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavourite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPosition = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPosition) {
      case 0:
        page = GeneratePage();
        break;
      case 1:
        // creates cross mark on UI - ie Unfinished page : Placeholder()
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedPosition');
    }

    //LayoutBuilder's builder callback is called every time the constraints change
    return LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Namer App'),
            ),
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth>=600, // to expand navigation rail when larger screen
                    destinations: [
                      NavigationRailDestination(
                          icon: Icon(Icons.home), label: Text('Home')),
                      NavigationRailDestination(
                          icon: Icon(Icons.favorite), label: Text('Favourites'))
                    ],
                    selectedIndex: selectedPosition,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedPosition = value;
                      });
                      ;
                    },
                  ),
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ))
              ],
            ));
      }
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
        Text('Following are favorite words'),
        for(var word in appState.favorites)
          Text("${word.asLowerCase}"),
      ],
    );
  }
}

class GeneratePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData iconData = Icons.favorite_border;
    if (appState.favorites.contains(pair)) iconData = Icons.favorite;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                },
                icon: Icon(iconData),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next')),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myTextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "${pair.first} ${pair.second}",
          style: myTextStyle,
        ),
      ),
    );
  }
}
