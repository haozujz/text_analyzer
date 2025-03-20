// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:nlp_flutter/Services/logger_service.dart';

// //import 'package:aws_appsync/aws_appsync.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';




//In base_view.dart
          // Try 1) chatgpt appsync w/o amplify, check subsciprtion schema 2) use sydney appsync to connect to tokyo dynamodb and cognito and lambda (but nothing new)
          // 3) Apollo
                      // await RealTimeDataFetcher().initializeAppSyncClient(
            //   next.isSignedIn,
            //   next.user!,
            // );
            // // await RealTimeDataFetcher().initializeAppSyncClient(next.user!);
            // RealTimeDataFetcher().subscribeToDataChanges();

            // await NetworkService().fetchAnalysisResult(next.user!);












// class RealTimeDataFetcher {
//   RealTimeDataFetcher._();
//   static final RealTimeDataFetcher _instance = RealTimeDataFetcher._();
//   factory RealTimeDataFetcher() => _instance;

//   // Fetch auth session and initialize the AppSync client
//   Future<void> initializeAppSyncClient(
//     bool isSignedIn,
//     String? authToken,
//   ) async {
//     try {
//       if (isSignedIn && authToken != null) {
//         // Set the Auth token for API calls
//         final apiUrl =
//             "https://v26bowi4qjhldmzdmahsfbbcfy.appsync-api.ap-northeast-1.amazonaws.com/graphql";
//         final subscriptionUrl =
//             "wss://v26bowi4qjhldmzdmahsfbbcfy.appsync-realtime-api.ap-northeast-1.amazonaws.com/graphql";

//         Amplify.API.get(apiUrl, headers: {'Authorization': authToken});
//         LoggerService().info("AppSync Client initialized successfully.");
//       } else {
//         LoggerService().info("User is not signed in or token is missing.");
//       }
//     } catch (e) {
//       LoggerService().error("Error initializing AppSync client: $e");
//     }
//   }

//   // Subscription to listen to real-time updates
//   void subscribeToDataChanges() {
//     final subscription = gql('''
//       subscription OnDataChanged {
//         onDataChanged {
//           id
//           content
//         }
//       }
//     ''');

//     Amplify.API.subscribe(subscription as GraphQLRequest).listen((response) {
//       final data = response.data['onDataChanged'];
//       LoggerService().info("Received real-time update: $data");
//       // Handle new data (update UI)
//     });
//   }
// }


      //final session = await Amplify.Auth.fetchAuthSession();
      //final isSignedIn = session.isSignedIn;
      //final authToken = (session as CognitoAuthSession).userPoolTokens?.idToken;












// class RealTimeDataFetcher {
//   RealTimeDataFetcher._();
//   static final RealTimeDataFetcher _instance = RealTimeDataFetcher._();
//   factory RealTimeDataFetcher() => _instance;

//   late GraphQLClient _client;

//   // Initialize AppSync Client with GraphQL endpoint and WebSocket endpoint
//   Future<void> initializeAppSyncClient(String user) async {
//     final apiUrl =
//         "https://v26bowi4qjhldmzdmahsfbbcfy.appsync-api.ap-northeast-1.amazonaws.com/graphql";
//     final subscriptionUrl =
//         "wss://v26bowi4qjhldmzdmahsfbbcfy.appsync-realtime-api.ap-northeast-1.amazonaws.com/graphql";

//     final HttpLink httpLink = HttpLink(
//       apiUrl, // AppSync HTTP endpoint
//     );

//     final WebSocketLink websocketLink = WebSocketLink(
//       subscriptionUrl, // AppSync WebSocket endpoint
//       config: SocketClientConfig(
//         autoReconnect: true,
//         inactivityTimeout: Duration(minutes: 5),
//         headers: {
//           'Authorization': user, // Add your token here
//         },
//       ),
//     );

//     // Create a split link to combine HTTP and WebSocket links
//     final Link link = Link.split(
//       (request) => request.isSubscription,
//       websocketLink,
//       httpLink,
//     );

//     // Initialize GraphQL Client
//     _client = GraphQLClient(
//       cache: GraphQLCache(store: InMemoryStore()),
//       link: link,
//     );
//   }

//   // GraphQL Query to fetch data
//   final String readDataQuery = """
//     query GetData {
//       getData {
//         id
//         content
//       }
//     }
//   """;

//   // GraphQL Subscription for real-time data
//   final String subscriptionQuery = """
//     subscription OnDataChanged {
//       onDataChanged {
//         id
//         content
//       }
//     }
//   """;

//   // Function to execute a query and get data
//   Future<void> fetchData() async {
//     try {
//       final result = await _client.query(
//         QueryOptions(document: gql(readDataQuery)),
//       );

//       if (result.hasException) {
//         LoggerService().error(
//           'Appsync Error fetching data: ${result.exception}',
//         );
//       } else {
//         final data = result.data?['getData'];
//         LoggerService().info("Appsync Fetched data: $data");
//         // Handle the fetched data (e.g., update the UI)
//       }
//     } catch (e) {
//       LoggerService().error("Appsync Error fetching data: $e");
//     }
//   }

//   // Function to execute subscription and listen for real-time updates
//   void subscribeToDataChanges() {
//     _client
//         .subscribe(SubscriptionOptions(document: gql(subscriptionQuery)))
//         .listen((result) {
//           if (result.hasException) {
//             print('Appsync Subscription error: ${result.exception}');
//           } else {
//             final data = result.data?['onDataChanged'];
//             print("Appsync Received real-time update: $data");
//             // Handle the real-time update data (e.g., update the UI)
//           }
//         });
//   }
// }