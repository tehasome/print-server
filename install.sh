#!/bin/bash

echo "🛠️ เริ่มติดตั้ง Print Monitor..."

# 🧱 STEP 1: Clone โปรเจกต์จาก GitHub
read -p "📦 ใส่ URL GitHub Repository (HTTPS): " GIT_REPO
git clone "$GIT_REPO" print-monitor
cd print-monitor || { echo "❌ ไม่พบโฟลเดอร์ print-monitor"; exit 1; }

# 🧾 STEP 2: รับค่าจากผู้ใช้เพื่อสร้างไฟล์ .env
echo "🌐 กำหนดค่าเชื่อมต่อกับ CUPS Server"
read -p "🖨️ IP หรือ URL ของ CUPS Server (เช่น http://192.168.1.100:631): " cups_url
read -p "🌐 PORT ของ Node.js ที่ต้องการรัน (default 3000): " port

# ถ้ายังไม่พิมพ์ port ให้ใช้ 3000
if [ -z "$port" ]; then
  port=3000
fi

# ✍️ สร้างไฟล์ .env
cat <<EOF > .env
PORT=$port
CUPS_SERVER=$cups_url
EOF

echo "✅ สร้างไฟล์ .env เรียบร้อย"

# 🐳 STEP 3: Build Docker container
echo "⚙️ สร้าง Docker image..."
docker build -t print-monitor .

# 🏃 STEP 4: Run Container
echo "🚀 เริ่มรัน Print Monitor บน port $port ..."
docker run -d --name print-monitor -p $port:$port --env-file .env print-monitor

echo "🎉 ติดตั้งเสร็จสมบูรณ์! เปิดใช้งานที่ http://localhost:$port/jobs"
