//onboarding.go implements handling REST API:
/*
 *	/a3/api/v1/event/onboarding
 */
package event

import (
	"context"
	"encoding/json"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/share"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
)

type OnBoarding struct {
	crud.Crud
}

func OnBoardingNew(ctx context.Context) crud.SectionCmd {
	onBoarding := new(OnBoarding)
	onBoarding.New()
	onBoarding.Add("GET", getMethodHandle)
	return onBoarding
}

//Fetch and Convert A3 onboarding infomation To Json
func getMethodHandle(r *http.Request, d crud.HandlerData) []byte {
	var ctx = r.Context()
	onboardingInfo := a3share.GetOnboardingInfo(ctx)

	jsonData, err := json.Marshal(onboardingInfo)
	if err != nil {
		log.LoggerWContext(ctx).Error("marshal error:" + err.Error())
		return []byte(err.Error())
	}
	return jsonData
}
