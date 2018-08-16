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
)

func init() {
	gdcUrl = "https://10.155.100.17/acct-webapp"
	tokenUrl = "https://10.155.100.17/acct-webapp/oauth/cookietoken"
	vhmidUrl = "https://10.155.100.17/acct-webapp/services/acct/selectvhm"
	userName = "admin%40cust001.com"
	password = "aerohive"
}
