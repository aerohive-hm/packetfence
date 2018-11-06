package a3api

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/caddy/caddy"
	"github.com/inverse-inc/packetfence/go/caddy/caddy/caddyhttp/httpserver"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/julienschmidt/httprouter"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/ama/apibackend"
)

func init() {
	caddy.RegisterPlugin("a3-api", caddy.Plugin{
		ServerType: "http",
		Action:     setup,
	})

	fmt.Println("init a3-api.")
}

type A3apiHandler struct {
	Next   httpserver.Handler
	router *httprouter.Router
}

func setup(c *caddy.Controller) error {
	ama.Ctx = log.LoggerNewContext(context.Background())
	result, _ := utils.ExecShell(`sed -n '/level/ p' /usr/local/pf/conf/caddy-services/a3-ama.conf | sed -r 's/\s*level\s*//'`, true)
	level := strings.TrimRight(result, "\n")	
	ama.Ctx = log.LoggerSetLevel(ama.Ctx, strings.ToLower(level))


	A3api, err := buildA3apiHandler(ama.Ctx)

	if err != nil {
		return err
	}

	/*
		Create a goroutine for the frontend component, frontend
		goroutine must be started before the cloud integration
		setup flow
	*/
	go amac.Entry(ama.Ctx)
	go apibackend.MariadbStatusCheck()

	httpserver.GetConfig(c).AddMiddleware(func(next httpserver.Handler) httpserver.Handler {
		A3api.Next = next
		return A3api
	})

	log.LoggerWContext(ama.Ctx).Info("a3-api setup success.")

	return nil
}

func buildA3apiHandler(ctx context.Context) (A3apiHandler, error) {
	A3api := A3apiHandler{}

	router := httprouter.New()
	router.POST("/api/v1/*filepath", apibackend.Handle)
	router.PUT("/api/v1/*filepath", apibackend.Handle)
	router.GET("/api/v1/*filepath", apibackend.Handle)
	router.DELETE("/api/v1/*filepath", apibackend.Handle)

	A3api.router = router

	return A3api, nil
}



func (h A3apiHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) (int, error) {
	ctx := r.Context()

	log.LoggerWContext(ctx).Debug(fmt.Sprintf("AMA REST URL path %s", r.URL.Path))
	sections := strings.Split(r.URL.Path, "/") //r.URL.Path: 
	if len(sections) > 2 && sections[1] == "configurator" {
		if apibackend.HandleRedirect(w, r) == "redirect"  {
			log.LoggerWContext(ctx).Error(fmt.Sprintf("initial setup done, redirect path %s", r.URL.Path))
			return h.Next.ServeHTTP(w, r)
		}
	} 
	
	
	if handle, params, _ := h.router.Lookup(r.Method, r.URL.Path); handle != nil {
		w.Header().Set("Content-Type", "application/json")
		handle(w, r, params)
		// TODO handle errors
		return 0, nil
	}

	return h.Next.ServeHTTP(w, r)
}


