# 示例 App 上传 TestFlight

工作流：`.github/workflows/ios-testflight.yml`。

它只做这些事：在 `macos-latest` 上用 Flutter stable 编译 `example/`，用手动签名打出 App Store IPA，再上传到 TestFlight。**不会**提交 App Review，也**不会**送给外部测试审核。构建处理完之后，在 App Store Connect 打开「凌云UI」→ TestFlight → iOS Builds 即可。

不会在 pull request 或 `v*` tag 上自动跑。这个仓库的 tag 是 Flutter 包版本，不是示例 App 的发版。每次上传都会占用 GitHub macOS 分钟数。

Linux 上的 `ci.yml` / `pages.yml` 不包含这次任务。macOS 与 Android 的 Bundle ID 仍是 `com.example.example`。

## 怎么跑

1. 仓库 **Actions** → **iOS TestFlight** → **Run workflow**。
2. `build_name` 留空则用 `example/pubspec.yaml` 的营销版本（当前 `1.0.0`）。必须是 `1`、`1.2` 或 `1.2.3`。
3. `build_number` 留空则用本次 GitHub **run number**。同一个营销版本的构建号不能重复；重跑同一次 run 时请手填一个更大的整数。
4. 成功后 IPA 会作为 artifact `lingyun-ui-ipa` 保留 7 天。上传失败但 IPA 已经打出来时，也可以下载它再用 Transporter 手工传。

## 已经存在的 secrets

这三个名字不要改，工作流只读它们：

| Secret | 内容 |
| --- | --- |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect API 的 Issuer ID |
| `APP_STORE_CONNECT_KEY_ID` | Key ID |
| `APP_STORE_CONNECT_API_KEY_P8` | `.p8` 文件的**全文** PEM，含 `-----BEGIN PRIVATE KEY-----`。不是 Key ID，也不是 Base64 |

API Key 在 App Store Connect → 用户和访问 → 集成 → App Store Connect API。角色需要是 **Admin**，这样 CI 才能创建 App Store 描述文件。只读或 App Manager 通常能上传，但不能管理证书和描述文件。

## 还必须添加的 secrets

Apple 不提供已有分发证书的私钥。下面两个 secret 是签名所必需的，仓库里不能代填。

| Secret | 内容 |
| --- | --- |
| `IOS_DISTRIBUTION_CERT_P12_BASE64` | Apple Distribution 证书 `.p12` 的 Base64（证书和私钥都在里面） |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | 导出该 p12 时设置的**非空**密码 |

可选：

| Secret | 什么时候需要 |
| --- | --- |
| `APPLE_TEAM_ID` | 10 位 Developer Team ID，例如 `AB12CD34EF`。不是 Issuer ID。留空时，工作流用 API 读取 Bundle ID `com.qiudeteng.lingyunui` 的 `seedId`。读取失败时再填这个。 |
| `IOS_APPSTORE_PROFILE_BASE64` | 已有 App Store 描述文件（`.mobileprovision`）的 Base64。留空时，每次运行用 API **更新**名为 `lingyun-ui-flutter-appstore` 的描述文件。API 返回 403 时改为提供这个文件，并保证它包含上面的那张分发证书。 |

每个 Apple Developer 账号最多大约 3 张有效的 Apple Distribution 证书。CI **不会**每次新建证书。请自己创建或导出一张，并保管好 p12。丢了私钥就只能吊销后重建。

## 一次性 Apple 准备

1. 在 App Store Connect 签好协议，包括免费 App 也需要的 **Paid Applications** 协议。没签的话上传会得到含糊的协议错误。
2. 确认应用「凌云UI」的 Bundle ID 是 `com.qiudeteng.lingyunui`（SKU `lingyun-ui-flutter-demo`）。开发者门户里要有同名 App ID。
3. 准备分发证书，二选一。

**Mac 上已经有这张证书：** 钥匙串访问 → 我的证书 → 选中带私钥的 **Apple Distribution** → 导出 `.p12` 并设置密码。

**还没有证书（Windows 或 Mac 都可以）：** 用 OpenSSL 生成 CSR。Windows 上如果 `Get-Command openssl` 找不到，先 `winget install ShiningLight.OpenSSL.Light`，或使用 Git for Windows 自带的 `C:\Program Files\Git\usr\bin\openssl.exe`。密码不要包含空格或引号。

```powershell
$openssl = if (Get-Command openssl -ErrorAction SilentlyContinue) { "openssl" } else { "C:\Program Files\Git\usr\bin\openssl.exe" }
& $openssl req -new -newkey rsa:2048 -nodes -keyout distribution.key -out distribution.csr -subj "/CN=Lingyun UI Distribution/C=CN"
```

把 `distribution.csr` 上传到 [developer.apple.com](https://developer.apple.com/account/resources/certificates/add) → **Apple Distribution** → 下载 `distribution.cer`，再和私钥打成 p12（把 `YOUR_PASSWORD` 换成你自己的密码）：

```powershell
$openssl = if (Get-Command openssl -ErrorAction SilentlyContinue) { "openssl" } else { "C:\Program Files\Git\usr\bin\openssl.exe" }
$env:P12_PASS = "YOUR_PASSWORD"
& $openssl x509 -inform DER -in distribution.cer -out distribution.pem
& $openssl pkcs12 -export -inkey distribution.key -in distribution.pem -out distribution.p12 -passout env:P12_PASS
```

macOS / Linux 终端：

```bash
openssl req -new -newkey rsa:2048 -nodes -keyout distribution.key -out distribution.csr -subj "/CN=Lingyun UI Distribution/C=CN"
openssl x509 -inform DER -in distribution.cer -out distribution.pem
P12_PASS='YOUR_PASSWORD' openssl pkcs12 -export -inkey distribution.key -in distribution.pem -out distribution.p12 -passout env:P12_PASS
```

4. 把 p12 做成一行 Base64，写入 secret `IOS_DISTRIBUTION_CERT_P12_BASE64`。

Windows PowerShell：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path .\distribution.p12))) | Set-Clipboard
```

macOS：

```bash
base64 -i distribution.p12 | pbcopy
```

5. 把同一密码写入 `IOS_DISTRIBUTION_CERT_PASSWORD`。
6. 删掉本机的 `distribution.key`、`distribution.p12`、`.cer`。这些文件已经在 `.gitignore` 里，不要提交。

## 应用本身改了什么

- Runner 的 Bundle ID：`com.qiudeteng.lingyunui`（Debug / Release / Profile）。
- 测试包：`com.qiudeteng.lingyunui.RunnerTests`。测试目标不进 IPA。
- 显示名：`凌云UI`。
- `ITSAppUsesNonExemptEncryption` = false，避免每个构建都停在 Missing Compliance。示例没有自带加密。

签名只在 CI 的 Runner **Release** 配置上改成手动，不会写进提交。本机 `flutter run` 仍走原来的自动签名。

## 第一次失败时先看

- secret 检查在装 Flutter 之前就会停，避免空跑 macOS 分钟数。
- sigh 403：把 API Key 改成 Admin，或提供 `IOS_APPSTORE_PROFILE_BASE64`。
- 「No signing certificate」/ 导入 p12 失败：密码不对，或 p12 里没有私钥，或用成了 Development 证书。
- 构建号重复：给 `build_number` 填一个更大的整数。
- 协议错误：回到 App Store Connect 把协议签完。
