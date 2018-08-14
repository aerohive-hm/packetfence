//handleEvent.go implements handling REST API:
/*
 *	/a3/api/v1/event/...
 */
package apibackend

import (
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/event"
)

func init() {
	sections := crud.Sections{
		"onboarding": event.OnBoardingNew,
	}
	Register("event", sections)
}
