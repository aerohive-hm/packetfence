/*rdctoken.go implements handling REST API:
 *      /a3/api/v1/event/report
 */
package event

import (
	"context"
	//"encoding/json"
	"fmt"
	"net/http"

	//"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	//"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
)

type ReportDBCounter struct {
	recvCounter  int64
	recvCounterNode int64
	recvCounterLoationlog int64
}

var Counter ReportDBCounter

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
	//cloudInfo := amac.CloudInfo{}

	Counter.recvCounter++

	log.LoggerWContext(ctx).Info(fmt.Sprintf("receive DB report event data count: %d", Counter.recvCounter))

	log.LoggerWContext(ctx).Info(string(d.ReqData))

	return []byte(crud.PostOK)
}
