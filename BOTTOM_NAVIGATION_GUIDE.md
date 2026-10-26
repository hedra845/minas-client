# دليل استخدام Bottom Navigation Bar الموحد

## نظرة عامة

تم إنشاء `CustomBottomNavigationBar` widget موحد لجميع الصفحات في التطبيق مع دعم كامل للغة العربية والإنجليزية.

## المميزات

- **دعم متعدد اللغات**: يعرض النصوص باللغة العربية أو الإنجليزية تلقائياً
- **تصميم موحد**: نفس المظهر والسلوك في جميع الصفحات
- **تنقل سلس**: انتقال سريع بين الصفحات الرئيسية
- **دعم الثيمات**: يتكيف مع الثيم الفاتح والداكن

## كيفية الاستخدام

### 1. استيراد الـ Widget

```dart
import 'package:minas_client/widgets/custom_bottom_navigation.dart';
```

### 2. إضافة الـ Bottom Navigation Bar

```dart
bottomNavigationBar: CustomBottomNavigationBar(
  currentIndex: 0, // رقم الصفحة الحالية (0-4)
  onTap: (index) {
    if (index != 0) { // تجنب إعادة تحميل الصفحة الحالية
      BottomNavigationHelper.navigateToPage(context, index);
    }
  },
),
```

### 3. أرقام الصفحات

| الرقم | الصفحة | المسار |
|-------|---------|---------|
| 0 | الرئيسية | `/home` |
| 1 | الحجوزات | `/bookings` |
| 2 | العروض | `/offers` |
| 3 | الإيداع | `/form_deposit` |
| 4 | العضويات | `/membership` |

## مثال كامل

```dart
import 'package:flutter/material.dart';
import 'package:minas_client/widgets/custom_bottom_navigation.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('عنوان الصفحة')),
      body: Center(child: Text('محتوى الصفحة')),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // صفحة العروض
        onTap: (index) {
          if (index != 2) {
            BottomNavigationHelper.navigateToPage(context, index);
          }
        },
      ),
    );
  }
}
```

## التنقل المخصص

إذا كنت تريد تنقل مخصص، يمكنك استخدام `BottomNavigationHelper` مباشرة:

```dart
onTap: (index) {
  switch (index) {
    case 0:
      Navigator.pushReplacementNamed(context, '/home');
      break;
    case 1:
      Navigator.pushReplacementNamed(context, '/bookings');
      break;
    // ... باقي الحالات
  }
},
```

## دعم اللغة

الـ widget يستخدم ملفات الترجمة الموجودة في:
- `assets/translations/ar.json` للعربية
- `assets/translations/en.json` للإنجليزية

النصوص المدعومة:
- `home` → الرئيسية / Home
- `bookings` → الحجوزات / Bookings
- `offers` → العروض / Offers
- `deposit` → الإيداع / Deposit
- `membership` → العضويات / Membership

## التخصيص

يمكنك تخصيص الألوان والأيقونات من خلال تعديل:
- `lib/widgets/custom_bottom_navigation.dart`
- `lib/theme/app_theme.dart`

## ملاحظات مهمة

1. تأكد من أن `currentIndex` صحيح لكل صفحة
2. استخدم `if (index != currentIndex)` لتجنب إعادة تحميل الصفحة الحالية
3. تأكد من وجود جميع ملفات الأيقونات في `assets/images/`
4. تأكد من وجود جميع مفاتيح الترجمة في ملفات اللغة
