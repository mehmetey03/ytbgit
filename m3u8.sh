#!/bin/bash
set -euo pipefail  # Hata durumunda dur, tanımsız değişkenleri kontrol et

# GitHub Actions'ta çalışıyorsa özel yol
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
cd "$WORKSPACE" || exit 1

echo "🛠️  Ortam hazırlanıyor..."
mkdir -p playlist
rm -f playlist/*.m3u8 playlist.m3u

# JSON işleme
echo "📥 Kanallar indiriliyor..."
jq -c '.[]' link.json | while read -r i; do
    name=$(echo "$i" | jq -r '.name | gsub("[^a-zA-Z0-9]"; "_")')  # Özel karakterleri temizle
    url=$(echo "$i" | jq -r '.url')
    echo "🔗 $name işleniyor..."
    curl -fsSL "$url" -H "User-Agent: Mozilla/5.0" -H "Referer: https://live.artofknot.com/" -o "playlist/${name}.m3u8"
done

# Ana playlist oluştur
echo "📝 Ana playlist oluşturuluyor..."
{
    echo "#EXTM3U"
    for file in playlist/*.m3u8; do
        [ -e "$file" ] || continue  # Boş klasör kontrolü
        name=$(basename "$file" .m3u8)
        echo "#EXTINF:-1,$name"
        echo "https://raw.githubusercontent.com/${GITHUB_REPOSITORY:-user/repo}/main/playlist/${name}.m3u8"
    done
} > playlist.m3u

echo "✅ Başarıyla tamamlandı!"
