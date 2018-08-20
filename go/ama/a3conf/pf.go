package a3config

import (
//	"fmt"
//"regexp"
)

func UpdateEmail(email string) error {
	section := Section{
		"alerting": {
			"emailaddr": email,
		},
	}
	return A3Commit("PF", section)
}

func UpdateHostname(hostname string) error {
	section := Section{
		"general": {
			"hostname": hostname,
		},
	}
	return A3Commit("PF", section)
}

func GetHostname() string {
	section := A3Read("PF", "general")
	if section == nil {
		return ""
	}
	return section["general"]["hostname"]
}

func GetWebServices() Section {
	return A3Read("PF", "webservices")
}

func UpdateIface() {

}
func ReadIface(ifname string) Section {
	if ifname != "all" {
		return A3Read("PF", ifname)
	}
	return nil
}
