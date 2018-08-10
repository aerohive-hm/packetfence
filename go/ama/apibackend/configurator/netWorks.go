/*netWorks.go implements handling REST API:
 *	/a3/api/v1/configurator/networks
 */
package configurator

type item struct {
	Id       string   `json:"id"`
	Name     string   `json:"name"`
	IpAdddr  string   `json:"ip_addr"`
	NetMask  string   `json:"netmask"`
	Vip      string   `json:"vip"`
	Type     []string `json:"type"`
	Services []string `json:"services"`
}

type Networks struct {
	ClusterEnable string `json:"cluster_enable"`
	HostName      string `json:"hostname"`
	Items         []item `json:"items"`
}
