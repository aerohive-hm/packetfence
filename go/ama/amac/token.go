/*
	The file implements the below APIs:
	1) update/read RDC token
	2) distribute a new RDC token for every node if RDC token is updated
 	3) request RDC token from other nodes if no valid RDC token
 	4) fetch a RDC token with GDC token
*/

package amac

import (
	//	"bytes"
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
	"strconv"
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
	VhmName   string `json:"vhmName"`
	OwnerId   int    `json:"ownerId"`
	OrgId     int    `json:"orgId"`
	MessageID string `json:"messageId"`
}

type rdcTokenReqFromRdc struct {
	Header tokenCommonHeader `json:"header"`
}

type tokenResData struct {
	MsgType string `json:"msgType"`
	Token   string `json:"token"`
}

type A3TokenResFromRdc struct {
	Header tokenCommonHeader `json:"header"`
	Data   tokenResData      `json:"data"`
}

//Fetch node list from cluster.conf
func FetchNodeList() []MemberList {
	conf := a3config.A3Read("CLUSTER", "all")
	if conf == nil {
		return nil
	}
	nodes := []MemberList{}
	headNode := []MemberList{}
	for secName, kvpair := range conf {
		is_primary := (secName == "CLUSTER")
		for k, v := range kvpair {
			if k == "management_ip" {
				node := MemberList{IpAddr: v}
				if is_primary {
					headNode = append(headNode, node)
				} else {
					nodes = append(nodes, node)
				}
			}
		}
	}
	nodes = append(headNode, nodes...)
	return nodes
}

func readRdcToken(ctx context.Context) string {
	tokenLock.Lock()
	if len(rdcTokenStr) != 0 {
		return rdcTokenStr
	}

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

func UpdateRdcToken(ctx context.Context, s string) {
	tokenLock.Lock()
	file, error := os.OpenFile("/usr/local/pf/conf/token.txt", os.O_RDWR|os.O_CREATE, 0600)
	if error != nil {
		log.LoggerWContext(ctx).Error(error.Error())
		return
	}
	_, _ = io.WriteString(file, s) //write file(string)

	file.Close()
	//update the variable to aviod multi IO
	rdcTokenStr = s
	tokenLock.Unlock()
	return
}

/*
	This function needs to be called if request RDC token
	for the other nodes, this func will be called by webUI
	it is public
*/
func ReqTokenForOtherNode(ctx context.Context, sysId string) []byte {
	var url string
	var res []byte
	tokenRes := A3TokenResFromRdc{}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("request token for the node %s", sysId))
	url = fmt.Sprintf("http://10.155.23.116:8008/rest/v1/token/1234567?targetSysId=%s", sysId)

	request, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return res
	}

	request.Header.Add("X-A3-Auth-Token", rdcTokenStr)
	request.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(request)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return res
	}

	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println("receive the response ", resp.Status)
	fmt.Println(string(body))

	err = json.Unmarshal([]byte(body), &tokenRes)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return res
	}

	if tokenRes.Data.MsgType != "amac_token" {
		log.LoggerWContext(ctx).Error("Incorrect message type")
		return res
	}
	resp.Body.Close()

	return []byte(body)
}

func reqTokenFromSingleNode(ctx context.Context, mem MemberList) string {
	tokenRes := A3TokenResFromRdc{}

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/rdctoken", mem.IpAddr)
	log.LoggerWContext(ctx).Info(fmt.Sprintf("begin to get token from %s", url))

	node := new(innerClient.Client)
	err := node.ClusterSend(ctx, "GET", url, "")
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return ""
	}

	body := node.RespData

	/*
		url := fmt.Sprintf("https://%s:1443/a3/api/v1/event/rdctoken", mem.IpAddr)
		log.LoggerWContext(ctx).Info(fmt.Sprintf("begin to get token from %s", url))
		request, err := http.NewRequest("GET", url, nil)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return ""
		}

		//Using the packetfence token if communicating with cluster members
		//To do, get a real packetfence token, take the expiration of token
		//into account
		request.Header.Add("Packetfence-Token", "packetfence token")
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return ""
		}

		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println("receive the response ", resp.Status)
	*/
	fmt.Println(string(body))
	err = json.Unmarshal([]byte(body), &tokenRes)
	if err != nil {
		fmt.Println("json Unmarshal fail")
		log.LoggerWContext(ctx).Error(err.Error())
		return ""
	}

	if tokenRes.Data.MsgType != "amac_token" {
		log.LoggerWContext(ctx).Error("Incorrect message type")
		return ""
	}

	//	resp.Body.Close()

	return tokenRes.Data.Token
}

/*
	This function needs to be called if the RDC token is absent
	or expires
*/
func reqTokenFromOtherNodes(ctx context.Context) int {

	//mockup the active node list
	memList := FetchNodeList()
	nodeNum := 0
	token := ""

	log.LoggerWContext(ctx).Info("begin to request RDC token from other nodes")

	for _, mem := range memList {
		nodeNum++
		token = reqTokenFromSingleNode(ctx, mem)
		if len(token) > 0 {
			UpdateRdcToken(ctx, token)
			return 0
		}
	}
	if nodeNum > 1 && token == "" {
		log.LoggerWContext(ctx).Error("Requeting token from other nodes fail")
	}
	return -1
}

//Fetch systemID for one Node -- Todo
func FetchSysIDForNode(node MemberList) string {
	return ""
}

func distributeToSingleNode(ctx context.Context, mem MemberList) {

	token := ReqTokenForOtherNode(ctx, FetchSysIDForNode(mem))
	//reader := bytes.NewReader(token)
	//Using loop to make sure post successfully
	for {
		url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/rdctoken", mem.IpAddr)
		node := new(innerClient.Client)
		err := node.ClusterSend(ctx, "POST", url, string(token))
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return
		}
		statusCode := node.Status
		/*
			url := fmt.Sprintf("https://%s:1443/a3/api/v1/event/rdctoken", mem.IpAddr)
			log.LoggerWContext(ctx).Info(fmt.Sprintf("begin to post token to %s", url))
			request, err := http.NewRequest("POST", url, reader)
			if err != nil {
				log.LoggerWContext(ctx).Error(err.Error())
				return
			}

			//Using the packetfence token if communicating with cluster members
			//To do, get a real packetfence token, take the expiration of token
			//into account
			request.Header.Add("Packetfence-Token", "packetfence token")
			request.Header.Set("Content-Type", "application/json")
			resp, err := client.Do(request)
			if err != nil {
				log.LoggerWContext(ctx).Error(err.Error())
				return
			}

			body, _ := ioutil.ReadAll(resp.Body)
			fmt.Println("receive the response ", resp.Status)
			fmt.Println(string(body))
			statusCode := resp.StatusCode
			resp.Body.Close()
		*/
		/*
			statusCode = 401 means authenticate fail, need to request valid RDC token
			from the other nodes
		*/
		if statusCode == 200 {
			fmt.Println("post token OK ")
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
	2) Requesting a token for every node
	3) Posting the new token to every node actively
*/
func distributeToken(ctx context.Context) {

	//mockup the active node list
	memList := FetchNodeList()

	for _, mem := range memList {
		go distributeToSingleNode(ctx, mem)
	}
	return
}

func fillRdcTokenReq() {
	rdcTokenReq := rdcTokenReqFromRdc{}

	rdcTokenReq.Header.SystemID = utils.GetA3SysId()
	rdcTokenReq.Header.Hostname = a3config.GetHostname()
	rdcTokenReq.Header.OwnerId, _ = strconv.Atoi(VhmidStr)
}

/*
	This func is used to fetch the token from RDC, the requset message only
	need to include the GDC token
*/
func fetchTokenFromRdc(ctx context.Context) (string, string) {
	tokenRes := A3TokenResFromRdc{}

	log.LoggerWContext(ctx).Info("begin to fetch RDC token")
	//url := fmt.Sprintf("http://10.155.23.116:8008/rest/token/apply/%s", utils.GetA3SysId())
	log.LoggerWContext(ctx).Error(fetchRdcTokenUrl)

	request, err := http.NewRequest("POST", fetchRdcTokenUrl, nil)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return "", OtherError
	}

	//Taking the GDC token to request a RDC token
	request.Header.Add("Authorization", gdcTokenStr)
	request.Header.Set("Content-Type", "application/json")
	resp, err := client.Do(request)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return "", SrvNoResponse
	}

	body, _ := ioutil.ReadAll(resp.Body)
	log.LoggerWContext(ctx).Info(string(body))

	err = json.Unmarshal([]byte(body), &tokenRes)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return "", ErrorMsgFromSrv
	}

	if tokenRes.Data.MsgType != "amac_token" {
		log.LoggerWContext(ctx).Error("Incorrect message type")
		return "", ErrorMsgFromSrv
	}
	//RDC token need to write file, if process restart we can read it
	UpdateRdcToken(ctx, tokenRes.Data.Token)
	//Save RDC url and VHM to config file if get the RDC token
	//To do, inform the BE to synchronize the config file
	err = a3config.UpdateCloudConf(a3config.RDCUrl, rdcUrl)
	if err != nil {
		log.LoggerWContext(ctx).Error("Save RDC URL error: " + err.Error())
	}

	err = a3config.UpdateCloudConf(a3config.Vhm, VhmidStr)
	if err != nil {
		log.LoggerWContext(ctx).Error("Save vhm error: " + err.Error())
	}
	/*
		To do, post the RDC token/RDC URL/VHMID to the other memebers
	*/
	//Updating the RDC token for the other nodes actively
	//distributeToken(ctx)

	return rdcTokenStr, ConnCloudSuc
}
