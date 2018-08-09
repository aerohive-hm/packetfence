/*adminUser.go implements handling REST API:
 *	/a3/api/v1/configurator/admin_user
 */
package a3Configurator

type UserInfo struct {
	Id   string `json:"id"`
	User string `json:"user"`
	Pass string `json:"pass"`
}
