package amac

import (
	//"crypto/x509"
	"fmt"
	"io/ioutil"
	"net/http"
	"sync"
	"time"
	"unsafe"
)

const (
	AMA_STATUS_INIT      = 0
	AMA_STATUS_CONNECTED = 1
	AMA_STATUS_UNKNOWN   = 100
)
const (
	gdcConfigChange   = 1
	ifConfigChange    = 2
	licenseInfoChange = 3
)
const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var (
	ama_connect_status = AMA_STATUS_INIT
	m                  = new(sync.RWMutex)
	timeoutCount       uint64
	//create channel to store messages from UI
	msgChannel = make(chan []byte, 4096)
)

type msgFromUi struct {
	msgType int
	data    string
}

type SliceMock struct {
	addr uintptr
	len  int
	cap  int
}

func updateConnStatus(status int) {
	m.Lock()
	ama_connect_status = status
	m.Unlock()
}

func readConnStatus() int {
	m.RLock()
	status := ama_connect_status
	m.RUnlock()
	return status
}

func Entry() {
	var msg []byte
	/*
		try to connet to GDC and RDC, the loopConnect() will not return
		unless connected successfully
	*/
	if (len(vhmidUrl) != 0) && (len(userName) != 0) && (len(password) != 0) {
		loopConnect()
	}

	//start a goroutine, sending the keepalive only when the status is connected
	go keepaliveToRdc()

	/*
		Read the channel to monitor the configuration change from UI
		If config change, change the connect status to init and reconnect
		to GDC
	*/
	for {
		select {
		case msg = <-msgChannel:
			handleMsgFromUi(msg)

		default:
			time.Sleep(5 * time.Second)
		}
	}

}

/*
	Handling the message from web UI, such as items about GDC change,
	network info change, or license info changes
*/
func handleMsgFromUi(message []byte) {
	var msg *msgFromUi = *(**msgFromUi)(unsafe.Pointer(&message))
	fmt.Println("msg.msgType", msg.msgType)
	fmt.Println("msg.data", msg.data)
	switch msg.msgType {
	case gdcConfigChange:
		updateConnStatus(AMA_STATUS_INIT)
		fmt.Println("read the channel")
		//to do, get the latest config info
		loopConnect()
		break
	case ifConfigChange:
		break
	case licenseInfoChange:
		break
	default:
		fmt.Println("unexpected message")
	}
}

func keepaliveToRdc() {
	// create a ticker for heartbeat
	ticker := time.NewTicker(10 * time.Second)
	timeoutCount = 0

	for _ = range ticker.C {
		/*
			check the timeoutCount of keepalive, if hearbeat fails,
			need to re-onboarding
		*/
		if timeoutCount >= KEEPALIVE_TIMEOUT_COUNT_MAX {
			updateConnStatus(AMA_STATUS_INIT)
			result := connectToRdc()
			if result == 0 {
				updateConnStatus(AMA_STATUS_CONNECTED)
				timeoutCount = 0
			} else {
				timeoutCount++
				fmt.Printf("keepaliveToRdc, timeout_cout:%d\n", timeoutCount)
				//Onboarding fail, not send keepalive
				continue
			}
		}
		//Check the connect status, if not connected, do nothing
		if readConnStatus() != AMA_STATUS_CONNECTED {
			continue
		}
		//msgChannel <- data
		fmt.Println("sending the keepalive")
		request, err := http.NewRequest("GET", "http://10.155.100.17:8000/rest/v1/poll/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA", nil)
		if err != nil {
			panic(err)
		}

		//增加header选项
		request.Header.Add("x-auth-token", "juanlitest")
		request.Header.Set("Content-Type", "application/json")

		resp, result := client.Do(request)
		if result != nil {
			timeoutCount++
			continue
		}
		timeoutCount = 0
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))
		fmt.Println(resp.Status)
		//To do, handle the response, new token may be included in this message
		resp.Body.Close()

		//Dispatch the data from keepalive_reponse
		//go AMA_dispatcher()
	}

}

/*
func AMA_dispatcher() {
	var i int = 0
	var msg []byte

	fmt.Println("print value in dispatcher() ")
	for {
		i++
		fmt.Println("begin read i=%d ", i)
		msg = <-start.Msg_channel
		fmt.Println(string(msg))
		fmt.Println("end read i=%d ", i)

	}
}
*/
