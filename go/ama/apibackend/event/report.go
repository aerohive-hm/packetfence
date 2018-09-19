/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/report
 */
package event

import (
	"context"
	"encoding/json"
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
	recvCounterNodeCategory int64
	recvCounterRadacct int64
	recvCounterIp4log int64
	recvCounterViolation int64
	recvCounterClass int64
	recvCounterRadaudit int64
}

var ReportCounter ReportDBCounter

type Report struct {
	crud.Crud
}

func ReportNew(ctx context.Context) crud.SectionCmd {
	newreport := new(Report)
	newreport.New()
	newreport.Add("POST", handlePostReport)
	return newreport
}



// Get a key for database table entry
// Thus the updating same table entry will be overwrite, don't send too much duplicate data to cloud
func GetkeyfromPostReport(r *http.Request, d crud.HandlerData) string {
	ctx := r.Context()

	reportData := new(report.ReportData)
	err := json.Unmarshal(d.ReqData, reportData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return ""
	}

	var parseReportData report.ReportDataer
	switch reportData.TableName {
	case "node":
		ReportCounter.recvCounterNode++
		parseReportData = new(report.NodeReportData)
	case "node_category":
		ReportCounter.recvCounterNodeCategory++
		parseReportData = new(report.NodecategoryReportData)
	case "locationlog":
		ReportCounter.recvCounterLoationlog++
		parseReportData = new(report.LocationlogReportData)
	case "radacct":
		ReportCounter.recvCounterRadacct++
		parseReportData = new(report.RadacctReportData)
	case "ip4log":
		ReportCounter.recvCounterIp4log++
		parseReportData = new(report.Ip4logReportData)
	case "class":
		ReportCounter.recvCounterClass++
		parseReportData = new(report.ClassReportData)
	case "violation":
		ReportCounter.recvCounterViolation++
		parseReportData = new(report.ViolationReportData)
	case "radius_audit_log":
		ReportCounter.recvCounterRadaudit++
		parseReportData = new(report.RadauditReportData)

	default:
		log.LoggerWContext(ctx).Error(fmt.Sprintf("don't know table %s", reportData.TableName))
		return reportData.TableName
	}

	err = json.Unmarshal(d.ReqData, parseReportData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return ""
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive DB report data for table %s data:%#v", reportData.TableName, parseReportData))

	return parseReportData.GetTableKey4Redis()
}


func handlePostReport(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()

	ReportCounter.recvCounter++

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive DB report event data count: %d", ReportCounter.recvCounter))
	log.LoggerWContext(ctx).Info(string(d.ReqData))

	redisKey := GetkeyfromPostReport(r, d)
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
	if count >= amac.CacheTableUpLimit {
		amac.ReportDbTable(ctx, true)
	}

	return []byte(crud.PostOK)
}
