import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Screens/ListResults/list_results_screen.dart';
import 'package:nlp_flutter/Screens/Profile/profile_screen.dart';
import 'Services/websocket.dart';
import 'Utilities/constants.dart';
import 'ViewModels/text_analysis_vm.dart';

class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  TabViewState createState() => TabViewState();
}

class TabViewState extends ConsumerState<TabView> {
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
        //elevation: 100,
        leading:
            _selectedIndex == 0 || _selectedIndex == 1
                ? IconButton(
                  icon: Icon(CupertinoIcons.camera, color: AppColors.text),
                  onPressed: () {
                    textAnalysisViewModel.toggleTextAnalysis();
                  },
                )
                : SizedBox.shrink(),
        actions: [
          _selectedIndex == 0 || _selectedIndex == 1
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
      body: _selectedIndex == 0 ? ListResultsScreen() : ProfileScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.button,
        unselectedItemColor: CupertinoColors.systemGrey,
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
