import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool isPlaying = false;
bool isDataLoaded= false;

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
        UrlSource('https://storage.googleapis.com/melatec/ytmelody.wav'),
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
        isDownloading = true; // Mulai unduhan, atur nilai isDownloading menjadi true
      });
      
      const String audioUrl = 'https://storage.googleapis.com/melatec/ytmelody.wav';
      final http.Response response = await http.get(Uri.parse(audioUrl));

      if (response.statusCode == 200) {
        final String downloadsPath = '/storage/emulated/0/Download';

        // Simpan audio ke direktori unduhan
        final File file = File('$downloadsPath/ytmelody.wav');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          audioFilePath = file.path;
          isDownloading = false;
        });

        // Beri notifikasi bahwa unduhan telah selesai
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio downloaded successfully in /Download/ytmelody.wav'),
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
          padding: EdgeInsets.all(0), // Padding di sekitar tombol
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2), // Warna latar belakang dengan opacity 20%
                  borderRadius: BorderRadius.circular(10.0), // Bentuk ikon
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.0), // Atur padding sesuai kebutuhan Anda
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 30.0, // Ukuran ikon
                          color: Colors.grey, // Warna ikon abu
                        ),
                        onPressed: () {
                          playPause();
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Padding(
                      padding: EdgeInsets.all(0), // Atur padding sesuai kebutuhan Anda
                      child: IconButton(
                        icon: Icon(
                          Icons.stop,
                          size: 30.0, // Ukuran ikon
                          color: Colors.grey, // Warna ikon abu
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
                  // Implementasi logika untuk tombol download
                  downloadAudio();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.green, // Warna latar belakang tombol download
                ),
                child: SizedBox( // Lebar tetap untuk tombol download
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
                          padding: EdgeInsets.symmetric(vertical: 16.0), // Atur padding atas dan bawah sesuai kebutuhan Anda
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

class MelodyExtractionScreen extends StatefulWidget {
  @override
  _MelodyExtractionScreenState createState() => _MelodyExtractionScreenState();
}

class _MelodyExtractionScreenState extends State<MelodyExtractionScreen> {
  String? youtubeUrl;
  late String audioUrl;
  TextEditingController textEditingController = TextEditingController();
  bool isSucess = false;
  bool isLoading = false;
  String errorString = "None";
  AudioPlayer player = AudioPlayer();

  bool isValidYoutubeUrl(String url) {
    // Regex pattern untuk URL YouTube
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

      if (textEditingController.text.isEmpty ||
          !isValidYoutubeUrl(textEditingController.text)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Invalid URL"),
              content: Text("Please enter a valid YouTube URL."),
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
        final response = await http.post(Uri.parse(url), body: {'youtube_url': textEditingController.text});
        final String responseBody = response.body;

        bool cek = responseBody.contains('error');
        
        if (response.statusCode == 200 && !cek) {
          play();
          setState(() {
            isDataLoaded = true;
          });

        } else {
          print('Error: ${response.body}');
          setState(() {
            errorString = 'Video not found';
          });
        }

        setState(() {
            isLoading = !isLoading;
        });

      } catch (e) {
        setState(() {
            isLoading = !isLoading;
        });
        print('Exception: $e');
        setState(() {
            errorString = 'Server not responding';
        });
      }
    }

    void play() async {
      setState(() {
        isPlaying = true;
      });
      player = AudioPlayer();
      await player.play(UrlSource('https://storage.googleapis.com/melatec/ytmelody.wav'));
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
                      'assets/youtube.png',
                      width: 30.0,
                      height: 30.0,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 15.0), 
                    TextFormField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        labelText: 'Input URL youtue disini',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintStyle: TextStyle(fontSize: 16.0),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
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
                  elevation: MaterialStateProperty.all(0), // Hilangkan bayangan ketika tombol ditekan
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), // Hapus warna latar belakang agar gradient bisa terlihat
                ),
              ),
              
              SizedBox(height: 40.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFF1b4965), // Warna latar belakang teks
                  borderRadius: BorderRadius.circular(5.0), // Untuk memberikan sudut melengkung pada background
                ),
                padding: EdgeInsets.all(8.0), // Padding untuk teks di dalam kontainer
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
                    color: Colors.blue, // Warna indikator loading
                    strokeWidth: 2.0, // Lebar indikator loading
                  ),
                )
              else if (!isDataLoaded && !isLoading)
                Text(
                  errorString,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey.withOpacity(0.8), // Warna abu dengan tingkat kejernihan 80%
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}
