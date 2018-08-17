package utils

import (
	"time"
)

var startTime time.Time

//uptime return value using ms as the unit.
func uptime() int64 {
	duration := time.Since(startTime)
	ms := int64(duration.Seconds() * 1000)
	return ms
}

func init() {
	startTime = time.Now()
}
