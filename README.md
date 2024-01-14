# flathead_county_community_events

## Developer: Edward McNeil

## Description:
This application was developed for the (V05) Mobile Applications event of Business Professionals of America. 
This project is a pseudo-social media application allowing users to view and create events for their local community.       

## Design Concept
The design concept of this app was to utilize the default framework of Dart/Flutter, Firebase and conversational generative A.I. to develop components of this application. 
The application was designed to mimic a social-media platform and designed with information security in mind (authentication; TODO: Text Scan using Google Moderation API).
This app contains multiple components such as a login screen, event view page, and create event page. 
Users are able to see all the events created before them, but they must login in order to create events of their own. 
The user logs into this app by providing their email and creating a password, password reset are available with email verification. 
Login credentials are stored in Google Firebase authentication.
The graphical user interface (GUI) is designed to be a scrollable list for the ease of the user. 

## Source Code
To protect the API keys in this public repository, the Android, IOS build directories are deleted along with the Firebase_options.dart API key file. 
