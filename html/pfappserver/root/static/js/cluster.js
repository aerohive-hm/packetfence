$(document).ready(function(){
    // getClusterStatusInfo();
    document.getElementById("submitNewClusterInfo").onclick = function(){
      console.log("in submitNewClusterInfo");
      submitClusterInfo();
    }

    getClusterStatusInfo();

    //button press on trashcan, array, removeClusterNode();
    // document.getElementById('remove-node').onclick = function(){
        //check if something got selected

        //pop up a modal asking yes or no
    // }
});

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
        console.log("success");
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

function removeClusterNode(){
   var base_url = window.location.origin;
   $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cluster',
      dataType: 'json',
      processData: false,
      contentType: false,


      //add checked row
      //slect one
      //grab host name and add to api ca_file_uploadand send it
      //success : remove entire row
      //call getClusterStatusInfo
   });
}

//function to get cluster table data
function getClusterStatusInfo(){
  var base_url = window.location.origin;
  $.ajax({
      type: 'GET',
      url: base_url + '/a3/api/v1/configuration/cluster',
      success: function(data){
        console.log("success");
        console.log(data);
        $.each(data.items, function(i, members){
          console.log(members);
          if (members.type == "matser"){
            $("#cluster-management-table-tbody").append("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
          } else {
            $("#cluster-management-table-tbody").append("<tr><td>" + "<input id='delete-cluster-node' type='checkbox' />" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
          }
        });
      },
      error: function(data){
        document.getElementById('errorMessage').innerHTML = "Could not grab the cluster info";
        $("#success-alert").show();
        setTimeout(function(){
          $("#success-alert").slideUp(500);
        }, 3000);
      }
  });
}
