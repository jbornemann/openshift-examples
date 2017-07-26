oc start-build weather-on-shift

RESULT="Statuspending"
while [[ $RESULT != "Statuscomplete" && $RESULT != "Statusfailed" ]]; do
  RESULT=$( oc describe bc weather-on-shift  | grep -A 1 -e Build.*Status - | awk '{ print $2 }' | tr -d '\n' )
  sleep 5
  echo "Build still running. Checking for job completion in 5 seconds.."
done

if [[ $RESULT == "Statusfailed" ]]; then
  echo "Build failed" 
  exit 1
fi 

echo "Test build succeeded.."
echo "Checking service.."

nc -w 10 weather-on-shift.myproject.svc 8080 < /dev/null 

if [ "$?" == "1" ]; then
	echo "Service connection failed"
	exit 1
fi

echo "Health check succeeded"


