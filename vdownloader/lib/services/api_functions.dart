import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import "dart:convert";
import "package:VDownloader/global.dart";

void updateTotal() {
  total = 0;

  if (videoFormats.isNotEmpty && vid_format_selected != 2) {
    final video = videoFormats.firstWhere((e) => e["id"] == selectedVideo);
    total += video["filesize"];
  }

  if (audioFormats.isNotEmpty && vid_format_selected != 0) {
    final audio = audioFormats.firstWhere((e) => e["id"] == selectedAudio);
    total += audio["filesize"];
  }
}

String proc_size(double size) {
  size = (size / 1024) / 1024;
  if (size >= 900) {
    return "~${(size / 1024).toStringAsFixed(2)} Gb";
  } else {
    return "~${size.toStringAsFixed(2)} Mb";
  }
}

Future sendurl(String url, int port, vformat, aformat) async {
  final reponse = await http.post(
    Uri.parse("http://$backend_ip:$port/Download"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "url": url,
      "vformat": vformat,
      "aformat": aformat,
      "state": vid_format_selected,
    }),
  );
  return jsonDecode(reponse.body);
}

String pros_duartion(dynamic duration) {
  String Hour = (duration ~/ 3600).toString();
  String Minute = (((duration ~/ 60) - (60 * (duration ~/ 3600))).toString())
      .padLeft(2, '0');
  String second =
      ((duration -
                  ((3600 * (duration ~/ 3600)) +
                      (60 * ((duration ~/ 60) - (60 * (duration ~/ 3600))))))
              .toString())
          .padLeft(2, '0');
  if (duration >= 3600) {
    return "$Hour:$Minute:$second";
  } else {
    return "$Minute:$second";
  }
}

Future get_info(url, port) async {
  final reponse = await http.post(
    Uri.parse("http://$backend_ip:$port/Info"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"url": url}),
  );
  vidinfo = jsonDecode(reponse.body);
  debugPrint(reponse.body);
  return jsonDecode(reponse.body);
}
