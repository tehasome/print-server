#!/bin/bash

echo "🛠️ เริ่มติดตั้ง Print Monitor..."

# STEP 0: ตรวจสอบ Node.js
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "🚧 ไม่พบ Node.js หรือ npm กำลังติดตั้ง..."
    sudo apt update
    sudo apt install -y nodejs npm
else
    echo "✅ พบ Node.js และ npm แล้ว"
fi

# STEP 1: Clone GitHub repo
if [ ! -d "print-monitor" ]; then
  git clone https://github.com/tehasome/print-server.git print-monitor
else
  echo "📁 โฟลเดอร์ print-monitor มีอยู่แล้ว"
fi

cd print-monitor || { echo "❌ ไม่พบโฟลเดอร์ print-monitor"; exit 1; }

# STEP 2: รับค่าเพื่อสร้างไฟล์ .env
echo "🌐 กำหนดค่า Webhook URL"
read -p "Webhook URL (เช่น http://your-laravel-server.com/api/printer-status-update): " WEBHOOK_URL
read -p "WEBHOOK_API_KEY: " WEBHOOK_API_KEY

cat <<EOF > .env
WEBHOOK_URL=$WEBHOOK_URL
WEBHOOK_API_KEY=$WEBHOOK_API_KEY
EOF
echo "✅ สร้างไฟล์ .env เรียบร้อย"

# STEP 3: ติดตั้ง dependencies
echo "📦 ติดตั้ง dependencies..."
npm install

# STEP 4: Run node index.js แบบ background
echo "🚀 เริ่มรัน Print Monitor แบบ background..."
nohup node index.js > print-monitor.log 2>&1 &

echo "✅ ติดตั้งเสร็จสิ้น! คุณสามารถดู log ได้ที่ print-monitor.log"
