#!/usr/bin/bash

sleep 5;

API='X-Yandex-API-Key: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';

URL='https://api.weather.yandex.ru/v2/informers?lat=55.765426&lon=37.605703';

curl -H "$API"  "$URL"  > ~/weather/full.txt;

grep -Pom1 '(?s)((?<="fact":{)(.*?)(?=(,"xxxxxxxxx")))' ~/weather/full.txt > ~/weather/fact.txt;

icon=$(grep -Pom1 '(?s)((?<="icon":")(.*?)(?=(","condition")))' ~/weather/fact.txt);

curl -O https://yastatic.net/weather/i/icons/funky/dark/"$icon".svg;

inkscape --export-type=png -w 75 -h 75 "$icon".svg;

mv "$icon".png ~/weather/icon/wicon.png;

rm "$icon".svg;


