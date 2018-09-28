package utils

import (
	"time"
)

var startTime time.Time

const (
	StdTimeFormat = "2006-01-02 15:04:05"
	ExpireTime    = "2038-01-01 00:00:00"
	StdTimeiTFormat = "2006-01-02T15:04:05"
)

//uptime return value using ms as the unit.
func uptime() int64 {
	duration := time.Since(startTime)
	ms := duration.Nanoseconds() / int64(time.Millisecond)
	return ms
}

func init() {
	startTime = time.Now()
}

func AhNowUtcFormated() string {
	return time.Now().UTC().Format(StdTimeFormat)
}

// License time format need a T char
func AhNowUtcFormated4License() string {
	return time.Now().UTC().Format(StdTimeiTFormat)
}

