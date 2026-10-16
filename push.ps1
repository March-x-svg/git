# 在本机推送代码到 GitHub（Windows PowerShell）
#
# 为什么需要这个脚本：
#   1. 本机存在 TLS 拦截代理（SteamTools），系统证书库里有它的根证书，
#      所以必须让 Git 使用 OpenSSL 后端 + 包含该根证书的 CA 包（.cacert.pem）。
#   2. Git 的凭据助手（!gh auth git-credential）会启动 sh.exe 创建命名管道，
#      DSH 沙箱会拦截，因此推送需要在沙箱外（普通终端）执行。
#
# 用法：
#   在普通 PowerShell 窗口中运行：
#     cd C:\Users\win10\Desktop\git
#     .\push.ps1
#   或带提交信息：
#     .\push.ps1 -Message "feat: 新增功能"

param(
  [string]$Message,
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$repo = "C:\Users\win10\Desktop\git"
$cacert = Join-Path $repo ".cacert.pem"

Set-Location $repo

# 1. 确保 TLS 校验能通过
if (-not (Test-Path $cacert)) {
  Write-Host "未找到 $cacert，正在从 Windows 证书库与本机 TLS 链生成本地 CA 包..." -ForegroundColor Yellow
  $roots = Get-ChildItem Cert:\CurrentUser\Root | Where-Object { $_.Subject -like "*SteamTools Certificate*" }
  if (-not $roots) {
    Write-Warning "证书库中没有找到本机 TLS 拦截根证书，HTTPS 可能无法通过校验。"
  } else {
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $roots) {
      [void]$sb.AppendLine("### " + $c.Subject)
      [void]$sb.AppendLine("-----BEGIN CERTIFICATE-----")
      [void]$sb.AppendLine([Convert]::ToBase64String($c.RawData, 'InsertLineBreaks'))
      [void]$sb.AppendLine("-----END CERTIFICATE-----")
    }
    Set-Content -Path $cacert -Value $sb.ToString() -Encoding ascii
    Write-Host "已生成本地 CA 包: $cacert" -ForegroundColor Green
  }
}

git config --local http.sslBackend openssl
git config --local http.sslCAInfo $cacert
git config --local credential.https://github.com.helper "!gh auth git-credential"

# 2. 有改动就提交
if ($Message) {
  git add -A
  git commit -m $Message
}

# 3. 推送
git push -u origin $Branch
if ($LASTEXITCODE -eq 0) {
  Write-Host "推送成功: https://github.com/March-x-svg/git" -ForegroundColor Green
} else {
  Write-Host "推送失败，请检查 gh auth status 与网络代理设置。" -ForegroundColor Red
}
