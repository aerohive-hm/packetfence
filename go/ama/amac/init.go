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
	GlobalSwitch      string //enable/disable the cloud integration
	KeepaliveInterval int
	ReportInterval    int
)

func UpdateConnSwitch(action string) error {
	switchConf := a3config.ReadCloudConf(a3config.Switch)
	if switchConf != action {
		err := a3config.UpdateCloudConf(a3config.Switch, action)
		if err != nil {
			return err
		}
	}
	GlobalSwitch = action
	return nil
}

func init() {
	_ = update("")
	if len(GlobalSwitch) == 0 {
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
	//If not specify the keepalive interval, write default value to conf
	intervalStr := a3config.ReadCloudConf(a3config.Interval)
	if intervalStr == "" {
		err := a3config.UpdateCloudConf(a3config.Interval, "30") //30 second by default
		if err != nil {
			return errors.New("Set keepalive interval failed")
		}
		KeepaliveInterval = 30
	} else {
		KeepaliveInterval, _ = strconv.Atoi(intervalStr)
	}

	//If not specify the report interval, write default value to conf
	reportIntervalStr := a3config.ReadCloudConf(a3config.ReportInterval)
	if reportIntervalStr == "" {
		err := a3config.UpdateCloudConf(a3config.ReportInterval, "30") //30 second by default
		if err != nil {
			return errors.New("Set report interval failed")
		}
		ReportInterval = 30
	} else {
		ReportInterval, _ = strconv.Atoi(reportIntervalStr)
	}

	//If not specify the sync interval, write default value to conf
	syncIntervalStr := a3config.ReadCloudConf(a3config.SyncInterval)
	if syncIntervalStr == "" {
		err := a3config.UpdateCloudConf(a3config.SyncInterval, "3600") //3600 second by default
		if err != nil {
			return errors.New("Set sync interval failed")
		}
	}
	
	GlobalSwitch = a3config.ReadCloudConf(a3config.Switch)

	return nil
}

func updateRDCInfo() {
	rdcUrl = a3config.ReadCloudConf(a3config.RDCUrl)
	//Not check the rdcUrl if NULL
	if len(rdcUrl) != 0 {
		installRdcUrl(nil, rdcUrl)
	}

	GlobalSwitch = a3config.ReadCloudConf(a3config.Switch)

	VhmidStr = a3config.ReadCloudConf(a3config.Vhm)

	OrgIdStr = a3config.ReadCloudConf(a3config.OrgId)
}
