intro.ogv is your WhatsApp intro video, converted to Ogg Theora because that is the only
video format Godot 4 plays. 27 seconds, 1280x720, 30 fps, with the audio kept.

The command used was:

    ffmpeg -i intro.mp4 -vf "scale=1280:720:flags=lanczos" \
           -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 -ar 44100 intro.ogv

To swap in a different video, run the same command on yours and save it here as intro.ogv.
If the file is missing the game skips straight to the menu, so nothing breaks.

Lower -q:v for a smaller file. At -q:v 5 -q:a 3 this same video comes out at 9.5 MB
instead of 17 MB, which matters if you ever export to web.
