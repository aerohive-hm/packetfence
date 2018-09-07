package utils

import (
	"time"
)

var startTime time.Time

const (
	StdTimeFormat = "2006-01-02 15:04:05"
	ExpireTime    = "2038-01-01 00:00:00"
)

//uptime return value using ms as the unit.
func uptime() int64 {
	duration := time.Since(startTime)
	ms := int64(duration.Seconds() * 1000)
	return ms
}

func init() {
	startTime = time.Now()
}

func AhNowUtcFormated() string {
	return time.Now().UTC().Format(StdTimeFormat)
}
