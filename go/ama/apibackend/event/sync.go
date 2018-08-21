/*sync.go implements handling REST API:
 *	/a3/api/v1/event/cluster/sync
 */
package event

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	//	"github.com/inverse-inc/packetfence/go/ama/fetch"
	"github.com/inverse-inc/packetfence/go/log"
)

type SyncData struct {
	Status string `json:"status"`
}

type Sync struct {
	crud.Crud
}

func ClusterSyncNew(ctx context.Context) crud.SectionCmd {
	sync := new(Sync)
	sync.New()
	sync.Add("POST", handleUpdateSync)
	return sync
}

func handleUpdateSync(r *http.Request, d crud.HandlerData) []byte {
	ctx := r.Context()
	sync := new(SyncData)

	err := json.Unmarshal(d.ReqData, sync)
	if err != nil {
		return []byte(err.Error())
	}

	log.LoggerWContext(ctx).Info(fmt.Sprintf("%v", sync))

	return []byte(crud.PostOK)
}
