#!/system/bin/sh
# Manual KernelSU action: stock -> 60 FPS -> 120 FPS + combat fix -> stock
set -eu
MODDIR=${0%/*}
PKG=com.aspyr.swkotor
ORIG=a226ac4f6c7bdcdd8d584f5423cd1912c746757ee79939fef417b9c9243b7d52
FPS60=175fa822bf28abbe8e853467b04752b3838f7bdebffeafca7c486052fe8e0924
FPS120=e0ae12c7f846caf4ace0f7a90df2c9549db07c6c31282969363054fdc7eadbde
LOCK=/data/local/tmp/kotor_fps_toggle.lock
STAGE60=/data/local/tmp/kotor_unified_60_libKOTOR.so
STAGE120=/data/local/tmp/kotor_unified_120_libKOTOR.so

fail() { echo "ERROR: $*"; exit 1; }
gethash() { sha256sum "$1" | cut -d ' ' -f 1; }
[ "$(id -u)" = 0 ] || fail 'Root required.'
mkdir "$LOCK" 2>/dev/null || fail "Another FPS switch is in progress (or stale lock: $LOCK)."
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT HUP INT TERM
[ -f "$MODDIR/libKOTOR_60.so" ] || fail 'Missing 60 FPS payload.'
[ -f "$MODDIR/libKOTOR_120.so" ] || fail 'Missing 120 FPS payload.'
[ "$(gethash "$MODDIR/libKOTOR_60.so")" = "$FPS60" ] || fail '60 FPS payload checksum mismatch.'
[ "$(gethash "$MODDIR/libKOTOR_120.so")" = "$FPS120" ] || fail '120 FPS payload checksum mismatch.'
APK=$(pm path "$PKG" | sed -n 's/^package://p' | grep '/base.apk$' | head -n 1)
[ -n "$APK" ] || fail 'KOTOR base.apk not found.'
TARGET="${APK%/base.apk}/lib/arm64/libKOTOR.so"
[ -f "$TARGET" ] || fail "KOTOR ARM64 library not found: $TARGET"
CURRENT=$(gethash "$TARGET")
case "$CURRENT" in
 "$ORIG") NEXT=60; SRC="$MODDIR/libKOTOR_60.so"; STAGE="$STAGE60"; EXPECTED="$FPS60" ;;
 "$FPS60") NEXT=120; SRC="$MODDIR/libKOTOR_120.so"; STAGE="$STAGE120"; EXPECTED="$FPS120" ;;
 "$FPS120") NEXT=stock ;;
 *) fail "Unrecognized installed/mounted library: $CURRENT. No changes made." ;;
esac
# Stage and checksum the new payload before stopping game or changing mounts.
if [ "$NEXT" != stock ]; then
 cp "$SRC" "$STAGE" || fail 'Cannot stage library.'
 chown 0:0 "$STAGE" || fail 'Cannot set ownership.'
 chmod 755 "$STAGE" || fail 'Cannot set permissions.'
 # Match the exact original library SELinux context where supported.
 chcon --reference="$TARGET" "$STAGE" 2>/dev/null || chcon u:object_r:apk_data_file:s0 "$STAGE" || fail 'Cannot set SELinux context.'
 [ "$(gethash "$STAGE")" = "$EXPECTED" ] || fail 'Staged library checksum mismatch.'
fi
am force-stop "$PKG" || fail 'Cannot force-stop KOTOR.'
if [ "$CURRENT" != "$ORIG" ]; then
 echo 'Unmounting current FPS patch...'
 umount "$TARGET" || fail 'Cannot unmount current patch. No new patch applied.'
 UNDER=$(gethash "$TARGET")
 [ "$UNDER" = "$ORIG" ] || fail "Unexpected underlying library ($UNDER). Do not launch until mount stack is inspected."
fi
if [ "$NEXT" = stock ]; then
 echo 'SUCCESS: STOCK 40 FPS restored. Next Action: 60 FPS.'
 exit 0
fi
if ! mount -o bind "$STAGE" "$TARGET"; then
 fail 'Bind mount failed. Stock library is currently visible.'
fi
NOW=$(gethash "$TARGET")
if [ "$NOW" != "$EXPECTED" ]; then
 umount "$TARGET" 2>/dev/null || true
 fail "Mounted library checksum mismatch ($NOW)."
fi
if [ "$NEXT" = 60 ]; then
 echo 'SUCCESS: 60 FPS ACTIVE. Next Action: 120 FPS + combat fix.'
else
 echo 'SUCCESS: 120 FPS + COMBAT MOVEMENT FIX ACTIVE. Next Action: stock 40 FPS.'
fi
