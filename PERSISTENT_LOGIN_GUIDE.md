# دليل حفظ حالة تسجيل الدخول (Persistent Login)

## نظرة عامة

تم تنفيذ نظام حفظ حالة تسجيل الدخول في التطبيق بحيث لا يحتاج المستخدم لإعادة تسجيل الدخول في كل مرة يفتح فيها التطبيق. يتم حفظ بيانات الجلسة محلياً واستخدامها تلقائياً عند فتح التطبيق.

## الملفات المُحدثة

### 1. خدمة المصادقة الجديدة (`lib/services/auth_service.dart`)

#### الوظائف الرئيسية:
- **`isLoggedIn()`**: فحص حالة تسجيل الدخول
- **`getToken()`**: الحصول على رمز المصادقة المحفوظ
- **`saveLoginSession()`**: حفظ بيانات الجلسة بعد تسجيل الدخول
- **`getUserData()`**: الحصول على بيانات المستخدم المحفوظة
- **`logout()`**: تسجيل الخروج وحذف بيانات الجلسة
- **`verifyToken()`**: التحقق من صحة الرمز مع الخادم
- **`getAuthHeaders()`**: الحصول على headers المصادقة للطلبات
- **`isSessionValid()`**: فحص صحة الجلسة مع الخادم

#### البيانات المحفوظة:
```dart
static const String _tokenKey = 'auth_token';           // رمز المصادقة
static const String _userDataKey = 'user_data';         // بيانات المستخدم
static const String _loginStatusKey = 'is_logged_in';   // حالة تسجيل الدخول
```

### 2. شاشة البداية (`lib/splash_screen.dart`)

#### التحديثات:
- إضافة فحص حالة تسجيل الدخول تلقائياً
- التوجيه للصفحة المناسبة حسب حالة المستخدم:
  - **مسجل دخول**: الانتقال للصفحة الرئيسية
  - **غير مسجل**: الانتقال لصفحة تسجيل الدخول

```dart
Future<void> _checkLoginStatusAndNavigate() async {
  final isLoggedIn = await AuthService.isLoggedIn();
  
  if (isLoggedIn) {
    // الانتقال للصفحة الرئيسية
    Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (_) => const TravelHomePage()));
  } else {
    // الانتقال لصفحة تسجيل الدخول
    Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (_) => const LoginPage()));
  }
}
```

### 3. صفحة تسجيل الدخول (`lib/login_page.dart`)

#### التحديثات:
- استخدام `AuthService.saveLoginSession()` لحفظ بيانات الجلسة
- حفظ رمز المصادقة وبيانات المستخدم تلقائياً

```dart
final success = await AuthService.saveLoginSession(
  token: token,
  userData: userData,
);
```

### 4. صفحة الملف الشخصي (`lib/profile.dart`)

#### التحديثات:
- إضافة وظيفة تسجيل الخروج مع تأكيد
- حذف بيانات الجلسة والانتقال لصفحة تسجيل الدخول

```dart
Future<void> _handleLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(...); // تأكيد تسجيل الخروج
  
  if (shouldLogout == true) {
    final success = await AuthService.logout();
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
```

### 5. خدمة الحجوزات (`lib/services/reservation_service.dart`)

#### التحديثات:
- استخدام `AuthService` للحصول على headers المصادقة
- تبسيط إدارة الرموز المميزة

```dart
Future<Map<String, String>> get headers async {
  return await AuthService.getAuthHeaders();
}
```

## سير العمل (Workflow)

### 1. فتح التطبيق
```
التطبيق يبدأ
↓
SplashScreen يظهر
↓
فحص حالة تسجيل الدخول (AuthService.isLoggedIn())
↓
إذا مسجل دخول: الانتقال للصفحة الرئيسية
إذا غير مسجل: الانتقال لصفحة تسجيل الدخول
```

### 2. تسجيل الدخول
```
المستخدم يدخل البيانات
↓
إرسال طلب تسجيل الدخول للخادم
↓
الحصول على رمز المصادقة
↓
حفظ الرمز وبيانات المستخدم (AuthService.saveLoginSession())
↓
الانتقال للصفحة الرئيسية
```

### 3. استخدام التطبيق
```
طلبات API تلقائياً تتضمن رمز المصادقة
↓
إذا انتهت صلاحية الرمز (401/403)
↓
عرض رسالة انتهاء الجلسة
↓
الانتقال لصفحة تسجيل الدخول
```

### 4. تسجيل الخروج
```
المستخدم يضغط على تسجيل الخروج
↓
عرض تأكيد تسجيل الخروج
↓
حذف بيانات الجلسة (AuthService.logout())
↓
الانتقال لصفحة تسجيل الدخول
```

## الميزات الأمنية

### 1. حفظ آمن للبيانات
- استخدام `SharedPreferences` لحفظ البيانات محلياً
- تشفير البيانات الحساسة (يمكن إضافته لاحقاً)
- حذف تلقائي للبيانات عند تسجيل الخروج

### 2. التحقق من صحة الجلسة
- فحص وجود الرمز المميز
- التحقق من صحة الرمز مع الخادم (اختياري)
- معالجة انتهاء صلاحية الجلسة

### 3. إدارة الأخطاء
- معالجة أخطاء الشبكة
- معالجة انتهاء صلاحية الرمز
- رسائل واضحة للمستخدم

## مفاتيح الترجمة الجديدة

### الإنجليزية
```json
{
  "logout_confirmation": "Are you sure you want to logout?",
  "logout_success": "Logged out successfully"
}
```

### العربية
```json
{
  "logout_confirmation": "هل أنت متأكد من أنك تريد تسجيل الخروج؟",
  "logout_success": "تم تسجيل الخروج بنجاح"
}
```

## الاختبار

### حالات الاختبار
1. **تسجيل دخول جديد**: التأكد من حفظ البيانات
2. **إعادة فتح التطبيق**: التأكد من عدم طلب تسجيل الدخول مرة أخرى
3. **تسجيل الخروج**: التأكد من حذف البيانات
4. **انتهاء صلاحية الجلسة**: التأكد من التعامل الصحيح مع الأخطاء

### الاختبار اليدوي
1. سجل دخول بحساب صحيح
2. أغلق التطبيق وأعد فتحه
3. تأكد من عدم ظهور صفحة تسجيل الدخول
4. اضغط على تسجيل الخروج
5. تأكد من الانتقال لصفحة تسجيل الدخول

## التحسينات المستقبلية

### 1. الأمان
- تشفير البيانات المحفوظة محلياً
- استخدام Biometric Authentication
- تحديث تلقائي للرموز المميزة

### 2. تجربة المستخدم
- خيار "تذكرني" في صفحة تسجيل الدخول
- إعدادات مدة انتهاء الجلسة
- تسجيل دخول بصمة الإصبع/الوجه

### 3. الوظائف
- مزامنة البيانات عبر الأجهزة
- وضع عدم الاتصال
- إشعارات الجلسة

## استكشاف الأخطاء

### المشاكل الشائعة
1. **عدم حفظ حالة الدخول**: تحقق من صحة حفظ الرمز
2. **طلب تسجيل دخول متكرر**: تحقق من صحة فحص الحالة
3. **أخطاء API**: تحقق من صحة headers المصادقة

### التشخيص
```dart
// فحص حالة تسجيل الدخول
final isLoggedIn = await AuthService.isLoggedIn();
print('Is logged in: $isLoggedIn');

// فحص الرمز المحفوظ
final token = await AuthService.getToken();
print('Token: $token');

// فحص بيانات المستخدم
final userData = await AuthService.getUserData();
print('User data: $userData');
```
