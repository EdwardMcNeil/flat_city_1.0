import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
//import 'dart.io';
import 'package:logger/logger.dart';

var logger = Logger(level: Level.warning);

class MyApplicationStateInitializer {
  late ApplicationState model;
  late DateTime startDate;
  late DateTime endDate;
  Future<ApplicationState> init() async {
    ApplicationState x = ApplicationState();
    logger.d('waiting for init app');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.d('do rest app');
    await x.initDb().then((m) {
      logger.d('we is done init db');
      model = m;

      // return m;
    });

    return model;
  }
}

MyApplicationStateInitializer myAppState = MyApplicationStateInitializer();

class ApplicationState extends ChangeNotifier {
  ApplicationState() {}
  bool loggedIn = false;
  bool emailVerified = false;
  bool userIsAdmin = false;
  bool iAmInitialized = false;
  String userId = '';
  Future<ApplicationState> initDb() async {
    logger.d('initDb');

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);
    FirebaseAuth.instance.userChanges().listen((user) async {
      logger.d('got user $user');
      if (user != null) {
        if (user.emailVerified) {
          emailVerified = true;
          loggedIn = true;
          if (loggedIn) {
            setUserRole();
          }
        }
      }
      iAmInitialized = true;
      notifyListeners();
    });
    return this;
  }

  void setUserRole() {
    if (emailVerified && loggedIn) {
      String email = FirebaseAuth.instance.currentUser?.email ?? "Nothing";
      if (email == 'tortoise.effendi@gmail.com') {
        userIsAdmin = true;
      }
    }
  }

  String getUserId() {
    String userId = '';
    if (emailVerified && loggedIn) {
      userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }
    logger.d('we got user id $userId');
    return userId;
  }

  String getInitialForCurrentUser() {
    String email = FirebaseAuth.instance.currentUser?.displayName ?? '';
    String result = email.isNotEmpty ? email.substring(0, 1) : 'You';
    return result;
  }

  Future<void> refreshLoggedInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }
    logger.d('waiting for current user refresh');
    await currentUser.reload();
    logger.d('got currentUser refresh');
    userId = currentUser.uid;
    setUserRole();
    logger.d('user role is admin: $userIsAdmin');
  }

  bool userVerified() {
    return loggedIn && emailVerified;
  }
} // end ApplicationState

class Event {
  final String title;
  // final String date;
  final String location;
  final String description;
  final String? imageUrl;
  late String? userId;
  late DateTime? startDate;
  late DateTime? endDate;
  late Timestamp? tStart;
  late Timestamp? tEnd;

  Event({
    required this.title,
    // equired this.date,
    required this.location,
    required this.description,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.userId,
    this.tStart,
    this.tEnd,
  });

  Event.fromJson(Map<String, Object?> json)
      : this(
            title: json['title'] as String,

            /// date: json['date'] as String,
            location: json['location'] as String,
            description: json['description'] as String,
            imageUrl: json['imageUrl'] as String?,
            userId: json['userId'] as String?,
            tStart: json['startDate'] as Timestamp,
            tEnd: json['endDate'] as Timestamp);

  Map<String, Object?> toJson() {
    return {
      // Event details
      'title': title,
      // 'date': date,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

List<Event> events = [
  Event(
    title: 'Community Hackathon',
    // date: '2024-11-25',
    location: 'Kalispell, Montana',
    description:
        'Join us for a day of hacking and learning with fellow Flutter developers.',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-11-25 08:00:00'),
    endDate: DateTime.parse('2024-11-25 12:00:00'),
  ),
  Event(
    title: 'Flutter Meetup',
    // date: '2024-12-02',
    location: 'Whitefish, Montana',
    description:
        'Come network with other Flutter enthusiasts and learn about the latest developments.',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-12-02 10:00:00'),
    endDate: DateTime.parse('2024-12-02 13:00:00'),
  ),
  Event(
    title: 'Flutter Workshop',
    // date: '2024-12-09',
    location: 'Columbia Falls, Montana',
    description:
        'Get hands-on experience with Flutter in this beginner-friendly workshop.',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-10-23 11:00:00'),
    endDate: DateTime.parse('2024-10-23 15:00:00'),
  ),
  Event(
    title: 'Chess Club',
    // date: '2024-11-25',
    location: 'Sommers, Montana',
    description: 'Learn Chess with our local Grandmaster',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-11-24 10:00:00'),
    endDate: DateTime.parse('2024-11-24 14:00:00'),
  ),
  Event(
    title: 'BBQ Night-Out',
    // date: '2024-6-02',
    location: 'Kalispell, Montana',
    description: 'Free Steak and Burgers',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-08-18 15:00:00'),
    endDate: DateTime.parse('2024-08-18 17:00:00'),
  ),
  Event(
    title: 'Moutain Ski Trip',
    // date: '2024-5-09',
    location: 'Whitefish, Montana',
    description: 'Join us at Big Mountain for an allday ski trip',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-12-26 08:00:00'),
    endDate: DateTime.parse('2024-12-26 17:00:00'),
  ),
  Event(
    title: 'Music Festival',
    // date: '2024-4-25',
    location: 'Kalispell, Montana',
    description: 'Hosted by the local high schools',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-07-18 11:00:00'),
    endDate: DateTime.parse('2024-07-18 17:00:00'),
  ),
  Event(
    title: 'Play Rehearsal',
    // date: '2024-12-02',
    location: 'Kalispell, Montana',
    description: 'Peter Pan by elementary students',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-09-25 13:00:00'),
    endDate: DateTime.parse('2024-09-25 16:00:00'),
  ),
  Event(
    title: 'Fleching Lessons',
    // date: '2024-12-09',
    location: 'Eureka, Montana',
    description: 'Learn how to make a bow for free!',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-11-25 10:00:00'),
    endDate: DateTime.parse('2024-11-25 13:00:00'),
  ),
  Event(
    title: 'Around the Lake Marathon',
    // date: '2024-11-25',
    location: 'Sommers, Montana',
    description: 'Run 26.2 miles within a day',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-08-29 07:00:00'),
    endDate: DateTime.parse('2024-08-29 17:00:00'),
  ),
  Event(
    title: 'Community Cleanup',
    // date: '2025-1-02',
    location: 'Whitefish, Montana',
    description: 'Help pickup garbage around the community.',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-05-25 16:00:00'),
    endDate: DateTime.parse('2024-05-25 20:00:00'),
  ),
  Event(
    title: 'Bake Sale',
    // date: '2024-4-09',
    location: 'Kalispell, Montana',
    description: 'Meet at the local health club for charity work.',
    imageUrl: 'https://via.placeholder.com/300x200',
    startDate: DateTime.parse('2024-04-17 10:00:00'),
    endDate: DateTime.parse('2024-04-17 14:00:00'),
  ),
];

final allEventsCollection =
    FirebaseFirestore.instance.collection('user').withConverter<Event>(
          fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
          toFirestore: (event, _) => event.toJson(),
        );

final eventsCollection = FirebaseFirestore.instance
    .collection('user')
    .withConverter<Event>(
      fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
      toFirestore: (event, _) => event.toJson(),
    )
    .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
    .orderBy('endDate');

Future<DocumentReference> addEvent(Event event) async {
  DocumentReference doc = await allEventsCollection.add(event).then((result) {
    logger.d('We added an event with results $result');
    return result;
  });
  return doc;
}

void oneTime(String userId) async {
  for (Event e in events) {
    e.userId = userId;
    var result = await addEvent(e);
    logger.d('oneTime got result $result');
  }
}
