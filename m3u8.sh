#!/bin/bash
set -euo pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
cd "$WORKSPACE" || exit 1

echo "🛠️  Preparing environment..."
mkdir -p playlist
rm -f playlist/*.m3u8 playlist.m3u

echo "📥 Downloading channels..."
jq -c '.[]' link.json | while read -r i; do
    name=$(echo "$i" | jq -r '.name')
    url=$(echo "$i" | jq -r '.url')
    
    echo "🔗 Processing $name..."
    if [[ $url == 192.168.* ]]; then
        echo "⚠️  Local IP skipped on GitHub: $url"
        echo "#EXTM3U\n#EXTINF:-1,$name (Local)" > "playlist/${name}.m3u8"
    else
        curl -fsSL --max-time 15 "$url" \
             -H "User-Agent: Mozilla/5.0" \
             -o "playlist/${name}.m3u8" || true
    fi
done

echo "📝 Generating master playlist..."
echo "#EXTM3U" > playlist.m3u
for file in playlist/*.m3u8; do
    [ -e "$file" ] || continue
    name=$(basename "$file" .m3u8)
    echo "#EXTINF:-1,$name" >> playlist.m3u
    echo "https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/playlist/${name}.m3u8" >> playlist.m3u
done

echo "✅ Successfully completed!"
