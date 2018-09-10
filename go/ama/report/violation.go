package report

type Violation struct {
	Id          int32  `json:"id"`
	TenantID    int32  `json:"tenantID"`
	Mac         string `json:"mac"`
	Vid         int32  `json:"vid"`
	StartDate   int64  `json:"startDate"`
	ReleaseDate int64  `json:"releaseDate"`
	Status      string `json:"status"`
	TicketRef   string `json:"ticketRef"`
	Notes       string `json:"notes"`
	ModifyDate  int64  `json:"modifyDate"`
}
