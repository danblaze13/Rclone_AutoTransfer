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
  local info_message="从 $source 到 $target"

  # 记录备份开始时间
  local start_time=$(date +%Y%m%d%H%M%S)
  echo "[${start_time}] 开始备份 $info_message" >> $log_file
  send_telegram "🚀开始备份 $info_message"

  # 检查源和目标是否一致
  DIFF=$(rclone check "$source" "$target" --quiet)
  if [ -z "$DIFF" ]; then
    echo "[${start_time}] 源和目标一致，无需备份 $info_message" >> $log_file
    send_telegram "✅源和目标一致，无需备份 $info_message"
    return 0
  fi

  # 执行备份操作并获取传输的数据量
  transfer_info=$(rclone copy "$source" "$target" --bwlimit "$SPEED" --max-transfer "$DAILY_LIMIT" -v --progress --drive-chunk-size=128M --buffer-size=128M --transfers 8 | tee -a $log_file | grep 'Transferred:')

  # 记录备份结束时间
  local end_time=$(date +%Y%m%d%H%M%S)
  
  if [ $? -eq 0 ]; then
    echo "[${end_time}] 备份完成 $info_message\n$transfer_info" >> $log_file
    send_telegram "✅备份完成 $info_message\n$transfer_info"
  else
    echo "[${end_time}] 备份失败 $info_message" >> $log_file
    send_telegram "❌备份失败 $info_message，请检查日志以获取更多信息。"
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
  local end_time=$(date +%Y%m%d%H%M%S)
  echo "[${end_time}] 关闭脚本..." >> $log_file
  send_telegram "🚀脚本已关闭"
  pkill -f "$process_name"
  sleep 5
  exit 0
}

# 开始执行备份操作
echo "[$(date +%Y%m%d%H%M%S)] 执行备份操作..." >> $log_file
backup "$source" "$target"
