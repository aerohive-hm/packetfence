package a3config

import (
//	"fmt"
//"regexp"
)

var pfPath = ConfRoot + "/" + pfConf

func UpdateEmail(email string) error {
	section := Section{
		"alerting": {
			"emailaddr": email,
		},
	}
	return pfCommit(section)
}

func UpdateHostname(hostname string) error {
	section := Section{
		"general": {
			"hostname": hostname,
		},
	}
	return pfCommit(section)
}

func GetHostname() string {
	section := pfRead("general")
	if section == nil {
		return ""
	}
	return section["general"]["hostname"]
}

func GetWebServices() Section {
	return pfRead("webservices")
}

func UpdateIface() {

}
func ReadIface(ifname string) Section {
	if ifname != "all" {
		return pfRead(ifname)
	}
	return nil
}
