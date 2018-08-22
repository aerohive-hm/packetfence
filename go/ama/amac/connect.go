/*
	The file implements the following functions:
	1) connect to the GDC to get GDC token
	2) connect to the GDC to get the VHMID and RDC URL
 	3) Onboarding to the HM with the RDC token
*/

package amac

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"io/ioutil"
	"net/http"
	"strings"
	"time"
)

var (
	//Init the transport structure
	tr = &http.Transport{
		TLSClientConfig:    &tls.Config{InsecureSkipVerify: true},
		DisableKeepAlives:  true,
		DisableCompression: true,
	}

	//init the client structure
	client = &http.Client{Transport: tr, Timeout: 10 * time.Second}

	//Store the token to avoid multiple IO
	gdcTokenStr string
	rdcTokenStr string
	VhmidStr    string
)

type response struct {
	Location string `json:"location"`
	OwnerId  int    `json:"ownerId"`
}
type VhmidResponse struct {
	Data response `json:"data"`
}

type A3Interface struct {
	Parent      string   `json:"parent"`
	Vlan        string   `json:"vlan"`
	IpAddress   string   `json:"ipAddress"`
	Vip         string   `json:"vip"`
	Netmask     string   `json:"netmask"`
	Type        string   `json:"type"`
	Service     []string `json:"services"`
	Description string   `json:"description"`
}

type A3OnboardingData struct {
	Msgtype         string        `json:"msgType"`
	MacAddress      string        `json:"macAddress"`
	IpMode          string        `json:"ipMode"`
	IpAddress       string        `json:"ipAddress"`
	Netmask         string        `json:"netmask"`
	DefaultGateway  string        `json:"defaultGateway"`
	SoftwareVersion string        `json:"softwareVersion"`
	SystemUptime    uint64        `json:"systemUpTime"`
	Vip             string        `json:"vip"`
	ClusterHostName string        `json:"clusterHostName"`
	ClusterPrimary  bool          `json:"clusterPrimary"`
	Interfaces      []A3Interface `json:"interfaces"`
}

type A3CommonHeader struct {
	SystemID  string `json:"systemId"`
	ClusterID string `json:"clusterId"`
	Hostname  string `json:"hostname"`
	MessageID string `json:"messageId"`
}

type A3OnboardingInfo struct {
	Header A3CommonHeader   `json:"header"`
	Data   A3OnboardingData `json:"data"`
}

type A3TokenReqData struct {
	MsgType  string `json:"msgType"`
	SystemID string `json:"systemId"`
}

type A3TokenReqToRdc struct {
	Header A3CommonHeader `json:"header"`
	Data   A3TokenReqData `json:"data"`
}

type A3TokenResData struct {
	MsgType string `json:"msgType"`
	Token   string `json:"token"`
}

type A3TokenResFromRdc struct {
	Header A3CommonHeader `json:"header"`
	Data   A3TokenResData `json:"data"`
}

func GetTokenReq(systemId string) A3TokenReqToRdc {
	tokenReqToRdcInfo := A3TokenReqToRdc{}

	tokenReqToRdcInfo.Header.Hostname = "fake-for-demo1"
	tokenReqToRdcInfo.Header.SystemID = "47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA"
	tokenReqToRdcInfo.Header.ClusterID = "1C45299D-DB95-4C7F-A787-219C327971BA"
	tokenReqToRdcInfo.Header.MessageID = "a738c4da-e5ae-43e0-957a-25d3363e0100"

	tokenReqToRdcInfo.Data.MsgType = "tokenRequest"
	tokenReqToRdcInfo.Data.SystemID = systemId

	return tokenReqToRdcInfo
}

/*
func GetOnboardingInfo() A3OnboardingInfo {
	onboardInfo := A3OnboardingInfo{}

	onboardInfo.Header.Hostname = "fake-for-demo1"
	onboardInfo.Header.SystemID = "47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA"
	onboardInfo.Header.ClusterID = "1C45299D-DB95-4C7F-A787-219C327971BA"
	onboardInfo.Header.MessageID = "a738c4da-e5ae-43e0-957a-25d3363e0100"

	onboardInfo.Data.Msgtype = "connect"
	onboardInfo.Data.MacAddress = "0019770004AA"
	onboardInfo.Data.IpMode = "DHCP"
	onboardInfo.Data.IpAddress = "10.16.0.10"
	onboardInfo.Data.Netmask = "255.255.255.0"
	onboardInfo.Data.DefaultGateway = "10.16.0.254"
	onboardInfo.Data.SoftwareVersion = "2.0"
	onboardInfo.Data.SystemUptime = 1532942958060
	onboardInfo.Data.Vip = "10.16.0.100"
	onboardInfo.Data.ClusterHostName = "A3-Cluster-demo"
	onboardInfo.Data.ClusterPrimary = false

	interfaceOne := A3Interface{"ETH0", "null", "10.16.0.10", "10.16.0.100", "255.255.255.0", "MANAGEMENT", []string{}, "ETH0"}
	interfaceTwo := A3Interface{"ETH0", "10", "10.16.1.10", "10.16.1.100", "255.255.255.0", "REGISTRATION", []string{"PORTAL"}, "ETH0 VLAN 10"}
	interfaceThree := A3Interface{Parent: "ETH1", Vlan: "30", IpAddress: "10.16.2.10", Vip: "10.16.2.100", Netmask: "255.255.255.0", Type: "PORTAL", Service: []string{"PORTAL", "RADIUS"}, Description: "ETH1 VLAN 30"}
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceOne)
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceTwo)
	onboardInfo.Data.Interfaces = append(onboardInfo.Data.Interfaces, interfaceThree)

	return onboardInfo
}
*/

/*
	Send onboarding info to HM once obataining the RDC's token
*/
func onbordingToRdc(ctx context.Context) int {
	for {
		node_info := utils.GetOnboardingInfo(ctx)
		data, _ := json.Marshal(node_info)

		log.LoggerWContext(ctx).Error("begin to send onboarding request to RDC")
		log.LoggerWContext(ctx).Error(string(data))
		reader := bytes.NewReader(data)

		//request, err := http.NewRequest("POST", "http://10.155.100.17:8008/rest/v1/report/1234567", reader)
		request, err := http.NewRequest("POST", "http://10.155.22.93:8882/rest/v1/report/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA", reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("X-A3-Auth-Token", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			fmt.Println("onbordingToRdc: RDC is down")
			return -1
		}

		body, _ := ioutil.ReadAll(resp.Body)

		log.LoggerWContext(ctx).Error("receive the response ", resp.Status)
		log.LoggerWContext(ctx).Error(string(body))
		statusCode := resp.StatusCode
		resp.Body.Close()
		/*
			statusCode = 401 means authenticate fail, need to request valid RDC token
			from the other nodes
		*/
		if statusCode == 401 {
			result := reqTokenFromOtherNodes(ctx)
			//result == 0 means get the token, try to onboarding again
			if result == 0 {
				continue
			} else {
				//not get the token, return and wait for the event from UI or other nodes
				return result
			}
		}
		return 0
	}
	return 0
}

/*
	This function is used to send update message if network/license changes
*/
func updateMsgToRdc(ctx context.Context) int {
	for {
		node_info := utils.GetIntChgInfo(ctx)
		data, _ := json.Marshal(node_info)
		log.LoggerWContext(ctx).Error("begin to send initerface change to RDC")
		log.LoggerWContext(ctx).Error(string(data))
		reader := bytes.NewReader(data)

		fmt.Println("begin to send initerface change to RDC")
		//request, err := http.NewRequest("POST", "http://10.155.100.17:8008/rest/v1/report/1234567", reader)
		request, err := http.NewRequest("POST", "http://10.155.22.93:8882/rest/v1/report/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA", reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("X-A3-Auth-Token", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update message to RDC fail")
			log.LoggerWContext(ctx).Error(err.Error())
			return -1
		}

		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println("receive the response ", resp.Status)
		//fmt.Println(string(body))
		log.LoggerWContext(ctx).Error(string(body))
		statusCode := resp.StatusCode
		resp.Body.Close()
		/*
			statusCode = 401 means authenticate fail, need to request valid RDC token
			from the other nodes
		*/
		if statusCode == 401 {
			result := reqTokenFromOtherNodes(ctx)
			//result == 0 means get the token, try to onboarding again
			if result == 0 {
				continue
			} else {
				//not get the token, return and wait for the event from UI or other nodes
				return result
			}
		}
		return 0
	}
	return 0
}

/*
	This func only for the node who do not know the GDC pasword,
	in this case, this node will request RDC token from the other nodes
*/
func connectToRdcWithoutPara(ctx context.Context) int {
	//Read the local RDC token, if exist, not send request to other nodes
	token := readRdcToken(ctx)
	if len(token) == 0 {
		result := reqTokenFromOtherNodes(ctx)
		//result != 0 means not get the token, return and waiting event from UI
		//or other nodes
		if result != 0 {
			log.LoggerWContext(ctx).Error("Request RDC token failed from other ondes")
			return result
		}
	}

	fmt.Println("begin to send onboarding request to RDC server")
	res := onbordingToRdc(ctx)
	if res != 0 {
		log.LoggerWContext(ctx).Error("Onboarding failed")
		return res
	}
	updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
	return 0
}

/*
 This func only for the node who get the GDC's accout and password
 in this case, this node will fetch the RDC token directly instead
 of asking the other nodes
*/
func connectToRdcWithPara(ctx context.Context) int {
	result := fetchTokenFromRdc(ctx)
	if result == "" {
		log.LoggerWContext(ctx).Error("Fetch token from RDC failed")
		return -1
	}
	res := onbordingToRdc(ctx)
	if res != 0 {
		log.LoggerWContext(ctx).Error("Onboarding failed")
		return -1
	}
	updateMsgToRdc(ctx)
	return 0
}

/*
	Fetch the token from GDC, GDC token is used to fetch the RDC URL
	RDC token and VHMID, no need to write file
*/
func fetchTokenFromGdc(ctx context.Context) string {

	//check url if NULL
	if len(tokenUrl) == 0 {
		return ""
	}
	body := fmt.Sprintf("grant_type=password&client_id=browser&client_secret=secret&username=%s&password=%s", userName, password)

	fmt.Println("begin to fetch GDC token")
	for {
		request, err := http.NewRequest("POST", tokenUrl, strings.NewReader(body))
		if err != nil {
			fmt.Println(err.Error())
			return ""
		}

		request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		resp, err := client.Do(request)
		if err != nil {
			fmt.Println(err.Error())
			//to do, using log instead of PrintIn
			fmt.Println("GDC is down\n")
			return ""
		}

		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))
		dat := make(map[string]interface{})
		err = json.Unmarshal([]byte(body), &dat)
		if err != nil {
			fmt.Println("json Unmarshal fail")
			return ""
		}
		//GDC token does not need to write file, it is one-time useful
		gdcTokenStr = dat["access_token"].(string)
		resp.Body.Close()
		return gdcTokenStr
	}
}

//Fetch the vhmid from GDC
func fetchVhmidFromGdc(ctx context.Context, s string) int {
	var vhmres VhmidResponse

	/*
		The vhmid bind with username/password, Vhmid_str variable should be
		updated when username changes
	*/
	if len(vhmidUrl) == 0 {
		return -1
	}
	fmt.Printf("begin to fetch the vhmid, token:%s, vhmid_url:%s\n", s, vhmidUrl)
	for {
		request, err := http.NewRequest("GET", vhmidUrl, nil)
		if err != nil {
			fmt.Println(err.Error())
			return -1
		}

		//fill the token
		dst := fmt.Sprintf("Bearer %s", gdcTokenStr)
		request.Header.Add("Authorization", dst)
		resp, err := client.Do(request)
		if err != nil {
			fmt.Println(err.Error())
			fmt.Printf("GDC is down")
			return -1
		}

		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))
		fmt.Println(resp.Status)

		json.Unmarshal([]byte(body), &vhmres)

		VhmidStr = fmt.Sprintf("%d", vhmres.Data.OwnerId)
		rdcUrl = vhmres.Data.Location
		//To do, save the vhmid and rdcurl to config file and synchronize to cluster member

		resp.Body.Close()
		return 0
	}
}

//Connect to GDC, get the token and vhmid
func connetToGdc(ctx context.Context) int {
	token := fetchTokenFromGdc(ctx)
	if token == "" {
		return -1
	}

	err := fetchVhmidFromGdc(ctx, token)
	if err != 0 {
		return -1
	}
	return 0
}

func connectToGdcRdc(ctx context.Context) int {
	result := connetToGdc(ctx)
	if result != 0 {
		return result
	}
	result = connectToRdcWithPara(ctx)
	if result != 0 {
		return result
	}
	return 0
}

func loopConnect(ctx context.Context) {
	result := connectToGdcRdc(ctx)
	if result == 0 {
		updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
		return
	}

	//Create a timer to connect the GDC and RDC
	ticker := time.NewTicker(10 * time.Second)
	for _ = range ticker.C {
		result := connectToGdcRdc(ctx)
		if result == 0 {
			updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
			ticker.Stop()
			return
		}
		continue
	}
	return
}
