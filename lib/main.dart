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
        fontFamily: 'Poppins',
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
  int _nOexampleTerms = 4;
  final List<String> _searchArrayDisplay = ['curated', 'nature', 'beautiful', 'flowers', 'abstract', 'fire', 'dark', 'love', 'winter', 'business', 'technology', 'space', 'city', 'dog', 'cat', 'beach', 'mountain', 'gamer', 'car', 'sports', 'science', 'landscape'];
  String selectedWord = 'None';
  List<Map> _images = [];
  final ScrollController _scrollController = ScrollController();
  late FocusNode myFocusNode;
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();

    super.dispose();
  }

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

      List<Map> responseImages = [];

      for (Map<String, dynamic> element in data['photos']) {
        var elementMap = <String, dynamic>{};
        elementMap ['image'] =  element['src']['portrait'];
        elementMap ['photographer'] =  element['photographer'];
        elementMap ['id'] =  element['id'];
        responseImages.add(elementMap);
      }

      setState(() {
        _images = _images + responseImages;
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
            itemCount: (_images.isNotEmpty ? _images.length : 1) + 1,
            itemBuilder: (context, int index){
              if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  
                  controller: myController,
                  onEditingComplete: () {
                    setState(() {
                      _images = [];
                      selectedWord = myController.text;
                    });
                    makeApiRequest(myController.text);
                  },
                  focusNode: myFocusNode,
                  cursorColor: const Color.fromARGB(255, 255, 255, 255),
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 106, 106, 106), width: 1),
                    ),
                  ),
                ),
              );
            } else if (index == 1) {
              return Column(children: [Padding(
                padding: const EdgeInsets.all(15),
                  child: SearchSelectMatrix(
                    words: _searchArrayDisplay.sublist(0,_nOexampleTerms),
                    onWordSelected: (word) {
                      myFocusNode.unfocus();
                      setState(() {
                        _images = [];
                        selectedWord = word;
                        makeApiRequest(word);
                      });
                    },
                  ),
                ),
                Center(child: (_nOexampleTerms < 10) ? IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Color.fromARGB(255, 255, 255, 255),
                  tooltip: 'more search terms',
                  onPressed: () {
                    setState(() {
                      _nOexampleTerms = _searchArrayDisplay.length - 1;
                    });
                  },
                ) : IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Color.fromARGB(255, 255, 255, 255),
                  tooltip: 'less search terms',
                  onPressed: () {
                    setState(() {
                      _nOexampleTerms = 9;
                    });
                  },
                ),
                ),
                ]
              );
            } else if (index == (_images.length)) {
              return Column(children: [
                Text(
                      textAlign: TextAlign.center,
                      '${_images.length} loaded (page ${calculatePageNumber(_images.length)-1})', style: TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                    ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                  onTap: () {
                    makeApiRequest(selectedWord);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 224, 224, 224),
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
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 130, 130, 130),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FadeInImage.assetNetwork(
                      placeholder: 'graphics/dark_placeholder_image.jpg',
                      image: _images[index-1]['image'],
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                      'Photographer: ${_images[index-1]['photographer']}\nID: ${_images[index-1]['id']}', style: TextStyle(color: Color.fromARGB(255, 149, 149, 149)),
                  ),
                ),
                const Padding(
                padding: EdgeInsets.all(15.0)

                ),
              ],
              
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