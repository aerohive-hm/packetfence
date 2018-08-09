package amac

import (
	//"crypto/x509"
	//"connect"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

//import _ "config"

const (
	AMA_STATUS_INIT      = 0
	AMA_STATUS_CONNECTED = 1
	AMA_STATUS_UNKNOWN   = 100
)
const KEEPALIVE_TIMEOUT_COUNT_MAX = 3

var AMA_connect_status = AMA_STATUS_INIT

func Entry() {
	// try to connet to GDC and RDC
	result := Connect_to_gdc_rdc()
	if result != 0 {
		//Create a timer to connect the GDC and RDC
		ticker := time.NewTicker(5 * time.Second)
		for _ = range ticker.C {
			result := Connect_to_gdc_rdc()
			if result != 0 {
				continue
			} else {
				AMA_connect_status = AMA_STATUS_CONNECTED
				ticker.Stop()
				break
			}
		}
	} else {
		AMA_connect_status = AMA_STATUS_CONNECTED
	}

	// create a timer to send keepalive
	if AMA_connect_status == AMA_STATUS_CONNECTED {
		ticker := time.NewTicker(10 * time.Second)
		timeout_cout := 0
		for _ = range ticker.C {
			fmt.Println("sending the keepalive")
			//check the result of keepalive, if hearbeat fails, need to re-onboarding
			if timeout_cout >= KEEPALIVE_TIMEOUT_COUNT_MAX {
				AMA_connect_status = AMA_STATUS_INIT
				result := Connect_to_rdc()
				if result == 0 {
					AMA_connect_status = AMA_STATUS_CONNECTED
					timeout_cout = 0
				} else {
					timeout_cout++
				}
			}
			request, err := http.NewRequest("GET", "http://10.155.22.93:8882/rest/v1/poll/47B4-FB5D-7817-2EDF-0FFE-D9F0-944A-9B72", nil)
			if err != nil {
				panic(err)
			}

			//增加header选项
			request.Header.Add("x-auth-token", "juanlitest")
			request.Header.Set("Content-Type", "application/json")

			resp, result := Client.Do(request)
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
