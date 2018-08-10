package a3api

import (
	"context"
	//	"errors"
	"fmt"
	"net/http"
	//	"net/url"
	"github.com/inverse-inc/packetfence/go/ama/apibackend"
	"github.com/inverse-inc/packetfence/go/caddy/caddy"
	"github.com/inverse-inc/packetfence/go/caddy/caddy/caddyhttp/httpserver"
	"github.com/inverse-inc/packetfence/go/log"
	//	"github.com/inverse-inc/packetfence/go/pfconfigdriver"
	"github.com/inverse-inc/packetfence/go/ama/amac"
	"github.com/julienschmidt/httprouter"
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
	ctx := log.LoggerNewContext(context.Background())
	/*
		for c.Next() {
			if !c.NextArg() {
				return ArgErr()
			}
			val := c.Val()
		}
	*/

	A3api, err := buildA3apiHandler(ctx)

	if err != nil {
		return err
	}

	httpserver.GetConfig(c).AddMiddleware(func(next httpserver.Handler) httpserver.Handler {
		A3api.Next = next
		return A3api
	})

	log.LoggerWContext(ctx).Info("a3-api setup success.")
	
    //Create a goroutine for the frontend component
    go amac.Entry()
    
	return nil
}

func buildA3apiHandler(ctx context.Context) (A3apiHandler, error) {
	A3api := A3apiHandler{}

	router := httprouter.New()
	router.POST("/api/v1/*filepath", a3apibackend.Handle)
	router.GET("/api/v1/*filepath", a3apibackend.Handle)

	A3api.router = router

	return A3api, nil
}

func (h A3apiHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) (int, error) {
	//	ctx := r.Context()

	if handle, params, _ := h.router.Lookup(r.Method, r.URL.Path); handle != nil {
		w.Header().Set("Content-Type", "application/json")
		handle(w, r, params)
		// TODO handle errors
		return 0, nil
	}

	return h.Next.ServeHTTP(w, r)
}
