#!/bin/bash

cd "${0%/*}"
. ../common.sh

echo "Processing CS2..."

ProcessDepot ".so"
ProcessDepot ".dll"
ProcessVPK

while IFS= read -r -d '' file
do
	echo " > $file"

	# When updating vpk_extensions, also update "vpk:..." in GameTracking/files.json
	~/ValveResourceFormat/Decompiler/bin/Release/linux-x64/publish/Decompiler \
		--input "$file" \
		--output "$(echo "$file" | sed -e 's/\.vpk$/\//g')" \
		--vpk_cache \
		--vpk_decompile \
		--vpk_extensions "txt,lua,kv3,db,gameevents,vcss_c,vjs_c,vts_c,vxml_c,vsndevts_c,vsndstck_c,vpulse_c" \
	|| echo "Decompiler failed"
done <   <(find . -type f -name "pak01_dir.vpk" -print0)

ProcessToolAssetInfo
FixUCS2

CreateCommit "$(grep "ClientVersion=" game/csgo/steam.inf | grep -o '[0-9\.]*')" "$1"

echo "Done"
