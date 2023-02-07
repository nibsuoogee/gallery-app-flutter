import 'dart:ffi';

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
  List<String> _searchArray = ['nature', 'beautiful', 'flowers', 'landscape', 'abstract', 'fire', 'dark', 'love', 'winter'];
  String selectedWord = 'None';
  List<String> _images = [];
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    _scrollController.jumpTo(0.0);
  }

  int calculatePageNumber(int imageNumber) {
    int nextPage = (imageNumber/15).floor() + 1;
    return ((nextPage >= 1) ? nextPage : 1);
  }

  void makeApiRequest(String searchWord) async {
    if (searchWord.isEmpty) {return;}

    int page = calculatePageNumber(_images.length);
    Uri myuri = Uri.parse('https://api.pexels.com/v1/search?query=$searchWord&page=$page');
    final response = await http.get(
      myuri,
      headers: {
        'Authorization': 'xArSBTqDja5yVW7ARgAocuqHuIyuSr3RoXcWmsfk65Mup3rxeZHGBk95',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map;

      List<String> responseImages = [];

      for (Map<String, dynamic> element in data['photos']) {
        responseImages.add(element['src']['portrait']);
      }

      setState(() {
        _images = _images + responseImages;
      });
      return;

    } else {
      throw Exception('Failed to load data');
    }
  }

  void addCollie() {
    setState(() {
      _images.add("https://www.vastavalo.net/albums/userpics/13414/normal_4564_collie.jpg");
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('graphics/gg_logo.png', fit: BoxFit.contain, height: 100),
      ),

      body: Container(
        color: Colors.black,
        child: Flex(
        direction: Axis.vertical,
        children: [
         Expanded(
          child: SizedBox(
            child: ListView.builder(
            controller: _scrollController,
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
                        _images = [];
                        selectedWord = word;
                      });
                    },
                  ),
                );
            } else if (index == (_images.length)) {
              return Column(children: [
                Text(
                      textAlign: TextAlign.center,
                      '${_images.length} loaded (page ${calculatePageNumber(_images.length)})', style: TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                    ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                  onTap: () {
                    makeApiRequest(selectedWord);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 224, 224, 224),
                      width: 2,
                    ),
                    ),
                    child: const Text(
                      textAlign: TextAlign.center,
                      'Load more images', style: TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                  onTap: () {
                    scrollToTop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 130, 130, 130),
                      width: 2,
                    ),
                    ),
                    child: const Text(
                      textAlign: TextAlign.center,
                      'Back to top', style: TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                    ),
                  ),
                ),
              )
              ]);
              
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FadeInImage.assetNetwork(
                      placeholder: 'graphics/dark_placeholder_image.jpg',
                      image: _images[index-1],
                    ),
                ),
              );
            }
          },)
          )),
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
                    color: word == selectedWord ? Color.fromARGB(255, 231, 20, 20) : Color.fromARGB(255, 189, 189, 189),
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