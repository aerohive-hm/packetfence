/*
	We cache items containing tables' info to redis in two Redis data structure: Redis Strings, Redis Sets
	Redis Strings: store the item value with the unique table ID as the key;
	Redis Sets: store table ID as the value.
	We use Redis Strings, so the item with unique table ID as key could be replaced by newest item;
	We use Redis Sets, so could fetch unique valid table IDs more easily, which could be used to extract real item value.
*/

package cache

import (
	"github.com/inverse-inc/packetfence/go/log"
	"context"
	"fmt"
)

const tableSets string = "a3tables"

func CacheTableInfo(tableId string, value []byte) (int,error) {
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		return 0,err
	}

	c := r.pool.Get()
	defer c.Close()

	_, err = c.Do("SET", tableId, string(value))
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("SET key %s failed", tableId))
		return 0,err
	}

	_, err = c.Do("SADD", tableSets, tableId)
	if err != nil {
		log.LoggerWContext(context.Background()).Error(fmt.Sprintf("ADD table %s failed", tableId) )
		return 0,err
	}

	count, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		return 0,err
	}
	
	return int(count.(int64)),nil
}

func FetchTablesInfo(count int) ([]interface{}, error){
	var tables []interface{}
	var max int = count

	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		return nil, err
	}

	c := r.pool.Get()
	defer c.Close()

	number, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		return nil,err
	}

	if int64(count) > number.(int64) {
		max = int(number.(int64))
	}
	if max == 0 {
		log.LoggerWContext(context.Background()).Info("No memeber in sets:", tableSets)
		return nil, nil
	}

	for i := 0; i < max; i++ {
		tableId, err := c.Do("SRANDMEMBER", tableSets)
		if err != nil {
			log.LoggerWContext(context.Background()).Error("SRANDMEMBER", tableSets, "failed")
			continue
		}

		table, err := c.Do("GET", string(tableId.([]byte)))
		if err != nil {
			log.LoggerWContext(context.Background()).Error(fmt.Sprintf("Get %s failed", string(tableId.([]byte))) )
			continue;
		}

		tables = append(tables, table)

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

	return tables, err
}

func RedisTablesCount() (int,error) {
	r, err := NewRedisPool("", "")
	if err != nil {
		log.LoggerWContext(context.Background()).Error("New Redis Pool failed")
		return 0, err
	}

	c := r.pool.Get()
	defer c.Close()
	
	count, err := c.Do("SCARD", tableSets)
	if err != nil {
		log.LoggerWContext(context.Background()).Error("Get sets count failed")
		return 0,err
	}

	return int(count.(int64)), nil
}


