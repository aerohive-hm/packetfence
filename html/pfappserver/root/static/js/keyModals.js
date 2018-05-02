function openExpiredModal(){
    console.log("show expired modal");
    $('#expiredModal').modal({backdrop:'static', keyboard: false });
    $('#expiredModal').modal('show');
}

function openAlmostExpiredModal(){
    $('#myModal').modal({backdrop:'static', keyboard: false });
    $('#myModal').modal('show');
}

// $(document).ready(function(){
  openExpiredModal();
  openAlmostExpiredModal();
// });
