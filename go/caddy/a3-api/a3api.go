package a3api

import (
	"context"
	"encoding/json"
	//	"errors"
	"fmt"
	"net/http"
	//	"net/url"

	"github.com/inverse-inc/packetfence/go/caddy/caddy"
	"github.com/inverse-inc/packetfence/go/caddy/caddy/caddyhttp/httpserver"
	"github.com/inverse-inc/packetfence/go/log"
	//	"github.com/inverse-inc/packetfence/go/pfconfigdriver"
	"github.com/julienschmidt/httprouter"
	"github.com/inverse-inc/packetfence/go/ama/amac"
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
	router.POST("/api/v1/event", A3api.handlePostEvent)
	router.GET("/api/v1/event", A3api.handleGetEvent)

	A3api.router = router

	return A3api, nil
}

func (h A3apiHandler) handlePostEvent(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	ctx := r.Context()

	var test struct {
		code string
		msg  string
	}

	err := json.NewDecoder(r.Body).Decode(&test)

	if err != nil {
		msg := fmt.Sprintf("Error while decoding payload: %s", err)
		log.LoggerWContext(ctx).Error(msg)
		http.Error(w, fmt.Sprint(err), http.StatusBadRequest)
		return
	}

	log.LoggerWContext(ctx).Info("get POST event success.")
}

func (h A3apiHandler) handleGetEvent(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	ctx := r.Context()

	log.LoggerWContext(ctx).Info("get GET event success")
}

func (h A3apiHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) (int, error) {
	//	ctx := r.Context()

	w.Header().Set("Content-Type", "application/json")

	if handle, params, _ := h.router.Lookup(r.Method, r.URL.Path); handle != nil {
		handle(w, r, params)
		// TODO handle errors
		return 0, nil
	}

	return h.Next.ServeHTTP(w, r)
}
