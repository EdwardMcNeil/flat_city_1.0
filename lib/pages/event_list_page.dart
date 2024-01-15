import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../db/events.dart';
import 'package:logger/logger.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

// A debug tool for printing to the terminal
var logger = Logger(level: Level.warning);

// Main hierarchical class of this page
class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

// Updates the output
class _EventsListPageState extends State<EventsListPage> {
  MyApplicationStateInitializer applicationStateInitializer =
      MyApplicationStateInitializer();
  void refreshMe() {
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   logger.w('in init state');
  // }
// Main Graphical Output
  @override
  Widget build(BuildContext context) {
    logger.d(
        'app state model userVerified returns: ${myAppState.model.userVerified()}');
    return Scaffold(
      appBar: AppBar(
        // Title
        title: const Text('FlatCity Events'),
        actions: [
          Visibility(
            // Only visible to users who have signed in
            visible: myAppState.model.userVerified(),
            child: ElevatedButton(
              onPressed: () {
                // logger.e('remove me');
                // oneTime(myAppState.model.getUserId());
                // The "plus" icon in the upper right to add an event
                context.push('/add');
              },
              //child: const Text('Add Event'),
              child: const Icon(Icons.add),
            ),
          ),
          Visibility(
            visible: myAppState.model.userVerified(),
            child: ElevatedButton(
              onPressed: () {
                // The profile icon in the upper right corner leading to information of the user
                context.push('/profile');
              },
              //child: const Text('Add Event'),
              child: const Icon(Icons.verified_user),
            ),
          ),
          Visibility(
            // Sign in button for user if the user has not signed in yet
            visible: !myAppState.model.userVerified(),
            child: ElevatedButton(
              onPressed: () {
                context.push('/sign-in');
              },
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
      // Referencing the database for event details
      body: FirestoreListView<Event>(
        query: eventsCollection,
        pageSize: 10,
        itemBuilder: (context, snapshot) {
          Event event = snapshot.data();
          // Converting to proper type of data for the Date property of the events
          event.startDate = event.tStart!.toDate();
          event.endDate = event.tEnd!.toDate();
          // Coverting format of the date property of events
          DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
          String startFormattedDate = formatter.format(event.startDate!);
          String endFormattedDate = formatter.format(event.endDate!);
          // Formatting
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Text Output
                  const SizedBox(height: 8),
                  Text('Start: $startFormattedDate'),
                  const SizedBox(height: 8),
                  Text('End: $endFormattedDate'),
                  const SizedBox(height: 8),
                  Text('Location: ${event.location}'),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 8),
                  // -- event.imageUrl.isNotEmpty
                  // --     ? Image.network(event.imageUrl)
                  // --     : const Text('')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
