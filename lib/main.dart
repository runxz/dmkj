import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/dosen': (context) => DosenPage(),
        '/announcement': (context) => AnnouncementPage(),
        '/feedback': (context) => FeedbackPage(),
      },
    );
  }
}

class DosenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Dosen Page'),
      ),
      body: Center(
        child: Container(
          width: 480,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
          ),
          child: PageView(
            controller: controller,
            children: const <Widget>[
              Center(
                child: Text('First Page'),
              ),
              Center(
                child: Text('Second Page'),
              ),
              Center(
                child: Text('Third Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Announcement Page'),
      ),
      body: Center(
        child: Container(
          width: 480,
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.blue[50],
          ),
          child: Column(
            children: [
              // Content for the Announcement page here
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Feedback Page'),
      ),
      body: Center(
        child: Container(
          width: 480,
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.blue[50],
          ),
          child: Column(
            children: [
              // Content for the Feedback page here
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchUsername = '';
  List<dynamic> searchResults = [];
  List<String> searchSuggestions = [];
  TextEditingController searchController = TextEditingController();

  Future<void> fetchData(String query) async {
    try {
      setState(() {
        searchResults = [];
      });
      final response = await http.get(
        Uri.parse(
            'https://irch-it.my.id/flutter/search_user.php?username=$query'),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            searchResults = data;
          });
        } else if (data is Map && data.containsKey('error')) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(data['error']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else if (response.statusCode == 404) {
        print('User not found');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User not found'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://irch-it.my.id/flutter/search_suggestions.php?query=$query'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            searchSuggestions = data.cast<String>();
          });
        }
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Mahasiswa TRKJ'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Homepage'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Dosen'),
              onTap: () {
                Navigator.pushNamed(context, '/dosen');
              },
            ),
            ListTile(
              title: Text('Announcement'),
              onTap: () {
                Navigator.pushNamed(context, '/announcement');
              },
            ),
            ListTile(
              title: Text('Feedback'),
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: 480,
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.blue[50],
          ),
          child: Column(
            children: [
              Icon(
                Icons.person,
                color: Colors.blue[800],
                size: 94,
              ),
              Text(
                "Data Mahasiswa TRKJ",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Enter Name or NPM'),
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchUsername = value;
                  });
                  // Call the updateSuggestions function with a delay
                  Future.delayed(Duration(milliseconds: 500), () {
                    updateSuggestions(searchUsername);
                  });
                },
              ),
              // Suggestions ListView
              if (searchSuggestions.isNotEmpty)
                Container(
                  height: 100, // Set an appropriate height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
                  ),
                  child: ListView.builder(
                    itemCount: searchSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          searchSuggestions[index],
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          // Fill the search input with the selected suggestion
                          searchController.text = searchSuggestions[index];
                          // Make the actual search request
                          fetchData(searchSuggestions[index]);
                          // Clear suggestions
                          setState(() {
                            searchSuggestions = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: ElevatedButton(
                  onPressed: () {
                    fetchData(searchUsername);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue[700]),
                  ),
                  child: Text('Search'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipOval(
                                child: Image.network(
                                  searchResults[index]['img_path'],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            SizedBox(height: 8.0),
                            Text(
                              'Nama: ${searchResults[index]['name'] ?? ''}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text('NPM: ${searchResults[index]['npm'] ?? ''}'),
                            Text(
                                'Whatsapp: ${searchResults[index]['whatsapp'] ?? ''}'),
                            Text(
                              'Angkatan: ${searchResults[index]['angkatan'] ?? ''}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              'Hobi: ${searchResults[index]['hobi'] ?? ''}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                                'Quotes: ${searchResults[index]['quotes'] ?? ''}'),
                            SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
