package crud

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
	"net/url"
)

type HandlerData struct {
	Cmd      string //configurator
	SubCmd   string //adminuser
	Header   string
	UrlParam url.Values /*/?aa=123&bb=abc*/
	ReqData  []byte
	RespData string
}

type Sections map[string]SectionNew

type SectionNew func(ctx context.Context) SectionCmd

type SectionCmd interface {
	Processor(w http.ResponseWriter, r *http.Request, d HandlerData)
}

const PostOK = `{"code": "ok"}`
const PostNOTOK = `{"code": "fail"}`

type Crud struct {
	handlers map[string]CrudSubHandler
}

type CrudSubHandler func(r *http.Request, d HandlerData) []byte

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

	jsonData := handler(r, d)
	fmt.Fprintf(w, string(jsonData))
}

func FormPostRely(code string, msg string) []byte {
	if code == "fail" {
		return []byte(fmt.Sprintf(`{"code":"%s", "msg":"%s"}`, code, msg))
	}
	if msg == "" {
		return []byte(PostOK)
	}
	return []byte(fmt.Sprintf(`{"code":"ok", %s}`, msg))
}
