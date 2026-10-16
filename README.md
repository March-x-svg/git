# git

这是一个已初始化并推送到 GitHub 的 Git 仓库。

- 远程仓库: https://github.com/March-x-svg/git.git
- 默认分支: `main`

## 快速开始

```bash
git add .
git commit -m "your message"
git push
```

## 本机环境说明

本机装有 TLS 拦截代理（SteamTools），系统证书库中有它的根证书。Git 默认的
`schannel` 后端在当前沙箱里取不到凭据，因此本仓库使用 OpenSSL 后端 + 本机 CA 包：

- `http.sslBackend=openssl`
- `http.sslCAInfo=.cacert.pem`（含系统 CA + 本机拦截根证书，已被 `.gitignore` 忽略）

Git 的凭据助手会启动 `sh.exe` 创建命名管道，DSH 沙箱会拦截。所以推送请在本仓库
根目录用普通终端运行：

```powershell
.\push.ps1              # 仅推送
.\push.ps1 -Message "feat: 新增功能"   # 提交并推送
```
