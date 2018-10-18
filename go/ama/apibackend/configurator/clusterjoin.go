/*join.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/join
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type JoinData struct {
	PrimaryServer string `json:"primary_server"`
	Admin         string `json:"admin"`
	Passwd        string `json:"passwd"`
}

type Join struct {
	crud.Crud
}

func ClusterJoinNew(ctx context.Context) crud.SectionCmd {
	join := new(Join)
	join.New()
	join.Add("POST", handleUpdateJoin)
	return join
}

// Login primary server with API: "https://PrimaryServer:9999/api/v1/login"
func handleUpdateJoin(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	join := new(JoinData)
	code := "fail"
	ret := ""

	err := json.Unmarshal(d.ReqData, join)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("Join Auth POST cluster Primary = %s, admin = %s",
		join.PrimaryServer, join.Admin))

	//write to pf.conf in order to use API client.ClusterAuth()
	a3config.WriteUserPassToPF(join.PrimaryServer, join.Admin, join.Passwd)
	//use administrative user to do authentication
	client := new(apibackclient.Client)
	client.Host = join.PrimaryServer
	err = client.ClusterAuth()
	if err != nil {
		log.LoggerWContext(ctx).Error("ClusterAuth error: " + err.Error())
		ret = CheckClusterAuthError(err)
		a3config.DeleteClusterPrimary()
		return crud.FormPostRely(code, ret)
	}
	//check mgt0 ip is the same range with primary eth0 ip
	_, primaryNetData := a3share.GetPrimaryNetworksData(ctx)
	netMask := GetEthMaskFromNetworksDate(primaryNetData)
	mgtip := utils.GetOwnMGTIp()
	if !utils.IsSameIpRange(join.PrimaryServer, mgtip, netMask) {
		ret = fmt.Sprintf("mgtip [%s] and primary ip [%s] are not the same net range", mgtip, join.PrimaryServer)
		a3config.DeleteClusterPrimary()
		return crud.FormPostRely(code, ret)
	}
	//check primary if the standalone
	_, primaryclusterData := a3share.GetPrimaryClusterStatus(ctx)
	if !primaryclusterData.Is_cluster {
		ret = fmt.Sprintf("primary [%s] is standalone.", join.PrimaryServer)
		a3config.DeleteClusterPrimary()
		return crud.FormPostRely(code, ret)
	}

	code = "ok"
	a3config.RecordSetupStep(a3config.StepClusterNetworking, code)
	a3config.Isclusterjoin = true
	return crud.FormPostRely(code, ret)
}

func CheckClusterAuthError(err error) string {
	ret := ""
	/*Detailedly distinguish error messages for A3-466*/
	if strings.Contains(err.Error(), "no route to host") {
		ret = fmt.Sprintf("Ip [%s] unreachable error", a3config.ReadClusterPrimary())
		return ret
	}
	if strings.Contains(err.Error(), "connection refused") {
		ret = fmt.Sprintf("Connection refused error")
		return ret
	}
	if strings.Contains(err.Error(), "status code is 401") {
		ret = fmt.Sprintf("User/Password error")
		return ret
	}
	if strings.Contains(err.Error(), "no such host") {
		ret = fmt.Sprintf("DNS can not be resolved error")
		return ret
	}
	return err.Error()
}

func GetEthMaskFromNetworksDate(NetworksDate a3config.NetworksData) string {
	for _, i := range NetworksDate.Items {
		if i.Name == "eth0" {
			return i.NetMask
		}
	}
	return "255.255.255.255"
}
