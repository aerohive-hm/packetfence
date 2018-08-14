//Package apibackend implements handling multiple REST API, They are:
/*
*	/a3/api/v1/configurator/admin_user
*	/a3/api/v1/configurator/networks
*	/a3/api/v1/configurator/cluster/networks
*	/a3/api/v1/configurator/cluster/join
*	/a3/api/v1/configurator/cluster/status
*
*	/a3/api/v1/configuration/interface
*	/a3/api/v1/configuration/cloud
*	/a3/api/v1/configuration/license
*	/a3/api/v1/configuration/cluster
*
*	/a3/api/v1/event/onboarding
*	/a3/api/v1/event/cluster/join
*	/a3/api/v1/event/cluster/sync
*	/a3/api/v1/event/cluster/remove
*
*	/a3/api/v1/services/a3/status
*	/a3/api/v1/services/ama/info
*	/a3/api/v1/service/ama/operation
*
*	/a3/api/v1/cluster/ama/info
 */
package apibackend

import (
	"net/http"
	"reflect"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/julienschmidt/httprouter"
)

type Sections map[string]interface{}

var mHandler = make(map[string]Sections)

type A3ApiHandler func(w http.ResponseWriter, r *http.Request, d crud.HandlerData)

func Register(Cmd string, sections Sections) {
	mHandler[Cmd] = sections
}

// parse http.request to handlerdata
func ParseRequestToData(r *http.Request) (handlerData crud.HandlerData) {
	ctx := r.Context()
	i := len(strings.Split(r.URL.Path, "/")) //r.URL.Path: /api/v1/cmd/subcmd
	if i > 4 {
		handlerData.Cmd = strings.Split(r.URL.Path, "/")[3]
		handlerData.SubCmd = strings.Split(r.URL.Path, "/")[4]
	} else {
		log.LoggerWContext(ctx).Error("Error can not find cmd in url")
	}
	return handlerData
}

func Handle(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	ctx := r.Context()
	d := ParseRequestToData(r)

	section, ok := mHandler[d.Cmd]
	if !ok {
		log.LoggerWContext(ctx).Error("Error can not find handlesub")
		return
	}
	func() {
		cmd, ok := section[d.SubCmd]
		if !ok {
			log.LoggerWContext(ctx).Error("Can not find handler of section.")
			return
		}
		f := reflect.ValueOf(cmd)
		obj := f.Call(nil)
		obj.Processor(w, r, d)
		//cmd().Processor(w, r, d)
		return
	}()
}

/*
func SubCmdHandler(w http.ResponseWriter, r *http.Request, d crud.HandlerData) {
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
