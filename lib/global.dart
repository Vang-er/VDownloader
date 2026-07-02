import "package:flutter/material.dart";
import 'package:web_socket_channel/web_socket_channel.dart';

final channel = WebSocketChannel.connect(
  Uri.parse("ws://$backend_ip:5000/progress"),
);
final progressStream = channel.stream.asBroadcastStream();
final TextEditingController urlController = TextEditingController();
var vidinfo;
var selectedVideo;
var selectedAudio;
double total = 0;
var vid_title;
List<dynamic> videoFormats = [];
List<dynamic> audioFormats = [];
int vid_format_selected = 1;
int page_index = 0;
double Download_Size = 0;
IconData dwnbtnicon = Icons.search;
Color btncol = Color.fromARGB(255, 148, 90, 248);
bool isLoading = false;
bool vid_data_loaded = false;
bool show_info = false;
bool info_latch = false;
bool show_warn = false;
bool is_progressing = false;
String backend_ip = "10.12.86.188";
String dwnbtntxt = "Check";
String warn_msg = "TEST";
String duration_procced = "00:00";
String? selectedVideoId;
String? selectedAudioId;
