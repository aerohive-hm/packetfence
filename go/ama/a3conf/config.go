package a3config

import (
	//	"fmt"
	"gopkg.in/ini.v1"
)

const ConfRoot = "/usr/local/pf/conf"

var ConfDict = map[string]string{
	"PF":       "pf.conf",
	"PFD":      "pf.conf.defaults",
	"NETWORKS": "networks.conf",
	"CLUSTER":  "cluster.conf",
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
		if section.HasKey(k) {
			section.Key(k).SetValue(v)
			continue
		}

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
