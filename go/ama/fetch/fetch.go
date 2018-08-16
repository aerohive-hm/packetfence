/*fetch.go implements get pfconfig date by unified method */

package fetch

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
	General pfconfigdriver.PfConfGeneral
}

type PfConfCaptivePortal struct {
	Comm
	CaptivePortal pfconfigdriver.PfConfCaptivePortal
}

type PfConfFencing struct {
	Comm
	Fencing pfconfigdriver.PfConfFencing
}

type PfConfDatabase struct {
	Comm
	Database pfconfigdriver.PfConfDatabase
}

type ManagementNetwork struct {
	Comm
	Network pfconfigdriver.ManagementNetwork
}
