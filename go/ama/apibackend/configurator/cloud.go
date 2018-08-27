package configurator

import (
	"context"

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
	cloud.Add("POST", configuration.HandlePostCloudInfo)
	return cloud
}
