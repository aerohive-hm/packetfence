package report

import (
	"encoding/json"
	"fmt"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"github.com/inverse-inc/packetfence/go/log"
	"net/http"
)

type ReportDataer interface {
	GetTableKey4Redis() string
}

func (d NodeReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s+%s", d.TableName, d.TenantId, d.Mac)
}

func (d NodecategoryReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d+%s", d.TableName, d.CategoryID, d.Name)
}

func (d LocationlogReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.Id)
}

func (d RadacctReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.RadacctID)
}

func (d Ip4logReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s+%s", d.TableName, d.TenantID, d.Ip)
}

func (d ClassReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.Vid)
}

func (d ViolationReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.Id)
}

func (d RadauditReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.Id)
}

type ReportData struct {
	TableName string `json:"ah_tablename"`
	TimeStamp string `json:"ah_timestamp"`
}

// Get a key for database table entry
// Thus the updating same table entry will be overwrite, don't send too much duplicate data to cloud
func GetkeyfromPostReport(r *http.Request, d crud.HandlerData) string {
	ctx := r.Context()

	reportData := new(ReportData)
	err := json.Unmarshal(d.ReqData, reportData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return ""
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive DB report event data : table:%s", reportData.TableName))

	var parseReportData ReportDataer
	switch reportData.TableName {
	case "node":
		parseReportData = new(NodeReportData)
	case "node_category":
		parseReportData = new(NodecategoryReportData)
	case "locationlog":
		parseReportData = new(LocationlogReportData)
	case "radacct":
		parseReportData = new(RadacctReportData)
	case "ip4log":
		parseReportData = new(Ip4logReportData)
	case "class":
		parseReportData = new(ClassReportData)
	case "violation":
		parseReportData = new(ViolationReportData)
	case "radius_audit_log":
		parseReportData = new(RadauditReportData)

	default:
		log.LoggerWContext(ctx).Error(fmt.Sprintf("don't know table %s", reportData.TableName))
		return reportData.TableName
	}

	err = json.Unmarshal(d.ReqData, parseReportData)
	if err != nil {
		log.LoggerWContext(ctx).Error("Unmarshal error:" + err.Error())
		return ""
	}

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("receive DB report event table data:%#v", parseReportData))

	return parseReportData.GetTableKey4Redis()
}
