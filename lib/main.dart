//import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Services/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'Utilities/constants.dart';
import 'amplify_outputs.dart';

import 'base_view.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(ProviderScope(child: MyApp()));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    //await Amplify.addPlugin(AmplifyAPI()); // For appsync
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.configure(amplifyConfig);
    LoggerService().info('Successfully configured');
  } on Exception catch (e) {
    LoggerService().error('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NLP App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: BaseView(),
    );
  }
}
