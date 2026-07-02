from flask import Flask ,request,jsonify
from pprint import pprint
from pathlib import Path
from flask_sock import Sock
import yt_dlp
import platform
trigger = 0
state = None
current_ws = None
web_socket = None
last_progress = ""
progress = ""
VDback = Flask(__name__)
sock = Sock(VDback)
cur_OS = platform.system()
path = f"{Path.home()}/Downloads/"
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
def progress_track(data):
    global progress, web_socket, trigger, state

    if web_socket is None:
        print("web socket is none")

    # -----------------------------
    # Video only
    # -----------------------------
    if state == 0:

        if data.get("status") == "downloading":
            progress = (f"Downloading Video | {int(data.get('_percent'))}% | {pros_duration(data.get('eta'))}")

        else:
            progress = data.get("status")

    # -----------------------------
    # Audio only
    # -----------------------------
    elif state == 2:

        if data.get("status") == "downloading":
            progress = (f"Downloading Audio | {int(data.get('_percent'))}% | {pros_duration(data.get('eta'))}")
            print(progress)

        else:
            progress = data.get("status")
            print(progress)

    # -----------------------------
    # Video + Audio
    # -----------------------------
    elif state == 1:
        print("started")
        if trigger == 0:
            print("phase1")
            if data.get("status") == "downloading":
                progress = (f"Downloading Video | {int(data.get('_percent'))}% | {pros_duration(data.get('eta'))}")
                print(progress)

            elif data.get("status") == "finished":
                trigger = 1

        elif trigger == 1:
            
            if data.get("status") == "downloading":
                progress = (f"Downloading Audio | {int(data.get('_percent'))}% | {pros_duration(data.get('eta'))}")
                print(progress)
            elif data.get("status") == "finished":
                trigger = 2

        if trigger == 2:
            progress = "Finished"
            print(progress)
            trigger = 0

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

        # -----------------------------
        # Video Only
        # -----------------------------
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

        # -----------------------------
        # Audio Only
        # -----------------------------
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

        # -----------------------------
        # Video + Audio
        # -----------------------------
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
        print("malformed input")
        return {"sucess":False,"error":str(e)} , 400

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
    if state == 0 :  
        fin_format = f"{req_format[0]}"  
        fext = "mp4"  
    elif state == 1:  
        fin_format = f"{req_format[0]}+{req_format[1]}"  
        fext = "mp4"  
    elif state == 2:  
        fin_format = f"{req_format[1]}"  
        fext = "mp3"  
    else:  
        fin_format = f"{req_format[0]}+{req_format[1]}"  
        fext = "mp4"  
    ydl_opts = {  
    "format": fin_format,  
    "outtmpl": f"{path} %(title)s.{fext}",  
    "noplaylist": True,  
    "writethumbnail": True,  
    "writesubtitles":True,  
    "embedsubtitles":True,  
    "writeautomaticsub": False,  
    "progress_hooks":[progress_track]

    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])
            return {"status":"200"}
    except Exception as e:
        print(e)
        print("malformed input")
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