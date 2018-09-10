package report

type LocationLog struct {
	Id               int32  `json:"id"`
	TenantID         int32  `json:"tenantID"`
	Mac              string `json:"mac"`
	Switch           string `json:"switch"`
	Port             string `json:"port"`
	Vlan             string `json:"vlan"`
	Role             string `json:"role"`
	ConnType         string `json:"connectionType"`
	connSubType      string `json:"connectionSubType"`
	Dot1xUserName    string `json:"dot1xUserNmae"`
	Ssid             string `json:"ssid"`
	StartTime        int64  `json:"startTime"`
	EndTime          int64  `json:"endTime"`
	SwitchIp         string `json:"switchIp"`
	SwitchMac        string `json:"switchMac"`
	StrippedUserName string `json:"strippedUserName"`
	Realm            string `json:"realm"`
	SessionId        string `json:"sessionId"`
	IfDesc           string `json:"ifDesc"`
	ModifyDate       int64  `json:"modifyDate"`
}
