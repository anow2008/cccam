#!/bin/sh

# 1. تحديد المسار الصحيح لملف الـ CCcam
CCCAM_FILE="/etc/tuxbox/config/CCcam.cfg"

# 2. رابط الـ Raw للملف على جيت هاب اللي فيه السطر
URL="https://raw.githubusercontent.com/anow2008/cccam/main/server"

echo "-------------------------------------------------------"
echo "⬇️  جاري تحميل سطر السيرفر من GitHub..."
echo "-------------------------------------------------------"

# 3. جلب السطر مباشرة من الرابط وتخزينه في متغير وتنظيفه تماماً
if command -v curl >/dev/null 2>&1; then
    SERVER_LINE=$(curl -k -sL --max-time 10 "$URL" | head -n 1 | tr -d '\r\n' | xargs)
else
    SERVER_LINE=$(wget --no-check-certificate -qO- --timeout=10 --tries=2 "$URL" | head -n 1 | tr -d '\r\n' | xargs)
fi

# التأكد من أن الرابط رجع ببيانات وليس فارغاً
if [ -z "$SERVER_LINE" ]; then
    echo "❌ فشل في الاتصال بـ GitHub أو الملف فارغ!"
    exit 1
fi

# 4. التأكد من وجود المجلد والملف في المسار المحدد، وإذا لم يكن موجوداً يتم إنشاؤه
mkdir -p "$(dirname "$CCCAM_FILE")"
if [ ! -f "$CCCAM_FILE" ]; then
    touch "$CCCAM_FILE"
fi

# 5. كتابة السطر داخل الملف (إضافة في نهاية الملف بدون مسح محتوياته القديمة)
echo "$SERVER_LINE" >> "$CCCAM_FILE"

# 6. إعطاء الملف تصريح 644 عشان الإيمو يقراه فوراً
chmod 644 "$CCCAM_FILE"

echo "-------------------------------------------------------"
echo "✅ تم بنجاح كتابة السطر داخل ملف CCcam.cfg"
echo "✨ السطر المضاف: $SERVER_LINE"
echo "📍 المسار الجديد: $CCCAM_FILE"
echo "-------------------------------------------------------"
