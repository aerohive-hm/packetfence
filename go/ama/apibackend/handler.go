package a3apibackend

import (
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/log"
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

var mhandle = make(map[string]Callback)

type Callback func(w http.ResponseWriter, r *http.Request, d HandlerData)

func Register(handlersub string, callback Callback) {
	mhandle[handlersub] = callback
}

// parse http.request to handlerdata
func ParseRequestToData(r *http.Request) HandlerData {
	ctx := r.Context()
	handlerdata := HandlerData{}
	handlerdata.Method = r.Method
	i := len(strings.Split(r.URL.Path, "/")) //r.URL.Path: /api/v1/cmd/subcmd
	if i > 4 {
		handlerdata.Cmd = strings.Split(r.URL.Path, "/")[3]
		handlerdata.SubCmd = strings.Split(r.URL.Path, "/")[4]
	} else {
		log.LoggerWContext(ctx).Error("Error can not find cmd in url")
	}
	return handlerdata
}

func Handle(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	ctx := r.Context()
	d := ParseRequestToData(r)

	handle, ok := mhandle[d.Cmd]
	if ok {
		handle(w, r, d)
	} else {
		log.LoggerWContext(ctx).Error("Error can not find handlesub")
	}
	return
}
