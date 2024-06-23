# simple script to get weather information from current location
echo "Running weather.sh" >&2

LOCATION=$(curl --silent http://ip-api.com/csv)
CITY=$(echo "$LOCATION" | cut -d , -f 6)

if [ -n "$CITY" ]; then
	RES=$(curl -s "wttr.in/$CITY?format="%c+%t+%h+%p)
	echo "$RES"
else
	echo "No info available"
fi
