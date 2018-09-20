/*rdctoken.go implements handling REST API:
 *      /api/v1/event/radiusauth
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/report"
	//"github.com/inverse-inc/packetfence/go/ama/cache"
	"github.com/inverse-inc/packetfence/go/log"
	"time"
)

type RadAuth struct {
	crud.Crud
}

func RadAuthNew(ctx context.Context) crud.SectionCmd {
	radauth := new(RadAuth)
	radauth.New()
	radauth.Add("POST", handlePostRadAuth)
	return radauth
}

func fillRadAuditTable(src *report.RadauditOriData) report.RadauditParseStruct {
	dst := report.RadauditParseStruct{}
	dst.TableName = "radius_audit_log"
	dst.TimeStamp = fmt.Sprintf("%d", time.Now().UTC().UnixNano()/(int64(time.Millisecond)*1000))

	dst.UserName = src.UserName.Value[0]
	dst.NasIpAddr = src.NasIpAddress.Value[0]
	dst.NasPort = fmt.Sprintf("%d", src.NasPort.Value[0])
	//dst. = src.ServiceType.Value[0]
	dst.CalledStationID = src.CalledStationId.Value[0]
	dst.CallingStationID = src.CallingStationId.Value[0]
	dst.NasIdentifier = src.NasIdentifier.Value[0]
	dst.NasPortType = fmt.Sprintf("%d", src.NasPortType.Value[0])
	//dst. = src.AcctSessionId.Value[0]
	//dst. = src.AcctMultiSessionId.Value[0]
	dst.StripUserName = src.StrippedUserName.Value[0]
	dst.Realm = src.Realm.Value[0]
	dst.SSID = src.CalledStationSsid.Value[0]
	//dst. = src.FreeRadiusClientIpAddress.Value[0]
	return dst
}

/* This function will hanle the JSON data from the radius process */
func handlePostRadAuth(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	log.LoggerWContext(ctx).Error("into handlePostRadAuth")
	radReq := report.RadauditOriData{}

	err := json.Unmarshal(d.ReqData, &radReq)
	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
		return []byte("")
	}

	log.LoggerWContext(ctx).Error(fmt.Sprintf("print the data :%+v", radReq))
	_ = fillRadAuditTable(&radReq)
	/*
		redisKey := GetkeyfromPostReport(r, dst)
		if redisKey == "" {
			redisKey = "amaReportData"
		}

		log.LoggerWContext(ctx).Debug(fmt.Sprintf("fetch redis key=%s for event data", redisKey))

		count, err := cache.CacheTableInfo(redisKey, dst)
		if err != nil {
			log.LoggerWContext(ctx).Error("cache data to queue fail")
			return []byte(crud.PostOK)
		}
		log.LoggerWContext(ctx).Debug(fmt.Sprintf("%d messages in queue", count))
	*/

	amac.ReportDbTable(ctx, true)

	return []byte("")
}
