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
	ReqData  []byte
	RespData string
}

type Sections map[string]SectionNew

type SectionNew func(ctx context.Context) SectionCmd

type SectionCmd interface {
	Processor(w http.ResponseWriter, r *http.Request, d HandlerData)
}

const PostOK = `{"code": "ok"}`

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
	return []byte(fmt.Sprintf(`"code":"%s", "msg":"%s"`, code, msg))
}
