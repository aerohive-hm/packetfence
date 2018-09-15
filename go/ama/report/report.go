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

func (d NodeParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s+%s", d.TableName, d.TenantId, d.Mac)
}

func (d NodecategoryParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s+%s", d.TableName, d.CategoryID, d.Name)
}

func (d LocationlogParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.Id)
}

func (d RadacctParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.RadacctID)
}

func (d Ip4logParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s+%s", d.TableName, d.TenantID, d.Ip)
}

func (d ClassParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.Vid)
}

func (d ViolationParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.Id)
}

func (d RadauditParseStruct) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.Id)
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

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("receive DB report event data : table:%s", reportData.TableName))

	var parseReportData ReportDataer
	switch reportData.TableName {
	case "node":
		parseReportData = new(NodeParseStruct)
	case "node_category":
		parseReportData = new(NodecategoryParseStruct)
	case "locationlog":
		parseReportData = new(LocationlogParseStruct)
	case "radacct":
		parseReportData = new(RadacctParseStruct)
	case "ip4log":
		parseReportData = new(Ip4logParseStruct)
	case "class":
		parseReportData = new(ClassParseStruct)
	case "violation":
		parseReportData = new(ViolationParseStruct)
	case "radius_audit_log":
		parseReportData = new(RadauditParseStruct)

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
