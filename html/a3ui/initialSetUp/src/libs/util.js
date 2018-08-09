
import $ from 'jquery';
import React from 'react';
import {Button,notification,message} from 'antd';
import Moment from 'moment';

export function RequestApi(type,url,data,xCsrfToken,callback,errorCallback){
    let t1 = new Date().getTime();
    $.ajax({
        type: type,
        url:  url,
        data: data,
        dataType: "json",
        contentType:"application/json", 
        beforeSend: function(xhr) {
            xhr.setRequestHeader("X-CSRF-TOKEN", xCsrfToken);
        },
        success: function(data){
            let t2 = new Date().getTime();
            callback(data);
        },
        error:function(error){
            let t3 = new Date().getTime();
            message.destroy();
            message.error(JSON.parse(error.responseText).error.message);
            window.parent.window.scrollTo(0, 0);
            errorCallback(error);
            
        }
    })
}

export function formatNum(str){
        if(str.indexOf(":")!==-1||str.indexOf(",")!==-1){
            return str;
        }
        var newStr = "";
        var count = 0;
        for(var i=str.length-1;i>=0;i--){
            if(count % 3 == 0 && count != 0){
                newStr = str.charAt(i) + "," + newStr;
            }else{
                newStr = str.charAt(i) + newStr;
            }
            count++;
        }
        return newStr;
}

export  function UnixToDate(unix,format){
        if(unix === undefined || unix === null) return null;

        if(unix * 1 <= 0) return null;

        if(format === undefined)
            format = "YYYY-MM-DD HH:mm";

        return Moment.unix(unix.toString().substr(0,10)).format(format);

}

//stringTime = "2014-07-10 10:21:12";
export  function  DateToUnix(stringTime){
        var timestamp = Date.parse(new Date(stringTime));
        timestamp = timestamp / 1000;

        return timestamp;

}

export function urlEncode(param, key, encode) {  
  if(param==null) return '';  
  var paramStr = '';  
  var t = typeof (param);  
  if (t == 'string' || t == 'number' || t == 'boolean') {  
    paramStr += '&' + key + '=' + ((encode==null||encode) ? encodeURIComponent(param) : param);  
  } else {  
    for (var i in param) {  
      var k = key == null ? i : key + (param instanceof Array ? '[' + i + ']' : '.' + i);  
      paramStr += urlEncode(param[i], k, encode);  
    }  
  }  
  return paramStr;  
}; 
    
export function isIp(data){
  var r = /^((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))$/;　　

  return r.test(data.toString());

}

export function isPositiveInteger(data){
  var r = /^[1-9][0-9]*$/;　　

  return r.test(data.toString());

}

export function isEmail(data){　
  var r = /^[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,4}$/;
  return r.test(data.toString().trim());

}


export function isHostname(data){　
  var r = /^[!@#$%^&*\(\)~\-+=_\]\[\.;\\\/'`A-Za-z\d]*$/;
  return r.test(data.toString().trim());

}