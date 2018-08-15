package apibackclient

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/sharedutils"
	"github.com/julienschmidt/httprouter"
)

var httpClient http.Client

type Client struct {
	Path     string
	Method   string //  post,get
	PostData string //  json data
	RespData string
	Status   string
	Host     string
	Port     string
}

type ErrorReply struct {
	Message string `json:"message"`
}

func New(ctx context.Context) *Client {
	return &Client{
		Host: "127.0.0.1",
		Port: "8080",
	}
}

func (c *Client) buildRequest(ctx context.Context, method, path, body string) *http.Request {
	uri := fmt.Sprintf("http://%s:%s/api/v1%s", c.Host, c.Port, path)
	log.LoggerWContext(ctx).Info("Calling Unified API on uri: " + uri)
	fmt.Println("uri=", uri)
	bodyReader := strings.NewReader("")
	if body != "" {
		bodyReader = strings.NewReader(body)
	}
	r, err := http.NewRequest(method, uri, bodyReader)
	r.Header.Set("Content-type", "application/json")
	sharedutils.CheckError(err)
	return r
}

// Ensures that the full body is read and closes the reader so that the connection can be reused
func (c *Client) ensureRequestComplete(ctx context.Context, resp *http.Response) {
	if resp == nil {
		return
	}

	defer resp.Body.Close()
	io.Copy(ioutil.Discard, resp.Body)
}

//path /config/base/baseid
func (c *Client) Call(ctx context.Context, method, path string, body string) error {
	r := c.buildRequest(ctx, method, path, body)
	resp, err := httpClient.Do(r)
	if err != nil {
		return err
	}
	defer c.ensureRequestComplete(ctx, resp)
	b, err := ioutil.ReadAll(resp.Body)
	sharedutils.CheckError(err)
	// Lower than 400 is a success
	if resp.StatusCode > 400 {
		errRep := ErrorReply{}
		dec := json.NewDecoder(resp.Body)
		err := dec.Decode(&errRep)
		if err != nil {
			return errors.New("Error body doesn't follow the Unified API standard, couldn't extract the error message from it.")
		}
		return errors.New(errRep.Message)
	}
	c.RespData = string(b)
	c.Status = resp.Status
	return err
}

func TestClientBuildRequest(w http.ResponseWriter, r *http.Request, p httprouter.Params) {

	ctx := r.Context()
	c := New(ctx)

	body := "{\"emailaddr\": \"zjlitest@aerohive.com\"}"
	c.Call(ctx, "PATCH", "/config/base/alerting", body)
	fmt.Fprintf(w, c.RespData)
}
