import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Kanit',
      ),
      home: const MyHomePage(title: 'GARBO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<Container> makeApiRequest() async {
    Uri myuri = Uri.parse('https://api.pexels.com/v1/search?query=nature&per_page=1');
    final response = await http.get(
      myuri,
      headers: {
        'Authorization': 'xArSBTqDja5yVW7ARgAocuqHuIyuSr3RoXcWmsfk65Mup3rxeZHGBk95',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;
      final imageUrl = 'what';

      return Container(
        child: Image.network(imageUrl),
        );

    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body:Container(
        color: Colors.black,
        child: FutureBuilder(
        future: makeApiRequest(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            //final imageUrl = data.containsKey(2) ? data[2] : 'Key not found';
            final imageUrl = 'https://images.pexels.com/photos/15286/pexels-photo.jpg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940';

            return Container(
              child: Image.network(imageUrl),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return CircularProgressIndicator();
        },
      ),
      ),

    );
  }
}

