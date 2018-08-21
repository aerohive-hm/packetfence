
export let networks ={
    "items": [
        {
            "id":"interface",
            "name":"eth0",
            "ip_addr":"10.0.123.1",
            "netmask":"255.255.255.0",
            "vip":"10.0.123.254",
            "type":"ISOLATION",
            "services":""
        },
        {
            "id":"interface1",
            "name":"VLAN10",
            "ip_addr":"192.168.10.1",
            "netmask":"255.255.255.0",
            "vip":"192.168.10.254",
            "type":"MANAGEMENT",
            "services":"RADIUS"
        },
        {
            "id":"interface1",
            "name":"VLAN102",
            "ip_addr":"192.168.10.1",
            "netmask":"255.255.255.0",
            "vip":"192.168.10.254",
            "type":"MANAGEMENT",
            "services":"RADIUS,PORTAL"
        }
    ]
}