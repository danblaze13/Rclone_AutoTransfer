#!/bin/bash

# 设置进程名称
process_name="Rclone_AutoTransfer"

# 定义源路径和目标路径
source="" # 示例 "GD:"
target="" # 示例 "DP:"

# 传输速度和每日传输限额
SPEED="" # 示例 "100M"
DAILY_LIMIT="" # 示例 "100G"

# 电报机器人 API
telegram_bot_token=""
telegram_chat_id=""

# 日志文件路径
log_file="" # 示例 /path/rclone_script.log 确保这个路径是存在的

# 备份操作函数
backup() {
  local source=$1
  local target=$2

  send_telegram "🚀开始备份从 $source 到 $target"
  echo "开始备份从 $source 到 $target" >> $log_file

  # 执行备份操作
  rclone copy "$source" "$target" --bwlimit "$SPEED" --max-transfer "$DAILY_LIMIT" -v --progress --drive-chunk-size=128M --buffer-size=128M --transfers 8

  if [ $? -eq 0 ]; then
    send_telegram "✅备份完成从 $source 到 $target"
    echo "备份完成从 $source 到 $target" >> $log_file
  else
    send_telegram "❌备份失败从 $source 到 $target，请检查日志以获取更多信息。"
    echo "备份失败从 $source 到 $target" >> $log_file
  fi
}

# 发送电报通知的函数
send_telegram() {
  local message=$1
  curl -s -X POST https://api.telegram.org/bot$telegram_bot_token/sendMessage -d chat_id=$telegram_chat_id -d text="$message" > /dev/null
}

# 注册信号处理程序，当接收到SIGTERM信号时关闭脚本
trap 'close_script' SIGTERM

# 关闭脚本
close_script() {
  echo "关闭脚本..."
  pkill -f "$process_name"
  sleep 5
  exit 0
}

# 执行备份操作
backup "$source" "$target"

# 当触发当日备份限额时，发送通知
if [ $? -eq 100 ]; then
  send_telegram "⛔当日备份限额已达到，备份已停止。等待下次备份开始。"
  echo "当日备份限额已达到，备份已停止。等待下次备份开始。" >> $log_file
fi
