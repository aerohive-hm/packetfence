package a3config

import (
	//"github.com/inverse-inc/packetfence/go/ama/utils"
)


const (
	StepGetStart  = "getStart"
	StepAdminUser = "adminUser"
	StepNetworks = "networks"
	StepLicensing = "licensing"
	StepEntitilement = "licensing,enterEntitlementKey"
	StepAgreement = "licensing,endUserLicenseAgreement"
	StepAerohiveCloud = "aerohiveCloud"
	StepStartingManagement = "startingManagement"
	StepJoinCluster = "joinCluster"
	StepClusterNetworking = "clusterNetworking"
	StepJoining = "joining"
	StepStartRegistration = "startingRegistration"	
)


// After POST successfully, record the step
// If user open browser again, we start the step to continue
func writeSetupStep(step string) error {
	section := Section{
		"general": {
			"step": step,
		},
	}
	return A3Commit("STEP", section)
}


func RecordSetupStep(step, code string) {
	if code != "ok" {
		return
	}
	err := writeSetupStep(step)
	if err != nil {
		return
	}
}


func ReadSetupStep() string {

	section := A3Read("STEP", "general")
	return section["general"]["step"]
}

