package apibackclient

import (
	"context"
	"fmt"

	"github.com/inverse-inc/packetfence/go/log"
)

func SendClusterSync(ip, Status string) error {
	ctx := context.Background()

	url := fmt.Sprintf("https://%s:9999/a3/api/v1/event/cluster/sync", ip)

	log.LoggerWContext(ctx).Info(fmt.Sprintf("post cluster event sync with: %s", url))

	client := new(Client)
	client.Host = ip
	err := client.ClusterSend("POST", url, fmt.Sprintf(`{"status":"%s"}`, Status))

	if err != nil {
		log.LoggerWContext(ctx).Error(err.Error())
	}
	return err
}
