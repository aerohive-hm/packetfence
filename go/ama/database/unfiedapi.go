package amadb

import (
	"context"
	//"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/db"
)
type UpdateItem struct {
	tablename     string 
	pid           string//primary key
	pidvalue      string   
	keyname       string//update key 
	keyvalue      string
}

/*update one key */
func (item *UpdateItem)Update(obj *UpdateItem) {
	var ctx = context.Background()
	db, err := db.DbFromConfig(ctx) 
	
	/* replace is better than insert because it does not need to check if pid exsit or not */
	prepare := fmt.Sprintf("replace into %s (pid,%s) values (?,?)",obj.tablename, obj.keyname)	 
	                      
	stmt, err := db.Prepare(prepare)
	if err != nil {
		fmt.Println(err)
	}
	stmt.Exec(obj.pidvalue,obj.keyvalue)
	 
    defer stmt.Close()
	defer db.Close()
}


func testUpdatedb() {
	fmt.Println("TestInsertdb start")
	var obj UpdateItem	 
	obj.tablename = "password"
	obj.pid = "pid"
	obj.pidvalue = "testXXX"
	obj.keyname = "password"
	obj.keyvalue = "testacdd1"
	obj.Update(&obj)	
}
