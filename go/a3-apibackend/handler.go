package a3apibackend

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/julienschmidt/httprouter"
)

type HandlerData struct {
	Method   string //get/post
	Cmd      string //configurator
	SubCmd   string //adminuser
	Header   string
	UrlParam string /*/?aa=123&bb=abc*/
	ReqData  string
	RespData string
}

// m map[string]Callback
var m = make(map[string]Callback)

func Register(modename string, callback Callback) {
	m[modename] = callback
}

type Callback func(w http.ResponseWriter, r *http.Request, d HandlerData)

// parse http.request to handlerdata
func ParseRequestToData(r *http.Request) HandlerData {

	handlerdata := HandlerData{}
	handlerdata.Method = r.Method
	//r.URL.Path: /api/v1/cmd/subcmd
	i := len(strings.Split(r.URL.Path, "/"))
	if i > 4 {
		handlerdata.Cmd = strings.Split(r.URL.Path, "/")[3]
		handlerdata.SubCmd = strings.Split(r.URL.Path, "/")[4]
	} else {
		fmt.Println("it can't find cmd or subcmd in request url")
	}
	return handlerdata
}

func Handle(w http.ResponseWriter, r *http.Request, p httprouter.Params) {

	handlerdata := ParseRequestToData(r)

	handle, ok := m[handlerdata.Cmd]
	if ok {
		handle(w, r, handlerdata)
	} else {
		fmt.Println("it can not match handlefuc")
	}
	return
}
