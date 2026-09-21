#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
download_dir="$tmp_dir/downloads"
output_dir="$tmp_dir/rules"
mkdir -p "$download_dir" "$output_dir"

download() {
  local target=$1 url=$2
  curl --fail --location --retry 3 --silent --show-error "$url" -o "$target"
  [[ -s $target ]] || { echo "空规则文件：$url" >&2; exit 1; }
  grep -Eq '^(DOMAIN|HOST|IP|USER-AGENT|URL-REGEX)' "$target" || {
    echo "无有效规则：$url" >&2
    exit 1
  }
  # Quantumult X 的第三列是策略；由配置中的 RULE-SET 统一指定。
  if [[ $url == */QuantumultX/* ]]; then
    awk 'BEGIN { FS=OFS="," }
      /^#/ || !NF { print; next }
      NF != 3 { exit 1 }
      { sub(/^HOST/, "DOMAIN", $1); print $1, $2 }' "$target" > "$target.converted"
    mv "$target.converted" "$target"
  fi
}

mirror() {
  download "$output_dir/$1" "$2"
}

mirror AWAvenue-Ads.list https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Surge-RULE-SET.list
mirror AI.list https://raw.githubusercontent.com/iab0x00/ProxyRules/main/Rule/AI.txt
mirror YouTube.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/YouTube/YouTube.list
mirror Netflix.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Netflix/Netflix.list
mirror Disney.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Disney/Disney.list
mirror Spotify.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Spotify/Spotify.list
mirror Telegram.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Telegram/Telegram.list
mirror PayPal.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/PayPal/PayPal.list
mirror Twitter.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Twitter/Twitter.list
mirror Facebook.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Facebook/Facebook.list
mirror Amazon.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Amazon/Amazon.list
mirror GitHub.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/GitHub/GitHub.list
mirror Microsoft.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Microsoft/Microsoft.list
mirror Google.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Google/Google.list
mirror Apple.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/QuantumultX/Apple/Apple.list
mirror BiliBili.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/BiliBili/BiliBili.list
mirror TikTok.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/TikTok/TikTok.list
mirror Global.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/QuantumultX/Global/Global.list
mirror Lan.list https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Lan/Lan.list

china_sources=()
download "$download_dir/China.list" https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/QuantumultX/China/China.list
china_sources+=("$download_dir/China.list")
for name in NetEaseMusic Baidu DouBan Sina Zhihu XiaoHongShu DouYin; do
  source_file="$download_dir/$name.list"
  download "$source_file" "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/$name/$name.list"
  china_sources+=("$source_file")
done
download "$download_dir/WeChat.list" https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/QuantumultX/WeChat/WeChat.list
china_sources+=("$download_dir/WeChat.list")
{
  echo '# 合并自 China、NetEaseMusic、Baidu、DouBan、Sina、Zhihu、XiaoHongShu、DouYin、WeChat 规则集'
  awk 'NF && $0 !~ /^#/ && !seen[$0]++' "${china_sources[@]}"
} > "$output_dir/China.list"

game_sources=()
for name in Sony Nintendo Epic SteamCN Steam Game; do
  source_file="$download_dir/$name.list"
  download "$source_file" "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/$name/$name.list"
  game_sources+=("$source_file")
done
{
  echo '# 合并自 Sony、Nintendo、Epic、SteamCN、Steam、Game 规则集'
  awk 'NF && $0 !~ /^#/ && !seen[$0]++' "${game_sources[@]}"
} > "$output_dir/Game.list"

hbo_file="$download_dir/HBO.list"
download "$hbo_file" https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/HBO/HBO.list
{
  echo '# 合并自本地 MAX 规则和 HBO 规则集'
  printf 'DOMAIN-SUFFIX,litix.io\nDOMAIN-SUFFIX,discomax.com\nDOMAIN-SUFFIX,brightline.tv\n'
  awk 'NF && $0 !~ /^#/ && !seen[$0]++' "$hbo_file"
} > "$output_dir/Max.list"

cat > "$output_dir/KRAK.list" <<'EOF'
# KRAK 规则集
DOMAIN-KEYWORD,onetrust
DOMAIN-KEYWORD,kraken
DOMAIN-KEYWORD,krak
DOMAIN-KEYWORD,zendesk
DOMAIN-KEYWORD,braze
DOMAIN-KEYWORD,launchdarkly
DOMAIN-KEYWORD,sentry
DOMAIN-KEYWORD,segment
DOMAIN-KEYWORD,nsureapi
DOMAIN-KEYWORD,sardine
DOMAIN-KEYWORD,stripe
DOMAIN-KEYWORD,appsflyer
DOMAIN-KEYWORD,expo
EOF

referenced_rules="$tmp_dir/referenced-rules"
awk -F/ '/^RULE-SET,https:\/\/raw\.githubusercontent\.com\/MattMin\/shadowrocket-config\/master\/rules\// { split($NF, value, ","); print value[1] }' "$repo_dir/shadowrocket.conf" | sort -u > "$referenced_rules"
[[ -s $referenced_rules ]] || { echo '配置中没有找到自有规则引用' >&2; exit 1; }
while IFS= read -r name; do
  [[ -s $output_dir/$name ]] || { echo "配置引用缺失：$name" >&2; exit 1; }
done < "$referenced_rules"
[[ $(find "$output_dir" -name '*.list' | wc -l | tr -d ' ') -eq $(wc -l < "$referenced_rules" | tr -d ' ') ]] || {
  echo '生成的规则文件与配置引用不一致' >&2
  exit 1
}

mkdir -p "$repo_dir/rules"
for name in NetEaseMusic Baidu DouBan WeChat Sina Zhihu XiaoHongShu DouYin; do
  rm -f "$repo_dir/rules/$name.list"
done
cp "$output_dir"/*.list "$repo_dir/rules/"
echo "规则同步完成：$(find "$output_dir" -name '*.list' | wc -l | tr -d ' ') 个文件"
