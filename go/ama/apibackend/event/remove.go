/*remove.go implements handling REST API:
 *	/a3/api/v1/event/cluster/remove
 */
package event

import (
	"context"
	"github.com/inverse-inc/packetfence/go/ama/apibackend/crud"
	"net/http"
)

type RemovedNodeInfo struct {
}

type RemovedNode struct {
	crud.Crud
}

func RemoveNodeNew(ctx context.Context) crud.SectionCmd {
	node := new(RemovedNode)
	node.New()
	node.Add("POST", handlePostRemoveNode)
	return node
}

func handlePostRemoveNode(r *http.Request, d crud.HandlerData) []byte {
	return nil
}
