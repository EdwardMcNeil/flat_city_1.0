import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'db/events.dart';
import 'package:logger/logger.dart';
import 'widgets/theme_switcher.dart';
import 'widgets/user_icon.dart';
import 'pages/event_list_page.dart';
import 'pages/create_event_page.dart';

var logger = Logger(level: Level.warning);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await myAppState.init().then((m) {
      logger.d('here is our model: ${myAppState.model.iAmInitialized}');
      runApp(const FlatCity());
    });
  }

  // -- runApp(MultiProvider(
  // --   providers: [
  // --     ChangeNotifierProvider<ApplicationState>(
  // --         create: (_) => applicationStateInitializer.model),
  // --   ],
  // --   builder: ((context, _) => const MaterialApp(home: EventsListPage())),
  // -- ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getRoute(),
    );
  }

}

class FlatCity extends StatelessWidget {
  const FlatCity({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
    );
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.grey,
    );
    final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => myAppState.model),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        child: const EventsListPage(),
        builder: (c, themeProvider, child) {
          return MaterialApp.router(
            routerConfig: getRoute(),
            scaffoldMessengerKey: scaffoldKey,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.selectedThemeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: AppColors.getMaterialColorFromColor(
                  themeProvider.selectedPrimaryColor),
              primaryColor: themeProvider.selectedPrimaryColor,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: AppColors.getMaterialColorFromColor(
                  themeProvider.selectedPrimaryColor),
              primaryColor: themeProvider.selectedPrimaryColor,
            ),
          );
        },
      ),
    );
  }
}

// routes down here ...

GoRouter getRoute() {
  final appRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const EventsListPage(),
        routes: [
          GoRoute(
            path: 'sign-in',
            builder: (context, state) {
              return SignInScreen(
                headerBuilder: (context, constraints, _) {
                  return AppBar(title: const Text('Profile'));
                },
                actions: [
                  ForgotPasswordAction(((context, email) {
                    final uri = Uri(
                      path: '/sign-in/forgot-password',
                      queryParameters: <String, String?>{
                        'email': email,
                      },
                    );
                    context.push(uri.toString());
                  })),
                  AuthStateChangeAction(((context, state) {
                    final user = switch (state) {
                      SignedIn state => state.user,
                      UserCreated state => state.credential.user,
                      _ => null
                    };
                    if (user == null) {
                      return;
                    }
                    if (state is UserCreated) {
                      user.updateDisplayName(user.email!.split('@')[0]);
                    }
                    if (!user.emailVerified) {
                      user.sendEmailVerification();
                      const snackBar = SnackBar(
                          content: Text(
                              'Please check your email to verify your email address'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      // user is authenticated
                      logger.d('fully authenticated user: $user');
                    }
                    context.pushReplacement('/');
                  })),
                ],
              );
            },
            routes: [
              GoRoute(
                path: 'forgot-password',
                builder: (context, state) {
                  final arguments = state.uri.queryParameters;
                  return ForgotPasswordScreen(
                    email: arguments['email'],
                    headerMaxExtent: 200,
                    headerBuilder: (context, constraints, _) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset('assets/Image.png',
                              alignment: Alignment.bottomCenter),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) {
              return Consumer2<ApplicationState, ThemeProvider>(
                  builder: (context, appState, theme, _) {
                String userId = appState.getInitialForCurrentUser();
                Widget userIcon = UserCircleIcon(
                  userName: userId,
                  backgroundColor: theme.selectedPrimaryColor,
                  size: 100,
                );
                return ProfileScreen(
                  key: ValueKey(appState.emailVerified),
                  avatar: userIcon,
                  avatarShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(102),
                  ),
                  avatarPlaceholderColor: theme.selectedPrimaryColor,
                  providers: const [],
                  appBar: AppBar(
                    title: const Text('profile 2'),
                  ),
                  actions: [
                    SignedOutAction(((context) {
                      context.pushReplacement('/');
                    })),
                  ],
                  children: [
                    Visibility(
                        visible: !appState.emailVerified,
                        child: OutlinedButton(
                          child: const Text('Recheck Verification State'),
                          onPressed: () {
                            appState.refreshLoggedInUser();
                          },
                        )),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 17),
                        //width: _containerWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text('Theme'),
                            ),
                            ThemeSwitcher(),
                            // -- const Padding(
                            // --   padding: EdgeInsets.symmetric(vertical: 10),
                            // --   child: Text('Primary Color'),
                            // -- ),
                            // -- PrimaryColorSwitcher(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
            },
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const CreateEventPage(),
          ),
          // -- ),
          // -- GoRoute(
          // --   path: 'photo',
          // --   builder: (context, state) {
          // --     return Consumer<ApplicationState>(
          // --       builder: (context, appState, _) => CameraPage(
          // --         key: ValueKey(appState.emailVerified),
          // --         loggedIn: appState.loggedIn,
          // --         isAdmin: appState.userIsAdmin,
          // --       ),
          // --     );
          // --   },
          // -- ),
          // -- GoRoute(
          // --   path: 'info',
          // --   builder: (context, state) {
          // --     return Consumer<ApplicationState>(
          // --       builder: (context, appState, _) => Info(
          // --         key: ValueKey(appState.emailVerified),
          // --         uri: GoRouterState.of(context)
          // --             .matchedLocation, // .uri.toString()
          // --       ),
          // --     );
          // --   },
          // -- ),
          // -- GoRoute(
          // --     path: 'warehouse',
          // --     builder: (context, state) {
          // --       return Consumer<ApplicationState>(
          // --         builder: (context, appState, _) => const NeuesItemsPage(
          // --             isAdmin: false), // const WarehousePage(),
          // --       );
          // --     },
          // --     routes: [
          // --       GoRoute(
          // --         path: 'detail',
          // --         builder: (context, state) {
          // --           return Consumer2<ApplicationState, ItemStore>(
          // --             builder: (context, appState, itemState, _) =>
          // --                 ItemDetailPage(
          // --                     docID: itemState.currentItem?.id ?? 'bogoindian',
          // --                     itemName: itemState.currentItem?.name ?? 'dunno'),
          // --           );
          // --         },
          // --       ),
          // --     ]),
          // -- GoRoute(
          // --   path: 'bigboard',
          // --   builder: (context, state) {
          // --     return Consumer<ApplicationState>(
          // --       builder: (context, appState, _) => BigBoardPage(),
          // --     );
          // --   },
          // -- ),
          // -- // GoRoute(
          // -- //     path: 'favorites',
          // -- //     builder: (context, state) {
          // -- //       return Consumer<ApplicationState>(
          // -- //         builder: (context, appState, _) =>
          // -- //             const FlexItemsPage(), //FavoritesPage(), // ScrollNotificationDemo(), // const FavoritesPage(),
          // -- //       );
          // -- //     }),
          // -- GoRoute(
          // --     path: 'favorites',
          // --     builder: (context, state) {
          // --       return Consumer<ApplicationState>(
          // --         builder: (context, appState, _) => ItemsPage(
          // --             isAdmin: false,
          // --             userId: appState
          // --                 .getInitialForCurrentUser()), // const WarehousePage(),
          // --       );
          // --     },
          // --     routes: [
          // --       GoRoute(
          // --         path: 'detail',
          // --         builder: (context, state) {
          // --           return Consumer2<ApplicationState, ItemStore>(
          // --             builder: (context, appState, itemState, _) =>
          // --                 ItemDetailPage(
          // --                     docID: itemState.currentItem?.id ?? 'bogoindian',
          // --                     itemName: itemState.currentItem?.name ?? 'dunno'),
          // --           );
          // --         },
          // --       ),
          // --     ]),
          // -- GoRoute(
          // --     path: 'chat',
          // --     builder: (context, state) {
          // --       return Consumer2<ApplicationState, GuestBookMessageStore>(
          // --         builder: (context, appState, guestState, _) {
          // --           return const ChatPage();
          // --         },
          // --       );
          // --     }),
          // -- GoRoute(
          // --     path: 'account',
          // --     builder: (context, state) {
          // --       return Consumer<ApplicationState>(
          // --         builder: (context, appState, _) => const AccountPage(),
          // --       );
          // --     }),
          // -- GoRoute(
          // --   path: 'admin',
          // --   builder: (context, state) {
          // --     return Consumer2<ApplicationState, ItemStore>(
          // --       builder: (context, appState, itemState, _) =>
          // --           const NeuesItemsPage(
          // --               isAdmin: true), // const WarehousePage(),
          // --     );
          // --   },
          // --   routes: [
          // --     GoRoute(
          // --       path: 'item',
          // --       builder: (context, state) {
          // --         return Consumer2<ApplicationState, ItemStore>(
          // --           builder: (context, appState, itemState, _) =>
          // --               const AddItemPage(),
          // --         );
          // --       },
          // --     ),
          // --     GoRoute(
          // --         path: 'photo',
          // --         builder: (context, state) {
          // --           return Consumer<ApplicationState>(
          // --             // KAIZA: probably do not need bools since this is under admin route only
          // --             builder: (context, appState, _) => CameraPage(
          // --               key: ValueKey(appState.emailVerified),
          // --               loggedIn: appState.loggedIn,
          // --               isAdmin: appState.userIsAdmin,
          // --             ),
          // --           );
          // --         }),
          // --     GoRoute(
          // --       path: 'detail',
          // --       builder: (context, state) {
          // --         return Consumer2<ApplicationState, ItemStore>(
          // --           builder: (context, appState, itemState, _) =>
          // --               ItemDetailPage(
          // --                   docID: itemState.currentItem?.id ?? 'bogoindian',
          // --                   itemName: itemState.currentItem?.name ?? 'dunno'),
          // --         );
          // --       },
          // --     ),
          // --   ],
          // -- ),
        ],
      ),
    ],
  );
  return appRouter;
}
