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
	"github.com/inverse-inc/packetfence/go/ama/share"
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
	client = &http.Client{Transport: tr, Timeout: 30 * time.Second}

	//Store the token to avoid multiple IO
	gdcTokenStr               string
	rdcTokenStr               string
	VhmidStr                  string
	OwnerIdStr                string
	OrgIdStr                  string
	connMsgUrl                string
	fetchRdcTokenUrl          string
	fetchRdcTokenUrlForOthers string
	keepAliveUrl              string
	updateMsgUrl              string
)

const (
	ConnCloudSuc    = "Connect to cloud successfully"
	SrvNoResponse   = "Server is unavailable"
	AuthFail        = "Authenticate fail, please check the input parameters"
	UrlIsNull       = "URL is NULL"
	ErrorMsgFromSrv = "Error messages from server, please check the input parameters"
	LimitedAccess   = "Limited access, please use an administrator/operator account"
	UpdateMsgSuc    = "Update message to cloud successfully"
	InvalidToken    = "Token is invalid, update message to cloud fail, "
	OtherError      = "System error"
)

type response struct {
	Location string `json:"location"`
	OwnerId  int64  `json:"ownerId"`
}
type VhmidResponse struct {
	Data response `json:"data"`
}

type connectResponseData struct {
	MsgType      string `json:"msgType"`
	MessageID    string `json:"messageId"`
	Successful   bool   `json:"successful"`
	ErrorCode    int    `json:"errorCode"`
	ErrorMessage string `json:"errorMessage"`
	ResponseData string `json:"responseData"`
}

type connectResponse struct {
	Header tokenCommonHeader   `json:"header"`
	Data   connectResponseData `json:"data"`
}

/*
	Installing the URL for fethcing RDC token, keepalive and onboarding
*/
func installRdcUrl(ctx context.Context, rdcUrl string) {

	if ctx != nil {
		log.LoggerWContext(ctx).Error("into installRdcUrl")
	}
	systemId := utils.GetA3SysId()

	//Get the RDC domain name
	a1 := strings.Split(rdcUrl, "//")[1]
	a2 := strings.Split(a1, "/")[0]
	domain := "https://" + a2

	connMsgUrl = domain + "/amac/rest/v1/report/syn/" + systemId
	fetchRdcTokenUrl = domain + "/amac/rest/token/apply/" + systemId
	fetchRdcTokenUrlForOthers = domain + "/amac/rest/v1/token/" + systemId
	keepAliveUrl = domain + "/amac/rest/v1/poll/" + systemId
	updateMsgUrl = domain + "/amac/rest/v1/report/" + systemId
	if ctx != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("connMsgUrl:%s,fetchRdcTokenUrl:%s, keepAliveUrl:%s", connMsgUrl, fetchRdcTokenUrl, keepAliveUrl))
	}
}

/*
	Send onboarding info to HM once obataining the RDC's token
*/
func onbordingToRdc(ctx context.Context) (int, string) {
	connRes := connectResponse{}

	if connMsgUrl == "" {
		log.LoggerWContext(ctx).Error("RDC URL is NULL")
		return -1, UrlIsNull
	}
	for {
		node_info := a3share.GetOnboardingInfo(ctx)
		data, _ := json.Marshal(node_info)

		log.LoggerWContext(ctx).Error("begin to send onboarding request to RDC, connMsgUrl=")
		log.LoggerWContext(ctx).Error(connMsgUrl)
		log.LoggerWContext(ctx).Error(string(data))
		reader := bytes.NewReader(data)

		request, err := http.NewRequest("POST", connMsgUrl, reader)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1, OtherError
		}

		//Add header option, the tokenStr is from RDC now
		request.Header.Add("Authorization", rdcTokenStr)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1, SrvNoResponse
		}

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Error(fmt.Sprintf("receive the response %d", resp.StatusCode))
		log.LoggerWContext(ctx).Error(string(body))
		statusCode := resp.StatusCode
		if statusCode == 200 {
			defer resp.Body.Close()
			err = json.Unmarshal([]byte(body), &connRes)
			if err != nil {
				log.LoggerWContext(ctx).Error(err.Error())
				return -1, ErrorMsgFromSrv
			}

			if connRes.Data.MsgType == "response" && connRes.Data.Successful == true {
				return 0, connRes.Data.ErrorMessage
			} else {
				return -1, connRes.Data.ErrorMessage
			}
		} else if statusCode == 401 {
			resp.Body.Close()
			/*
				statusCode = 401 means authenticate fail, need to request valid RDC token
				from the other nodes
			*/
			result := ReqTokenFromOtherNodes(ctx, nil)
			//result == 0 means get the token, try to onboarding again
			if result == 0 {
				continue
			} else {
				//not get the token, return and wait for the event from UI or other nodes
				return -1, AuthFail
			}
		}
		resp.Body.Close()
		return -1, OtherError
	}
	return -1, OtherError
}

/*
	This func only for the node who do not know the GDC pasword,
	in this case, this node will request RDC token from the other nodes
*/
func connectToRdcWithoutPara(ctx context.Context) int {
	if GetConnStatus() == AMA_STATUS_ONBOARDING_SUC {
		log.LoggerWContext(ctx).Info("Current status is onboarding successful, needn't onboard again.")
		return 0
	}
	//Read the local RDC token, if exist, not send request to other nodes
	token := readRdcToken(ctx)
	if len(token) == 0 {
		result := ReqTokenFromOtherNodes(ctx, nil)
		//result != 0 means not get the token, return and waiting event from UI
		//or other nodes
		if result != 0 {
			log.LoggerWContext(ctx).Error("Request RDC token failed from other ondes")
			return result
		}
	}

	log.LoggerWContext(ctx).Info("connectToRdcWithoutPara: begin to send onboarding request to RDC server")
	res, _ := onbordingToRdc(ctx)
	if res != 0 {
		log.LoggerWContext(ctx).Error("Onboarding failed")
		return res
	}
	//updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
	//_, _ = UpdateMsgToRdcSyn(ctx, RemoveNodeFromCluster)
	return 0
}

/*
 This func only for the node who get the GDC's accout and password
 in this case, this node will fetch the RDC token directly instead
 of asking the other nodes
*/
func connectToRdcWithPara(ctx context.Context) (int, string) {
	result, reason := fetchTokenFromRdc(ctx)
	if result == "" {
		log.LoggerWContext(ctx).Error("Fetch token from RDC failed")
		return -1, reason
	}
	log.LoggerWContext(ctx).Info("connectToRdcWithPara:begin to send onboarding request to RDC server")
	res, reason := onbordingToRdc(ctx)
	if res != 0 {
		log.LoggerWContext(ctx).Error("Onboarding failed")
		return -1, reason
	}
	/* Debugging code of integrating test with HM
	updateMsgToRdcAsyn(ctx, LicenseInfoChange)
	updateMsgToRdcAsyn(ctx, NetworkChange)

	{
		nodeInfo := NodeInfo{"B0C5-2104-0349-64CD-2D25-AAAA-AAAA-AAAA", "testforrequestRDCtoken"}
		_ = ReqTokenForOtherNode(ctx, nodeInfo)
	}
	*/
	return 0, ConnCloudSuc
}

/*
	Fetch the token from GDC, GDC token is used to fetch the RDC URL
	RDC token and VHMID, no need to write file
*/
func fetchTokenFromGdc(ctx context.Context) (string, string) {

	//check url if NULL
	if len(tokenUrl) == 0 {
		return "", UrlIsNull
	}
	body := fmt.Sprintf("grant_type=password&client_id=browser&client_secret=secret&username=%s&password=%s", userName, password)

	log.LoggerWContext(ctx).Info("begin to fetch GDC token")
	log.LoggerWContext(ctx).Info(fmt.Sprintf("tokenUrl:%s,userName:%s,password:%s", tokenUrl, userName, password))
	for {
		request, err := http.NewRequest("POST", tokenUrl, strings.NewReader(body))
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return "", OtherError
		}

		request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return "", SrvNoResponse
		}
		defer resp.Body.Close()

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Info(string(body))
		dat := make(map[string]interface{})
		err = json.Unmarshal([]byte(body), &dat)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return "", ErrorMsgFromSrv
		}

		statusCode := resp.StatusCode
		if statusCode == 200 {
			//GDC token does not need to write file, it is one-time useful
			gdcTokenStr = fmt.Sprintf("Bearer %s", dat["access_token"].(string))
			return gdcTokenStr, ConnCloudSuc
		} else if statusCode == 401 {
			return "", AuthFail
		}

		errMsg := fmt.Sprintf("Server(GDC) respons the code %d, please check the input parameters", statusCode)
		return "", errMsg
	}
}

//Fetch the vhmid from GDC
func fetchVhmidFromGdc(ctx context.Context, s string) (int, string) {
	var vhmres VhmidResponse

	/*
		The vhmid bind with username/password, Vhmid_str variable should be
		updated when username changes
	*/
	if len(vhmidUrl) == 0 {
		return -1, UrlIsNull
	}
	log.LoggerWContext(ctx).Info("begin to fetch vhm and RDC URL")
	for {
		request, err := http.NewRequest("GET", vhmidUrl, nil)
		if err != nil {
			fmt.Println(err.Error())
			return -1, OtherError
		}

		//fill the token
		request.Header.Add("Authorization", s)
		resp, err := client.Do(request)
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return -1, SrvNoResponse
		}
		defer resp.Body.Close()

		body, _ := ioutil.ReadAll(resp.Body)
		log.LoggerWContext(ctx).Info(string(body))

		json.Unmarshal([]byte(body), &vhmres)

		OwnerIdStr = fmt.Sprintf("%d", vhmres.Data.OwnerId)
		rdcUrl = vhmres.Data.Location
		log.LoggerWContext(ctx).Info(fmt.Sprintf("rdcUrl = %s", rdcUrl))

		installRdcUrl(ctx, rdcUrl)

		return 0, ConnCloudSuc
	}
}

//Connect to GDC, get the token and vhmid
func connetToGdc(ctx context.Context) (int, string) {
	token, reason := fetchTokenFromGdc(ctx)
	if token == "" {
		return -1, reason
	}

	err, reason := fetchVhmidFromGdc(ctx, token)
	if err != 0 {
		return -1, reason
	}
	return 0, ConnCloudSuc
}

func connectToGdcRdc(ctx context.Context) (int, string) {
	result, reason := connetToGdc(ctx)
	if result != 0 {
		return result, reason
	}
	result, reason = connectToRdcWithPara(ctx)
	if result != 0 {
		return result, reason
	}
	return 0, reason
}

func LoopConnect(ctx context.Context, pass string) (int, string) {
	updateConnStatus(AMA_STATUS_CONNECING_GDC)
	err := update(pass)
	if err != nil {
		log.LoggerWContext(ctx).Error("Update config failed")
		return -1, OtherError
	}
	result, reason := connectToGdcRdc(ctx)
	if result == 0 {
		updateConnStatus(AMA_STATUS_ONBOARDING_SUC)
		return 0, reason
	} else {
		updateConnStatus(AMA_STATUS_INIT)
		return -1, reason
	}
	return 0, ConnCloudSuc
}
