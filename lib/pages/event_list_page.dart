import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../db/events.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'dart:async';

// A debug tool for printing to the terminal
var logger = Logger(level: Level.warning);

// Main hierarchical class of this page
class EventsListPage extends StatefulWidget {
  EventsListPage({super.key, required this.searchString});
  String searchString = '';
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

  bool doSearch = false;
  bool refresh = false;
  // @override
  // void initState() {
  //   super.initState();
  //   logger.w('in init state');
  // }
// Main Graphical Output

  // Getting the events that have not expired only and ordered by most recent date
  // var eventsCollection = FirebaseFirestore.instance
  //     .collection('user')
  //     .withConverter<Event>(
  //       fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
  //       toFirestore: (event, _) => event.toJson(),
  //     )
  //     .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
  //     .orderBy('endDate');
//
  final searchController = TextEditingController();

  Future<String?> showSearchDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Search Term'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'What do you want to search for?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                doSearch = false;
                logger.d(
                    'do something with search string ${searchController.text} in where clause');
                //theUserListView.query;

                // eventsCollection = FirebaseFirestore.instance
                //     .collection('user')
                //     .withConverter<Event>(
                //       fromFirestore: (snapshot, _) =>
                //           Event.fromJson(snapshot.data()!),
                //       toFirestore: (event, _) => event.toJson(),
                //     )
                //     .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
                //     .where(Filter.or(
                //       Filter("title",
                //           isGreaterThanOrEqualTo: searchController.text),
                //       Filter("location",
                //           isGreaterThanOrEqualTo: searchController.text),
                //       Filter("description",
                //           isGreaterThanOrEqualTo: searchController.text),
                //     ))
                //     .orderBy('endDate');
                myAppState.model.setSearchString(searchController.text);
                // not working setState(() {});
                // Navigator.pop(context, searchController.text);

                // context.push('/');
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.searchString = myAppState.model.getSearchString();
    var eventsCollection = FirebaseFirestore.instance
        .collection('user')
        .withConverter<Event>(
          fromFirestore: (snapshot, _) => Event.fromJson(snapshot.data()!),
          toFirestore: (event, _) => event.toJson(),
        )
        .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
        // .where(Filter.or(
        //   Filter("title", isGreaterThanOrEqualTo: widget.searchString),
        //   Filter("location", isGreaterThanOrEqualTo: widget.searchString),
        //   Filter("description", isGreaterThanOrEqualTo: widget.searchString),
        // ))
        //.where('title',
        //    isGreaterThanOrEqualTo: myAppState.model.getSearchString())
        .orderBy('endDate');

    late FirestoreListView<Event> theUserListView;

    Widget myFirestoreListView() {
      theUserListView = FirestoreListView<Event>(
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
          bool displayThisEvent =
              event.description.contains(widget.searchString) ||
                  event.title.contains(widget.searchString) ||
                  event.location.contains(widget.searchString);

          Widget theResult = !displayThisEvent
              ? Text('')
              : Card(
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
                        Text('contact: ${event.email}'),
                        if (event.email != '') const SizedBox(height: 8),
                        if (event.url != null && event.url != '')
                          Text('url: ${event.url}'),
                        // -- event.imageUrl.isNotEmpty
                        // --     ? Image.network(event.imageUrl)
                        // --     : const Text('')
                      ],
                    ),
                  ),
                );
          return theResult;
        },
      );
      return theUserListView;
    }

    logger.d(
        'app state model userVerified returns: ${myAppState.model.userVerified()}');
    if (refresh) {
      setState(() {});
      refresh = false;
    }
    return Scaffold(
      appBar: AppBar(
        // Title
        title: doSearch ? const Text('Search') : const Text('FlatCity Events'),
        actions: [
          // Visibility(
          //   visible: !myAppState.model.userVerified() && doSearch,
          //   child: TextField(
          //     controller: searchController,
          //     decoration: const InputDecoration(
          //       hintText: 'Search for items...',
          //     ),
          //     onChanged: (searchText) {
          //       // Call your search function here
          //       logger.w('We got $searchText');
          //       doSearch = false;
          //       setState(() {});
          //     },
          //   ),
          // ),
          Visibility(
            // Only visible to users who have signed in
            visible: true,
            child: IconButton(
              onPressed: () async {
                // logger.e('remove me');
                // oneTime(myAppState.model.getUserId());
                // The "plus" icon in the upper right to add an event
                await showSearchDialog(context);
                setState(() {});
              },
              //child: const Text('Add Event'),
              icon: myAppState.model.getSearchString() == ''
                  ? const Icon(Icons.search)
                  : const Icon(Icons.filter_alt),
            ),
          ),
          Visibility(
            // Only visible to users who have signed in
            visible: myAppState.model.userVerified(),
            child: IconButton(
              onPressed: () {
                // logger.e('remove me');
                // oneTime(myAppState.model.getUserId());
                // The "plus" icon in the upper right to add an event
                context.push('/add');
              },
              //child: const Text('Add Event'),
              icon: const Icon(Icons.add),
            ),
          ),
          Visibility(
            visible: myAppState.model.userVerified(),
            child: IconButton(
              onPressed: () {
                // The profile icon in the upper right corner leading to information of the user
                context.push('/profile');
              },
              //child: const Text('Add Event'),
              icon: const Icon(Icons.verified_user_outlined),
            ),
          ),
          Visibility(
            visible: myAppState.model.userVerified(),
            child: IconButton(
              onPressed: () {
                // The profile icon in the upper right corner leading to information of the user
                context.push('/info');
              },
              icon: const Icon(Icons.info_outline),
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
      body: myFirestoreListView(),
    );
  }
}
