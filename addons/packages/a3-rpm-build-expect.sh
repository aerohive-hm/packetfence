#!/usr/bin/expect -f
set timeout 600
set VERSION [lindex $argv 0]
set DIST [lindex $argv 1]
set DATE [lindex $argv 2]
set BUILD_DIR [lindex $argv 3]
set PASSPHRASE [lindex $argv 4]
#spawn ./sign_image.sh $signfile  testprivatekey.pem $outfile
if [ "$BUILD_TYPE" != "RELEASE" ]; then
  spawn rpmbuild -ba --sign --define "ver $VERSION" --define "snapshot 1" --define "dist $DIST" --define "rev 0.$DATE" $BUILD_DIR/SPECS/A3.spec 
else 
  spawn rpmbuild -ba --sign --define "ver $VERSION" --define "dist $DIST" --define "rev 0.$DATE" $BUILD_DIR/SPECS/A3.spec 
fi  
expect {
"Enter pass phrase:" {send "$PASSPHRASE\r"}
}
expect eof
exit
