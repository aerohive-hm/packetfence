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
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/julienschmidt/httprouter"
)

var mHandler = make(map[string]crud.Sections)

func Register(Cmd string, sections crud.Sections) {
	mHandler[Cmd] = sections
}

// parse http.request to handlerdata
func ParseRequestToData(r *http.Request) (handlerData crud.HandlerData, err error) {
	handlerData.ReqData, err = ioutil.ReadAll(r.Body)
	if err != nil {
		return handlerData, err
	}
	i := len(strings.Split(r.URL.Path, "/")) //r.URL.Path: /api/v1/cmd/subcmd
	if i > 4 {
		handlerData.Cmd = strings.Split(r.URL.Path, "/")[3]
		handlerData.SubCmd = strings.Split(r.URL.Path, "/")[4]
	} else {
		fmt.Errorf("Can not find cmd in url = %s", r.URL.Path)
	}
	return handlerData, err
}

func Handle(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	ctx := r.Context()
	d, err := ParseRequestToData(r)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return
	}
	section, ok := mHandler[d.Cmd]
	if !ok {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Can not find subCmd"+
			"for d.Cmd = %s", d.Cmd))
		return
	}

	func() {
		New, ok := section[d.SubCmd]
		if !ok {
			log.LoggerWContext(ctx).Error(fmt.Sprintln("no handle of " +
				d.SubCmd + " found."))
		}
		cmd := New(ctx)
		cmd.Processor(w, r, d)
		return
	}()
}
