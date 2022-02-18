@ECHO OFF

SETLOCAL
PUSHD "%~dp0"
	ffmpeg -i "ice_cream_factory%%03d.png" -r 60 -c:v libx264 -preset veryslow -crf 17 -pix_fmt yuv420p -movflags +faststart "ice_cream_factory.mp4"
	PAUSE
POPD
ENDLOCAL
