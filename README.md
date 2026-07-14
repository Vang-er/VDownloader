<p align="center"><img src="readme_assets/trimmed2.png" width="1000"></p>

## What is VDownloader?
### VDownloader is a cross platform yt-dlp warpper app built with flutter and python.
## Why VDownloader?
### one of the things to pushed me to work on such a project that i noticed that all yt-dlp warpers are missing something important ,standradization which i focued on + to provede a GUI that both simple and advanced users can benefit from .
## Features (till pre V0.2)

  <h3>
    <li>Downloading separte videos from youtube</li>
    <li>Downloading audio without video and vice versa</li>
    <li>Quailty format selector which filters best quailty to size</li>
    <li>Downloading thumbnail and subtitles files of the video(but till verison pre-V0.2 ,embeding depencies wasn't provided so it won't work</li>
  </h3>

## Screenshots
<p align="center">
  <img src="readme_assets/screen0.jpg" width="220">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen1.jpg" width="220">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen2.jpg" width="220">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen3.jpg" width="220">
</p>

## Tech Stack
### UI => Dart(Flutter)
### backend => Python
## Building
### 1- Download Debendices

<h4>
  <li>Android SDK</li>
  <li>Flutter SDK</li>
  <li>Python 3</li>
</h4>

### 2- Clone the repo
### 3- run "flutter build apk --release" from the project root
## Limitaions
### Still the UI can't expose all yt-dlp functuions but i plan too!
### For some reason thumbnail and subtitles embeding don't work.
### Download mechanism will fail if you enterned an invaild URL (then you should restart the app)
## Future Plans
### I have a dream to build a UI that exposes all yt-dlp functions (including its helper tools) in the UI without confusing simple user.
### Also i plan to integrate a download engine into the app but then i will fork the project and name it libreload.
### Also i plan to add some post processors to the download process that can blur mature content and can remove music from downloaded audio.
## AI Usage
### The following list is nearly fully copied from a chatbot:
<h4>
  <li>MainActivity.kt</li>
  <li>Some advanced backend functions (ex.the format sorting function</li>
  <li>Drop down logic at the UI</li>
</h4>

### remaining code is <bold>either</bold> built genunily by me or was supervisoed by a chatbot   NOTE: i was learning both dart and flutter while building that project
