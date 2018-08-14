package crud

import (
	"context"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/log"
)

type HandlerData struct {
	Cmd      string //configurator
	SubCmd   string //adminuser
	Header   string
	UrlParam string /*/?aa=123&bb=abc*/
	ReqData  string
	RespData string
}

type Sections map[string]SectionNew

type SectionNew func(ctx context.Context) SectionCmd

type SectionCmd interface {
	Processor(w http.ResponseWriter, r *http.Request, d HandlerData)
}

type Crud struct {
	handlers map[string]CrudSubHandler
}

type CrudSubHandler func(r *http.Request, d HandlerData) ([]byte, error)

func (crud *Crud) New() {
	crud.handlers = make(map[string]CrudSubHandler)
}

func (crud *Crud) Add(key string, handler CrudSubHandler) {
	crud.handlers[key] = handler
}

func (crud *Crud) Processor(w http.ResponseWriter, r *http.Request, d HandlerData) {
	ctx := r.Context()

	handler, ok := crud.handlers[r.Method]
	if !ok {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Can't handle unsupported "+
			"method: %s", r.Method))
		return
	}

	jsonData, err := handler(r, d)
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Error while handling %s"+
			"method for subcmd %s:", r.Method, d.SubCmd))
		return
	}

	fmt.Fprintf(w, string(jsonData))
}
