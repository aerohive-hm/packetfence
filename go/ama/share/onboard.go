//onboard.go implements fetching onboarding info.
package a3share

import (
	"context"
	"fmt"
	"strconv"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/database"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type A3Interface struct {
	Parent    string   `json:"parent"`
	Vlan      int      `json:"vlan,omitempty"`
	IpAddress string   `json:"ipAddress"`
	Vip       string   `json:"vip"`
	Netmask   string   `json:"netmask"`
	Type      string   `json:"type"`
	Service   []string `json:"services"`
	//	Description string   `json:"description"`
}
type A3License struct {
	LicensedCapacity    int   `json:"licensedCapacity"`
	CurrentUsedCapacity int   `json:"currentUsedCapacity"`
	AverageUsedCapacity int   `json:"averageUsedCapacity"`
	NextExpirationDate  int64 `json:"nextExpirationDate"`
}

type A3OnboardingData struct {
	Msgtype         string        `json:"msgType"`
	MacAddress      string        `json:"macAddress"`
	IpMode          string        `json:"ipMode"`
	IpAddress       string        `json:"ipAddress"`
	Netmask         string        `json:"netmask"`
	DefaultGateway  string        `json:"defaultGateway"`
	SoftwareVersion string        `json:"softwareVersion"`
	SystemUptime    int64         `json:"systemUpTime"`
	Vip             string        `json:"vip"`
	ClusterHostName string        `json:"clusterHostName,omitempty"`
	ClusterPrimary  bool          `json:"clusterPrimary"`
	Interfaces      []A3Interface `json:"interfaces"`
	License         A3License     `json:"license"`
}

type A3OnboardingHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	MessageID string `json:"messageId"`
}

type A3OnboardingInfo struct {
	Header A3OnboardingHeader `json:"header"`
	Data   A3OnboardingData   `json:"data"`
}

var contextOnboard = log.LoggerNewContext(context.Background())

func (onboardingData *A3OnboardingData) GetValue(ctx context.Context) {
	ifaces, errint := utils.GetIfaceList("all")
	if errint < 0 {
		fmt.Errorf("Get interfaces infomation failed.")
		return
	}
	for _, iface := range ifaces {
		a3Interface := new(A3Interface)

		if iface.Master == "" {
			a3Interface.Parent = iface.Name
		} else {
			a3Interface.Parent = iface.Master
		}

		a3Interface.Vlan, _ = strconv.Atoi(iface.Vlan)
		a3Interface.IpAddress = iface.IpAddr
		value, _ := strconv.Atoi(iface.NetMask)
		a3Interface.Netmask = utils.NetmaskLen2Str(value)
		a3Interface.Vip = a3config.GetPrimaryClusterVip(iface.Name)
		a3Interface.Type = a3config.GetIfaceType(iface.Name)
		a3Interface.Service = a3config.GetIfaceServices(iface.Name)
		onboardingData.Interfaces = append(onboardingData.Interfaces, *a3Interface)
	}

	onboardingData.Msgtype = "connect"
	onboardingData.IpMode = "STATIC"
	onboardingData.DefaultGateway = "10.155.104.254"
	onboardingData.SoftwareVersion = utils.GetA3Version()
	onboardingData.SystemUptime = time.Now().UnixNano() / int64(time.Millisecond)
	//onboardingData.ClusterHostName = "Todo"
	onboardingData.ClusterPrimary = amadb.IsPrimaryCluster()
	managementIface, errint := utils.GetIfaceList("eth0")
	if errint < 0 {
		fmt.Errorf("Get ETH0 interfaces infomation failed")
		return
	}
	for _, iface := range managementIface {
		onboardingData.MacAddress = strings.ToUpper(strings.Replace(iface.HwAddr, ":", "", -1))
		onboardingData.IpAddress = iface.IpAddr
		value, _ := strconv.Atoi(iface.NetMask)
		onboardingData.Netmask = utils.NetmaskLen2Str(value)
		onboardingData.Vip = a3config.GetPrimaryClusterVip(iface.Name)
		break
	}
	//Fetch license info
	onboardingData.License.GetValue(nil)

	return
}

func (onboardHeader *A3OnboardingHeader) GetValue(ctx context.Context) {
	onboardHeader.Hostname = a3config.GetHostname()
	onboardHeader.SystemID = utils.GetA3SysId()
	onboardHeader.ClusterID = utils.GetClusterId()
	//When onboarding, Cloud will assign a unique messageid, so we could just make it empty;
	//onboardHeader.MessageID = ""
	return
}

func (lic *A3License) GetValue(ctx context.Context) {
	var context context.Context
	if ctx == nil {
		context = contextOnboard
	} else {
		context = ctx
	}

	tmpDB := new(amadb.A3Db)
	err := tmpDB.DbInit()
	if err != nil {
		log.LoggerWContext(context).Error("Open database error: " + err.Error())
		return
	}
	db := tmpDB.Db
	defer db.Close()

	//Fetch LicensedCapacity data
	results, err := db.Query("SELECT endpoint_count FROM a3_entitlement where type != 'Trial'")
	if err != nil {
		log.LoggerWContext(context).Error("Query database error: " + err.Error())
	} else {
		defer results.Close()
		for results.Next() {
			var count int
			err := results.Scan(&count)
			if err != nil {
				log.LoggerWContext(context).Error("Scan data error: " + err.Error())
			}
			lic.LicensedCapacity += count
		}
		if lic.LicensedCapacity == 0 {
			var trialCount int
			err = db.QueryRow("SELECT endpoint_count FROM a3_entitlement where type = 'Trial'").Scan(&trialCount)
			if err != nil {
				log.LoggerWContext(context).Error("Query database error: " + err.Error())
			} else {
				lic.LicensedCapacity = trialCount
			}
		}
	}
	//Fetch NextExpirationDate
	var times time.Time
	row := db.QueryRow("SELECT max(sub_end) FROM a3_entitlement")
	err = row.Scan(&times)
	if err != nil {
		log.LoggerWContext(context).Error("Query database error: " + err.Error())
	} else {
		lic.NextExpirationDate = times.UnixNano() / int64(time.Millisecond)
	}

	//Fetch AverageUsedCapacity
	var averge int
	row = db.QueryRow("SELECT moving_avg FROM a3_daily_avg order by daily_date DESC limit 1")
	err = row.Scan(&averge)
	if err != nil {
		log.LoggerWContext(context).Error("Query database error: " + err.Error())
	} else {
		lic.AverageUsedCapacity = averge
	}

	//Fetch CurrentUsedCapacity
	var currentUsed int
	row = db.QueryRow("SELECT COUNT(*) FROM node,radacct WHERE node.mac = radacct.callingstationid AND node.status = 'reg' AND radacct.acctstarttime IS NOT NULL AND radacct.acctstoptime IS NULL")
	err = row.Scan(&currentUsed)
	if err != nil {
		log.LoggerWContext(context).Error("Query database error: " + err.Error())
	} else {
		lic.CurrentUsedCapacity = currentUsed
	}
}

func GetOnboardingInfo(ctx context.Context) A3OnboardingInfo {
	var context context.Context
	onboardInfo := A3OnboardingInfo{}

	if ctx == nil {
		context = contextOnboard
	} else {
		context = ctx
	}
	onboardInfo.Data.GetValue(context)
	onboardInfo.Header.GetValue(context)

	return onboardInfo
}
