package amadb

import (
	//"context"
	"database/sql"
	"errors"
	"fmt"
	//	_ "github.com/go-sql-driver/mysql"

	"github.com/inverse-inc/packetfence/go/ama/a3config"
)

const (
	StdTimeFormat = "2006-01-02 15:04:05"
)

type SqlCmd struct {
	Sql  string
	Args []interface{}
}

type A3Db struct {
	Sql []SqlCmd
	Db  *sql.DB
	cb  func(...interface{}) error
}

func connect(user, pass, host, port, dbname string) (*sql.DB, error) {
	var where string
	if host == "localhost" {
		where = "unix(/var/lib/mysql/mysql.sock)"
	} else {
		where = "tcp(" + host + ":" + port + ")"
	}

	//?charset=utf8&parseTime=true&loc=Local
	db, err := sql.Open("mysql", user+":"+pass+"@"+where+"/"+dbname+"?parseTime=true")
	db.SetMaxIdleConns(0)
	db.SetMaxOpenConns(500)
	return db, err
}

func dbFromConfig() (*sql.DB, error) {
	dbCfg := a3config.A3ReadFull("PF", "database")["database"]
	if dbCfg == nil {
		return nil, errors.New("Can't find database.")
	}
	return connect(dbCfg["user"], dbCfg["pass"], dbCfg["host"],
		dbCfg["port"], dbCfg["db"])
}

func (db *A3Db) DbInit() error {
	tdb, err := dbFromConfig()
	if err != nil {
		fmt.Println(err.Error())
	}
	db.Db = tdb
	return err
}

func (db *A3Db) execOnce(sql string, args ...interface{}) error {
	stmt, err := db.Db.Prepare(sql)
	if err != nil {
		return err
	}
	defer stmt.Close()

	stmt.Exec(args...)
	return nil
}

func (db *A3Db) Exec(sql []SqlCmd) error {
	err := db.DbInit()
	if err != nil {
		return err
	}

	for _, v := range sql {
		err := db.execOnce(v.Sql, v.Args...)
		if err != nil {
			return err
		}
	}
	return nil
}
