package cache

import (
	"github.com/garyburd/redigo/redis"
	"time"
	"fmt"
)

type RedisPool struct {
	pool *redis.Pool
}

func NewRedisPool(server, passwd string) (*RedisPool, error) {
	if server == "" {
		server = ":6379"
	}

	pool := &redis.Pool{
		MaxIdle:     3,
		IdleTimeout: 30 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", server)
			if err != nil {
				fmt.Println(err)
			}
			if passwd != "" {
				if _, err := c.Do("AUTH", passwd); err != nil {
					c.Close()
					fmt.Println(err)
				}
			}
			return c, err
		},
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			_, err := c.Do("PING")
			return err
		},
	}
	return &RedisPool{pool}, nil
}
