/*
	When license info changes or remove a node from cluster
	assemble the corresponding message
*/
package a3share

import (
	"context"
)

type LicenseUpdateData struct {
	Msgtype             string `json:"msgType"`
	LicensedCapacity    int    `json:"licensedCapacity"`
	CurrentUsedCapacity int    `json:"currentUsedCapacity"`
	AverageUsedCapacity int    `json:"averageUsedCapacity"`
	NextExpirationDate  int64  `json:"nextExpirationDate"`
}

type LicenseUpdateInfo struct {
	Header A3OnboardingHeader `json:"header"`
	Data   LicenseUpdateData  `json:"data"`
}

type RemoveNodeData struct {
	Msgtype       string   `json:"msgType"`
	SystemIdArray []string `json:"removedClusterMemberSystemIDs"`
}

type removeNodeFromCluster struct {
	Header A3OnboardingHeader `json:"header"`
	Data   RemoveNodeData     `json:"data"`
}

//Obtaining the latest license info
func GetLicenseUpdateInfo(ctx context.Context) []LicenseUpdateInfo {

	var infoArray []LicenseUpdateInfo
	info := LicenseUpdateInfo{}
	var lic A3License

	//Fill the header
	info.Header.GetValue(ctx)

	//Fill the body
	lic.GetValue(ctx)
	info.Data.Msgtype = "license-update"
	info.Data.LicensedCapacity = lic.LicensedCapacity
	//info.Data.LicensedCapacity = 100
	info.Data.CurrentUsedCapacity = lic.CurrentUsedCapacity
	info.Data.AverageUsedCapacity = lic.AverageUsedCapacity
	info.Data.NextExpirationDate = lic.NextExpirationDate

	infoArray = append(infoArray, info)
	return infoArray
}

func FillRemoveNodeInfo(ctx context.Context, systemIdArray []string) removeNodeFromCluster {
	rmNodeInfo := removeNodeFromCluster{}

	rmNodeInfo.Header.GetValue(ctx)
	rmNodeInfo.Data.Msgtype = "cluster-member-removal"
	rmNodeInfo.Data.SystemIdArray = systemIdArray
	//rmNodeInfo.Data.SystemIdArray = append(rmNodeInfo.Data.SystemIdArray, "BBBB-2104-0349-64CD-2D25-B7A3-DC0A-841E")
	//rmNodeInfo.Data.SystemIdArray = append(rmNodeInfo.Data.SystemIdArray, "CCCC-2104-0349-64CD-2D25-B7A3-DC0A-841E")

	return rmNodeInfo
}
