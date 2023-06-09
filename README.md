# 🌐 Rclone AutoTransfer

Rclone AutoTransfer 是一个基于 rclone 的多云备份脚本，旨在提供一种简单而可靠的方式来实现云存储之间的数据备份。它能将文件从一个云存储服务复制到另一个，确保你的数据得到双重备份，从而提高数据的安全性和可靠性。

## ✨ 主要功能

- 从源路径自动备份文件到目标路径的云存储服务。
- 自动检测并关闭已存在的备份任务，以避免冲突，实现启动新任务。
- 支持定义传输速度和每日传输配额。
- 提供备份通知功能，目前支持电报机器人 API。
- 可选设置定时执行任务，自动化备份流程。

## 🚀 开始使用

1. 打开 `Rclone_AutoTransfer.sh` 脚本文件，并在文件顶部配置你的备份参数（源路径、目标路径、传输速度、每日传输限额、电报机器人 API 和聊天 ID、日志目录等）。
2. 保存脚本并确保有执行权限（`chmod +x Rclone_AutoTransfer.sh`）。
3. 运行 `Rclone_AutoTransfer.sh` 脚本开始备份任务：`./Rclone_AutoTransfer.sh`。
4. （可选）如果需要定时执行任务，请按照以下的指引设置。

**请注意：** 在使用脚本之前，请确保已正确配置并安装了 rclone 工具，并且已经完成了云存储服务的挂载。

## ⏰ 定时执行任务（可选）

如果你想让备份任务在特定的时间自动运行，你可以将 Rclone AutoTransfer 脚本设置为定时任务。下面是设置步骤：

1. 在命令行中，输入 `crontab -e` 打开 cron 配置文件。
2. 在新的一行中，添加你的定时任务。例如，如果你希望每天凌晨2点执行备份任务，可以添加以下行：
    ```
    0 2 * * * /path/to/script/Rclone_AutoTransfer.sh
    ```
   请将 `/path/to/script/` 替换为 `Rclone_AutoTransfer.sh` 脚本文件的实际路径。
3. 保存并关闭配置文件。

现在，Rclone AutoTransfer 脚本将按照你的定时任务设置自动执行。

## ⚠️ 注意事项

- 此脚本会定期向指定的电报聊天发送消息。请确保正确配置了你的电报机器人 API 和聊天 ID。
- 对于大规模的备份任务，确保你的服务器有足够的存储空间来保存日志文件。

## 💻 需要的工具

- **Bash**：脚本语言，主要用于命令行和脚本编程。
- **[rclone](https://rclone.org/)**：一个命令行程序，用于同步文件和目录到不同的云存储服务。在此脚本中，它主要用于从源云存储服务复制文件到目标云存储服务。你可以按照 [rclone 官方指南](https://rclone.org/install/)进行安装。
- **[jq](https://stedolan.github.io/jq/)**：一个轻量级的命令行 JSON 处理工具。在此脚本中，它主要用于解析电报 API 的 JSON 响应，以获取和更新消息 ID。jq 可以通过包管理器（如 apt、brew 等）进行安装。例如，使用 apt 安装可以使用以下命令： `sudo apt-get install jq`。
- **电报机器人**：在此脚本中，电报机器人用于发送和更新备份任务的状态通知。

请确保在运行此脚本之前，已在你的系统上安装并配置了这些工具。

## 🙌 贡献



我们欢迎你通过提交 Pull 请求或 Issue 来帮助改进这个脚本。

## 📄 许可证

这个项目采用 MIT 许可证。请参阅 [LICENSE](LICENSE) 文件以获取更多信息。
