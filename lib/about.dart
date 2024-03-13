import 'package:flutter/material.dart';
import 'melody_extraction_file.dart';
import 'melody_extraction_yt.dart';
import 'prediction.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  int _selectedIndex = 3;

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


    switch (index) {
        case 0:
          _navigateToPage(PredictionPage());
          break;
        case 1:
          _navigateToPage(MelodyFilePage());
          break;
        case 2:
          _navigateToPage(MelodyExtractionScreen());
          break;
        case 3:
          break;
        default:
          break;
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                  'About & Tutorial',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 50.0),

                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                Text(
                  'Application Name',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5.0),
                Text(
                  'Melody Similarity Detection (Melatec)',
                  style: TextStyle(fontSize: 16.0),
                ),

                SizedBox(height: 30.0),
                Text(
                  'Version',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5.0),
                Text(
                  '1.0.0',
                  style: TextStyle(fontSize: 16.0),
                ),

                SizedBox(height: 30.0),
                Text(
                  'Developer',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5.0),
                Text(
                  'Muhammad Luqman Aristio',
                  style: TextStyle(fontSize: 16.0),
                ),

                SizedBox(height: 30.0),
                Text(
                  'Copyright',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5.0),
                Text(
                  'Melody Similarity Detection',
                  style: TextStyle(fontSize: 16.0),
                ),


                SizedBox(height: 50.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'Tutorial',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.0),
                      Text(
                        '1. Siapkan file audio musik dalam format .wav ataupun .mp3 atau dapat menggunakan URL youtube. Kemudian masuk ke menu sesuai dengan metode yang dipilih',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about1.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '2. Untuk menu file extract, upload file audio yang sudah disiapkan kemudian klik tombol Process. Tunggu proses ekstraksi beberapa menit hingga loading selesai',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about2.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '3. Sama halnya dengan menu file extract, pada menu youtube extract juga hanya perlu memasukan URL atau link dari video yang akan diproses. Kemudian klik tombol Process',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about3.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '4. Setelah proses selesai, maka akan tampil sebuah player audio yang merupakan hasil ekstraksi melodinya. Anda bisa memutar audio dan mendownloadnya juga',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about4.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '5. Kemudian, masuk ke menu prediction. Disini pengguna tinggal mengupload file audio hasil ekstraksi melodi dan menekan tombol Predict. Tunggu beberapa saat hingga selesai',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about5.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        '6. Terakhir, setelah proses sebelumnya selesai, akan muncul hasil prediksi file musik tersebut berupa judul musik beserta penyanyi aslinya.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Image.asset(
                        'assets/about6.png', 
                        // width: 100.0,
                        // height: 100.0,
                      ),
                      SizedBox(height: 40.0),
                    ],
                  ),
                )
              ],
            ),
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
