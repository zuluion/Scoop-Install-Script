# Scoop-Install-Script
---
1. 方法1：
  1. 先 powershell 打开执行策略 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
  1. 执行脚本
2. 方法2：`powershell -ExecutionPolicy Bypass -File .\scoop-install.ps1`
