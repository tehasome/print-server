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

# STEP 4: ติดตั้ง PM2 ถ้ายังไม่มี
if ! command -v pm2 &> /dev/null; then
    echo "🚧 กำลังติดตั้ง pm2..."
    sudo npm install -g pm2
fi

# STEP 5: สั่งรันด้วย pm2
echo "🚀 รันแอปด้วย pm2..."
pm2 start index.js --name print-monitor --env production

# STEP 6: ตั้งให้ pm2 auto-restart หลังบูตเครื่อง
pm2 startup systemd -u $USER --hp $HOME | bash
pm2 save

echo "🎉 ติดตั้งเสร็จสิ้น! แอปกำลังรันอยู่ 🎯"
echo "📊 ตรวจสอบสถานะ: pm2 status"
echo "📜 ดู log: pm2 logs print-monitor"
