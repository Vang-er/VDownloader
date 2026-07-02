import 'package:flutter/material.dart';
import 'package:vdownloader/global.dart';
import 'package:flutter/services.dart';
import 'package:vdownloader/services/api_functions.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    super.initState();
    print("test from initstate");
    progressStream.listen((message) {
      if (!mounted) return;
      setState(() {
        print("test from inside set stat");
        debugPrint(message);
        dwnbtntxt = message;
        is_progressing = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: Duration(seconds: 1),
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          flexibleSpace: Stack(
            children: [
              Positioned(width: 200, child: Image.asset("assets/LOGO.png")),
            ],
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_outlined),
              iconSize: 30,
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
            SingleChildScrollView(
              child: Column(
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
                            onChanged: (value) {
                              if (vid_data_loaded) {
                                setState(() {
                                  is_progressing = false;
                                  vid_data_loaded = false;
                                  dwnbtnicon = Icons.search;
                                  dwnbtntxt = "Check";
                                });
                              }
                            },
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
                              tooltip: "Paste",
                              iconSize: 20,
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                ClipboardData? data = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                if (data != null) {
                                  urlController.text =
                                      urlController.text + (data.text ?? '');
                                  await get_info(urlController.text, 5000).then(
                                    (info) {
                                      if (info["sucess"] == true) {
                                        setState(() {
                                          vidinfo = info;
                                          videoFormats = info["video_formats"];
                                          audioFormats = info["audio_formats"];
                                          if (vidinfo["video_formats"]
                                              .isNotEmpty) {
                                            selectedVideo =
                                                vidinfo["video_formats"]
                                                    .first["id"];
                                          }
                                          if (vidinfo["audio_formats"]
                                              .isNotEmpty) {
                                            selectedAudio =
                                                vidinfo["audio_formats"]
                                                    .first["id"];
                                          }
                                          duration_procced = pros_duartion(
                                            vidinfo["duration"],
                                          );
                                          vid_title = vidinfo["title"];
                                          vid_data_loaded = true;
                                          show_info = true;
                                          dwnbtnicon = Icons.download;
                                          dwnbtntxt = "Download";
                                          updateTotal();
                                        });
                                      }
                                      if (info["sucess"] == false) {
                                        warn_msg = "";
                                      }
                                    },
                                  );
                                }
                                setState(() {
                                  isLoading = false;
                                });
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
                  Visibility(
                    visible: show_warn,
                    child: Container(
                      child: Text(
                        warn_msg,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight(1000),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: show_info,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 5),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      width: 350,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 325,
                            height: 180,

                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Image.network(
                                    vidinfo?["thumbnail"] ?? "",
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                    errorBuilder:
                                        ((context, error, stackTrace) {
                                          return Center(
                                            child: Icon(Icons.error, size: 10),
                                          );
                                        }),
                                    width: 325,
                                  ),
                                  // Image.asset("assets/LOGO.png"),
                                  Positioned(
                                    width: 50,
                                    height: 20,
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      width: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                        color: const Color.fromARGB(
                                          188,
                                          104,
                                          58,
                                          183,
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,

                                        child: Text(
                                          duration_procced,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight(600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              vid_title ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight(600),
                              ),
                            ),
                          ),
                          Container(
                            width: 325,
                            height: 245,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.deepPurple,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: SegmentedButton<int>(
                                      showSelectedIcon: false,
                                      segments: const [
                                        ButtonSegment(
                                          value: 0,
                                          label: Text(
                                            "Video",
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: 1,
                                          label: Text(
                                            "Video&Audio",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: 2,
                                          label: Text(
                                            "Audio",
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                      ],
                                      selected: {vid_format_selected},
                                      onSelectionChanged: (Set<int> value) {
                                        setState(() {
                                          vid_format_selected = value.first;
                                          debugPrint(
                                            "Selected: $vid_format_selected",
                                          );
                                          updateTotal();
                                          // debugPrint(download_index);
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 20),
                                  child: SizedBox(
                                    width: 290,
                                    child: Opacity(
                                      opacity: vid_format_selected == 2
                                          ? 0.4
                                          : 1,
                                      child: DropdownButtonFormField<String>(
                                        dropdownColor: const Color.fromARGB(
                                          255,
                                          0,
                                          0,
                                          0,
                                        ),
                                        initialValue: selectedVideo,
                                        decoration: const InputDecoration(
                                          labelText: "Video Quality",
                                          border: OutlineInputBorder(),
                                        ),

                                        onChanged: vid_format_selected == 2
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  selectedVideo = value!;
                                                  final selectedVideoInfo =
                                                      videoFormats.firstWhere(
                                                        (e) =>
                                                            e["id"] ==
                                                            selectedVideo,
                                                      );
                                                  final selectedAudioInfo =
                                                      audioFormats.firstWhere(
                                                        (e) =>
                                                            e["id"] ==
                                                            selectedAudio,
                                                      );
                                                  total = 0;

                                                  if (vid_format_selected !=
                                                      2) {
                                                    total +=
                                                        selectedVideoInfo["filesize"];
                                                  }

                                                  if (vid_format_selected !=
                                                      0) {
                                                    total +=
                                                        selectedAudioInfo["filesize"];
                                                  }
                                                });
                                              },

                                        items: videoFormats
                                            .map<DropdownMenuItem<String>>((
                                              format,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value:
                                                    format["id"], // what gets stored
                                                child: Text(
                                                  "${format["resolution"]} ~${format["size"]}", // what the user sees
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 290,

                                  child: Opacity(
                                    opacity: vid_format_selected == 0 ? 0.4 : 1,
                                    child: DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      initialValue: selectedAudio,
                                      decoration: const InputDecoration(
                                        labelText: "Audio Quality",
                                        border: OutlineInputBorder(),
                                      ),

                                      onChanged: vid_format_selected == 0
                                          ? null
                                          : (value) {
                                              setState(() {
                                                selectedAudio = value!;
                                                final selectedVideoInfo =
                                                    videoFormats.firstWhere(
                                                      (e) =>
                                                          e["id"] ==
                                                          selectedVideo,
                                                    );
                                                final selectedAudioInfo =
                                                    audioFormats.firstWhere(
                                                      (e) =>
                                                          e["id"] ==
                                                          selectedAudio,
                                                    );
                                                total = 0;

                                                if (vid_format_selected != 2) {
                                                  total +=
                                                      selectedVideoInfo["filesize"];
                                                }

                                                if (vid_format_selected != 0) {
                                                  total +=
                                                      selectedAudioInfo["filesize"];
                                                }
                                              });
                                            },

                                      items: audioFormats
                                          .map<DropdownMenuItem<String>>((
                                            format,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: format["id"],
                                              child: Text(
                                                "${format["resolution"]} ~${format["size"]}",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Download Size: ${proc_size(total)}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight(900),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 217, 0, 255),
                          const Color.fromARGB(255, 60, 7, 152),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 5),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      //   color: isLoading
                      //       ? Colors.deepPurple.shade900
                      //       : Colors.deepPurple,
                    ),
                    width: 325,
                    height: 50,
                    child: TextButton(
                      onPressed: isLoading || is_progressing
                          ? null
                          : () async {
                              if (isLoading) return;
                              setState(() {
                                isLoading = true;
                              });
                              if (urlController.text != "") {
                                if (vid_data_loaded == false) {
                                  await get_info(
                                    urlController.text,
                                    5000,
                                  ).then((info) {
                                    if (info["sucess"] == true) {
                                      setState(() {
                                        vidinfo = info;

                                        videoFormats = info["video_formats"];
                                        audioFormats = info["audio_formats"];

                                        if (videoFormats.isNotEmpty) {
                                          selectedVideoId =
                                              videoFormats.first["id"];
                                        }

                                        duration_procced = pros_duartion(
                                          vidinfo["duration"],
                                        );
                                        vid_title = vidinfo["title"];
                                        vid_data_loaded = true;
                                        show_info = true;
                                        dwnbtnicon = Icons.download;
                                        dwnbtntxt = "Download";
                                        updateTotal();
                                        // selectedAudio = null;
                                        // selectedVideo = null;
                                        // videoFormats.clear();
                                        // audioFormats.clear();
                                      });
                                    } else if (info["sucess"] == false) {
                                      setState(() {
                                        show_info = false;
                                        warn_msg = "Please enter a vaild URL";
                                        show_warn = true;
                                      });
                                      Future.delayed(Duration(seconds: 5), () {
                                        setState(() {
                                          show_warn = false;
                                        });
                                      });
                                    }
                                  });
                                } else if (vid_data_loaded == true) {
                                  sendurl(
                                    urlController.text,
                                    5000,
                                    selectedVideo,
                                    selectedAudio,
                                  ).then((info) {
                                    if (info["sucess"] == false) {
                                      setState(() {
                                        warn_msg = "Please enter a vaild URL";
                                        show_warn = true;
                                      });
                                      Future.delayed(Duration(seconds: 5), () {
                                        setState(() {
                                          show_warn = false;
                                        });
                                      });
                                    }
                                  });
                                }
                              } else {
                                setState(() {
                                  show_warn = true;
                                  warn_msg = "Pleas enter a URL";
                                });
                                Future.delayed(Duration(seconds: 5), () {
                                  setState(() {
                                    show_warn = false;
                                  });
                                });
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                      child: is_progressing
                          ? Text(
                              dwnbtntxt,
                              style: TextStyle(
                                fontWeight: FontWeight(900),
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(dwnbtnicon, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  dwnbtntxt,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
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
    );
  }
}
