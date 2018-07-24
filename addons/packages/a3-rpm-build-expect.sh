#!/usr/bin/expect -f
set timeout 600
set VERSION [lindex $argv 0]
set DIST [lindex $argv 1]
set DATE [lindex $argv 2]
set BUILD_DIR [lindex $argv 3]
set PASSPHRASE [lindex $argv 4]
set BUILD_TYPE $::env(BUILD_TYPE)
puts $BUILD_TYPE
#spawn ./sign_image.sh $signfile  testprivatekey.pem $outfile
if {$BUILD_TYPE eq "RELEASE"} {
  spawn rpmbuild -ba --sign --define "ver $VERSION"  --define "snapshot 1" --define "dist $DIST" --define "rev 0.$DATE" --define "release_build 1" $BUILD_DIR/SPECS/A3.spec 
} else {
  spawn rpmbuild -ba --sign --define "ver $VERSION"  --define "snapshot 1" --define "dist $DIST" --define "rev 0.$DATE" --define "release_build 0" $BUILD_DIR/SPECS/A3.spec 
}
expect {
"Enter pass phrase:" {send "$PASSPHRASE\r"}
}
expect eof
exit
