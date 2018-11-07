package amadb

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"

	_ "github.com/go-sql-driver/mysql"
	"github.com/inverse-inc/packetfence/go/ama"
	"github.com/inverse-inc/packetfence/go/ama/a3config"
	"github.com/inverse-inc/packetfence/go/log"
)


type SqlCmd struct {
	Sql  string
	Args []interface{}
}

type SqlCmd2 struct {
	Table string
	Vars  string
	Args  []interface{}
	Where string
}

type A3Db struct {
	Sql []SqlCmd
	Db  *sql.DB
	cb  func(...interface{}) error
}

type SqlOpt int

const (
	_ SqlOpt = iota
	INSERT
	SELECT
	REPLACE
	UPDATE
	DELETE
)

var sqlOpt = map[SqlOpt]string{
	INSERT:  `insert into %s(%s)values(%s)`,
	SELECT:  `select %s from %s%s`,
	REPLACE: `replace into %s(%s)values(%s)`,
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

	_, err = stmt.Exec(args...)
	return err
}

func (db *A3Db) Exec(sql []SqlCmd) error {
	err := db.DbInit()
	if err != nil {
		return err
	}
	defer db.Db.Close()

	for _, v := range sql {
		log.LoggerWContext(ama.Ctx).Info(fmt.Sprintln(v.Sql))
		//err := db.execOnce(v.Sql, v.Args...)
		_, err := db.Db.Exec(v.Sql, v.Args...)
		if err != nil {
			return err
		}
	}
	return nil
}

func (db *A3Db) Insert(sql SqlCmd2) error {
	params := ""
	for range sql.Args {
		params += "?,"
	}
	params = strings.TrimRight(params, ",")

	tmp := []SqlCmd{
		{
			fmt.Sprintf(`insert into %s(%s)values(%s)`, sql.Table, sql.Vars, params),
			sql.Args,
		},
	}
	return db.Exec(tmp)
}
