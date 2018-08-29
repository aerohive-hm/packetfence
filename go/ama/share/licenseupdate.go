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
