
$(document).ready(function(){
    //functions in this file:
    //getCheckedNodes(inputTbody)
    //getClusterStatusInfo()
    //submitClusterInfo()
    //removeClusterNode(nodeArray)

    //to change submit info
    document.getElementById("submitNewClusterInfo").onclick = function(e){
        e.preventDefault();
        if( $("#sharedKey").val().length === 0 || $("#vrid").val().length === 0 ) {
            document.getElementById('errorMessage').innerHTML = "Enter values in all fields.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        } else if (($("#sharedKey").val().length !== 0  && $("#vrid").val().length !== 0) && ($("#vrid").val() < 1 || $("#vrid").val() > 255)){
            document.getElementById('errorMessage').innerHTML = "The Virtual Router ID must be between 1 to 255.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        } else {
            submitClusterInfo();
        }
    }

    $("#cluster-management-table-tbody tr").remove();
    $("#net-interfaces-table-tbody tr").remove();
    getClusterStatusInfo();

    //button press on trashcan, array, removeClusterNode(), removeClusterNode(nodeArray)
    document.getElementById('remove-node').onclick = function(e){
        e.preventDefault();

        getCheckedNodes(document.getElementById('cluster-management-table-tbody'));
        var getListOfNodes = getCheckedNodes(document.getElementById('cluster-management-table-tbody'));
        if (getListOfNodes == 0){

        } else {
          $('.removeModal').show();

          $('#close-modal').on('click', function() {
              $('modal').hide();
          });
          document.getElementById("removing-node").onclick =  function(){
              removeClusterNode(getListOfNodes);
              $('.modal.in').modal('hide');
          }
        }
    }

});

//function to get the number of cluster nodes checked in table
function getCheckedNodes(inputTbody){
    var nodeArray = [];
    var getInputFields = inputTbody.getElementsByTagName('input');
    var numberOfInputs = getInputFields.length;

    for(var i = 0; i < numberOfInputs; i++) {
        if(getInputFields[i].type == 'checkbox' && getInputFields[i].checked == true){
            nodeArray.push(getInputFields[i].value);
        }
    }
    $("#listOfSelectedNodes").text(nodeArray + " will be removed from the cluster.");
    return nodeArray;
}

//function to submit the password and virtual router id
function submitClusterInfo(){
    var base_url = window.location.origin;
    var form = document.forms.namedItem("newClusterInfo");
    var formData = new FormData(form);

    //turn info into Json
    var object = {};
    formData.forEach(function(value, key){
        object[key] = value;
    });

    $.ajax({
        type: 'POST',
        url: base_url + '/ama/cluster',
        dataType: 'json',
        data: object,
        success: function(data){
            data = jQuery.parseJSON(data.A3_data);
            $('input').val('');
            document.getElementById('successMessage').innerHTML = "Successfully updated the cluster info.";
            $("#success-alert").show();
            setTimeout(function(){
                $("#success-alert").slideUp(500);
            }, 3000);
        },
        error: function(data){
            data = jQuery.parseJSON(data.A3_data);
            document.getElementById('errorMessage').innerHTML = "Unsuccessful update of the cluster info.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

//function to remove the cluster node child
function removeClusterNode(nodeArray){
    var base_url = window.location.origin;
    var object = {"hostname":nodeArray.join(",")};

    $.ajax({
        type: 'POST',
        url: base_url + '/ama/cluster_remove',
        dataType: 'json',
        data: object,
        traditional: true,
        success: function(data){
            data = jQuery.parseJSON(data.A3_data);
            getClusterStatusInfo();
            $("#cluster-management-table").load("#cluster-management-table-tbody");
            if (data.code === "fail"){
              document.getElementById('errorMessage').innerHTML = "Failed to remove nodes(s)";
              $("#error-alert").show();
              setTimeout(function(){
                  $("#error-alert").slideUp(500);
              }, 3000);
            } else {
              document.getElementById('successMessage').innerHTML = "Successfully removed nodes(s)";
              $("#success-alert").show();
              setTimeout(function(){
                  $("#success-alert").slideUp(500);
              }, 3000);
            }

        },
        error: function(data){
            data = jQuery.parseJSON(data.A3_data);
            document.getElementById('errorMessage').innerHTML = data.msg;
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

//function to get cluster table data
function getClusterStatusInfo(){
    var base_url = window.location.origin;
    $.ajax({
        type: 'GET',
        url: base_url + '/ama/cluster',
        success: function(data){
            data = jQuery.parseJSON(data.A3_data);
            $("#cluster-management-table-tbody tr").remove();
            $("#net-interfaces-table-tbody tr").remove();
            //cluster management table
            $.each(data.nodes, function(i, members){
                if (members.type === "Master"){
                    $("#cluster-management-table-tbody").prepend("<tr><td>" + "" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
                } else {

                    // if (members.status == Inactive)
                    $("#cluster-management-table-tbody").append("<tr><td>" + "<input id='delete-cluster-node' type='checkbox' value='"+ members.hostname +"'/>" + "</td><td>" + members.hostname + "</td><td>" + members.ipaddr + "</td><td>" +  members.type + "</td><td>" +  members.status + "</td></tr>");
                }
            });
            //interfaces table
            $.each(data.interfaces, function(ethr, vip) {
                if(ethr.indexOf('.') !== -1){ //if there is period in eth0
                    ethr = "VLAN " + ethr.split(".").pop();
                    $("#net-interfaces-table-tbody").append("<tr><td style='padding-left:25px;'>" + ethr + "</td><td>" + vip + "</td></tr>");
                } else {
                    ethr = ethr;
                    $("#net-interfaces-table-tbody").append("<tr><td>" + ethr + "</td><td>" + vip + "</td></tr>");
                }
            });

            //stylizes the stripes on the table
            $('table tr:nth-child(even) td').each(function(){
                $(this).css('background-color', '#f4f6f9');
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
