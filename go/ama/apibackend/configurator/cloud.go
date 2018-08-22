package configurator

import (
	"context"
//	"encoding/json"
	//	"fmt"
//	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
//	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/configuration"
)

type CloudConf struct {
	Url  string `json:"url"`
	User string `json:"user"`
	Pass string `json:"pass"`
}

type Cloud struct {
	crud.Crud
}

func CloudNew(ctx context.Context) crud.SectionCmd {
	cloud := new(Cloud)
	cloud.New()
	//cloud.Add("GET", handleGetCloudConf)
	cloud.Add("POST", configuration.HandlePostCloudInfo)
	return cloud
}

/*
func handleGetCloudConf(r *http.Request, d crud.HandlerData) []byte {
	// Data for demo
	cloud := map[string]string{
		"url":  "https://www.cloud.aerohive.com",
		"user": "czhong@aerohive.com",
	}

	var ctx = r.Context()
	jsonData, err := json.Marshal(cloud)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}

func handlePostCloudConf(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	cloud := new(CloudConf)
	err := json.Unmarshal(d.ReqData, cloud)
	if err != nil {
		log.LoggerWContext(ctx).Error("unmarshal error:" + err.Error())
		return []byte(`{"code":"fail"}`)
	}

	return []byte(crud.PostOK)
}
*/