package report

type NodeCategory struct {
	CategoryID     int32  `json:"categoryID"`
	Name           string `json:"name"`
	MaxNodesPerPid int32  `json:"maxNodesPerPid"`
	Notes          string `json:"notes"`
}
