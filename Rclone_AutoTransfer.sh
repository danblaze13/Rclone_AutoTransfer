#!/bin/bash

# 设置进程名称
process_name="Rclone_AutoTransfer"

# 定义源路径和目标路径
source="source:/" # 示例 "GD:"
target="target:Target" # 示例 "DP:"

# 传输速度和每日传输限额
SPEED="speed" # 示例 "100M"
DAILY_LIMIT="limit" # 示例 "100G"

# 电报机器人 API
telegram_bot_token="telegram_bot_token"
telegram_chat_id="telegram_chat_id"

# 日志文件目录
log_dir="/path/to/log" # 示例 /path/to/log

# 获取 rclone rc 服务的进程ID
rcd_pid=$!

# 备份操作函数
backup() {
  local source=$1
  local target=$2

  # 创建新的日志文件
  local current_time=$(date "+%Y.%m.%d-%H.%M.%S")
  local log_file="${log_dir}/rclone_script_${current_time}.log"

  # 发送开始备份的消息，并保存API响应
  local response=$(send_telegram "🚀开始备份从 $source 到 $target")
  # 从响应中解析出消息ID
  local message_id=$(echo "$response" | jq -r '.result.message_id')

  # 启动后台任务，定期更新电报消息
  while true; do
    sleep 10
    local transferred=$(get_transferred_data)
    update_telegram "$message_id" "🔄备份中，已传输：$transferred GiB"
  done &

  # 获取 rclone copy 的进程ID
  stats_pid=$!

  # 执行备份操作，添加更全面的错误处理
  rclone copy "$source" "$target" --bwlimit "$SPEED" --max-transfer "$DAILY_LIMIT" -v --progress --drive-chunk-size=128M --buffer-size=128M --transfers 8 --log-file "$log_file" --rc --rc-addr :5573 || {
    # 记录错误信息
    echo "备份失败，错误信息如下：" >> "$log_file"
    echo "$?" >> "$log_file"

    # 结束后台任务
    kill $stats_pid

    # 发送备份失败的通知
    update_telegram "$message_id" "❌备份失败从 $source 到 $target，请检查日志以获取更多信息。"
    exit 1
  }

  # 结束后台任务
  kill $stats_pid

  # 发送备份完成的通知，并附上已传输的数据量
  local transferred=$(get_transferred_data)
  update_telegram "$message_id" "✅备份完成从 $source 到 $target，共传输了 $transferred 数据。"
}

# 发送电报通知的函数
send_telegram() {
  local message=$1
  local response=$(curl -s -X POST https://api.telegram.org/bot$telegram_bot_token/sendMessage -d chat_id=$telegram_chat_id -d text="$message")
  echo "$response"
}

# 更新电报消息的函数
update_telegram() {
  local message_id=$1
  local message=$2
  curl -s -X POST https://api.telegram.org/bot$telegram_bot_token/editMessageText -d chat_id=$telegram_chat_id -d message_id="$message_id" -d text="$message" > /dev/null
}

# 统计传输的数据量
get_transferred_data() {
  local response=$(rclone rc --rc-addr :5573 core/stats)
  local transferred=$(echo "$response" | jq -r '.bytes')
  transferred=$(awk "BEGIN {print $transferred/1024/1024/1024}")
  echo "$transferred"  # 返回结果
}

# 注册信号处理程序，当接收到SIGTERM信号时关闭脚本
trap 'close_script' SIGTERM

# 关闭脚本的函数，增加发送关闭通知的步骤
close_script() {
  echo "关闭脚本..."
  pkill -f "$process_name"
  sleep 5
  # 发送脚本关闭的通知
  send_telegram "🛑脚本已关闭。"
  # 当 rclone copy 完成后，停止 rclone rc 服务
  kill ${rcd_pid}
  exit 0
}

# 执行备份操作
backup "$source" "$target"

# 当触发当日备份限额时，发送通知，同时增加已传输的数据量
if [ $? -eq 100 ]; then
  local transferred=$(get_transferred_data)
  send_telegram "⛔当日备份限额已达到，备份已停止。已传输 $transferred 数据，等待下次备份开始。"
fi
