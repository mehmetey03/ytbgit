#!/bin/bash
set -euo pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
cd "$WORKSPACE" || exit 1

echo "🛠️  Ortam hazırlanıyor..."
mkdir -p playlist
rm -f playlist/*.m3u8 playlist.m3u

echo "📥 Kanallar indiriliyor..."
jq -c '.[]' link.json | while read -r i; do
    name=$(echo "$i" | jq -r '.name | gsub("[^a-zA-Z0-9]"; "_")')
    url=$(echo "$i" | jq -r '.url')
    
    echo "🔗 $name işleniyor..."
    if ! curl -fsSL --max-time 30 "$url" \
         -H "User-Agent: Mozilla/5.0" \
         -H "Referer: https://live.artofknot.com/" \
         -o "playlist/${name}.m3u8"; then
         echo "⚠️  $name indirilemedi, boş dosya oluşturuluyor"
         echo "#EXTM3U" > "playlist/${name}.m3u8"
    fi
done

echo "📝 Ana playlist oluşturuluyor..."
{
    echo "#EXTM3U"
    for file in playlist/*.m3u8; do
        [ -e "$file" ] || continue
        name=$(basename "$file" .m3u8)
        echo "#EXTINF:-1,$name"
        echo "https://raw.githubusercontent.com/${GITHUB_REPOSITORY:-user/repo}/main/playlist/${name}.m3u8"
    done
} > playlist.m3u

echo "✅ Başarıyla tamamlandı!"
