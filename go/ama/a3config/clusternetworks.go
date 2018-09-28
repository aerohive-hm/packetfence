//clusternetworks.go implements handle for /api/v1/configurator/cluster/networks.
package a3config

import (
	"context"
	"fmt"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/log"
)

type ClusterNetworksData struct {
	Hostname string `json:"hostname"`
	SysId    string `json:"system_id,omitempty"`
	Items    []Item `json:"items"`
}

func GetClusterNetworksData(ctx context.Context, primaryData NetworksData) ClusterNetworksData {
	clusterNetworksData := ClusterNetworksData{}
	clusterNetworksData.Hostname = GetPfHostname()
	Items := GetItemsValue(ctx)

	for _, p := range primaryData.Items {
		if VlanInface(p.Name) {
			continue
		}
		for _, i := range Items {
			/*only append cluster management interface*/
			if VlanInface(i.Name) {
				continue
			}
			if i.Name == p.Name {
				p.IpAddr = i.IpAddr
				clusterNetworksData.Items = append(clusterNetworksData.Items, p)
				break
			}
		}
	}

	for _, p := range primaryData.Items {
		/*only append primary vlan interface*/
		if !VlanInface(p.Name) {
			continue
		}
		p.IpAddr = "0.0.0.0"
		for _, i := range Items {
			/*only append cluster vlan interface*/
			if !VlanInface(i.Name) {
				continue
			}
			if i.Name == p.Name {
				p.IpAddr = i.IpAddr
				break
			}
		}
		clusterNetworksData.Items = append(clusterNetworksData.Items, p)
	}
	/*write primary host to pf for  next step check*/
	UpdatePrimaryHostnameToClusterPF(primaryData.HostName)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusterNetworksData))
	return clusterNetworksData

}

// when cluster node join, update self networks data
func UpdateClusterNetworksData(ctx context.Context, networksData ClusterNetworksData, respData ClusterEventRespData) error {

	web := respData.Items[0]
	err := UpdateWebservices(web.User, web.Password)

	if err != nil {
		log.LoggerWContext(ctx).Error("Update Webservices account error:" + err.Error())
		return err
	}
	// update Db root password
	err = UpdateDbRootPassword(respData.DbPassword)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateDbRootPassword error:" + err.Error())
		return err
	}

	// update hostname to system and pf.conf
	err = UpdateHostname(networksData.Hostname)
	if err != nil {
		log.LoggerWContext(ctx).Error("UpdateHostname error:" + err.Error())
		return err
	}

	for _, item := range networksData.Items {
		err = UpdateInterface(item)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update Interface error:" + err.Error())
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

	ama.InitClusterStatus("server")

	return err
}
