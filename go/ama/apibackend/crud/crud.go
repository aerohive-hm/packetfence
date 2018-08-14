package crud

import (
	"fmt"
	"net/http"
	//	"reflect"

	"github.com/inverse-inc/packetfence/go/log"
)

type HandlerData struct {
	//  Method   string //get/post
	Cmd      string //configurator
	SubCmd   string //adminuser
	Header   string
	UrlParam string /*/?aa=123&bb=abc*/
	ReqData  string
	RespData string
}

type New interface {
	New() interface{}
}

type Crud struct {
	handlers map[string]CrudSubHandler
}

type CrudSubHandler func(r *http.Request, d HandlerData) ([]byte, error)

func (crud *Crud) Add(key string, handler CrudSubHandler) {
	crud.handlers[key] = handler
}

func (crud *Crud) Processor(w http.ResponseWriter, r *http.Request, d HandlerData) {
	ctx := r.Context()

	handler, ok := crud.handlers[r.Method]
	if !ok {
		log.LoggerWContext(ctx).Error("Can't handle unsupported method:%s", r.Method)
		return
	}

	jsonData, err := handler(r, d)
	if err != nil {
		log.LoggerWContext(ctx).Error("Error while handling %s"+
			"method for subcmd %s:", r.Method, d.SubCmd)
		return
	}
	fmt.Fprintf(w, string(jsonData))
}

/*
func ExecSubCmd(w http.ResponseWriter, r *http.Request, d HandlerData) {
	ctx := r.Context()
	cmdNew, ok := sections[d.SubCmd]
	if !ok {
		log.LoggerWContext(ctx).Error("Can not find handler of section.")
		return
	}
	section().Processor(w, r, d)
	return
}
*/
