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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

bool isPlaying = false;
bool isDataLoaded= false;
String urlGoogleAudio = '';

class MusicPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const MusicPlayerWidget({required this.audioPlayer});

  @override
  _MusicPlayerWidgetState createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  Duration _duration = Duration();
  Duration _position = Duration();
  double _progress = 0.0;
  late String audioFilePath;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    widget.audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
        _progress = _position.inMilliseconds / _duration.inMilliseconds;
      });
    });

    widget.audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _position = Duration();
        _progress = 0.0;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void playPause() {
    if (isPlaying) {
      widget.audioPlayer.pause();
    } else if(!isPlaying && _position.inMilliseconds == 0) {
      widget.audioPlayer.play(
        UrlSource(urlGoogleAudio),
        volume: 1.0, 
      );
    }
    else{
      widget.audioPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void stop() {
    widget.audioPlayer.stop();

    setState(() {
        isPlaying = false;
        _position = Duration();
        _progress = 0.0;
      });
  }

  Future<void> downloadAudio() async {
  setState(() {
    isDownloading = true;
  });

  final http.Response response = await http.get(Uri.parse(urlGoogleAudio));

  if (response.statusCode == 200) {
      final String downloadsPath = '/storage/emulated/0/Download';

      // Generate random filename
      String randomString = getRandomString(10); // You can adjust the length as needed
      final File file = File('$downloadsPath/ytmelody_$randomString.wav');

      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        audioFilePath = file.path;
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio downloaded successfully in /Download/ytmelody_$randomString.wav'),
        ),
      );
    } else {
      // Tampilkan pesan kesalahan jika unduhan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download audio'),
        ),
      );
    }
  }

  // Function to generate a random string
  String getRandomString(int length) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(length, (index) => charset[random.nextInt(charset.length)]).join();
  }

    Future<void> requestStoragePermission() async {
      setState(() {
        isDownloading = true;
      });

      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (status.isGranted) {
        downloadAudio();
      } else {
        setState(() {
          isDownloading = true;
        });
        print('Izin penyimpanan ditolak');
      }
    }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 0.0),
        Text(
          'Duration : ${_formatDuration(_position)} / ${_formatDuration(_duration)}',
          style: TextStyle(fontSize: 14.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Slider(
                value: _position.inMilliseconds.toDouble(),
                max: _duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  widget.audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: Colors.blue, 
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: EdgeInsets.all(0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(10.0), 
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 30.0, 
                          color: Colors.grey, 
                        ),
                        onPressed: () {
                          playPause();
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Padding(
                      padding: EdgeInsets.all(0), 
                      child: IconButton(
                        icon: Icon(
                          Icons.stop,
                          size: 30.0, 
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          stop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  downloadAudio();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.green, 
                ),
                child: SizedBox( 
                  child: isDownloading 
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 26),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.065,
                          height: MediaQuery.of(context).size.width * 0.065,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0), 
                          child: Text(
                            'Download',
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}

class MelodyFilePage extends StatefulWidget {
  @override
  _MelodyFilePageState createState() => _MelodyFilePageState();
}

class _MelodyFilePageState extends State<MelodyFilePage> {
  String? youtubeUrl;
  late String audioUrl;
  TextEditingController textEditingController = TextEditingController();
  bool isSucess = false;
  bool isLoading = false;
  String errorString = "None";
  AudioPlayer player = AudioPlayer();
  late File _audioFile = File('');

  int _selectedIndex = 1;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    print(index);

    switch (index) {
      case 0:
        _navigateToPage(PredictionPage());
        break;
      case 1:
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

  bool isValidYoutubeUrl(String url) {
    RegExp regex = RegExp(
        r"^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$",
        caseSensitive: false);
    return regex.hasMatch(url);
  }

  void stop() {
    if (isPlaying) {
      player.stop();
      setState(() {
        isPlaying = false;
      });
    }
  }

    Future<void> fetchAndPlayAudio() async {
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

      stop();

      String url = 'http://34.128.77.135:8000/api/convert/'; 

      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('audio_file', _audioFile!.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();

          var jsonResponse = jsonDecode(responseBody);

          var audioUrl = jsonResponse['audio_url'];

          setState(() {
            urlGoogleAudio = audioUrl;
          });

          play();
          setState(() {
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

    void play() async {
      setState(() {
        isPlaying = true;
      });
      player = AudioPlayer();
      await player.play(UrlSource(urlGoogleAudio));
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
                'Melody Extraction',
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
                      'assets/music.png',
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
                            allowedExtensions: ['wav', 'mp3'], 
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
                  fetchAndPlayAudio();
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
                MusicPlayerWidget(audioPlayer: player)
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
