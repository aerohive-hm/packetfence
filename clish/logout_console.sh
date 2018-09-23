#!/bin/sh
pid=`ps -ef|grep clish|grep -v color|awk '{print $2}'`
kill -9 $pid
