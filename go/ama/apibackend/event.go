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
		"onboarding":    event.OnBoardingNew,
		"clusterjoin":   event.ClusterJoinNew,
		"clustersync":   event.ClusterSyncNew,
		"rdctoken":      event.RdcTokenNew,
		"clusterremove": event.RemoveNodeNew,
		"amastatus":     event.AMAStatusNew,
		"amaaction":     event.AMAActionNew,
	}
	Register("event", sections)
}
