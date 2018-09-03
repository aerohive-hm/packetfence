package a3config

import (
	"os"

	"github.com/go-ini/ini"
	"github.com/inverse-inc/packetfence/go/ama/utils"
)

const ConfRoot = "/usr/local/pf/conf"

var ConfDict = map[string]string{
	"PF":        "pf.conf",
	"PFD":       "pf.conf.defaults",
	"NETWORKS":  "networks.conf",
	"CLUSTER":   "cluster.conf",
	"A3DB":      "dbinfo.A3",
	"CLOUD":     "cloud.conf",
	"RDCREGION": "rdc_region.conf",
}

type keyHash map[string]string
type Section map[string]keyHash

type A3Conf struct {
	path     string
	cfg      *(ini.File)
	sections Section
}

func updateKeyHash(section *(ini.Section), kh keyHash) {
	for k, v := range kh {
		section.NewKey(k, v)
	}
}

func (conf *A3Conf) upSection() {
	for s, khs := range conf.sections {
		sect := conf.cfg.Section(s)
		if sect != nil {
			updateKeyHash(sect, khs)
		}
	}
}

func (conf *A3Conf) loadCfg(path string) error {
	if !utils.IsFileExist(path) {
		_, err := os.Create(path)
		if err != nil {
			return err
		}
	}

	cfg, err := ini.Load(path)
	if err != nil {
		return err
	}

	conf.path = path
	conf.cfg = cfg
	return nil
}

func (conf *A3Conf) save(sections Section) error {
	conf.sections = sections
	conf.upSection()

	conf.cfg.SaveTo(conf.path)
	return nil
}

func readSection(conf *A3Conf, Id string) {
	section := conf.cfg.Section(Id)
	if section == nil {
		return
	}
	conf.sections = make(Section)
	conf.sections[Id] = section.KeysHash()
}

func readAllSections(conf *A3Conf) {
	sections := conf.cfg.Sections()
	if sections == nil {
		return
	}
	conf.sections = make(Section)
	for _, section := range sections {
		conf.sections[section.Name()] =
			section.KeysHash()
	}

}

func (conf *A3Conf) readSection(sectionId string) {
	if sectionId == "all" {
		readAllSections(conf)
	} else {
		readSection(conf, sectionId)
	}
	return
}

func A3Commit(key string, sections Section) error {
	conf := new(A3Conf)
	err := conf.loadCfg(ConfRoot + "/" + ConfDict[key])
	if err != nil {
		return err
	}

	return conf.save(sections)
}

func A3CommitPath(path string, sections Section) error {
	conf := new(A3Conf)
	err := conf.loadCfg(path)
	if err != nil {
		return err
	}

	return conf.save(sections)
}

func A3Read(key string, sectionId string) Section {
	conf := new(A3Conf)
	err := conf.loadCfg(ConfRoot + "/" + ConfDict[key])
	if err != nil {
		return nil
	}
	conf.readSection(sectionId)
	if conf.sections == nil {
		return nil
	}
	return conf.sections
}

func A3ReadFull(key string, sectionId string) Section {
	conf := new(A3Conf)
	err := conf.loadCfg(ConfRoot + "/" + ConfDict["PFD"])
	if err != nil {
		goto END
	}

	err = conf.cfg.Append(ConfRoot + "/" + ConfDict[key])
	if err != nil {
		goto END
	}

	conf.readSection(sectionId)
	return conf.sections

END:
	if err != nil {
		return nil
	}
	return conf.sections
}

func deleteSection(conf *A3Conf, Id string) {
	section := conf.cfg.Section(Id)
	if section == nil {
		return
	}
	conf.cfg.DeleteSection(Id)
}
func deleteAllSections(conf *A3Conf) {
	sections := conf.cfg.Sections()
	if sections == nil {
		return
	}
	for _, section := range sections {
		conf.cfg.DeleteSection(section.Name())
	}
}

func (conf *A3Conf) deleteSection(sectionId string) {
	if sectionId == "all" {
		deleteAllSections(conf)
	} else {
		deleteSection(conf, sectionId)
	}
	return
}

func A3Delete(key string, sectionId string) error {
	conf := new(A3Conf)
	err := conf.loadCfg(ConfRoot + "/" + ConfDict[key])
	if err != nil {
		return err
	}
	conf.deleteSection(sectionId)
	conf.cfg.SaveTo(conf.path)

	return nil
}
