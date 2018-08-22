package amac

import (
	"errors"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"net/url"
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
	_ = update("")
}

func update(pass string) error {
	gdcUrl = a3config.ReadCloudConf(a3config.GDCUrl)
	if len(gdcUrl) == 0 {
		return errors.New("Fetch GDC Url failed")
	}
	tokenUrl = gdcUrl + "/oauth/cookietoken"
	vhmidUrl = gdcUrl + "/services/acct/selectvhm"
	userName = a3config.ReadCloudConf(a3config.User)
	if len(userName) != 0 {
		userName = url.QueryEscape(userName)
	}
	if pass != "" {
		password = url.QueryEscape(pass)
	}
	return nil
}
