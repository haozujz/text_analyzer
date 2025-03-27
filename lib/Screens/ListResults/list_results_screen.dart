import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Utilities/Constants.dart';
import '../../ViewModels/auth_vm.dart';
import '../../ViewModels/text_analysis_vm.dart';
import 'analysis_result_item.dart';

class ListResultsScreen extends ConsumerStatefulWidget {
  const ListResultsScreen({super.key});

  @override
  ConsumerState<ListResultsScreen> createState() => _ListResultsScreenState();
}

class _ListResultsScreenState extends ConsumerState<ListResultsScreen>
    with WidgetsBindingObserver {
  String searchQuery = '';
  late FocusNode _searchFocusNode;
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;

    // Keyboard is considered open if viewInsets.bottom > 0
    final isKeyboardOpen = bottomInset > 0;

    // If it *was* open and now it's closed → unfocus
    if (_wasKeyboardOpen && !isKeyboardOpen) {
      _searchFocusNode.unfocus();
    }

    // Update state
    _wasKeyboardOpen = isKeyboardOpen;
  }

  @override
  Widget build(BuildContext context) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    final textAnalysisVM = ref.read(textAnalysisViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);

    final results = textAnalysisState.storedAnalysisResults;
    final filteredResults =
        searchQuery.trim().isEmpty
            ? results
            : results.where((r) {
              final query = searchQuery.toLowerCase();
              return r.text.toLowerCase().contains(query);
            }).toList();

    void onDeleteTapped(String id) {
      if (authState.user == null) {
        return;
      }
      ;
      textAnalysisVM.deleteAnalysisResult(user: authState.user!, id: id);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent, // captures taps outside
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child:
                    filteredResults.isEmpty
                        ? const Center(
                          child: Text(
                            'No results available',
                            style: TextStyle(color: AppColors.text),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredResults.length,
                          itemBuilder: (context, index) {
                            final result = filteredResults[index];
                            return Dismissible(
                              key: Key(result.id),
                              direction: DismissDirection.endToStart,
                              background: _buildDeleteBackground(),
                              onDismissed: (_) {
                                onDeleteTapped(result.id);
                              },
                              child: AnalysisResultItem(
                                result: result,
                                identityId: authState.identityId ?? '',
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          hintText: 'Search results...',
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.redAccent,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
