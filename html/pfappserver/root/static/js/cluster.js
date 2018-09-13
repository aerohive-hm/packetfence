var fakeData = [
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
        },
    ]


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

    $.each(fakeData, function(i, members){
      console.log("inside each function");
      if (members.type == "master"){
        $("#cluster-management-table-tbody").append("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
      } else {
        $("#cluster-management-table-tbody").append("<tr><td>" + "<input type='checkbox' class='remove-cluster-node' name='remove-cluster-node' id='remove-cluster-node' value=" + members.hostname + ">" + "</td><td>" +  members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
      }
    });
    //button press on trashcan, array, removeClusterNode();
    document.getElementById('remove-node').onclick = function(){
        // $("input:checkbox[name=type]:checked").each(function(){
        //     nodeArray.push($(this).val());
        // });
        var getListOfNodes = getCheckedNodes(document.getElementById('cluster-management-table-tbody'));
        console.log("get List of nodes: "); console.log(getListOfNodes);
        // $("#removeConfirmation").css("display","block");
        // $("#listOfSelectedNodes").text(getListOfNodes);
        removeClusterNode(getListOfNodes);
    }
});

function getCheckedNodes(inputTbody){
  var nodeArray = [];
  var getInputFields = inputTbody.getElementsByTagName('input');
  var numberOfInputs = getInputFields.length;
  console.log("number selected: " + numberOfInputs);

  // traverse the inpfields elements, and adds the value of selected (checked) checkbox in selchbox
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
      },
      error: function(data){
        console.log("error");
        console.log(data);
      }
   });
}
//    remove add later  //add checked row
      //slect one
      //grab host name and add to api ca_file_uploadand send it
      //success : remove entire row
      //call getClusterStatusInfo


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
        $.each(fakeData.items, function(i, members){
          console.log(members);
          if (members.type == "master"){
            $("#cluster-management-table-tbody").append("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
          } else {
            $("#cluster-management-table-tbody").append("<tr><td>" + "<a id='remove' style='padding-left:1px;' href=''><i class='icon-trash-o'></i></a>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
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
