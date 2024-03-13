import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'dart:io';
import 'about.dart'; 
import 'prediction.dart';
import 'melody_extraction_yt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:convert'; 
import 'melody_extraction_file.dart';

bool isDataLoaded= false;

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  late File _audioFile = File('');
  int _selectedIndex = 0;
  bool isLoading = false;
  String errorString = "None";
  String songTitle = "";
  String singerName = "";
  String youtubeLinkVideo = "";

  @override
  void initState() {
    super.initState();
    isDataLoaded = false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    print(index);

    switch (index) {
        case 0:
          break;
        case 1:
          _navigateToPage(MelodyFilePage());
          break;
        case 2:
          _navigateToPage(MelodyExtractionScreen());
          break;
        case 3:
          _navigateToPage(AboutPage());
          break;
        default:
          break;
      }
    }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = 0.0;
          var end = 1.0;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> predictionResult() async {
      if(isLoading){
        setState(() {
            isLoading = !isLoading;
        });
      }

      if (_audioFile?.path == '') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("No File Selected"),
              content: Text("Please select an audio file."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        setState(() {
          isLoading = !isLoading;
        });
        return;
      }

      String url = 'http://34.128.77.135:8000/api/predict/'; 

      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('audio_file', _audioFile!.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();

          var jsonResponse = jsonDecode(responseBody);

          var predictions = jsonResponse['prediction'] as List;

          // Ambil nilai terbesar dan indeksnya dari prediksi
          double maxPredictionValue = predictions[0].reduce((value, element) => value > element ? value : element);
          int maxPredictionIndex = predictions[0].indexOf(maxPredictionValue);

          setState(() {
            switch (maxPredictionIndex) {
              case 0:
                singerName = 'Justin Bieber';
                songTitle = 'Love Yourself';
                youtubeLinkVideo = 'https://youtu.be/oyEuk8j8imI?si=FWB2WrSGL2YWX-9Z';
                break;
              case 1:
                singerName = 'John Legend';
                songTitle = 'All of Me';
                youtubeLinkVideo = 'https://youtu.be/450p7goxZqg?si=mL7OzMq0yM6Q2UOy';
                break;
              case 2:
                singerName = 'Adele';
                songTitle = 'Hello';
                youtubeLinkVideo = 'https://youtu.be/YQHsXMglC9A?si=ZChbgP3sPW1Bkjwq';
                break;
              case 3:
                singerName = 'Ellie Goulding';
                songTitle = 'Love Me Like You Do';
                youtubeLinkVideo = 'https://youtu.be/AJtDXIazrMo?si=akQd7-ARpIqclQi0';
                break;
              case 4:
                singerName = 'Ed Sheeran';
                songTitle = 'Perfect';
                youtubeLinkVideo = 'https://youtu.be/2Vv-BfVoq4g?si=2OXE20Cc1Y7QsW62';
                break;
              default:
                break;
            }
            isDataLoaded = true;
          });
        } else {
          print('Error: ${response.reasonPhrase}');
          setState(() {
            errorString = 'Error: ${response.reasonPhrase}';
          });
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Exception: $e');
        setState(() {
          isLoading = false;
          errorString = 'Server not responding';
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo_color.png',
                width: 200.0,
                height: 120.0,
                fit: BoxFit.contain,
              ),
              Text(
                'Model Prediction',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 50.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/music_predict.png',
                      width: 30.0,
                      height: 30.0,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 15.0), 
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      color: Colors.grey.withOpacity(0.4), // Warna latar belakang abu
                      child: TextButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['wav'], 
                            allowMultiple: false,
                          );
                          if (result != null) {
                            setState(() {
                              _audioFile = File(result.files.single.path!);
                            });
                          }
                        },
                        child: Text(
                          _audioFile.path == '' ? 'Choose Audio File' : path.basename(_audioFile.path),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  predictionResult();
                  setState(() {
                    isLoading = !isLoading;
                  });
                  setState(() {
                    isDataLoaded = false;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.855,
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3C89), Color(0xFF3F72AF)], // Warna gradient
                    ),
                  ),
                  child: Text(
                    'Process',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0), 
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), 
                ),
              ),
              
              SizedBox(height: 40.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF1b4965), 
                  borderRadius: BorderRadius.circular(5.0), 
                ),
                padding: EdgeInsets.all(8.0), 
                child: Text(
                  'Result',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255),),
                ),
              ),
              SizedBox(height: 30.0),
              if (!isLoading && isDataLoaded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0), // Padding di kiri dan kanan teks
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // Mengatur teks menjadi rata kiri
                    children: [
                      Text(
                        'Judul Lagu',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                      Text(
                        '$songTitle',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Penyanyi',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                      Text(
                        '$singerName',
                        style: TextStyle(
                          fontSize: 17.0,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Youtube Link',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                      Text(
                        '$youtubeLinkVideo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17.0,
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1), 
                        ),
                      ),
                    ],
                  ),
                )
              else if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue, 
                    strokeWidth: 2.0, 
                  ),
                )
              else if (!isDataLoaded && !isLoading)
                Text(
                  errorString,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey.withOpacity(0.8), 
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Atur warna ikon menjadi abu
            label: 'Prediction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file), // Atur warna ikon menjadi abu
            label: 'File Extract',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline), // Atur warna ikon menjadi abu
            label: 'Youtube Extract',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline), // Atur warna ikon menjadi abu
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Atur warna item yang dipilih menjadi biru
        unselectedItemColor: Colors.grey, // Atur warna teks dan ikon yang tidak dipilih menjadi abu
        elevation: 8, // Atur tinggi bayangan di sisi atas
        onTap: _onItemTapped,
      ),
    );
  }
}
