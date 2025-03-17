import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Utilities/constants.dart';
import 'ViewModels/text_analysis_vm.dart';

class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends ConsumerState<TabView> {
  int _selectedIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textAnalysisViewModel = ref.read(
      textAnalysisViewModelProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 100,
        leading:
            _selectedIndex == 0
                ? IconButton(
                  icon: Icon(CupertinoIcons.camera, color: AppColors.text),
                  onPressed: () {
                    textAnalysisViewModel.toggleTextAnalysis();
                  },
                )
                : SizedBox.shrink(),
        actions: [
          _selectedIndex == 0
              ? IconButton(
                icon: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: AppColors.text,
                ),
                onPressed: () {
                  // TODO: Implement menu action
                },
              )
              : SizedBox.shrink(),
        ],
      ),
      body:
          _selectedIndex == 0
              ? Center(
                child: ElevatedButton(
                  onPressed: textAnalysisViewModel.toggleTextAnalysis,
                  child: const Text("Toggle"),
                ),
              )
              : ElevatedButton(
                onPressed: () async {
                  await Amplify.Auth.signOut();
                },
                child: const Text("Sign Out"),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed, // Mimic iOS look with fixed icons
        selectedItemColor: AppColors.button, // Apple-like color
        unselectedItemColor: CupertinoColors.systemGrey, // Apple-like color
        backgroundColor: AppColors.background,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_alt_fill),
            label: '',
          ),
        ],
      ),
    );
  }
}
