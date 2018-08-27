package a3config

//	"fmt"
//"regexp"

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
