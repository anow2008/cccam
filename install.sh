#!/bin/sh

# 1. مسار ملف الـ CCcam
CCCAM_FILE="/etc/tuxbox/config/CCcam.cfg"

# 2. رابط الـ Raw لجيت هاب
URL="https://raw.githubusercontent.com/anow2008/cccam/main/server"

echo "-------------------------------------------------------"
echo "⬇️  جاري جلب سطر الـ CCcam من GitHub..."
echo "-------------------------------------------------------"

# 3. محاولة سحب السطر مع تخطي فحص شهادات الأمان (SSL) لتفادي مشاكل الصور القديمة
if command -v curl >/dev/null 2>&1; then
    SERVER_LINE=$(curl -k -sL --max-time 10 "$URL" | head -n 1 | tr -d '\r\n' | xargs)
elif command -v wget >/dev/null 2>&1; then
    SERVER_LINE=$(wget --no-check-certificate -qO- --timeout=10 --tries=2 "$URL" | head -n 1 | tr -d '\r\n' | xargs)
fi

# لو الطرق العادية منجحتش، محاولة باستخدام wget المدمج في busybox بشكل مباشر
if [ -z "$SERVER_LINE" ]; then
    SERVER_LINE=$(wget -qO- "$URL" 2>/dev/null | head -n 1 | tr -d '\r\n' | xargs)
fi

# التأكد من أن السكربت نجح في سحب السطر ولم يرجع فارغاً
if [ -z "$SERVER_LINE" ]; then
    echo "❌ خطأ: لم يتم سحب أي بيانات!"
    echo "تأكد من أن الرسيفر متصل بالإنترنت، أو جرب تشغيل الأمر يدوياً."
    exit 1
fi

# 4. التأكد من وجود الفولدر والملف
mkdir -p "$(dirname "$CCCAM_FILE")"
if [ ! -f "$CCCAM_FILE" ]; then
    touch "$CCCAM_FILE"
fi

# 5. كتابة السطر في نهاية الملف
echo "$SERVER_LINE" >> "$CCCAM_FILE"

# 6. ضبط التصاريح
chmod 644 "$CCCAM_FILE"

echo "-------------------------------------------------------"
echo "✅ تم بنجاح!"
echo "✨ السطر المضاف: $SERVER_LINE"
echo "📍 المسار: $CCCAM_FILE"
echo "-------------------------------------------------------"
