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
        primarySwatch: Colors.red,
        fontFamily: 'Kanit',
      ),
      home: const MyHomePage(title: 'GARBO GALLERY'),
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
  List<String> _searchArray = ['nature', 'beautiful', 'flowers', 'landscape', 'abstract', 'fire', 'dark', 'love', 'winter'];
  String selectedWord = 'None';
  List<String> _images = [];

  void makeApiRequest(String searchWord) async {
    Uri myuri = Uri.parse('https://api.pexels.com/v1/search?query=$searchWord');
    final response = await http.get(
      myuri,
      headers: {
        'Authorization': 'xArSBTqDja5yVW7ARgAocuqHuIyuSr3RoXcWmsfk65Mup3rxeZHGBk95',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;
      final imageUrl = 'what';

      List<String> responseImages = [];

      for (Map<String, dynamic> element in data['photos']) {
        responseImages.add(element['src']['portrait']);
      }

      setState(() {
        _images = responseImages;
      });
      return;

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

      body: Container(
        color: Colors.black,
        child: Flex(
        direction: Axis.vertical,
        children: [
         Expanded(
          child: SizedBox(           
            child: ListView.builder(
            itemCount: _images.length + 1,
            itemBuilder: (context, int index){
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(15),
                  child: SearchSelectMatrix(
                    words: _searchArray,
                    onWordSelected: (word) {
                      makeApiRequest(word);
                      setState(() {
                        selectedWord = word;
                      });
                    },
                  ),
                );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    _images[index-1],
                  ),
                ),
              );
            }
          },)
          ))
        ]
      ),
      )
    );
  }
}

class SearchSelectMatrix extends StatefulWidget {
  final List<String> words;
  final Function(String) onWordSelected;

  SearchSelectMatrix({required this.words, required this.onWordSelected});

  @override
  State<SearchSelectMatrix> createState() => _SearchSelectMatrix();
}

class _SearchSelectMatrix extends State<SearchSelectMatrix> {
  String selectedWord = '';

  @override
  Widget build(BuildContext context) {
      return Container(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.words.map((word) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedWord = word;
                });
                widget.onWordSelected(word);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: word == selectedWord ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  word, style: const TextStyle(color: Colors.white),
                  ),
              ),
            );
          }).toList(),
        ),
      );
    }
}