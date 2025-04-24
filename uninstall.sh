#!/bin/bash

APP_NAME="print-monitor"
APP_DIR="$HOME/print-monitor"

echo "🧹 เริ่มลบ Print Monitor ($APP_NAME)"

# 1. หยุดและลบ PM2 App
if command -v pm2 &> /dev/null; then
    echo "🛑 หยุดแอปจาก pm2..."
    pm2 stop $APP_NAME 2>/dev/null
    pm2 delete $APP_NAME 2>/dev/null
    pm2 save
else
    echo "⚠️ ไม่พบ pm2 ข้ามขั้นตอนการหยุด"
fi

# 2. ลบโฟลเดอร์โปรเจกต์
if [ -d "$APP_DIR" ]; then
    echo "🗑️ ลบโฟลเดอร์ $APP_DIR"
    rm -rf "$APP_DIR"
else
    echo "📁 ไม่พบโฟลเดอร์ $APP_DIR แล้ว"
fi

# 3. ถามผู้ใช้ว่าต้องการลบ global PM2 หรือไม่
read -p "❓ ต้องการลบ pm2 ออกจากระบบด้วยหรือไม่? (y/N): " REMOVE_PM2
if [[ "$REMOVE_PM2" =~ ^[Yy]$ ]]; then
    echo "🧽 กำลังลบ pm2..."
    sudo npm uninstall -g pm2
fi

echo "✅ ลบ Print Monitor สำเร็จแล้ว!"
