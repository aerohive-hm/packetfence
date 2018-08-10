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
	gdcUrl = "https://a-cloud.aerohive.com"
	tokenUrl = "https://a-cloud.aerohive.com/oauth/cookietoken"
	vhmidUrl = "https://a-cloud.aerohive.com/services/acct/selectvhm"
	userName = "juanli@aerohive.com"
	password = "Aerohive123"
}
