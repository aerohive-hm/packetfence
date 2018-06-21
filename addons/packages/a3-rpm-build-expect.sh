#!/usr/bin/expect -f
set timeout 600
set password "a3r0hiv3"
#set signfile [lindex $argv 0]
#set outfile  [lindex $argv 1]
set VERSION [lindex $argv 0]
set DIST [lindex $argv 1]
set DATE [lindex $argv 2]
set BUILD_DIR [lindex $argv 3]
#spawn ./sign_image.sh $signfile  testprivatekey.pem $outfile
spawn rpmbuild -ba --sign --define "ver $VERSION" --define "snapshot 1" --define "dist $DIST" --define "rev 0.$DATE" $BUILD_DIR/SPECS/A3.spec 
expect {
"Enter pass phrase:" {send "$password\r"}
}
expect eof
exit
