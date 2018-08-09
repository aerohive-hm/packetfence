package amac

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
	"time"
)

//import (
//std_config "github.com/larspensjo/config"
//)

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
	token_str string
	vhmid_str string
	rdc_url   string
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

func connectToRdc() int {

	fmt.Println("begin to post data to rdc server")
	//begin: send the onboarding info to AMAC and get the onboarding info
	for {
		node_info := GetOnboardingInfo()
		data, _ := json.Marshal(node_info)
		fmt.Println(string(data))
		reader := bytes.NewReader(data)

		request, err := http.NewRequest("POST", "http://10.155.22.93:8882/rest/v1/report/syn/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA", reader)
		if err != nil {
			fmt.Println(err.Error())
			return -1
		}

		//Add header option
		request.Header.Add("X-A3-Auth-Token", token_str)
		request.Header.Set("Content-Type", "application/json")
		resp, err := client.Do(request)
		if err != nil {
			fmt.Println(err.Error())
			fmt.Println("RDC is down")
			return -1
		}

		fmt.Println("post send success")
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))
		fmt.Println(resp.Status)
		/*
			To do, need handle the resp code if not 200, such as: if authentication fail
		*/
		resp.Body.Close()

		return 0
	}
	//end: send the onboarding info to AMAC and get the onboarding info
	return 0
}

func readToken() string {
	if len(token_str) != 0 {
		return token_str
	}

	file, error := os.OpenFile("./token.txt", os.O_RDWR|os.O_CREATE, 0600)
	if error != nil {
		fmt.Println(error)
	}
	content, _ := ioutil.ReadAll(file)
	file.Close()
	return string(content)
}

func updateToken(s string) {
	file, error := os.OpenFile("./token.txt", os.O_RDWR|os.O_CREATE, 0600)
	if error != nil {
		fmt.Println(error)
		return
	}

	_, _ = io.WriteString(file, s) //write file(string)

	file.Close()
	return
}

//Fetch the token from GDC
func fetchToken() string {
	//check url if NULL
	if len(token_url) == 0 {
		return ""
	}
	body := fmt.Sprintf("grant_type=password&client_id=browser&client_secret=secret&username=%s&password=Aerohive123", username)

	fmt.Println("token is null,begin to fetch the token")

	for {
		request, err := http.NewRequest("POST", token_url, strings.NewReader(body))
		if err != nil {
			fmt.Println(err.Error())
			return ""
		}

		request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		resp, err := client.Do(request)
		if err != nil {
			fmt.Println(err.Error())
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
		dst := fmt.Sprintf("Bearer %s", dat["access_token"].(string))
		token_str = dst
		updateToken(dst)
		resp.Body.Close()
		return dst
	}
}

//Fetch the vhmid from GDC
func fetchVhmid(s string) int {
	var vhmres VhmidResponse

	/*
		The vhmid bind with username/password, Vhmid_str variable should be
		updated when username changes
	*/
	if len(vhmid_url) == 0 {
		return -1
	}
	fmt.Printf("begin to fetch the vhmid, token:%s, vhmid_url:%s\n", s, vhmid_url)
	for {
		request, err := http.NewRequest("GET", vhmid_url, nil)
		if err != nil {
			fmt.Println(err.Error())
			return -1
		}

		//fill the token
		request.Header.Add("Authorization", s)
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

		vhmid_str = fmt.Sprintf("%d", vhmres.Data.OwnerId)
		rdc_url = vhmres.Data.Location
		//Cfg.AddOption("gdc_rdc_info", "vhmid", vhmid)
		//Cfg.AddOption("gdc_rdc_info", "rdc_url", vhmres.Data.Location)
		//Cfg.WriteFile("config.txt", 0600, "save the rdc url and vhmid")
		/*
			Must update the Cfg varibal after AddOption, otherwise multiple write
			will lost the original fields
		*/
		//Cfg, err = std_config.ReadDefault(*ConfigFile)

		resp.Body.Close()
		return 0
	}
}

//Connect to GDC, get the token and vhmid
func connetToGdc() int {

	token := fetchToken()
	if token == "" {
		return -1
	}

	err := fetchVhmid(token)
	if err != 0 {
		return -1
	}

	return 0
}

func connectToGdcRdc() int {
	result := connetToGdc()
	if result != 0 {
		return result
	}
	result = connectToRdc()
	if result != 0 {
		return result
	}
	return 0
}

func loopConnect() {
	result := connectToGdcRdc()
	if result == 0 {
		updateConnStatus(AMA_STATUS_CONNECTED)
		return
	}

	//Create a timer to connect the GDC and RDC
	ticker := time.NewTicker(5 * time.Second)
	for _ = range ticker.C {
		result := connectToGdcRdc()
		if result == 0 {
			updateConnStatus(AMA_STATUS_CONNECTED)
			ticker.Stop()
			return
		}
		continue
	}
	return
}
