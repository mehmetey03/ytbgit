#!/bin/bash
cd "$(dirname "$0")"
mkdir -p playlist
rm -f playlist/*.m3u8

# link.json'dan verileri oku
cat link.json | jq -c '.[]' | while read -r i; do
    name=$(echo "$i" | jq -r '.name')
    url=$(echo "$i" | jq -r '.url')
    echo "📥 $name indiriliyor..."
    curl -sSL "$url" \
        -H "User-Agent: Mozilla/5.0" \
        -H "Referer: https://live.artofknot.com/" \
        -o "playlist/${name}.m3u8"
done

# playlist.m3u dosyasını oluştur
echo "#EXTM3U" > playlist.m3u
for file in playlist/*.m3u8; do
    name=$(basename "$file" .m3u8)
    echo "#EXTINF:-1,$name" >> playlist.m3u
    echo "https://raw.githubusercontent.com/mehmetey03/ytbgit/main/$file" >> playlist.m3u
done
