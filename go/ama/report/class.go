package report

/*
MariaDB [A3]> desc class;
+------------------+--------------+------+-----+---------+-------+
| Field            | Type         | Null | Key | Default | Extra |
+------------------+--------------+------+-----+---------+-------+
| vid              | int(11)      | NO   | PRI | NULL    |       |
| description      | varchar(255) | NO   |     | none    |       |
| auto_enable      | char(1)      | NO   |     | Y       |       |
| max_enables      | int(11)      | NO   |     | 0       |       |
| grace_period     | int(11)      | NO   |     | NULL    |       |
| window           | varchar(255) | NO   |     | 0       |       |
| vclose           | int(11)      | YES  |     | NULL    |       |
| priority         | int(11)      | NO   |     | NULL    |       |
| template         | varchar(255) | YES  |     | NULL    |       |
| max_enable_url   | varchar(255) | YES  |     | NULL    |       |
| redirect_url     | varchar(255) | YES  |     | NULL    |       |
| button_text      | varchar(255) | YES  |     | NULL    |       |
| enabled          | char(1)      | NO   |     | N       |       |
| vlan             | varchar(255) | YES  |     | NULL    |       |
| target_category  | varchar(255) | YES  |     | NULL    |       |
| delay_by         | int(11)      | NO   |     | 0       |       |
| external_command | varchar(255) | YES  |     | NULL    |       |
+------------------+--------------+------+-----+---------+-------+
17 rows in set (0.01 sec)
*/

type ClassParseStruct struct {
	TableName       string      `json:"ah_tablename"`
	TimeStamp       string      `json:"ah_timestamp"`
	Vid             interface{} `json:"vid,omitempty"`
	Description     string      `json:"description,omitempty"`
	AutoEnable      string      `json:"auto_enable,omitempty"`
	MaxEnables      string      `json:"max_enables,omitempty"`
	GracePeriod     string      `json:"grace_period,omitempty"`
	Window          string      `json:"window,omitempty"`
	Vclose          string      `json:"vclose,omitempty"`
	Priority        string      `json:"priority,omitempty"`
	Template        string      `json:"template,omitempty"`
	MacEnableUrl    string      `json:"max_enable_url,omitempty"`
	RedirectUrl     string      `json:"redirect_url,omitempty"`
	ButtonText      string      `json:"button_text,omitempty"`
	Enabled         string      `json:"enabled,omitempty"`
	Vlan            string      `json:"vlan,omitempty"`
	TargetCategory  string      `json:"target_category,omitempty"`
	DelayBy         string      `json:"delay_by,omitempty"`
	ExternalCommand string      `json:"external_command,omitempty"`
}

type ClassReportData struct {
	TableName string      `json:"ah_tablename"`
	TimeStamp string      `json:"ah_timestamp"`
	Vid       interface{} `json:"vid"`
}
