package report

import (
	"fmt"
)

type ReportDataer interface {
	GetTableKey4Redis() string
}

func (d NodeReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d+%s", d.TableName, d.TenantId, d.Mac)
}

func (d NodecategoryReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d+%s", d.TableName, d.CategoryID, d.Name)
}

func (d LocationlogReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%s", d.TableName, d.Mac)
}

func (d RadacctReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d", d.TableName, d.RadacctID)
}

func (d Ip4logReportData) GetTableKey4Redis() string {
	return fmt.Sprintf("%s+%d+%s", d.TableName, d.TenantID, d.Ip)
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


