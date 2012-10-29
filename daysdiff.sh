#!/bin/bash
#echo $(( ($( date -d "2011-01-30 11:00" +%s ) - $( date -d "2009-09-17 12:00:00" +%s )) / 86400 ))
print_help()
{
  echo "Usage : $0 [options]"
  echo "options :"
  echo "  -from <start_date>"
  echo "  -to <end_date>"
  echo "  -delta <nb_days>"
  echo "date format is yyyy-mm-dd"
}

if [ $# -eq 0 ]; then
  print_help
  exit 1
fi

while [ $# -gt 0 ] ; do
  case $1 in
    -from)
      from=$2
      shift;;
    -to)
      to=$2
      shift;;
    -delta)
      delta=$2
      shift;;
    -h|*)
      print_help
      exit 1
  esac
  shift
done
seconds_per_day=$(( 60 * 60 * 24))
if [ ! -z $to ] && [ ! -z $from ]; then
  echo $(( ($( date -d "$to 12:00" +%s ) / $seconds_per_day - $( date -d "$from 12:00" +%s ) / $seconds_per_day ) ))
fi

if [ -z $to ] && [ -z $delta ]; then
  echo $(( ($( date -d "`date +%Y-%m-%d` 12:00" +%s ) / $seconds_per_day - $( date -d "$from 12:00" +%s ) / $seconds_per_day ) ))
fi

if [ -z $from ] && [ -z $delta ]; then
  echo $(( ($( date -d "$to 12:00" +%s ) / $seconds_per_day - $( date -d "`date +%Y-%m-%d` 12:00" +%s ) / $seconds_per_day) ))
fi

if [ ! -z $delta ] && [ ! -z $from ]; then
  from_sec=`date -d "$from 12:00" +%s`
  echo "`date +%Y-%m-%d -d @$(( $delta * $seconds_per_day + $from_sec ))`"

fi
if [ ! -z $delta ] && [ ! -z $to ]; then
  to_sec=`date -d "$to 12:00" +%s`
  echo "`date +%Y-%m-%d -d @$(($to_sec - $delta * $seconds_per_day ))`"

fi
