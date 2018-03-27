var keyArray = [
  // US region
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
     "entitlementKey":    "P82G9-DA9BA-67LRQ-4KA6B-LK539-3YTXQ",
     "capacity":          3000,
     "validFrom":         "2018-03-01 00:00:00UTC",
     "validTo":           "2019-02-28 23:59:59UTC"
   }
];

//print keys to table
function printFullTable(data)
{
    var table = document.getElementById('keyTable'); //grab table
    var tableBody = document.createElement('tbody');
    for (var i = 0; i < data.length; i++)
    {
        var dataset1= data[i];
        var row = document.createElement('tr'); // create row
        var properties = ['entitlementKey',
        'capacity', 'validFrom', 'validTo']; //properties for each row

        for (var j = 0; j < properties.length; j++) // append each column
        {
            var cell = document.createElement('td'); //create a td for every cell
            row.appendChild(cell); //append value to cell in that row
        }
        tableBody.appendChild(row);
        table.appendChild(tableBody); //add row
    }
}
printFullTable(keyArray);
