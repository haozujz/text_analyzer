import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModels/text_analysis_vm.dart'; // Ensure this is the path where your AnalysisResult class is located

class ListResultsScreen extends ConsumerStatefulWidget {
  const ListResultsScreen({super.key});

  @override
  ConsumerState<ListResultsScreen> createState() => _ListResultsScreenState();
}

class _ListResultsScreenState extends ConsumerState<ListResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Analysis Results')),
      body:
          textAnalysisState.storedAnalysisResults.isEmpty
              ? Center(child: Text('No results available'))
              : ListView.builder(
                itemCount: textAnalysisState.storedAnalysisResults.length,
                itemBuilder: (context, index) {
                  final result = textAnalysisState.storedAnalysisResults[index];
                  return ListTile(
                    title: Text(result.text),
                    subtitle: Text(result.createdAt.toIso8601String()),
                    leading: CircleAvatar(
                      child: Text(
                        result.language,
                      ), // Display language as an icon (or any other info)
                    ),
                    onTap: () {
                      // You can navigate to a detailed view or perform any other action
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(result.text),
                            content: Text(
                              'Sentiment: ${result.sentiment.sentiment}',
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
