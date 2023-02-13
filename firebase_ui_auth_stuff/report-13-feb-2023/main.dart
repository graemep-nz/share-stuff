import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

//import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_auth/src/providers/email_auth_provider.dart' as eapd;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  FirebaseUIAuth.configureProviders(
    [
      eapd.EmailAuthProvider(),
      //GoogleProvider(clientId: GOOGLE_CLIENT_ID),
      // ... other providers
    ]
  );

  runApp(MyApp3());
}

void saveLastLoggedInUser(User? lastUser)
{
  if (lastUser?.email != null) {
    // save it
  }
}


class MyApp3 extends StatelessWidget {
  static List<AuthProvider> providers = [eapd.EmailAuthProvider()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return DoSignIn(providers, signInTheme);
        },
        '/profile': (context) {
          //print("profile screen  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
          return ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
        '/verify-email': (context) => EmailVerificationScreen(
          //actionCodeSettings: ActionCodeSettings(...),
          actions: [
            EmailVerifiedAction(() {
              Navigator.pushReplacementNamed(context, '/profile');
            }),
            AuthCancelledAction((context) {
              FirebaseUIAuth.signOut(context: context);
              Navigator.pushReplacementNamed(context, '/sign-in');
            }),
          ],
        ),
      },
    );
  }

  static final signInTheme = ThemeData(
    textTheme: const TextTheme(labelLarge:TextStyle(fontSize:20, color: Colors.blue ),   // the forgot password "button"
      titleMedium: TextStyle(fontSize: 16,color: Colors.blueAccent)),  // text in email text box
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(fontSize:24, color: Colors.blue ),
      labelStyle: const TextStyle(color: Colors.blue ),   // hint text inside text field
      constraints: const BoxConstraints(maxHeight: 50, maxWidth: 40, minWidth: 40),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2, color:Colors.lightBlue)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        // https://medium.flutterdevs.com/flutter-2-0-button-cheat-sheet-93217b3c908a
        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF64B5F6)),
        textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize:16)),  // the sign in button text
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.all(12),
        ),
        minimumSize: MaterialStateProperty.all(const Size(300,50)),  // the width here has no effect
        maximumSize: MaterialStateProperty.all(const Size(300,50)), // the width here has no effect
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))) ,
      ),
    ),
  );
}

class DoSignIn extends StatelessWidget {
  final List<AuthProvider> providers;
  final ThemeData signInTheme;

  const DoSignIn(this.providers, this.signInTheme);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: signInTheme,
      child: Builder(
          builder: (context) {
            //print("return SignInScreen <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
            //double width = MediaQuery.of(context).size.width;
            //double height = MediaQuery.of(context).size.height;
            //print("sign in width  ${width}  $height  ${MediaQuery.of(context).size}  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");

            return SignInScreen(
              breakpoint: 800,
              resizeToAvoidBottomInset: true,
              //email: "***@gmail.com",
              headerMaxExtent: 180,
              headerBuilder: (context, constraints, _) {
                //print("Why aren't you calling me?");
                //if (constraints.maxHeight < 50) print("vvvvvvvvvvvvv ${constraints.maxHeight}");
                return Center(
                  child: Column (
                    children : [
                      SizedBox(height: (constraints.maxHeight > 50 ? constraints.maxHeight - 30 : 0)),
                      if (constraints.maxHeight > 50)
                        Text(
                          'Welcome to My App',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                        // fontFamily: 'Arial',
                          )
                        ),
                    ]
                  )
                );
                //print("imaging  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                //return Center(
                //  child: Image.asset('assets/polygonal-dove-3.jpg'),
                //);
                /*
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    //child: Image.network('https://firebase.flutter.dev/img/flutterfire_300x.png'),
                    child: Image.asset('assets/polygonal-dove-3.jpg'),
                  ),
                );
                */

              },

              providers: providers,
              actions: [
                AuthStateChangeAction<UserCreated>((context, state) {
                      // perform post-registration logic here, for example – open a new screen
                  Navigator.pushReplacementNamed(context, '/sign-in');
                }),
                AuthStateChangeAction<SignedIn>((context, state) {
                  if (!state.user!.emailVerified) {
                    Navigator.pushNamed(context, '/verify-email');
                  } else {
                    saveLastLoggedInUser(FirebaseAuth.instance.currentUser);
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                }),
              ],
            );
          }
      ),
    );
  }
}


/*
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return const SignInScreen(
              providers: [
                //EmailAuthProvider(),
              ]
          );
        }

        // Render your application if authenticated
        return MyApp();
      },
    );
  }
}

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            // https://medium.flutterdevs.com/flutter-2-0-button-cheat-sheet-93217b3c908a
            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(fontSize:18)),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(12),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),

      home: AuthGate(),
    );
  }
}

****/

