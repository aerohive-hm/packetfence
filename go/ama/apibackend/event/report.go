/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/report
 */
package event

import (
	"context"
	//"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/ama/cache"
	"github.com/inverse-inc/packetfence/go/ama/report"
	"github.com/inverse-inc/packetfence/go/log"
)

type ReportDBCounter struct {
	recvCounter           int64
	recvCounterNode       int64
	recvCounterLoationlog int64
}

var ReportCounter ReportDBCounter

type Report struct {
	crud.Crud
}

func ReportNew(ctx context.Context) crud.SectionCmd {
	report := new(Report)
	report.New()
	report.Add("POST", handlePostReport)
	return report
}

func handlePostReport(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	ReportCounter.recvCounter++

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive DB report event data count: %d", ReportCounter.recvCounter))
	log.LoggerWContext(ctx).Debug(string(d.ReqData))

	redisKey := report.GetkeyfromPostReport(r, d)
	if redisKey == "" {
		redisKey = "amaReportData"
	}

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("fetch redis key=%s for event data", redisKey))

	count, err := cache.CacheTableInfo(redisKey, d.ReqData)
	if err != nil {
		log.LoggerWContext(ctx).Error("cache data to queue fail")
		return []byte(crud.PostOK)
	}
	log.LoggerWContext(ctx).Debug(fmt.Sprintf("%d messages in queue", count))
	if count >= 30 {
		amac.ReportDbTable(ctx)
	}

	return []byte(crud.PostOK)
}
