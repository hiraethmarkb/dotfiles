# MPD daemon start (if no other user instance exists)
[ ! -s ~/.mpd/pid ] && mpd

export CHROMIUM_USER_FLAGS="–enable-plugins –enable-extensions –enable-user-scripts –enable-printing –enable-sync –auto-ssl-client-auth –ppapi-flash-path=/usr/lib64/chromium-browser/pepper/libpepflashplayer.so"
