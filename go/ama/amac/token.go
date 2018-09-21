/*
	The file implements the below APIs:
	1) update/read RDC token
	2) distribute a new RDC token for every node if RDC token is updated
 	3) request RDC token from other nodes if no valid RDC token
 	4) fetch a RDC token with GDC token
*/

package amac

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	innerClient "github.com/inverse-inc/packetfence/go/ama/client"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

var (
	tokenLock = new(sync.RWMutex)
)

type MemberList struct {
	IpAddr string `json:"ipAddr"`
}

type tokenCommonHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	VhmId     string `json:"vhmId"`
	OwnerId   int64  `json:"ownerId"`
	OrgId     int64  `json:"orgId"`
	MessageID string `json:"messageId,omitempty"`
}

type rdcTokenReqFromRdc struct {
	Header tokenCommonHeader `json:"header"`
}

type NodeInfo struct {
	SystemID string
	Hostname string
}

type CloudInfo struct {
	RdcUrl  string `json:"rdcurl"`
	VhmID   string `json:"vhmID"`
	Switch  string `json:"switch"`
	OrgID   string `json:"orgId"`
	Token   string `json:"rdctoken"`
	PriNode string `json:"primarynode"`
	Region	string `json:"region"`
}

type tokenResData struct {
	MsgType string `json:"msgType"`
	Token   string `json:"token"`
	Region  string `json:"region"`
}

type A3TokenResFromRdc struct {
	Header tokenCommonHeader `json:"header"`
	Data   tokenResData      `json:"data"`
}

//Fetch node list from cluster.conf
func fetchNodeList() []MemberList {
	conf := a3config.A3Read("CLUSTER", "all")
	if conf == nil {
		return nil
	}
	nodes := []MemberList{}
	ownMgtIP := utils.GetOwnMGTIp()
	for secName, kvpair := range conf {
		if secName == "CLUSTER" {
			continue
		}
		for k, v := range kvpair {
			if k == "management_ip" && v != ownMgtIP {
				node := MemberList{IpAddr: v}
				nodes = append(nodes, node)
			}
		}
	}
	return nodes
}

func readRdcToken(ctx context.Context) string {
	if len(rdcTokenStr) != 0 {
		return rdcTokenStr
	}

	tokenLock.Lock()
	file, error := os.OpenFile("/usr/local/pf/conf/token.txt", os.O_RDWR|os.O_CREATE, 0600)
	if error != nil {
		fmt.Println(error)
	}
	content, _ := ioutil.ReadAll(file)
	file.Close()
	//update the variable to aviod multi IO
	rdcTokenStr = string(content)
	tokenLock.Unlock()
	return rdcTokenStr
}

func UpdateRdcToken(ctx context.Context, s string, reOnboard bool) {
	tokenLock.Lock()
	file, error := os.OpenFile("/usr/local/pf/conf/token.txt", os.O_RDWR|os.O_CREATE, 0600)
	if error != nil {
		log.LoggerWContext(ctx).Error(error.Error())
		tokenLock.Unlock()
		return
	}
	_, _ = io.WriteString(file, s) //write file(string)

	file.Close()
	//update the variable to aviod multi IO
	rdcTokenStr = s
	tokenLock.Unlock()

	if reOnboard == true {
		updateRDCInfo()
		event := new(MsgStru)
		event.MsgType = RdcTokenUpdate
		MsgChannel <- *event
	}
	return
}

//Reading the RDC's region based on the URL
func GetRdcRegin(rdcUrl string) string {
	if rdcUrl == "" {
		return ""
	}
	//Removing the https://, the key not includ to contain https://
	//Becaust the limitation of the ini package
	a1 := strings.Split(rdcUrl, "//")[1]
	a2 := strings.Split(a1, "/")[0]

	//Reading the conf file
	region := a3config.ReadRdcRegion(a2)

	/*
		Region will return null in two cases:
		1) on-premise deployment
		2) Adding a new RDC, but not sychronize to the static mapping file
	*/
	if region == "" {
		return ""
	} else {
		return region
	}
}

/*
	This function needs to be called if request RDC token
	for the other nodes, this func will be called by webUI
	it is public
*/
func ReqTokenForOtherNode(ctx context.Context, node NodeInfo) tokenResData {
	//	var url string
	var res tokenResData
	tokenRes := A3TokenResFromRdc{}

	nodeInfo := fillRdcTokenReqHeader(&node)

	data, _ := json.Marshal(nodeInfo)
	reader := bytes.NewReader(data)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Begin to fetch RDC token for node %s, url:%s", node.Hostname, fetchRdcTokenUrlForOthers))

	request, err := http.NewRequest("POST", fetchRdcTokenUrlForOthers, reader)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return res
	}

	request.Header.Add("Authorization", rdcTokenStr)
	request.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(request)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return res
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive the response %s", resp.Status))
	log.LoggerWContext(ctx).Info(string(body))

	statusCode := resp.StatusCode
	//Unmarshal only when statusCode equal 200
	if statusCode == 200 {
		err = json.Unmarshal([]byte(body), &tokenRes)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return res
		}

		if tokenRes.Data.MsgType != "amac_token" {
			log.LoggerWContext(ctx).Error("Incorrect message type")
			return res
		}

		res.MsgType = "amac_token"
		res.Token = tokenRes.Data.Token
		res.Region = tokenRes.Data.Region
		return res
	} else {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Request RDC token fail, receive the response %s", resp.Status))
		return res
	}
}

//This API was used by nodes without GDC and RDC token.
func reqTokenFromSingleNode(ctx context.Context, mem MemberList) []byte {
	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/rdctoken?systemID=%s&hostname=%s", mem.IpAddr, utils.GetA3SysId(), utils.GetHostname())
	log.LoggerWContext(ctx).Info(fmt.Sprintf("begin to get token from %s", url))

	node := new(innerClient.Client)
	node.Host = mem.IpAddr
	err := node.ClusterSend("GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return nil
	}

	//The body content is token
	body := node.RespData

	return body
}

/*
	This function needs to be called if the RDC token is absent
	or expires
*/
func ReqTokenFromOtherNodes(ctx context.Context, node *MemberList) int {

	//mockup the active node list
	memList := []MemberList{}

	if node == nil {
		memList = append(memList, fetchNodeList()...)
	} else {
		memList = append(memList, *node)
	}
	nodeNum := 0
	var tokenRegion tokenResData

	log.LoggerWContext(ctx).Info("begin to request RDC token from other nodes")

	for _, mem := range memList {
		nodeNum++
		jsonData := reqTokenFromSingleNode(ctx, mem)
		err := json.Unmarshal(jsonData, &tokenRegion)
		if err != nil {
			log.LoggerWContext(ctx).Error("Unmarshal failed: " + err.Error())
			continue
		}
		if len(tokenRegion.Token) > 0 {
			dst := fmt.Sprintf("Bearer %s", tokenRegion.Token)
			UpdateRdcToken(ctx, dst, true)
			err = a3config.UpdateCloudConf(a3config.Region, tokenRegion.Region)
			if err != nil {
				log.LoggerWContext(ctx).Error("Save region error: " + err.Error())
				continue
			}
			return 0
		}
	}
	if nodeNum >= 1 && tokenRegion.Token == "" {
		log.LoggerWContext(ctx).Error("Requeting token from other nodes fail")
	}
	return -1
}

//Fetch systemID for one Node -- Todo
func FetchSysIDForNode(node MemberList) string {
	return ""
}

func distributeToSingleNode(ctx context.Context, mem a3config.NodeInfo, selfRenew bool) {
	cloudInfo := CloudInfo{}
	if selfRenew == false {
		tokenRegion := ReqTokenForOtherNode(ctx, NodeInfo{})
		cloudInfo.Token = tokenRegion.Token
		cloudInfo.Region = tokenRegion.Region
	} else {
		cloudInfo.RdcUrl = rdcUrl
		cloudInfo.Switch = GlobalSwitch
		cloudInfo.VhmID = VhmidStr
		cloudInfo.PriNode = utils.GetOwnMGTIp()
		cloudInfo.OrgID = OrgIdStr
	}
	jsonData, _ := json.Marshal(cloudInfo)
	//reader := bytes.NewReader(token)
	//Using loop to make sure post successfully
	for {
		url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/rdctoken", mem.IpAddr)
		node := new(innerClient.Client)
		node.Host = mem.IpAddr
		err := node.ClusterSend("POST", url, string(jsonData))
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return
		}
		statusCode := node.Status

		if statusCode == 200 {
			return
		} else if statusCode == 504 { //Gateway Timeout
			//keep on trying to post util success
			time.Sleep(5 * time.Second)
			//continue
			return
		}
		//Other errors will return
		return
	}
	return
}

/*
	If receiving the GDC para and get a new RDC token actively,
	calling this function to focus on the below things:
	1) Geting the list of active nodes in the cluser, include the materials
	   of generating the RDC token
	2) If selfRenew is false, will requesting a token for every node,
	   and posting the new token to every node actively;
	3) If selfRenew is true, will notice every node to renew RDC token by itself.
*/
func TriggerUpdateNodesToken(ctx context.Context, selfRenew bool) {
	nodeList := a3config.ClusterNew().FetchNodesInfo()
	ownMgtIp := utils.GetOwnMGTIp()
	for _, node := range nodeList {
		if node.IpAddr == ownMgtIp {
			continue
		}
		go distributeToSingleNode(ctx, node, selfRenew)
	}

	return
}

func fillRdcTokenReqHeader(node *NodeInfo) rdcTokenReqFromRdc {
	rdcTokenReq := rdcTokenReqFromRdc{}

	//Only SystemID, ClusterID and Hostname is necessary when request RDC token
	if node == nil {
		rdcTokenReq.Header.SystemID = utils.GetA3SysId()
		rdcTokenReq.Header.Hostname = utils.GetHostname()
	} else {
		rdcTokenReq.Header.SystemID = node.SystemID
		rdcTokenReq.Header.Hostname = node.Hostname
	}
	rdcTokenReq.Header.ClusterID = utils.GetClusterId()

	return rdcTokenReq
}

/*
	This func is used to fetch the token from RDC, the requset message only
	need to include the GDC token
*/
func fetchTokenFromRdc(ctx context.Context) (string, string) {
	tokenRes := A3TokenResFromRdc{}

	if fetchRdcTokenUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return "", UrlIsNull
	}

	node_info := fillRdcTokenReqHeader(nil)
	data, _ := json.Marshal(node_info)

	log.LoggerWContext(ctx).Info(fmt.Sprintf("begin to fetch RDC token from %s", fetchRdcTokenUrl))
	log.LoggerWContext(ctx).Info(string(data))
	reader := bytes.NewReader(data)

	request, err := http.NewRequest("POST", fetchRdcTokenUrl, reader)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return "", OtherError
	}

	//Taking the GDC token to request a RDC token
	log.LoggerWContext(ctx).Info(fmt.Sprintf("Including the GDC token %s", gdcTokenStr))
	request.Header.Add("Authorization", gdcTokenStr)
	request.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(request)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return "", SrvNoResponse
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	log.LoggerWContext(ctx).Info(string(body))

	statusCode := resp.StatusCode

	if statusCode == 200 {
		err = json.Unmarshal([]byte(body), &tokenRes)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return "", ErrorMsgFromSrv
		}
		if tokenRes.Data.MsgType != "amac_token" {
			log.LoggerWContext(ctx).Error("Incorrect message type")
			return "", ErrorMsgFromSrv
		}
		dst := fmt.Sprintf("Bearer %s", tokenRes.Data.Token)
		//RDC token need to write file, if process restart we can read it
		UpdateRdcToken(ctx, dst, false)

		//save region
		err = a3config.UpdateCloudConf(a3config.Region, tokenRes.Data.Region)
		if err != nil {
			log.LoggerWContext(ctx).Error("Save region error: " + err.Error())
		}
		
		//Save RDC url and VHM to config file if get the RDC token
		//To do, inform the BE to synchronize the config file
		err = a3config.UpdateCloudConf(a3config.RDCUrl, rdcUrl)
		if err != nil {
			log.LoggerWContext(ctx).Error("Save RDC URL error: " + err.Error())
		}

		//save ownerId
		err = a3config.UpdateCloudConf(a3config.OwnerId, OwnerIdStr)
		if err != nil {
			log.LoggerWContext(ctx).Error("Save ownerId error: " + err.Error())
		}

		//Save vhmid
		VhmidStr = tokenRes.Header.VhmId
		err = a3config.UpdateCloudConf(a3config.Vhm, VhmidStr)
		if err != nil {
			log.LoggerWContext(ctx).Error("Save vhmId error: " + err.Error())
		}

		//save orgid
		OrgIdStr := fmt.Sprintf("%d", tokenRes.Header.OrgId)
		err = a3config.UpdateCloudConf(a3config.OrgId, OrgIdStr)
		if err != nil {
			log.LoggerWContext(ctx).Error("Save orgId error: " + err.Error())
		}

		return dst, ConnCloudSuc
	} else if statusCode == 401 {
		return "", AuthFail
	} else if statusCode == 403 {
		return "", LimitedAccess
	}
	log.LoggerWContext(ctx).Error(fmt.Sprintf("Server(RDC) respons the code %d, please check the credential", statusCode))
	return "", AccessFail
}
