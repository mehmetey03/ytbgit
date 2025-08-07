#!/bin/bash
cd "$(dirname "$0")"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Gerekli araçlar (yerel test içindir)
sudo apt update
sudo apt install -y jq curl git

# Klasörü hazırla
mkdir -p playlist
rm -f playlist/*.m3u8

# link.json'dan linkleri çek ve .m3u8 dosyalarını indir
cat link.json | jq -c '.[]' | while read -r i; do
    name=$(echo "$i" | jq -r '.name')
    url=$(echo "$i" | jq -r '.url')
    echo "📥 $name indiriliyor..."
    curl -sSL "$url" \
        -H "User-Agent: Mozilla/5.0" \
        -H "Referer: https://live.artofknot.com/" \
        -o "playlist/${name}.m3u8"
done

# Ana dizine playlist.m3u dosyasını oluştur
echo "#EXTM3U" > playlist.m3u
for file in playlist/*.m3u8; do
    name=$(basename "$file" .m3u8)
    echo "#EXTINF:-1,$name" >> playlist.m3u
    echo "https://raw.githubusercontent.com/mehmetey03/ytbgit/main/playlist/$(basename "$file")" >> playlist.m3u
done

# Git işlemleri
git add playlist/*.m3u8 playlist.m3u
git commit -m "✅ Playlist dosyaları güncellendi: $(date)"
git push origin main
