//customers key
var keyArray = [
   {
     "entitlementKey":    "P82G9-DA9BA-67LRQ-4KA6B-LK539-3YTXQ",
     "capacity":          20000,
     "validFrom":         "2018-03-01 00:00:00UTC",
     "validTo":           "2019-02-28 23:59:59UTC"
   },
   {
     "entitlementKey":    "SF89F-08SF8-908F9-0S8F9-0890F-S9RS9",
     "capacity":          15000,
     "validFrom":         "2018-03-01 00:00:00UTC",
     "validTo":           "2019-02-28 23:59:59UTC"
   }
];

// database of keys purchased
var keyStorageArray = [
   {
     "entitlementKey":    "P82G9-DA9BA-67LRQ-4KA6B-LK539-3YTXQ",
     "capacity":          1000,
     "validFrom":         "2018-03-01 00:00:00UTC",
     "validTo":           "2019-02-28 23:59:59UTC"
   },
   {
     "entitlementKey":    "SF89F-08SF8-908F9-0S8F9-0890F-S9RS9",
     "capacity":          15000,
     "validFrom":         "2018-03-01 00:00:00UTC",
     "validTo":           "2019-02-28 23:59:59UTC"
   },
   {
     "entitlementKey":    "KRE98-FU90U-FS8UE-89UF8-9SE8F-USU90",
     "capacity":          3000,
     "validFrom":         "2017-03-01 00:00:00UTC",
     "validTo":           "2018-4-28 23:59:59UTC"
   },
   {
     "entitlementKey":    "KRE98-FU90U-FS8UE-89UF8-9SE8F-USU90",
     "capacity":          3000,
     "validFrom":         "2017-03-01 00:00:00UTC",
     "validTo":           "2018-4-28 23:59:59UTC"
   }
];

console.log(keyArray);
console.log(keyStorageArray[3]);

//print keys to table
function printFullTable(data)
{
    var table = document.getElementById('keyLicenseTable'); //grab table
    console.log(table);
    var tableBody = document.createElement('tbody');
    for (var i = 0; i < data.length; i++)
    {
        var dataset1 = data[i];
        console.log(dataset1);
        var row = document.createElement('tr'); // create row
        var properties = ['entitlementKey','capacity', 'validFrom', 'validTo']; //properties for each row

        for (var j = 0; j < properties.length; j++) // append each column
        {
            var cell = document.createElement('td'); //create a td for every cell
            cell.innerHTML = dataset1[properties[j]];
            row.appendChild(cell); //append value to cell in that row
            console.log(row);
        }
         console.log(tableBody);
         table.appendChild(tableBody).append(row);
    }
}
printFullTable(keyArray);

//check over capacity
$(document).ready(function(){
  var currUsedCapacity = document.getElementById("currUsedCapa");

});

//calc license capacity
function calcLicenseCapacity(data){
  var totalLicenseCapacity = 0;
  for (i = 0; i < keyArray.length; i++){
      totalLicenseCapacity = totalLicenseCapacity + keyArray[i].capacity;
      console.log(totalLicenseCapacity);
  }
  if (totalLicenseCapacity < 100000){
    console.log("yes less than 100000");
    document.getElementById("licenseCapa").innerHTML = totalLicenseCapacity + " ";
  } else {
    document.getElementById("licenseCapa").innerHTML = "Unlimited ";
  }
}
calcLicenseCapacity(keyArray);

var applyKeyButton = document.getElementById("applyKey");
function addNewLicenseKey(){
   applyKeyButton.click(function(){
      checkLicenseKey();
      calcLicenseCapacity(keyArray);
   });
}

// function checkLicenseKey(){
//   //check key
//   var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
//   //need to check if key exists
//   var userKeyInput = document.getElementById('keyInputt').value;
//   console.log("input1: " + userKeyInput);
//   //check regex with user input
//   console.log(checkKeyRegex.test(userKeyInput));
//   if (checkKeyRegex.test(userKeyInput) == true){
//     // check if key exists in keyArray
//       if(keyStorageArray[3].entitlementKey === userKeyInput){
//         //push new keyinput to array
//         keyArray.push(keyStorageArray[3]);
//       } else{
//         var errMsg = "<span class='errMsg'>Your license key cannot be found.</span>";
//         $("label").before(errMsg);
//         $("#keyInputt").css('border','1px solid #d9534f');
//       }
//   } else {
//       var errMsg = "<span class='errMsg'>Sorry please reenter the license key again.</span>";
//       $("label").before(errMsg);
//       $("#keyInputt").css('border','1px solid #d9534f');
//   }
// }
