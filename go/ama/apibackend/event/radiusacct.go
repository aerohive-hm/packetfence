/*rdctoken.go implements handling REST API:
 *      /api/v1/event/radiusacct
 */
package event

import (
	"context"
	//"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/cache"
	"github.com/inverse-inc/packetfence/go/ama/report"
	"github.com/inverse-inc/packetfence/go/log"
)

type RadAcct struct {
	crud.Crud
}

func RadAcctNew(ctx context.Context) crud.SectionCmd {
	radacct := new(RadAcct)
	radacct.New()
	radacct.Add("POST", handlePostRadAcct)
	return radacct
}

func fillRadAcctTableBasedAcctReq(src *report.RadacctOriData) report.RadacctParseStruct {
	dst := report.RadacctParseStruct{}
	dst.TableName = "radacct"
	dst.TimeStamp = fmt.Sprintf("%d", time.Now().UTC().UnixNano()/(int64(time.Millisecond)*1000))

	dst.UserName = src.UserName.Value[0]
	//dst.NasIpAddress = src.NasIpAddress.Value[0]
	//dst.NasPort = fmt.Sprintf("%d", src.NasPort.Value[0])
	dst.ServiceType = fmt.Sprintf("%d", src.ServiceType.Value[0])
	dst.CalledStaID = src.CalledStationId.Value[0]
	dst.CallingStaID = src.CallingStationId.Value[0]
	//dst.NasIdentifier = src.NasIdentifier.Value[0]
	dst.NasPortType = fmt.Sprintf("%d", src.NasPortType.Value[0])
	//dst. = src.AcctSessionId.Value[0]
	//dst. = src.AcctMultiSessionId.Value[0]
	//dst.StripUserName = src.StrippedUserName.Value[0]
	dst.Realm = src.Realm.Value[0]
	//dst.SSID = src.CalledStationSsid.Value[0]
	//dst.Mac = src.CallingStationId.Value[0]
	//dst. = src.FreeRadiusClientIpAddress.Value[0]
	dst.AcctStopTime = dst.TimeStamp
	return dst
}

/* This function will hanle the RDC token request from the other cluster members */
func handlePostRadAcct(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	//radAcct := report.RadacctParseStruct{}

	ReportCounter.recvCounter++

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("receive radacct report: %d", ReportCounter.recvCounter))
	log.LoggerWContext(ctx).Debug(string(d.ReqData))

	redisKey := GetkeyfromPostReport(r, d.ReqData)
	if redisKey == "" {
		redisKey = "amaReportData"
	}

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("fetch redis key=%s for event data", redisKey))
	count, err := cache.CacheTableInfoInOrder(redisKey, d.ReqData)
	if err != nil {
		log.LoggerWContext(ctx).Error("cache data to queue fail")
		return []byte(crud.PostOK)
	}
	log.LoggerWContext(ctx).Debug(fmt.Sprintf("%d messages in queue", count))

	if count >= amac.CacheTableUpLimit {
		amac.ReportDbTable(ctx, true)
	}

	return []byte("")
}
