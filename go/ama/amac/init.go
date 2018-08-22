package amac

import (
//"fmt"
)

var (

	//package variable to store the URL of HM
	gdcUrl   string
	rdcUrl   string
	tokenUrl string
	vhmidUrl string
	userName string
	password string
	enable   string //enable/disable the cloud integration
)

func init() {
	gdcUrl = "https://10.155.23.116.17/acct-webapp"
	tokenUrl = "https://10.155.23.116/acct-webapp/oauth/cookietoken"
	vhmidUrl = "https://10.155.23.116/acct-webapp/services/acct/selectvhm"
	userName = "admin%40cust001.com"
	password = "aerohive"
	enalbe = "true"
	rdcUrl = "https://10.155.23.116.17"
}
