$(document).ready(function(){
    // getClusterStatusInfo();
    document.getElementById("submitNewClusterInfo").onclick = function(){
      console.log("in submitNewClusterInfo");
      submitClusterInfo();
    }
    //button press on trashcan, array, removeClusterNode();
    document.getElementById('remove').onclick = function(){

    }
});

//remove the checkbox on the master node ( first one ); cluster tab only show up when in master node

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
   });
}

function createTable(tableData) {
    var table = $('<table></table>');
    $(tableData).each(function (i, rowData) {
        var row = $('<tr></tr>');
        $(rowData).each(function (j, cellData) {
            row.append($('<td>'+cellData+'</td>'));
        });
        table.append(row);
    });
    return table;
}

//function to get cluster table data
function getClusterStatusInfo(){
  $.ajax({
      type: 'GET',
      url: base_url + '/a3/api/v1/configuration/cluster',
      success: function(data){
        console.log("success");
        console.log(data);
        $("tbody").append(arrayToTable(data));
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
