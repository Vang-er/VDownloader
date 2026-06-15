import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final TextEditingController urlController = TextEditingController();
void main() {
  runApp(app());
}

class app extends StatefulWidget {
  State<app> createState() => _appState();
}

class _appState extends State<app> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            flexibleSpace: Stack(
              children: [
                Positioned(child: Image.asset("assets/LOGO.png"), width: 200),
              ],
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.history_rounded),
                iconSize: 35,
                tooltip: "tes123",
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(text: "Download"),
                Tab(text: "Queue"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.deepPurple),
                      color: const Color.fromARGB(15, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: 325,
                    height: 50,
                    margin: EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: urlController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Paste Video URL ....",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(40, 148, 90, 248),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () async {
                                ClipboardData? data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );

                                if (data != null) {
                                  urlController.text = data.text ?? '';
                                }
                              },
                              icon: Icon(
                                Icons.content_paste_rounded,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 5),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        width: 5,
                        color: Color.fromARGB(255, 148, 90, 248),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: const Color.fromARGB(255, 148, 90, 248),
                    ),
                    width: 325,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        debugPrint("keep working ,untill you Marry Malak ");
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "Download",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      color: Colors.grey,
                      size: 64,
                    ),

                    SizedBox(height: 16),

                    Text(
                      "Coming in Future Releases",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "This feature is under development.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
