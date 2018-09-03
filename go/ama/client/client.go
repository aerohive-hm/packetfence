package apibackclient

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/ama/utils"
	"github.com/inverse-inc/packetfence/go/log"
	"github.com/inverse-inc/packetfence/go/sharedutils"
)

var httpClient http.Client

type Client struct {
	Method   string //  post,get
	UrlId    string
	PostData string //  json data
	RespData []byte
	Status   int
	Host     string
	Port     string
	Token    string
}

var preUrl = map[string]string{
	"TxClusterEvent": "https://%s:9999/a3/api/v1/",
	"ClusterLogin":   "https://%s:9999/api/v1/login",
}

type ErrorReply struct {
	Message string `json:"message"`
}

func New(ctx context.Context) *Client {
	return &Client{
		Host: "10.155.103.191",
		Port: "9999",
	}
}

func genUrl(url string, host string, suffix string) string {
	return fmt.Sprintf(url, host, suffix)
}

func skipCertVerify() {
	http.DefaultTransport.(*http.Transport).TLSClientConfig =
		&tls.Config{InsecureSkipVerify: true}
}

func (c *Client) buildRequest(method, url, body string) (*http.Request, error) {
	bodyReader := strings.NewReader(body)
	skipCertVerify()

	r, err := http.NewRequest(method, url, bodyReader)
	if err != nil {
		return nil, err
	}

	if c.Token != "" {
		r.Header.Set("Authorization", c.Token)
	}

	r.Header.Set("Content-type", "application/json")
	r.Header.Set("Accept", "application/json")
	sharedutils.CheckError(err)
	return r, nil
}

// Ensures that the full body is read and closes the reader so that the connection can be reused
func (c *Client) ensureRequestComplete(resp *http.Response) {
	if resp == nil {
		return
	}

	defer resp.Body.Close()
	io.Copy(ioutil.Discard, resp.Body)
}

//path /config/base/baseid
func (c *Client) Call(method, url string, body string) error {
	ctx := log.LoggerNewContext(context.Background())

	log.LoggerWContext(ctx).Info(fmt.Sprintln(method, url))
	log.LoggerWContext(ctx).Info(fmt.Sprintln(body))
	r, err := c.buildRequest(method, url, body)
	if err != nil {
		return err
	}

	resp, err := httpClient.Do(r)
	if err != nil {
		return err
	}
	defer c.ensureRequestComplete(resp)

	b, err := ioutil.ReadAll(resp.Body)
	sharedutils.CheckError(err)

	c.RespData = b
	c.Status = resp.StatusCode
	log.LoggerWContext(ctx).Info(fmt.Sprintln("Response Code:", c.Status))

	/*
		// Lower than 400 is a success
		if resp.StatusCode < 400 {
			return err
		}
		errRep := ErrorReply{}
		dec := json.NewDecoder(resp.Body)
		err = dec.Decode(&errRep)
		if err != nil {
			return errors.New("Error body doesn't follow the Unified " +
				"API standard, couldn't extract the error message from it.")
		}
		return errors.New(errRep.Message)
	*/
	return err
}

func genBasicToken(user string, pass string) string {
	return "Basic " + utils.AhBase64Enc(user+":"+pass)
}

type token struct {
	Tk string `json:"token"`
}

func (c *Client) ClusterAuth() error {
	url := fmt.Sprintf(preUrl["ClusterLogin"], c.Host)
	webCfg := a3config.A3ReadFull("PF", "webservices")["webservices"]
	body := fmt.Sprintf(`{"username": "%s", "password":"%s"}`,
		webCfg["user"], webCfg["pass"])

	err := c.Call("POST", url, body)
	if err != nil {
		return err
	}

	if c.Status >= 400 {
		return errors.New(fmt.Sprintf("Status code = %d", c.Status))
	}

	t := new(token)
	err = json.Unmarshal(c.RespData, t)
	if err != nil {
		return err
	}

	if t.Tk == "" {
		return errors.New("no token found in response.")
	}

	c.Token = "Bearer " + t.Tk

	return err
}

func (c *Client) ClusterSend(method, url string, body string) error {
	ctx := context.Background()
	if c.Token == "" {
		err := c.ClusterAuth()
		if err != nil {
			log.LoggerWContext(ctx).Error(err.Error())
			return err
		}
	}

	return c.Call(method, url, body)
}
