/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/rdctoken
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
)

type TokenReq struct {
	SystemID string `json:"systemID"`
}

type Token struct {
	crud.Crud
}

func RdcTokenNew(ctx context.Context) crud.SectionCmd {
	token := new(Token)
	token.New()
	token.Add("GET", handleGetToken)
	token.Add("POST", handlePostToken)
	return token
}

/* This function will hanle the RDC token request from the other cluster members */
func handleGetToken(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()
	node := amac.NodeInfo{}

	para, ok := d.UrlParam["systemID"]
	if !ok {
		log.LoggerWContext(ctx).Error("Without systemID in URL parameter.")
		return nil
	}
	node.SystemID = para[0]

	para, ok = d.UrlParam["hostname"]
	if !ok {
		log.LoggerWContext(ctx).Error("Without hostname in URL parameter.")
		return nil
	}
	node.Hostname = para[0]
	tokenRegion := amac.ReqTokenForOtherNode(ctx, node)

	jsonData, err := json.Marshal(tokenRegion)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

/*
	When user input the GDC para to trigger the RDC token update in the other nodes
	this node will receive a post request and get a new RDC token
*/
func handlePostToken(r *http.Request, d crud.HandlerData) []byte {

	ctx := r.Context()
	cloudInfo := amac.CloudInfo{}

	log.LoggerWContext(ctx).Info("into handlePost Cloud info")
	err := json.Unmarshal(d.ReqData, &cloudInfo)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%+v", cloudInfo))

	if len(cloudInfo.Token) != 0 {
		amac.UpdateRdcToken(ctx, cloudInfo.Token, true)
	} else if (len(cloudInfo.RdcUrl) != 0 && len(cloudInfo.VhmID) != 0) {
		//update switch
		err = a3config.UpdateCloudConf(a3config.Switch, cloudInfo.Switch)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		}
		//update vhmid
		err = a3config.UpdateCloudConf(a3config.Vhm, cloudInfo.VhmID)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		}
		//update rdcurl
		err = a3config.UpdateCloudConf(a3config.RDCUrl, cloudInfo.RdcUrl)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		}

		//update OrgID
		err = a3config.UpdateCloudConf(a3config.OrgId, cloudInfo.OrgID)
		if err != nil {
			log.LoggerWContext(ctx).Error("Update cloud config error: " + err.Error())
		}

		node := amac.MemberList{IpAddr: cloudInfo.PriNode}
		amac.ReqTokenFromOtherNodes(ctx, &node)
	} else {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("%+v", cloudInfo))
		return []byte(crud.PostNOTOK)
	}

	return []byte(crud.PostOK)
}
