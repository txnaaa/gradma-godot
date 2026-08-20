intro.ogv is the intro video, converted to Ogg Theora because that is the only
video format Godot 4 plays. 27 seconds, 1280x720, 30 fps, with the audio kept.

The command used was:

    ffmpeg -i intro.mp4 -vf "scale=1280:720:flags=lanczos" \
           -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 -ar 44100 intro.ogv
