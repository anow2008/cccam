#!/bin/sh

# 1. تحديد المسار الصحيح لملف الـ CCcam
CCCAM_FILE="/etc/tuxbox/config/CCcam.cfg"

# 2. رابط الـ Raw للملف على جيت هاب اللي فيه السطور
URL="https://raw.githubusercontent.com/anow2008/cccam/main/server"

echo "-------------------------------------------------------"
echo "⬇️  جاري تحميل أسطر السيرفرات وتحديث الملف..."
echo "-------------------------------------------------------"

# 3. جلب الأسطر بالكامل من الرابط وتنظيفها من فواصل الويندوز (\r)
if command -v curl >/dev/null 2>&1; then
    SERVER_LINES=$(curl -k -sL --max-time 10 "$URL" | tr -d '\r')
else
    SERVER_LINES=$(wget --no-check-certificate -qO- --timeout=10 --tries=2 "$URL" | tr -d '\r')
fi

# التأكد من أن الرابط رجع ببيانات وليس فارغاً
if [ -z "$SERVER_LINES" ]; then
    echo "❌ فشل في الاتصال بـ GitHub أو الملف فارغ!"
    exit 1
fi

# 4. التأكد من وجود المجلد والملف في المسار المحدد، وإذا لم يكن موجوداً يتم إنشاؤه
mkdir -p "$(dirname "$CCCAM_FILE")"
if [ ! -f "$CCCAM_FILE" ]; then
    touch "$CCCAM_FILE"
fi

# 5. مسح المحتوى القديم بالكامل وكتابة السطور الجديدة صافي
echo "$SERVER_LINES" > "$CCCAM_FILE"

# 6. إعطاء الملف تصريح 644 عشان الإيمو يقراه فوراً
chmod 644 "$CCCAM_FILE"

echo "-------------------------------------------------------"
echo "✅ تم مسح القديم وتحديث ملف CCcam.cfg بالأسطر الجديدة!"
echo "📍 المسار: $CCCAM_FILE"
echo "-------------------------------------------------------"
