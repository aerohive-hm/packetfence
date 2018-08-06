package a3apibackend

import (
	//"encoding/json"
	//"fmt"
	"net/http"
	"strings"

	"github.com/julienschmidt/httprouter"
)

type HandlerData struct {
	Method   string //get/post
	Cmd      string //configurator
	SubCmd   string //admin_user
	Header   string
	UrlParam string /*/?aa=123&bb=abc*/
	ReqData  string
	RespData string
}

//define callback function
type Callback func(w http.ResponseWriter, r *http.Request, d HandlerData)

func HandleCallback(w http.ResponseWriter, r *http.Request, d HandlerData, callback Callback) {
	callback(w, r, d)
}

// parse http.request to handlerdata
func ParseRequestToData(r *http.Request) HandlerData {
	handlerdata := HandlerData{}
	ParseRequestCmdToData(r, &handlerdata)
	handlerdata.Method = r.Method
	return handlerdata
}

func ParseRequestCmdToData(r *http.Request, handlerdata *HandlerData) {

	if strings.Contains(r.URL.Path, "configuator/adminuser") {
		handlerdata.Cmd = "configuator"
		handlerdata.SubCmd = "adminuser"
	}

	if strings.Contains(r.URL.Path, "event/cluster/join") {
		handlerdata.Cmd = "event"
		handlerdata.SubCmd = "cluster/join"
	}

	//add others

}

func Handle(w http.ResponseWriter, r *http.Request, p httprouter.Params) {

	handlerdata := ParseRequestToData(r)

	if handlerdata.Cmd == "configuator" {
		HandleCallback(w, r, handlerdata, HandleConfiguator)
	}
	// add others
	/*
		if (handlerdata.Cmd == "event") {
			HandleCallback(w, r, handlerdata, HandleEvent)
		}
	*/
}
