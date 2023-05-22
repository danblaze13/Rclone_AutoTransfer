# 🌐 Rclone_AutoTransfer

这个多云备份脚本基于 rclone 工具，旨在提供一种简单而可靠的方式来实现云存储之间的数据备份。它支持将文件从一个云存储服务复制到另一个云存储服务，使你的数据得到双重备份，提高数据的安全性和可靠性。

### ✨ 主要功能

- 备份源路径中的文件到目标路径中的云存储服务。
- 自动检测已存在的备份任务，并在启动新任务前关闭旧任务，避免冲突。
- 支持定义传输速度和每日配额，支持定义备份通知（目前只支持电报）
- 支持定时执行任务的设置（可选），自动进行备份操作。

### 🚀 开始使用

1. 在脚本开头的变量部分，设置源路径（source）和目标路径（target），确保它们是有效的 rclone 云挂载路径。
2. 根据需要设置传输速度和每日传输限额，配置电报的通知参数
3. 保存脚本并确保有执行权限（`chmod +x Rclone_AutoTransfer.sh`）。
4. 执行脚本来进行备份操作：`./Rclone_AutoTransfer.sh`。
5. （可选）如果需要定时执行任务，请按照说明设置定时任务。

请注意：在使用脚本之前，请确保已正确配置并安装了 rclone 工具，并且已经完成了云存储服务的挂载。

当然！以下是关于定时执行任务的说明，标明为可选项：

### ⏰ 定时执行任务（可选）
你可以选择将多云备份脚本设置为定时执行的任务，以便自动进行备份操作。这样，你无需手动运行脚本，而是通过设置定时任务来触发备份。

🔧 **设置定时任务**
要设置定时任务，请按照以下步骤操作：

1. 打开终端，并进入脚本所在的文件夹。
2. 运行以下命令打开定时任务配置文件：
   ```
   crontab -e
   ```
3. 在打开的文件中，选择一个空行，然后输入定时任务的配置。以下是一个示例：
   ```
   # 每天凌晨2点执行备份任务
   0 2 * * * /path/to/script/Rclone_AutoTransfer.sh
   ```
   注意：请将 `/path/to/script/` 替换为多云备份脚本所在的实际路径。
4. 保存并关闭文件。

现在，多云备份脚本将按照你设置的定时任务自动执行备份操作。你可以根据需要调整定时任务的配置，以满足你的特定需求。

请注意，定时执行任务是可选项，如果你不打算使用定时任务，仍然可以通过手动运行脚本来执行备份操作。
