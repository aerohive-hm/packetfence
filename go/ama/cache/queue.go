package cache

import (
	"github.com/inverse-inc/packetfence/go/log"
	"context"
	"errors"
)

func (r *RedisPool) Enqueue(queueName string, data []byte) error {
	c := r.pool.Get()
	defer c.Close()

	_, err := c.Do("rpush", queueName, data)
	if err != nil {
		return err
	}
	log.LoggerWContext(context.Background()).Info("Enqueue succeed!")

	return nil
}

func (r *RedisPool) Dequeue(queueName string) ([]byte, error) {
	c := r.pool.Get()
	defer c.Close()

	reply, err := c.Do("LPOP", queueName)
	if err != nil {
		return nil,err
	}
	log.LoggerWContext(context.Background()).Info("Dequeue succeed!")

	return reply.([]byte),nil
}

func (r *RedisPool) QueueCount(queueName string) (int, error) {
	c := r.pool.Get()
	defer c.Close()

	lenqueue, err := c.Do("llen", queueName)
	if err != nil {
		return 0, err
	}

	count, ok := lenqueue.(int64)
	if !ok {
		return 0, errors.New("Get length of queue failed")
	}

	return int(count), nil
}


