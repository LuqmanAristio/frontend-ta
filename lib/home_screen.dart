import 'package:flutter/material.dart';
import 'melody_extraction_yt.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.0), 
              Image.asset(
                'assets/logo_color.png',
                width: 200.0,
                height: 150.0,
                fit: BoxFit.contain,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8, 
                child: Text(
                  'Aplikasi deteksi kemiripan musik berdasarkan melodi',
                  textAlign: TextAlign.center, 
                   style: TextStyle(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter', 
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    transform: Matrix4.translationValues(-150, 30, 0),
                    width: 450.0, 
                    height:450.0, 
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x66819CFF),
                    ),
                  ),
                  Container(
                    width: 350.0,
                    height: 400.0,
                    child: Image.asset(
                      'assets/hero.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
               SizedBox(height: 30.0), 
               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MelodyExtractionScreen()),
                  );
                },
                child: Text('Next', style: TextStyle(fontSize: 18.0, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Color(0x66819CFF),
                ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}