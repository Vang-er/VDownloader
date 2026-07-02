import 'package:flutter/material.dart';
import 'package:VDownloader/pages/history_page.dart';
import 'package:VDownloader/pages/setting_page.dart';
import 'package:VDownloader/pages/download_page.dart';
import 'global.dart';

final pages = [DownloadPage(), HistoryPage(), SettingsPage()];
void main() {
  runApp(app());
}

class app extends StatefulWidget {
  const app({super.key});

  @override
  State<app> createState() => _appState();
}

class _appState extends State<app> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: pages[page_index],
        bottomNavigationBar: BottomNavigationBar(
          useLegacyColorScheme: false,
          currentIndex: page_index,
          onTap: (index) {
            setState(() {
              page_index = index;
            });
          },
          unselectedItemColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 36, 30, 46),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
