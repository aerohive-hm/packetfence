
export let radconfig ={
    "data":[
        {
            "id":5020,
            "createdAt":1531844143027,
            "updatedAt":1531844143027,
            "enabled":true,
            "loginType":"Both",
            "authType":"PAP",
            "servers":[
                {
                    "id":5019,
                    "createdAt":1531844143025,
                    "updatedAt":1531844143026,
                    "address":"10.155.21.11",
                    "authPort":1812,
                    "acctPort":1813,
                    "secret":"aerohive222",
                    "position":0,
                    "mspOrgId":1726576907313,
                },
                {
                    "id":5018,
                    "createdAt":1531844143024,
                    "updatedAt":1531844143025,
                    "address":"10.155.21.12",
                    "authPort":1812,
                    "acctPort":1813,
                    "secret":"aerohive333",
                    "position":1,
                    "mspOrgId":1726576865337,
                }
            ]
        }
    ],
    "pagination":{
        "offset":0,
        "countInPage":1,
        "totalCount":1
    }
}


export let resultContent ={"data":{"resultContent":"VENDOR          Aerohive                        26928\r\n\r\nBEGIN-VENDOR    Aerohive\r\n\r\n# The following ATTRIBUTE and VALUE definitions are required.\r\nATTRIBUTE       AH-HM-Admin-Group-Id                    1       integer\r\nVALUE   AH-HM-Admin-Group-Id            Read-Only-Admin         0\r\nVALUE   AH-HM-Admin-Group-Id            Super-Admin             1\r\nVALUE   AH-HM-Admin-Group-Id            Read-Write-Admin        2\r\nVALUE   AH-HM-Admin-Group-Id            Monitor                 5\r\nVALUE   AH-HM-Admin-Group-Id            Help Desk               6\r\nVALUE   AH-HM-Admin-Group-Id            Guest Management        7\r\nVALUE   AH-HM-Admin-Group-Id            Observer                8\r\n\r\n# The following is an example of an admin group that you can define.\r\n#VALUE  AH-HM-Admin-Group-Id            Admin-Group100          100\r\n\r\nEND-VENDOR      Aerohive"}}




export let organization={
    "data":[
        {
            "id":1726576852992,
            "createdAt":1532570797281,
            "updatedAt":1532570797281,
            "ownerId":402,
            "orgId":1726576852992,
            "name":"",
            "type":"MSP_PRIVATE",
            "color":""
        },
        {
            "id":1726576865337,
            "createdAt":1532570797281,
            "updatedAt":1532570797281,
            "ownerId":402,
            "orgId":1726576865337,
            "name":"Organization A",
            "type":"REGULAR",
            "color":"Red"
        },
        {
            "id":1726576907313,
            "createdAt":1532570797281,
            "updatedAt":1532570797281,
            "ownerId":402,
            "orgId":1726576907313,
            "name":"Organization B",
            "type":"REGULAR",
            "color":"#00FF00"
        },
        {
            "id":1726576886325,
            "createdAt":1532570797281,
            "updatedAt":1532570797281,
            "ownerId":402,
            "orgId":1726576886325,
            "name":"Organization C",
            "type":"REGULAR",
            "color":"<representation of color blue>"
        }
    ],
    "pagination":{
        "offset":0,
        "countInPage":4,
        "totalCount":4
    }
}