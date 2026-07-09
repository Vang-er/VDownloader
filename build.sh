#!/bin/bash

echo "Syncing backend..."

cp ~/my_projects/VDownloader/backend/backend.py ~/my_projects/VDownloader/android/app/src/main/python/backend.py
flutter build apk
