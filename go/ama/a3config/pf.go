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

func UpdateIface() {

}

func ReadIface(ifname string) Section {
	if ifname != "all" {
		return A3Read("PF", ifname)
	}
	return nil
}

//Below is the APIs for write/read cloud.conf
//The const value as items presented in cloud.conf
const (
	GDCUrl   = "GDC_url"
	RDCUrl   = "RDC_url"
	User     = "user"
	Switch   = "switch" //Enable/Disable connection.
	Interval = "keepalive_interval"
	Vhm      = "vhm"
)

func UpdateCloudConf(key string, value string) error {
	section := Section{
		"general": {
			key: value,
		},
	}
	return A3Commit("CLOUD", section)
}

func ReadCloudConf(key string) string {
	if len(key) == 0 {
		return ""
	}
	section := A3Read("CLOUD", "general")
	return section["general"][key]
}

func ReadCloudConfAll() Section {
	return A3Read("CLOUD", "general")
}
