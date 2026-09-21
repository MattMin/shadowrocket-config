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

其余规则保持上游内容，并通过本仓库的 Raw 链接引用。

## 自动同步

GitHub Actions 每天北京时间 14:17 检查上游规则，仅在内容变化时提交。也可以在仓库的 **Actions → Sync rules → Run workflow** 中手动运行。

本地同步：

```bash
bash scripts/sync-rules.sh
```

## 安全

公开配置不包含 HTTPS 解密证书、私钥或密码。原始本地配置 `lazy_group.conf` 已加入 `.gitignore`。

## 规则来源

- [blackmatrix7/ios_rule_script](https://github.com/blackmatrix7/ios_rule_script)
- [iab0x00/ProxyRules](https://github.com/iab0x00/ProxyRules)
- [TG-Twilight/AWAvenue-Ads-Rule](https://github.com/TG-Twilight/AWAvenue-Ads-Rule)

规则内容及许可归对应上游项目所有。
