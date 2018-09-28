/*
	We cache items containing tables' info to redis in two Redis data structure: Redis Strings, Redis Sets
	Redis Strings: store the item value with the unique table ID as the key;
	Redis Sets: store table ID as the value.
	We use Redis Strings, so the item with unique table ID as key could be replaced by newest item;
	We use Redis Sets, so could fetch unique valid table IDs more easily, which could be used to extract real item value.
*/

package cache

import (
	"context"
	"fmt"
	"github.com/inverse-inc/packetfence/go/log"
	"sync"
)

var mu sync.Mutex

const tableSets string = "a3tables_set"
const tableQueue string = "a3tables_queue"

func CacheTableInfo(tableId string, value []byte) (int, error) {
	mu.Lock()
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		mu.Unlock()

		return 0, err
	}

	c := r.pool.Get()
	defer c.Close()

	_, err = c.Do("SET", tableId, string(value))
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("SET key %s failed", tableId))
		mu.Unlock()
		return 0, err
	}

	_, err = c.Do("SADD", tableSets, tableId)
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("ADD table %s failed", tableId))
		mu.Unlock()
		return 0, err
	}

	count, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		mu.Unlock()
		return 0, err
	}
	mu.Unlock()

	return int(count.(int64)), nil
}

func FetchTablesInfo(count int) ([]interface{}, error) {
	var tables []interface{}
	var max int = count

	mu.Lock()
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		mu.Unlock()
		return nil, err
	}

	c := r.pool.Get()
	defer c.Close()

	number, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		mu.Unlock()
		return nil, err
	}

	if int64(count) > number.(int64) {
		max = int(number.(int64))
	}
	if max == 0 {
		log.LoggerWContext(context.Background()).Info("No memeber in sets:", tableSets)
		mu.Unlock()
		return tables, nil
	}

	for i := 0; i < max; i++ {
		tableId, err := c.Do("SRANDMEMBER", tableSets)
		if err != nil {
			log.LoggerWContext(context.Background()).Error("SRANDMEMBER", tableSets, "failed")
			continue
		}

		table, err := c.Do("GET", string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("Get %s failed", string(tableId.([]byte))))
			continue
		}
		if table == nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("table == nil, key:%s", string(tableId.([]byte))))
		} else {
			tables = append(tables, table)
		}

		_, err = c.Do("DEL", string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("DEL %s failed", string(tableId.([]byte))))
			continue
		}

		_, err = c.Do("SREM", tableSets, string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("Remove %s from table sets failed", string(tableId.([]byte))))
			continue
		}
	}
	mu.Unlock()

	return tables, err
}

func RedisTablesCount() (int, error) {
	mu.Lock()
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		mu.Unlock()
		return 0, err
	}

	c := r.pool.Get()
	defer c.Close()

	count, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		mu.Unlock()
		return 0, err
	}
	mu.Unlock()

	return int(count.(int64)), nil
}

func CacheTableInfoInOrder(tableId string, value []byte) (int, error) {
	mu.Lock()
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		mu.Unlock()
		return 0, err
	}

	c := r.pool.Get()
	defer c.Close()

	_, err = c.Do("SET", tableId, string(value))
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("SET key %s failed", tableId))
		mu.Unlock()
		return 0, err
	}

	count, err := c.Do("SADD", tableSets, tableId)
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("ADD table %s failed", tableId))
		mu.Unlock()
		return 0, err
	}

	//Push tableID to queue in order
	//count equal to zero mean exist the repeating element
	if count.(int64) == 0 {
		_, err = c.Do("LREM", tableQueue, 0, tableId)
		if err != nil {
			log.LoggerWContext(context.Background()).Error("Remove repeating element failed:" + err.Error())
		}
	}
	num, err := c.Do("RPUSH", tableQueue, tableId)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Enqueue failed:" + err.Error())
		mu.Unlock()
		return 0, err
	}
	mu.Unlock()

	return int(num.(int64)), nil
}

func FetchTablesInfoInOrder(count int) ([]interface{}, error) {
	var tables []interface{}
	var max int = count

	mu.Lock()
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		mu.Unlock()
		return nil, err
	}

	c := r.pool.Get()
	defer c.Close()

	number, err := c.Do("llen", tableQueue)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get queue length failed")
		mu.Unlock()
		return nil, err
	}

	if int64(count) > number.(int64) {
		max = int(number.(int64))
	}
	if max == 0 {
		log.LoggerWContext(context.Background()).Info("No memeber in sets:", tableSets)
		mu.Unlock()
		return tables, nil
	}

	for i := 0; i < max; i++ {
		tableId, err := c.Do("LPOP", tableQueue)
		if err != nil {
			log.LoggerWContext(context.Background()).Error("Dequeue", tableQueue, "failed")
			continue
		}

		table, err := c.Do("GET", string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("Get %s failed", string(tableId.([]byte))))
			continue
		}
		if table == nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("table is nill, key:%s", string(tableId.([]byte))))
		} else {
			tables = append(tables, table)
		}

		_, err = c.Do("DEL", string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("DEL %s failed", string(tableId.([]byte))))
			continue
		}

		_, err = c.Do("SREM", tableSets, string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("Remove %s from table sets failed", string(tableId.([]byte))))
			continue
		}
	}
	mu.Unlock()

	return tables, err
}
