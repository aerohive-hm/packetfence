package a3config

//	"fmt"
//"regexp"

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

func ReadIface(ifname string) Section {
	if ifname != "all" {
		return A3Read("PF", ifname)
	}
	return nil
}
