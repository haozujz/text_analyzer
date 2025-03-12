import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Screens/text_analysis_screen.dart';

// import 'package:riverpod/riverpod.dart';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'amplify_outputs.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }

  runApp(ProviderScope(child: MyApp()));
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: Scaffold(
          body: Center(
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              // home: const MyHomePage(title: 'Flutter Demo Home Page'),
              home: const TextAnalysisScreen(),
            ),
          ),
        ),
      ),
    );
  }
}



// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Authenticator(
//       authenticatorBuilder: (context, state) {
//         return Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (state.currentStep == AuthenticatorStep.signIn) ...[
//                   const Text("Welcome Back!", style: TextStyle(fontSize: 24)),
//                   TextField(
//                     decoration: InputDecoration(labelText: "Email"),
//                     onChanged: (value) => state.username = value,
//                   ),
//                   TextField(
//                     decoration: InputDecoration(labelText: "Password"),
//                     obscureText: true,
//                     onChanged: (value) => state.password = value,
//                   ),
//                   ElevatedButton(
//                     onPressed: state.signIn,
//                     child: const Text("Login"),
//                   ),
//                   TextButton(
//                     onPressed:
//                         () => state.changeStep(
//                           AuthenticatorStep.signUp,
//                         ), // Navigate to sign-up
//                     child: const Text("Create an account"),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//       child: MaterialApp(
//         builder: Authenticator.builder(),
//         home: const TextAnalysisScreen(),
//       ),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Authenticator(
//       child: MaterialApp(
//         builder: Authenticator.builder(),
//         home: const Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [SignOutButton()],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // home: const MyHomePage(title: 'Flutter Demo Home Page'),
//       home: TextAnalysisScreen(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         //onPressed: _incrementCounter,
//         onPressed: () {
//           callLambdaFunction(); // This will call your function without arguments
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

  // // Add the plugins
  // Amplify.addPlugins([
  //   AmplifyAuthCognito(),
  //   AmplifyStorageS3(),
  //   AmplifyAPI(),
  //   AmplifyDataStore(),
  // ]);
