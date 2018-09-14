var fakeData = {
      "interfaces":[
        {
            "name":"eth0",
            "vip":"10.0.123.254"
        },
        {
            "name":"eth0.10",
            "vip":"192.168.10.254"
        },
        {
            "name":"eth1",
            "vip":"10.0.234.254"
        }
    ],
    "nodes": [
        {
            "hostname":"a3_node1.aerohive.com",
            "ipaddr":"10.155.100.1",
            "type":"master",
            "status":"active"
        },
        {
            "hostname":"a3_node2.aerohive.com",
            "ipaddr":"10.155.100.2",
            "type":"slave",
            "status":"active"
        },
        {
            "hostname":"a3_node3.aerohive.com",
            "ipaddr":"10.155.100.3",
            "type":"slave",
            "status":"inactive"
        }
      ]
}

$(document).ready(function(){
    // getClusterStatusInfo();
    document.getElementById("submitNewClusterInfo").onclick = function(){
      console.log("in submitNewClusterInfo");

      if( $("#sharedKey").val().length === 0 || $("#vrid").val().length === 0 || $("#vip").val().length === 0 ) {
        $(this).parents('p').addClass('warning');
      } else {
        submitClusterInfo();
      }
    }

    // getClusterStatusInfo();

    $.each(fakeData.nodes, function(i, members){
      console.log("inside each function");
      if (members.type == "master"){
        $("#cluster-management-table-tbody").append("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
      } else {
        $("#cluster-management-table-tbody").append("<tr><td>" + "<input type='checkbox' class='remove-cluster-node' name='remove-cluster-node' id='remove-cluster-node' value=" + members.hostname + ">" + "</td><td>" +  members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
      }
    });

    $.each(fakeData.interfaces, function(i, members){
      if (members.name == "eth0.10"){
        $("#net-interfaces-table-tbody").append("<tr><td>" + "VLAN 10" + "</td><td>" + members.vip + "</td></tr>");
      } else {
        $("#net-interfaces-table-tbody").append("<tr><td>" + members.name + "</td><td>" + members.vip + "</td></tr>");
      }
    });


    //button press on trashcan, array, removeClusterNode();
    document.getElementById('remove-node').onclick = function(){
        var getListOfNodes = getCheckedNodes(document.getElementById('cluster-management-table-tbody'));
        console.log("get List of nodes: "); console.log(getListOfNodes);

        $('.removeModal').show();
        $("#listOfSelectedNodes").text(getListOfNodes);

        $('#close-modal').on('click', function() {
            $('#openModal').hide();
        });
        $('#removing-modal').on('click', function() {
            removeClusterNode(getListOfNodes);
            $('#openModal').hide();
        });
    }
});

function getCheckedNodes(inputTbody){
  var nodeArray = [];
  var getInputFields = inputTbody.getElementsByTagName('input');
  var numberOfInputs = getInputFields.length;
  console.log("number selected: " + numberOfInputs);

  for(var i = 0; i < numberOfInputs; i++) {
    if(getInputFields[i].type == 'checkbox' && getInputFields[i].checked == true){
      nodeArray.push(getInputFields[i].value);
    }
  }
  return nodeArray;
}


function submitClusterInfo(){
  console.log("inside submit cluster info");
  var base_url = window.location.origin;
  var form = document.forms.namedItem("newClusterInfo");
  var formData = new FormData(form);

  //turn info into Json
  var object = {};
  formData.forEach(function(value, key){
      object[key] = value;
  });
  var jsonFormData = JSON.stringify(object);
  console.log("jsonFormData");
  console.log(jsonFormData);

  $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cluster',
      data:jsonFormData,
      dataType: 'json',
      processData: false,
      contentType: false,
      success: function(data){
        console.log(data);
      },
      error: function(data){
        document.getElementById('errorMessage').innerHTML = "Unsuccessful update of the cluster info";
        $("#success-alert").show();
        setTimeout(function(){
          $("#success-alert").slideUp(500);
        }, 3000);
      }
  });
}

function removeClusterNode(nodeArray){
   var base_url = window.location.origin;
   var dataJson = {"hostname":nodeArray};
   dataJson = JSON.stringify(dataJson);
   console.log("datajson: "); console.log(dataJson);
   console.log("- - - - - - - - - - - ");

   $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cluster/remove',
      dataType: 'json',
      data: dataJson,
      processData: false,
      contentType: false,
      success: function(data){
        console.log("successful");
        console.log(data);
        getClusterStatusInfo();
        $("#cluster-management-table").load("#cluster-management-table-tbody");

        //let user know 7 - 15 minutes restarting services
      },
      error: function(data){
        console.log("error");
        console.log(data);
      }
   });
}

//function to get cluster table data
function getClusterStatusInfo(){
  console.log("get cluster status info");
  var base_url = window.location.origin;
  $.ajax({
      type: 'GET',
      url: base_url + '/a3/api/v1/configuration/cluster',
      success: function(fakeData){
        console.log("success");
        console.log(fakeData);
        $.each(fakeData.nodes, function(i, members){
          console.log(members);
          if (members.type == "master"){
            $("#cluster-management-table-tbody").append("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
          } else {
            $("#cluster-management-table-tbody").append("<tr><td>" + "<a id='remove' style='padding-left:1px;' href=''><i class='icon-trash-o'></i></a>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
          }
        });
        $.each(fakeData.interfaces, function(i, members){
          if (members.name == "eth0.10"){
            $("#net-interfaces-table-tbody").append("<tr><td>" + "VLAN 10" + "</td><td>" + members.vip + "</td></tr>");
          } else {
            $("#net-interfaces-table-tbody").append("<tr><td>" + members.name + "</td><td>" + members.vip + "</td></tr>");
          }
        });

      },
      error: function(fakeData){
        document.getElementById('errorMessage').innerHTML = "Could not grab the cluster info";
        $("#success-alert").show();
        setTimeout(function(){
          $("#success-alert").slideUp(500);
        }, 3000);
      }
  });
}
