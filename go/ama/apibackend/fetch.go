package a3apibackend

import (
	"context"

	"github.com/inverse-inc/packetfence/go/pfconfigdriver"
)

type New interface{}
type Comm struct{}

func (c *Comm) GetPfConfSub(ctx context.Context, obj pfconfigdriver.PfconfigObject) {
	pfconfigdriver.FetchDecodeSocket(ctx, obj)
}

type PfConfWebservices struct {
	Comm
	Webservices pfconfigdriver.PfConfWebservices
}

type PfConfGeneral struct {
	Comm
	General pfconfigdriver.PfConfWebservices
}

type PfConfCaptivePortal struct {
	Comm
	CaptivePortal pfconfigdriver.PfConfWebservices
}
