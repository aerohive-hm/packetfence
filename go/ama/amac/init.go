package amac

import (
	"errors"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"net/url"
	"strconv"
)

var (
	//package variable to store the URL of HM
	gdcUrl            string
	rdcUrl            string
	tokenUrl          string
	vhmidUrl          string
	userName          string
	password          string
	globalSwitch      string //enable/disable the cloud integration
	keepaliveInterval int
)

func UpdateConnSwitch(action string) error{
	switchConf := a3config.ReadCloudConf(a3config.Switch)
	if switchConf != action {
		err := a3config.UpdateCloudConf(a3config.Switch, action)
		if err != nil {
			return err
		}
	}
	globalSwitch = action
	return nil
}

func init() {
	_ = update("")
	if len(globalSwitch) == 0 {
		UpdateConnSwitch("disable")
	}
}

func update(pass string) error {
	gdcUrl = a3config.ReadCloudConf(a3config.GDCUrl)
	if len(gdcUrl) == 0 {
		return errors.New("Fetch GDC Url failed")
	}
	tokenUrl = gdcUrl + "/oauth/cookietoken"
	vhmidUrl = gdcUrl + "/services/acct/selectvhm"

	rdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	//Not check the rdcUrl if NULL
	if len(rdcUrl) != 0 {
		installRdcUrl(nil, rdcUrl)
	}

	userName = a3config.ReadCloudConf(a3config.User)
	if len(userName) != 0 {
		userName = url.QueryEscape(userName)
	}
	if pass != "" {
		password = url.QueryEscape(pass)
	}
	//If not specify the interval, write default value to conf
	intervalStr := a3config.ReadCloudConf(a3config.Interval)
	if intervalStr == "" {
		err := a3config.UpdateCloudConf(a3config.Interval, "30") //30 second by default
		if err != nil {
			return errors.New("Set keepalive interval failed")
		}
		keepaliveInterval = 30
	} else {
		keepaliveInterval, _ = strconv.Atoi(intervalStr)
	}

	globalSwitch = a3config.ReadCloudConf(a3config.Switch)

	return nil
}

func updateRDCInfo() {
	rdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	//Not check the rdcUrl if NULL
	if len(rdcUrl) != 0 {
		installRdcUrl(nil, rdcUrl)
	}

	globalSwitch = a3config.ReadCloudConf(a3config.Switch)

	VhmidStr = a3config.ReadCloudConf(a3config.Vhm)

	OrgIdStr = a3config.ReadCloudConf(a3config.OrgId)
}