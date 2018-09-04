package a3share

import (
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
)

func StartService() {
	if utils.IsFileExist(utils.A3CurrentlyAt) {
		return
	}

	a3config.UpdateGaleraUser()
	a3config.UpdateWebservicesAcct()
	a3config.UpdateClusterFile()
	utils.InitStartService()
}
