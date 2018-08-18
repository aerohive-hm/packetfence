package a3config

import (
	"fmt"
	//"regexp"
)

var pfPath = ConfRoot + "/" + pfConf

func PfCommit(sections Section) {
	conf := new(A3Conf)
	conf.LoadCfg(pfPath)

	return tt.Commit(sections)
}

func PfRead(sectionId string) Section {
	conf := new(A3Conf)
	conf.LoadCfg(pfPath)
	conf.Read(id)
	return conf.sections
}

func GetHostname() {
}

func UpdateHostname() {
}

func UpdateIface() {
}
func ReadIface() {
}
