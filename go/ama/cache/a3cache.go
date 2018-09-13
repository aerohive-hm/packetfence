/*
	We cache items containing tables' info to redis in two Redis data structure: Redis Strings, Redis Sets
	Redis Strings: store the item value with the unique table ID as the key;
	Redis Sets: store table ID as the value.
	We use Redis Strings, so the item with unique table ID as key could be replaced by newest item;
	We use Redis Sets, so could fetch unique valid table IDs more easily, which could be used to extract real item value.
*/

package cache

import (
	"github.com/garyburd/redigo/redis"
	"fmt"
)

const tableSets string = "a3tables"

func CacheTableInfo(tableId string, value []byte) error {
	r, err := newRedisPool("", "")
	if err != nil {
		fmt.Println("New Redis Pool failed")
		return err
	}

	c := r.pool.Get()
	defer c.Close()

	_, err = c.Do("SET", tableId, string(value))
	if err != nil {
		fmt.Println("SET key ", tableId, "failed")
		return err
	}

	_, err = c.Do("SADD", tableSets, tableId)
	if err != nil {
		fmt.Println("ADD table ", tableId, "failed")
		return err
	}

	return nil
}

func FetchTablesInfo(count int, handle func([]byte)(interface{},error)) ([]interface{}, error){
	var tables []interface{}

	r, err := newRedisPool("", "")
	if err != nil {
		fmt.Println("New Redis Pool failed")
		return nil, err
	}

	c := r.pool.Get()
	defer c.Close()

	max, err := c.Do("SCARD", tableSets)
	if err != nil {
		fmt.Println("Get sets count failed")
		return nil,err
	}

	if count < max {
		max = count
	}

	for i := 0; i < max; i++ {
		tableId, err := c.Do("SRANDMEMBER", tableSets)
		if err != nil {
			fmt.Println("SRANDMEMBER", tableSets, "failed")
			continue
		}

		tableValue, err := c.Do("GET", tableId)
		if err != nil {
			fmt.Println("Get", tableId, "failed")
			continue;
		}

		table, err := handle([]byte(tableValue))
		if err != nil {
			fmt.Println("Convert to slice item failed")
			continue
		}

		tables = append(tables, table)

		_, err = c.Do("DEL", tableId)
		if err != nil {
			fmt.Println("DEL", tableId, "failed")
			continue
		}

		_, err = c.Do("SREM", tableId)
		if err != nil {
			fmt.Println("Remove", tableId, "from table sets failed")
			continue
		}
	}

	return tables, err
}