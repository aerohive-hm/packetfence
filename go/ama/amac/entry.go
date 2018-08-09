package amac

import (
	//"crypto/x509"
	"fmt"
	"io/ioutil"
	"net/http"
	"sync"
	"time"
)

const (
	AMA_STATUS_INIT      = 0
	AMA_STATUS_CONNECTED = 1
	AMA_STATUS_UNKNOWN   = 100
)
const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var (
	cfg_channel        = make(chan bool, 1)
	ama_connect_status = AMA_STATUS_INIT
	m                  = new(sync.RWMutex)
	timeout_cout       uint64
)

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
	/*
		try to connet to GDC and RDC, the func will not return
		unless connected successfully
	*/
	loopConnect()

	//start a goroutine for sending the keepalive
	go keepaliveToRdc()

	/*
		Read the channel to monitor the configuration change from UI
		If config change, change the connect status to init and remove the token
	*/
	for {
		select {
		case <-cfg_channel:
			updateConnStatus(AMA_STATUS_INIT)
			//to do, remove the token, reload the config file
			loopConnect()
			fmt.Println("read the channel")
		default:
			fmt.Println("into the default")
			time.Sleep(5 * time.Second)
		}
	}

}

func keepaliveToRdc() {
	// create a timer for heartbeat
	ticker := time.NewTicker(10 * time.Second)
	timeout_cout := 0
	for _ = range ticker.C {
		/*
			check the timeout_cout of keepalive, if hearbeat fails,
			need to re-onboarding
		*/
		if timeout_cout >= KEEPALIVE_TIMEOUT_COUNT_MAX {
			updateConnStatus(AMA_STATUS_INIT)
			result := connectToRdc()
			if result == 0 {
				updateConnStatus(AMA_STATUS_CONNECTED)
				timeout_cout = 0
			} else {
				timeout_cout++
				fmt.Printf("keepaliveToRdc, timeout_cout:%d\n", timeout_cout)
				//Onboarding fail, not send keepalive
				continue
			}
		}
		//Check the connect status, if not connected, do nothing
		if readConnStatus() != AMA_STATUS_CONNECTED {
			continue
		}
		fmt.Println("sending the keepalive")
		request, err := http.NewRequest("GET", "http://10.155.22.93:8883/rest/v1/poll/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9BAA", nil)
		if err != nil {
			panic(err)
		}

		//增加header选项
		request.Header.Add("x-auth-token", "juanlitest")
		request.Header.Set("Content-Type", "application/json")

		resp, result := client.Do(request)
		if result != nil {
			timeout_cout++
			continue
		}
		timeout_cout = 0
		body, _ := ioutil.ReadAll(resp.Body)
		fmt.Println(string(body))
		fmt.Println(resp.Status)
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
