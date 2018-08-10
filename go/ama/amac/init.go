package amac

import (
//"flag"
//"fmt"
//"github.com/larspensjo/config"
//"log"
)

//const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var (
	//Setting the configuration file
	//ConfigFile = flag.String("configfile", "config.txt", "General configuration file")
	//Cfg        *config.Config
	//create map, the key field is string, the value field is string
	//Topic = make(map[string]string)

	//package variable to store the URL of HM
	gdcUrl   string
	rdcUrl   string
	tokenUrl string
	vhmidUrl string
	userName string
	password string
)

func init() {
	/*
		var err error

		//begin: analyse the configuration file
		flag.Parse()
		Cfg, err = config.ReadDefault(*ConfigFile)
		if err != nil {
			log.Fatalf("Fail to find", *ConfigFile, err)
			return
		}

		//Initialized topic from the configuration
		if Cfg.HasSection("gdc_rdc_info") {
			section, err := Cfg.SectionOptions("gdc_rdc_info")
			if err == nil {
				for _, v := range section {
					options, err := Cfg.String("gdc_rdc_info", v)
					if err == nil {
						Topic[v] = options
					}
				}
			}
		}
		//END: Analyse the configuration file

		Token_url = fmt.Sprintf("%s%s", Topic["gdc_url"], Topic["token_path"])
		Vhmid_url = fmt.Sprintf("%s%s", Topic["gdc_url"], Topic["vhmid_path"])
		Username = Topic["username"]

		//Vhmid_str = Topic["vhmid"]
		//Rdc_url = Topic["rdc_url"]
	*/
	gdcUrl = "https://a-cloud.aerohive.com"
	tokenUrl = "https://a-cloud.aerohive.com/oauth/cookietoken"
	vhmidUrl = "https://a-cloud.aerohive.com/services/acct/selectvhm"
	userName = "juanli@aerohive.com"
	password = "Aerohive123"
}
