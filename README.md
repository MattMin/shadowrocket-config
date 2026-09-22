# Shadowrocket Config

个人使用的 Shadowrocket 配置及规则镜像。

## 使用

在 Shadowrocket 中导入以下配置链接：

```text
https://raw.githubusercontent.com/MattMin/shadowrocket-config/master/shadowrocket.conf
```

## 目录

- `shadowrocket.conf`：主配置文件。
- `rules/`：主配置引用的规则集。
- `scripts/sync-rules.sh`：下载并合并上游规则。
- `.github/workflows/sync-rules.yml`：自动同步工作流。

## 合并规则

- `Game.list`：Sony、Nintendo、Epic、SteamCN、Steam 和 Game。
- `Max.list`：HBO 及配置中的 MAX 域名规则。
- `KRAK.list`：KRAK 相关域名关键词。
- `China.list`：China、网易云音乐、百度、豆瓣、微信、新浪、知乎、小红书和抖音。

其余规则保留上游匹配项，并通过本仓库的 Raw 链接引用。Quantumult X 来源会转换为 Shadowrocket 格式，移除策略列，并为 IP-CIDR / IP6-CIDR / IP-CIDR6 规则补充 `no-resolve`。

## 配置说明

- 配置仅保留生效项；节点和订阅在 Shadowrocket 中添加，地区分组根据节点名称筛选。
- 广告拦截优先于 KRAK；已命中广告表的域名不会被 KRAK 放行。TikTok 专用规则位于 China 之前。
- `no-resolve` 让域名请求跳过对应 IP 规则，不为匹配该规则触发 DNS 查询；直接使用目标 IP 的请求仍可匹配。
- 地区自动测速分组使用 50ms 容差、600 秒检测间隔；香港分组排除名称包含“直连”或“IPv6”（不区分大小写）的节点。
- DNS 同时配置 DoH 与普通 DNS，并允许系统 DNS 回退；这不是强制全程加密 DNS。IPv6 已启用，优先 IPv4。
- 代理流量阻止 QUIC；节点不支持 UDP 时拒绝对应 UDP 流量。配置不启用 HTTPS 解密。

## 自动同步

GitHub Actions 每天北京时间 14:17 同步上游规则，通过配置检查后，仅在规则内容变化时提交。也可以在仓库的 **Actions → Sync rules → Run workflow** 中手动运行。单次下载连接超时为 15 秒、总超时为 120 秒，失败最多重试 3 次。

本地同步：

```bash
bash scripts/sync-rules.sh
python3 scripts/check-config.py
```

## 规则来源

- [blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script)
- [iab0x00/ProxyRules](https://github.com/iab0x00/ProxyRules)
- [TG-Twilight/AWAvenue-Ads-Rule](https://github.com/TG-Twilight/AWAvenue-Ads-Rule)

规则内容及许可归对应上游项目所有。
