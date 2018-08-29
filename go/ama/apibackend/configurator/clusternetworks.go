/*clusternetworks.go implements handling REST API:
 *	/a3/api/v1/configurator/cluster/networks
 */
package configurator

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
)

type clusterNetworks struct {
	crud.Crud
}

func ClusterNetworksNew(ctx context.Context) crud.SectionCmd {
	clusternet := new(clusterNetworks)
	clusternet.New()
	clusternet.Add("GET", handleGetClusterNetwork)
	clusternet.Add("POST", handleUpdateClusterNetwork)
	return clusternet
}

// Get network data from master
// Send request to call master API: /a3/api/v1/configurator/networks
func handleGetClusterNetwork(r *http.Request, d crud.HandlerData) []byte {

	var jsonData []byte
	var myIpAddr string
	ctx := r.Context()

	// get hostname, eth0 from self
	clusternet := a3config.GetClusterNetworksData(ctx)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("get hostname %s from self", clusternet.HostName))

	
	for _, i := range clusternet.Items {
		myIpAddr = i.IpAddr
		log.LoggerWContext(ctx).Info(fmt.Sprintf("get %s %s %s from self", i.Name, i.IpAddr, i.NetMask))
	}
	
	// get cluster network data from primary	
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/configurator/networks", a3config.ReadClusterPrimary())
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster network data from %s", url))

	client := new(apibackclient.Client)
	client.Host = a3config.ReadClusterPrimary()
	err := client.ClusterSend(ctx, "GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	body := client.RespData
	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster network data:%s", string(body)))

	networkData := new(a3config.NetworksData)
	err = json.Unmarshal(body, networkData)

	for _, i := range networkData.Items {
		log.LoggerWContext(ctx).Info(fmt.Sprintf("get %s %s %s from self", i.Name, i.IpAddr, i.NetMask))
		if i.Name == "eth0" {
			i.IpAddr = myIpAddr			 
		}
			
		clusternet.Items = append(clusternet.Items, i)
	}
	clusternet.Items = clusternet.Items[1:]
	// get item data append to clusternet
	//TODO

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", clusternet))
	jsonData, err = json.Marshal(clusternet)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
		
	return jsonData
}

func handleUpdateClusterNetwork(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	//clusternet := new(a3config.ClusterNetworksData)

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/join", a3config.ReadClusterPrimary())

	log.LoggerWContext(ctx).Info(fmt.Sprintf("read cluster network data from %s", url))

	client := new(apibackclient.Client)
	client.Host = a3config.ReadClusterPrimary()
	err := client.ClusterSend(ctx, "POST", url, string(d.ReqData))
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte(err.Error())
	}

	body := client.RespData
	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive from cluster primay data:%s", string(body)))	
	//TODO check if need to write account to pf.conf


	return []byte(crud.PostOK)
}
