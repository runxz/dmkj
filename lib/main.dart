import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
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

class Dosen {
  final String nidn;
  final String name;
  final String jabatanFungsional;
  final String pendidikanTertinggi;
  final String img;
  final String short_biography;
  final String whatsapp;

  Dosen({
    required this.nidn,
    required this.name,
    required this.jabatanFungsional,
    required this.pendidikanTertinggi,
    required this.img,
    required this.short_biography,
    required this.whatsapp,
  });
}

class Education {
  final String nidn;
  final String perguruanTinggi;
  final String gelar;
  final String tanggalIjazah;
  final String jenjang;

  Education({
    required this.nidn,
    required this.perguruanTinggi,
    required this.gelar,
    required this.tanggalIjazah,
    required this.jenjang,
  });
}

class DosenPage extends StatefulWidget {
  @override
  _DosenPageState createState() => _DosenPageState();
}

class _DosenPageState extends State<DosenPage> {
  List<Dosen> dosenList = [];
  List<Education> educationList = [];
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://irch-it.my.id/flutter/api.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dosenList = (data['dosen'] as List)
            .map((item) => Dosen(
                  nidn: item['nidn'],
                  name: item['name'],
                  jabatanFungsional: item['jabatan_fungsional'],
                  pendidikanTertinggi: item['pendidikan_tertinggi'],
                  img: item['img'],
                  short_biography: item['short_biography'],
                  whatsapp: item['whatsapp'],
                ))
            .toList();

        educationList = (data['educations'] as List)
            .map((item) => Education(
                  nidn: item['nidn'],
                  perguruanTinggi: item['perguruan_tinggi'],
                  gelar: item['gelar'],
                  tanggalIjazah: item['tanggal_ijazah'],
                  jenjang: item['jenjang'],
                ))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dosen Page'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: dosenList.length,
        itemBuilder: (context, index) {
          final dosen = dosenList[index];
          final relatedEducations =
              educationList.where((edu) => edu.nidn == dosen.nidn).toList();
          return DosenCard(dosen: dosen, educations: relatedEducations);
        },
      ),
    );
  }
}

class DosenCard extends StatelessWidget {
  final Dosen dosen;
  final List<Education> educations;

  DosenCard({required this.dosen, required this.educations});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '${dosen.name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIDN: ${dosen.nidn}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Jabatan Fungsional: ${dosen.jabatanFungsional}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Pendidikan Tertinggi: ${dosen.pendidikanTertinggi}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      child: ClipOval(
                        child: Image.network(
                          'https://irch-it.my.id/flutter/uploads/' + dosen.img,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Short Biography:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      '${dosen.short_biography}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Education Data:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Allow horizontal scrolling
                    child: DataTable(
                      columnSpacing: 20, // Adjust column spacing as needed
                      columns: [
                        DataColumn(label: Text('Perguruan Tinggi')),
                        DataColumn(label: Text('Gelar')),
                        DataColumn(label: Text('Tanggal Ijazah')),
                        DataColumn(label: Text('Jenjang')),
                      ],
                      rows: educations
                          .map(
                            (edu) => DataRow(
                              cells: [
                                DataCell(Text(edu.perguruanTinggi)),
                                DataCell(Text(edu.gelar)),
                                DataCell(Text(edu.tanggalIjazah)),
                                DataCell(Text(edu.jenjang)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16, // Adjust the position as needed
            right: 16, // Adjust the position as needed
            child: FloatingActionButton(
              onPressed: () async {
                final whatsappNumber = dosen.whatsapp;
                print(whatsappNumber);
                final message = 'Assalamualaikum wr.wb';
                final uri = Uri.parse(
                    'https://wa.me/$whatsappNumber?text=${Uri.encodeFull(message)}');
                print('URL: $uri');
                try {
                  await launchUrl(uri); // Directly launch the URL
                } catch (e) {
                  print('Error launching URL: $e');
                  // Handle the error and display an appropriate message to the user
                }
              },
              backgroundColor: Colors.green, // Customize the button color
              child: Icon(Icons.chat),
            ),
          ),
        ],
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

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<void> _submitFeedback(BuildContext context) async {
    final name = nameController.text;
    final message = messageController.text;

    final response = await http.post(
      Uri.parse('https://irch-it.my.id/flutter/feedback.php'),
      body: {
        'name': name,
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      // Display a pop-up message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback submitted!'),
        ),
      );

      // Clear the form fields
      nameController.clear();
      messageController.clear();
    } else {
      // Handle the error.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback.'),
        ),
      );
    }
  }

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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
          ),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Message'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _submitFeedback(context),
                child: Text('Submit'),
              ),
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
        searchSuggestions = [];
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
                title: Text('Dosen'),
                onTap: () {
                  Navigator.pushNamed(context, '/dosen');
                },
              ),
              /* ListTile(
                title: Text('Announcement'),
                onTap: () {
                  Navigator.pushNamed(context, '/announcement');
                },
              ),*/
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
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blue[800],
                  size: 94,
                ),
                Text(
                  "Data Mahasiswa TRKJ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 2.0)
                      ],
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
                ElevatedButton(
                  onPressed: () {
                    fetchData(searchUsername);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue[700]),
                  ),
                  child: Text('Search'),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: false,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        searchResults[index]['img_path'],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${searchResults[index]['angkatan'] ?? ''}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama: ${searchResults[index]['name'] ?? ''}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'NPM: ${searchResults[index]['npm'] ?? ''}',
                                  ),
                                  Text(
                                    'Hobi: ${searchResults[index]['hobi'] ?? ''}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    'Quotes: ${searchResults[index]['quotes'] ?? ''}',
                                  ),
                                  SizedBox(height: 8.0),
                                  // Create a WhatsApp link based on the 'whatsapp' field
                                  if (searchResults[index]['whatsapp'] != null)
                                    Row(
                                      children: [
                                        Icon(Icons.phone, color: Colors.green),
                                        SizedBox(width: 4.0),
                                        TextButton(
                                          onPressed: () async {
                                            final whatsappNumber =
                                                searchResults[index]
                                                    ['whatsapp'];
                                            final message =
                                                'Assalamualaikum wr.wb';
                                            final uri = Uri.parse(
                                                'https://wa.me/$whatsappNumber?text=${Uri.encodeFull(message)}');
                                            print('URL: $uri');
                                            try {
                                              await launchUrl(
                                                  uri); // Directly launch the URL
                                            } catch (e) {
                                              print('Error launching URL: $e');
                                              // Handle the error and display an appropriate message to the user
                                            }
                                          },
                                          child: Text('WhatsApp'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
