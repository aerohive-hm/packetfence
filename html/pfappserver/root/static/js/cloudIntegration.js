$(document).ready(function(){
    //three function calls: getNodeInfo, linkAerohiveAccount, unlinkAerohiveAccount
    setupObfuscatedTextHover('.pf-obfuscated-text + button');
    getNodeInfo();
    //link account btn press
    document.getElementById("link-account").onclick = function(e){
        e.preventDefault();
        var cloudurl  = document.getElementById('url').value;
        var clouduser = document.getElementById('user').value;
        var cloudpass = document.getElementById('pass').value;
        if(cloudurl == "" || clouduser == "" || cloudpass == ""){
            //if any of the three fields are empty
            document.getElementById('errorMessage').innerHTML = "Enter values in all fields.";
            $("#error-alert").show();
            setTimeout(function (){
              $("#error-alert").slideUp(500);
            }, 3000);
        } else {
            linkAerohiveAccount();
        }
    }

    //unlink button press
    document.getElementById('unlink-account').onclick = function(){
        document.getElementById("link-account").disabled = false;
        unlinkAerohiveAccount();
    }
});

//api call to get the info for each node/standalone
function getNodeInfo(){
    var rdcUrl            = document.getElementById('rdcUrl'),
        region            = document.getElementById('region'),
        ownerId           = document.getElementById('ownerId'),
        lastContactTime   = document.getElementById('lastContactTime'),
        vhmId             = document.getElementById('vhmId');
    var base_url = window.location.origin;
    $("#cloud-cluster-table-tbody tr").remove();
    $.ajax({
        type: 'GET',
        url: base_url + '/ama/cloud_integration/',
        success: function(data){
            //determine which page to show if linked or unlinked
            //linked
            data = jQuery.parseJSON(data.A3_data);
            if (data.msgtype == "nodesInfo"){
                $('#rdcUrl').html(data.body.header.rdcUrl);
                document.getElementById("rdcUrl").href = data.body.header.rdcUrl;
                if (data.body.header.region == ""){
                    $('#region').html("unknown");
                } else {
                    $('#region').html(data.body.header.region);
                }
                $('#ownerId').html(data.body.header.ownerId);
                 //if the field lastContactTime exists on the tt file
                if ($( "#lastContactTime" ).length){
                    if (typeof data.body.data[0].lastContactTime === "undefined"){
                    $('#lastContactTime').html("unknown");
                    } else {
                        $('#lastContactTime').html(data.body.data[0].lastContactTime);
                    }
                }
                $('#vhmId').html(data.body.header.vhmId);
                $(".disconnected").hide();
                if (data.body.header.mode === "cluster"){ //if it's a cluster
                    $.each(data.body.data, function(i, items){
                        $("#cloud-cluster-table-tbody").append("<tr><td id='connectedIcon'>" + items.status + "</td><td>" + items.hostname + "</td><td>" +  items.lastContactTime + "</td></tr>");
                    });
                    $('#cloud-cluster-table-tbody td:nth-child(1)').each(function() {
                        if ($(this).text() == "connected"){
                            $(this).html('<i class="icon-circle icon" style="color:#28a745; font-size:15px; margin: 0 auto;"></i>');
                        } else if ($(this).text() == "connecting") {
                            $(this).html('<i class="icon-circle icon" style="color:#ffc107; font-size:15px; margin: 0 auto;"></i>');
                        } else if ($(this).text() == "disconnect") {
                            $(this).html('<i class="icon-circle icon" style="color:#dc3545; font-size:15px; margin: 0 auto;"></i>');
                        } else {
                            $(this).html('<i class="icon-exclamation-triangle icon" style="color:#dc3545; font-size:15px; margin: 0 auto;"></i>');
                        }
                    });
                    $('#cloud-cluster-table-tbody tr:nth-child(even) td').each(function(){
                        $(this).css('background-color', '#f4f6f9');
                    });
                }
                $(".linked").show();
                $(".disconnected").hide();
            //unlinked
            } else if (data.msgtype == "cloudConf"){
                $(".linked").hide();
                $(".disconnected").show();
            } else {
                $(".disconnected").show();
            }
        },
        error: function(data){
            document.getElementById('errorMessage').innerHTML = "Could not retrieve data.";
            $("#error-alert").show();
            setTimeout(function (){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

//function unlink account
function unlinkAerohiveAccount(){
    var base_url = window.location.origin;
    var data = {url: ""};

    $.ajax({
        type: 'POST',
        url: base_url + '/ama/cloud_integration/',
        dataType: 'json',
        data: data,
        success: function(data){
            data = jQuery.parseJSON(data.A3_data);
            if (data.code == "fail"){
                document.getElementById('errorMessage').innerHTML = data.msg;
                $("#error-alert").show();
                setTimeout(function (){
                    $("#error-alert").slideUp(500);
                }, 3000);
            } else {
                $(".linked").hide();
                $(".disconnected").show();
                document.getElementById('successMessage').innerHTML = "Successfully unlinked.";
                $("#success-alert").show();
                setTimeout(function (){
                    $("#success-alert").slideUp(500);
                }, 3000);
            }
        },
        error: function(data){
            data = jQuery.parseJSON(data.A3_data);
            document.getElementById('errorMessage').innerHTML = data.msg;
            $("#error-alert").show();
            setTimeout(function (){
                $("#error-alert").slideUp(500);
            }, 3000);
            document.getElementById("link-account").disabled = false;
        }
    });
}

//function to link account
function linkAerohiveAccount(){
    $('#spin-spinner').show();
    var base_url = window.location.origin;
    var form = document.forms.namedItem("cloudForm");
    var formData = new FormData(form);

    var object = {};
    formData.forEach(function(value, key){
        object[key] = value;
    });

    document.getElementById("link-account").disabled = true;
    $.ajax({
        type: 'POST',
        url: base_url + '/ama/cloud_integration/',
        dataType: 'json',
        data: object,
        success: function(data){
            data = jQuery.parseJSON(data.A3_data);
            $('#spin-spinner').hide();

            if (data.code == "fail"){
                document.getElementById('errorMessage').innerHTML = data.msg;
                $("#error-alert").show();
                setTimeout(function (){
                    $("#error-alert").slideUp(500);
                }, 3000);
                document.getElementById("link-account").disabled = false;
            } else {
                $(".disconnected").hide();
                $(".linked").show();
                document.getElementById('successMessage').innerHTML = "Successfully linked";
                $("#success-alert").show();
                setTimeout(function (){
                    $("#success-alert").slideUp(500);
                }, 3000);
                getNodeInfo();
            }
        },
        error: function(data){
            data = jQuery.parseJSON(data.A3_data);
            document.getElementById('errorMessage').innerHTML = data.msg;
            $("#error-alert").show();
            setTimeout(function (){
                $("#error-alert").slideUp(500);
            }, 3000);
            document.getElementById("link-account").disabled = false;
        }
    });
}
