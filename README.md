<p align="center"><img src="readme_assets/trimmed2.png" width="1000"></p>

# A modern, open-source cross-platform GUI for yt-dlp built with Flutter and Python.
## Screenshots
<p align="center">
  <img src="readme_assets/screen0.jpg" width="200">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen1.jpg" width="200">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen2.jpg" width="200">
  &nbsp;&nbsp;&nbsp;
  <img src="readme_assets/screen3.jpg" width="200">
</p>

## What is VDownloader?
### VDownloader is a cross platform yt-dlp wrapper app built with flutter and python.
## Why VDownloader?
### One of the things to pushed me to work on this project was noticing that many yt-dlp warpers were missing something important : standradization, I wanted to build a GUI that both beginners and advanced users could benefit from.
## Features (till pre V0.2)

  <h3>
    <li>Downloading videos from YouTube</li>
    <li>Downloading audio without video and vice versa</li>
    <li>Quailty format selector which backend downloads best codec to the same quality to save size</li>
    <li>Downloading video thumbnails and subtitle files (Embedding is not available in pre-v0.2 because the required dependencies are not yet included.)</li>
  </h3>

## Tech Stack
### UI => Dart(Flutter)
### Backend => Python
## Challenges
### In this project , i faced multiple implementation challenges that thanks Allah i could solve them, first one is to run an upsteam yt-dlp direclty on andriod ,most yt-dlp anroid warpper uses youtubedl-android as it a ready made java library for yt-dlp but it miss that it is not always the latest version ,i solved that problem by running the backend with Chaquopy ,second challenge was to bundle pre built binaries with the app (like ffmpeg) and i tried to copy them from the assets folder and excute them but because of write XOR execute android 10+ polisy , i couldn't run ,to solve such problem ,we spoffed the name of the binary to let the android packager laod it as a dynamic library and be loaded into the runtime 
## Building
### 1- Download Dependencies

<h4>
  <li>Android SDK</li>
  <li>Flutter SDK</li>
  <li>Python 3</li>
</h4>

### 2- Clone the repo
### 3- Run `flutter build apk --release` from the project root.
## Limitaions
### The UI still doesn't expose all yt-dlp features, but I plan to improve this in future releases!
### Thumbnail and subtitle embedding is currently not working.
### The download process currently fails if an invalid URL is entered. Restarting the app is required.
## Future Plans
### I want to build a UI that exposes nearly all yt-dlp features (including its helper tools) without overwhelming beginner users.
### I also plan to integrate a custom download engine into the app. When that happens, I plan to fork the project under the name LibreLoad.
### I also plan to add post-processing features that can blur mature content and remove background music from downloaded audio.
## AI Usage
### The following list contains the parts of the project that were primarily generated with the help of AI:
<h4>
  <li>MainActivity.kt</li>
  <li>Some advanced backend functions (for example, the format sorting function)</li>
  <li>Drop down logic in the UI</li>
</h4>

### The remaining code was either written entirely by me or developed under my supervision with the assistance of AI. I was also learning both Dart and Flutter while building this project.
