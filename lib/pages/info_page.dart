import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Flat City')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: const Column(
          // Like stacking blocks vertically
          children: [
            Text(
                'This app was designed for the (V05) Mobile Applications event for BPA'),
            SizedBox(height: 28),
            Text(
                'The application allows users to view and create events in their community'),
            SizedBox(height: 28),
            Text('Glacier High School Chapter, Kalispell, Montana'),
          ],
        ),
      ),
    );

/*Padding(
          padding: EdgeInsets.all(20.0), // Add space around the Text
          child: Text('This app was designed for the (V05) Mobile Applications event for BPA\n The application allows users to view and create events in their community\n Glacier High School Chapter, Kalispell, Montana'),
          padding: EdgeInsets.all(20.0),
          child: Text('The application allows users to view and create events in their community'),
          padding: EdgeInsets.all(20.0),
          child: Text('Glacier High School Chapter, Kalispell, Montana'),*/
  }
}
