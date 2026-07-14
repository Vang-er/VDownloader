from flask import Flask ,request,jsonify
from pprint import pprint
from pathlib import Path
from flask_sock import Sock
import yt_dlp
import platform
import os
from pathlib import Path
trigger = 0
state = None
current_ws = None
web_socket = None
last_progress = ""
progress = ""
VDback = Flask(__name__)
sock = Sock(VDback)
cur_OS = platform.system()
def start_server(ffmpeg_dir):
    global FFMPEG_DIR
    FFMPEG_DIR = ffmpeg_dir
    print("FFmpeg directory:")
    print(FFMPEG_DIR)
    VDback.run(
        host="0.0.0.0",
        port=7070,
        threaded=True,
        debug=False
    )
def pros_duration(time):
    if time == None:
        return "00:00"
    else:
        hour = time // 3600
        minute = f"{((time // 60) - (60 * (time // 3600)))}".zfill(2)
        second = f"{(time - ((3600 * (time // 3600)) + (60 * ((time // 60) - (60 * (time // 3600))))))}".zfill(2)
    if time >= 3600:
        return f"{hour}:{minute}:{second}"
    elif time >= 60:
        return f"{minute}:{second}"
    else:
        return f"00:{second}"
def get_os():
    if "ANDROID_ROOT" in os.environ:
        return "android"

    if platform.system() == "Windows":
        return "windows"

    if platform.system() == "Linux":
        return "linux"

    if platform.system() == "Darwin":
        return "mac"

    return "unknown"
system = get_os()

if system == "android":
    download_path = "/storage/emulated/0/Download"
elif system == "linux":
    download_path = os.path.expanduser("~/Downloads")
elif system == "windows":
    download_path = str(Path.home() / "Downloads")
def postpros(data):
    print("post pros happend")
    print(f"9987:{data.keys()}")
    print(f"9987:{data.get('status')}")
    print(f"9987:{data.get('postprocessor')}")
    print(f"9987:{data.get('_default_template')}")
    progress = f"Running - {data.get('postprocessor')}"
    if web_socket is not None:
        web_socket.send(progress)
def progress_track(data):
    global progress, web_socket, trigger, state
    print(data)
    if web_socket is None:
        print("web socket is none")
    tmpfilename = data.get("tmpfilename")
    print(f"ext_is:{tmpfilename}")
    filename = ""
    if tmpfilename:
        name = Path(tmpfilename).name
        print(f"ext_is:{name}")
        if name.endswith(".part"):
            name = name[:-5] 
        ext = Path(name).suffix.lower().lstrip(".")
        print(f"ext_is:{ext}")
        if ext in {"mp4", "mkv", "webm", "avi", "mov"}:
            filename = "Video"

        elif ext in {"m4a", "mp3", "opus", "aac", "wav", "flac"}:
            filename = "Audio"

        elif ext in {"vtt", "srt", "ass"}:
            filename = "Subtitles"

        elif ext in {"jpg", "jpeg", "png", "webp"}:
            filename = "Thumbnail"

        else:
            filename = ext
    else:
        tmpfilename = data.get("filename")
    progress = (f"{data.get('status')} {filename} | {int(data.get('_percent'))}% | {pros_duration(data.get('eta'))}")
    if web_socket is not None:
        web_socket.send(progress)
def proc_channel(channel):
    if channel == 2:
        return "Stereo"
    elif channel == 1:
        return "Mono"
def proc_format(info):
    global best_video, best_audio, best_mixed

    best_video = {}
    best_audio = {}
    best_mixed = {}

    for fmt in info.get("formats", []):

        filesize = fmt.get("filesize") or fmt.get("filesize_approx") or float("inf")
        if fmt.get("vcodec") != "none" and fmt.get("acodec") == "none":

            height = fmt.get("height", 0)
            fps = fmt.get("fps", 0)
            token = f"{height}_{fps}"

            if (
                token not in best_video
                or filesize < best_video[token]["filesize"]
            ):
                best_video[token] = {
                    "id": fmt.get("format_id"),
                    "resolution": f"{height}P {fps}fps",
                    "size": proc_size(filesize if filesize != float("inf") else None),
                    "filesize": filesize,
                }

        elif fmt.get("vcodec") == "none" and fmt.get("acodec") != "none":

            abr = int(fmt.get("abr") or 0)
            channels = fmt.get("audio_channels") or 2

            token = f"{abr}_{channels}"

            if (
                token not in best_audio
                or filesize < best_audio[token]["filesize"]
            ):
                best_audio[token] = {
                    "id": fmt.get("format_id"),
                    "bit_rate": abr,
                    "resolution": f"{abr} Kb/s {proc_channel(channels)}",
                    "size": proc_size(filesize if filesize != float("inf") else None),
                    "filesize": filesize,
                }
        elif fmt.get("vcodec") != "none" and fmt.get("acodec") != "none":

            height = fmt.get("height", 0)
            fps = fmt.get("fps", 0)
            token = f"{height}_{fps}"

            if (
                token not in best_mixed
                or filesize < best_mixed[token]["filesize"]
            ):
                best_mixed[token] = {
                    "id": fmt.get("format_id"),
                    "resolution": f"{height}P {fps}fps",
                    "size": proc_size(filesize if filesize != float("inf") else None),
                    "filesize": filesize,
                }

    # Convert to lists
    best_video = list(best_video.values())
    best_audio = list(best_audio.values())
    best_mixed = list(best_mixed.values())

    # Sort results
    best_video.sort(key=lambda x: int(x["resolution"].split("P")[0]))
    best_audio.sort(key=lambda x: x["bit_rate"])
    best_mixed.sort(key=lambda x: int(x["resolution"].split("P")[0]))
def proc_size(size):
    if size is None:
        return "UNKNOWN"
    else:
        size = (size / 1024) / 1024
    if (size >= 900):
        return f"{int(size /1024)} Gb"
    else:
        return f"{round(size,2)} Mb"
def get_info(url):
    try:
        with yt_dlp.YoutubeDL({"quiet":True,"skip_download":True}) as ydl:
            return ydl.extract_info(url,download=False)
    except Exception as e:
        print(e)
        print(f"malformed input0: {e}")
        return {"sucess":False,"error":str(e)} , 400
@VDback.route("/")
def up():
    return "server is up and ready to recivive commands!!!"
@VDback.route("/Info",methods=['POST'])
def Get_info():
    url_info = request.json["url"]
    info = get_info(url_info)
    proc_format(info)
    print(best_video)
    print(best_audio)
    print(best_mixed)
    try:
        return jsonify({
        "title": info.get("title"),
        "thumbnail": info.get("thumbnail"),
        "duration": info.get("duration"),
        "video_formats": best_video,
        "audio_formats": best_audio,
        "sucess":True,
        })
    except Exception as e:
        return {"sucess":False,"error":str(e)} , 400
@VDback.route("/Download",methods=['POST'])
def get_url():
    global state
    global ydl_opt
    data = request.get_json()

    if not data or "url" not in data or ("vformat" not in data and "aformat" not in data):  
        return {  
        "sucess": False,  
        "error": "Missing URL"  
    }, 400  
    url = data["url"]  
    videoFormat = data["vformat"]  
    audioFormat = data['aformat']  
    req_format = [videoFormat,audioFormat]  
    state = data['state']  
    print(state)  
    mp3_compute = []
    merge_state = None
    if state == 0 :  
        fin_format = f"{req_format[0]}"    
        merge_state = "mp4"
    elif state == 1:  
        fin_format = f"{req_format[0]}+{req_format[1]}"  
        merge_state = "mp4"
    elif state == 2:  
        fin_format = f"{req_format[1]}"  
        merge_state = None
        mp3_compute = [
    {
        "key": "FFmpegExtractAudio",
        "preferredcodec": "mp3",
        "preferredquality": "0",
    }
]  
    else:  
        fin_format = f"{req_format[0]}+{req_format[1]}"  
        merge_state = "mp4"  
    ydl_opts = {  
    "format": fin_format,  
    "outtmpl": f"{download_path}/%(title)s.%(ext)s",
    "noplaylist": True,  
    "embedthumbnail": True,
    "writethumbnail": True,  
    "writesubtitles":True,  
    "embedsubtitles":True,  
    "writeautomaticsub": False, 
    "keepvideo": False, 
    "postprocessors": mp3_compute,
    "merge_output_format":merge_state,
    "progress_hooks":[progress_track],
    "postprocessor_hooks":[postpros],
    "verbose": True,
    "ffmpeg_location": os.path.join(
    FFMPEG_DIR,
    "libffmpeg.so",
    
),
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])
            progress = "Finished"
            if web_socket is not None:
                web_socket.send(progress)
            return {"status":"200"}
    except Exception as e:
        if web_socket is not None:
            web_socket.send("Error -Restart app")
        print(e)
        print(f"malformed input: {e}")
        return {"sucess":False,"error":str(e)}, 400
@sock.route("/progress")
def progress(ws):
    # global progress,last_progress,web_socket
    # web_socket = ws
    # while True:
    #     ws.receive()
    # while progress != last_progress:
    #     ws.send(progress)
    #     last_progress = progress
    global web_socket,current_ws
    current_ws = ws
    web_socket = ws
    while True:
        ws.receive()
if __name__ == "__main__":
    VDback.run(debug=True,port=5000,host="0.0.0.0")