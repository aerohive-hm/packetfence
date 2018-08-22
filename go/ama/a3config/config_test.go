package a3config

func TestCommit() error {
	tt := new(A3Conf)
	tt.LoadCfg(ConfRoot + "/" + pfConf)
	sections := Section{
		"general": {
			"hostname": "a3.dev.cn",
		},
		"alerting": {
			"emailaddr": "czhong@aerohive.com",
		},
		"webservices": {
			"user": "pfcluster",
			"pass": "aerohive",
		},
		"interface eth0": {
			"ip":   "10.155.10.68",
			"type": "management,portal,radius,high-availability",
			"mask": "255.255.255.0",
		},
	}

	return tt.Commit(sections)
}

func TestRead(id string) error {
	tt := new(A3Conf)
	tt.LoadCfg(ConfRoot + "/" + pfConf)
	tt.Read(id)
	fmt.Println(tt.sections)
	return nil
}
