//clusternetworks.go implements handle for /api/v1/configurator/cluster/networks.
package a3config

import (
	"context"
	"fmt"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterNetworksData struct {
	HostName string `json:"hostname"`
	Items    []Item `json:"items"`
}

func SyncDatafromPrimary(ip, user, password string) {
	//wait a moment?
	time.Sleep(60)
	utils.SyncFromPrimary(ip, user, password)
}

func GetClusterNetworksData(ctx context.Context, primaryData NetworksData) ClusterNetworksData {
	clusterNetworksData := ClusterNetworksData{}
	clusterNetworksData.HostName = GetHostname()
	Items := GetItemsValue(ctx)

	for _, i := range Items {
		/*only append cluster management interface*/
		if VlanInface(i.Name) {
			continue
		}
		clusterNetworksData.Items = append(clusterNetworksData.Items, i)
	}

	for _, i := range primaryData.Items {
		/*only append primary vlan interface*/
		if !VlanInface(i.Name) {
			continue
		}
		i.IpAddr = "0.0.0.0"
		clusterNetworksData.Items = append(clusterNetworksData.Items, i)
	}
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusterNetworksData))
	return clusterNetworksData

}

func UpdateClusterNetworksData(ctx context.Context, networksData ClusterNetworksData, respDate ClusterEventRespData) error {

	web := respDate.Items[0]
	err := UpdateWebservices(web.User, web.Password)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateWebservices error:" + err.Error())
		return err
	}
	err = UpdateHostname(networksData.HostName)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}
	utils.SetHostname(networksData.HostName)

	for _, item := range networksData.Items {
		err = UpdateInterface(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateInterface error:" + err.Error())
			return err
		}
		err = UpdateNetconf(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("UpdateNetconf error:" + err.Error())
			return err
		}
		err = writeOneNetworkConfig(ctx, item)
		if err != nil {
			log.LoggerWContext(ctx).Error("WriteNetworkConfigs error:" + err.Error())
			return err
		}
	}

	utils.ExecShell(`systemctl start packetfence-api-frontend`)
	return err
}
