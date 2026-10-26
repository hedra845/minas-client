import 'package:flutter/material.dart';
import 'package:minas_client/constans/colors.dart';
import 'package:minas_client/providers/language_provider.dart';
import 'package:provider/provider.dart';

// Membership Package Feature Model
class MembershipFeature {
  final String descriptionAr;
  final String descriptionEn;
  final bool isHighlighted;

  MembershipFeature({
    required this.descriptionAr,
    required this.descriptionEn,
    required this.isHighlighted,
  });
}

// Membership Package Model
class MembershipPackage {
  final String nameAr;
  final String nameEn;
  final String color;
  final String textColor;
  final String iconColor;
  final String checkmarkColor;
  final String checkmarkBgColor;
  final bool isPopular;
  final List<MembershipFeature> features;

  MembershipPackage({
    required this.nameAr,
    required this.nameEn,
    required this.color,
    required this.textColor,
    required this.iconColor,
    required this.checkmarkColor,
    required this.checkmarkBgColor,
    required this.isPopular,
    required this.features,
  });
}

// Sample Data
class MembershipPackagesData {
  static final List<MembershipPackage> packages = [
    MembershipPackage(
      nameAr: 'الباقة الأساسية',
      nameEn: 'Basic Package',
      color: '#21205d',
      textColor: '#ffffff',
      iconColor: '#ffffff',
      checkmarkColor: '#ffffff',
      checkmarkBgColor: '#ffffff30',
      isPopular: false,
      features: [
        MembershipFeature(
          descriptionAr: 'تسجيل مجاني دائم',
          descriptionEn: 'Free registration forever',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'دعم فني 24/7',
          descriptionEn: '24/7 technical support',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'إرسال العروض على الواتساب والإيميل',
          descriptionEn: 'Send offers via WhatsApp and email',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'تحديثات شهرية',
          descriptionEn: 'Monthly updates',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'احجز من 51-100 خدمة واحصل على خصم 10%',
          descriptionEn: 'Book 51-100 services and get 10% discount',
          isHighlighted: true,
        ),
      ],
    ),
    MembershipPackage(
      nameAr: 'الباقة الفضية',
      nameEn: 'Silver Package',
      color: '#a4a4a4',
      textColor: '#03003e',
      iconColor: '#03003e',
      checkmarkColor: '#03003e',
      checkmarkBgColor: '#03003e30',
      isPopular: true,
      features: [
        MembershipFeature(
          descriptionAr: 'تسجيل مجاني دائم',
          descriptionEn: 'Free registration forever',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'دعم فني 24/7',
          descriptionEn: '24/7 technical support',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'إرسال العروض على الواتساب والإيميل',
          descriptionEn: 'Send offers via WhatsApp and email',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'تحديثات شهرية',
          descriptionEn: 'Monthly updates',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'احجز من 21-50 خدمة واحصل على خصم 20%',
          descriptionEn: 'Book 21-50 services and get 20% discount',
          isHighlighted: true,
        ),
        MembershipFeature(
          descriptionAr: 'ترقية درجة الحجز مرة واحدة فقط',
          descriptionEn: 'Upgrade booking class once only',
          isHighlighted: true,
        ),
      ],
    ),
    MembershipPackage(
      nameAr: 'الباقة الذهبية',
      nameEn: 'Gold Package',
      color: '#f3b858',
      textColor: '#03003e',
      iconColor: '#03003e',
      checkmarkColor: '#03003e',
      checkmarkBgColor: '#03003e30',
      isPopular: false,
      features: [
        MembershipFeature(
          descriptionAr: 'تسجيل مجاني دائم',
          descriptionEn: 'Free registration forever',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'دعم فني 24/7',
          descriptionEn: '24/7 technical support',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'إرسال العروض على الواتساب والإيميل',
          descriptionEn: 'Send offers via WhatsApp and email',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'تحديثات شهرية',
          descriptionEn: 'Monthly updates',
          isHighlighted: false,
        ),
        MembershipFeature(
          descriptionAr: 'احجز من 51-100 خدمة واحصل على خصم 30%',
          descriptionEn: 'Book 51-100 services and get 30% discount',
          isHighlighted: true,
        ),
        MembershipFeature(
          descriptionAr: 'حجز فندق مجاني لمرة واحدة',
          descriptionEn: 'Free hotel booking once',
          isHighlighted: true,
        ),
        MembershipFeature(
          descriptionAr: 'استقبال في المطار لمرة واحدة',
          descriptionEn: 'Airport pickup once',
          isHighlighted: true,
        ),
      ],
    ),
  ];
}

class MembershipPackagesWidget extends StatelessWidget {
  final Function(MembershipPackage)? onPackageSelected;

  const MembershipPackagesWidget({super.key, this.onPackageSelected});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    final packages = MembershipPackagesData.packages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            isArabic ? 'باقات العضوية' : 'Membership Packages',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // First row - Basic and Silver packages
        Row(
          children: [
            Expanded(
              child: _buildPackageCard(
                context,
                packages[0], // Basic Package
                isArabic,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPackageCard(
                context,
                packages[1], // Silver Package
                isArabic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Second row - Gold package (centered)
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: _buildPackageCard(
              context,
              packages[2], // Gold Package
              isArabic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    MembershipPackage package,
    bool isArabic,
  ) {
    final packageColor = Color(
      int.parse(package.color.replaceFirst('#', '0xff')),
    );
    final textColor = Color(
      int.parse(package.textColor.replaceFirst('#', '0xff')),
    );
    final iconColor = Color(
      int.parse(package.iconColor.replaceFirst('#', '0xff')),
    );
    final checkmarkColor = Color(
      int.parse(package.checkmarkColor.replaceFirst('#', '0xff')),
    );
    final checkmarkBgColor = Color(
      int.parse(package.checkmarkBgColor.replaceFirst('#', '0xff')),
    );

    return GestureDetector(
      onTap: () => onPackageSelected?.call(package),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: packageColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and title
            Row(
              children: [
                // Logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? package.nameAr : package.nameEn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (package.isPopular)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isArabic ? 'الأكثر شعبية' : 'Most Popular',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Star icon
                Icon(Icons.star, color: iconColor, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            // Features list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: package.features.length,
                itemBuilder: (context, index) {
                  final feature = package.features[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkmark icon
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: checkmarkBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: checkmarkColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Feature text
                        Expanded(
                          child: Text(
                            isArabic
                                ? feature.descriptionAr
                                : feature.descriptionEn,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight:
                                  feature.isHighlighted
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Footer with MINAS logo
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MINAS',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative layout for mobile - single column
class MembershipPackagesMobileWidget extends StatelessWidget {
  final Function(MembershipPackage)? onPackageSelected;

  const MembershipPackagesMobileWidget({super.key, this.onPackageSelected});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.isArabic;
    final packages = MembershipPackagesData.packages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            isArabic ? 'باقات العضوية' : 'Membership Packages',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Single column layout for mobile
        ...packages
            .map(
              (package) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPackageCard(context, package, isArabic),
              ),
            )
            ,
      ],
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    MembershipPackage package,
    bool isArabic,
  ) {
    final packageColor = Color(
      int.parse(package.color.replaceFirst('#', '0xff')),
    );
    final textColor = Color(
      int.parse(package.textColor.replaceFirst('#', '0xff')),
    );
    final iconColor = Color(
      int.parse(package.iconColor.replaceFirst('#', '0xff')),
    );
    final checkmarkColor = Color(
      int.parse(package.checkmarkColor.replaceFirst('#', '0xff')),
    );
    final checkmarkBgColor = Color(
      int.parse(package.checkmarkBgColor.replaceFirst('#', '0xff')),
    );

    return GestureDetector(
      onTap: () => onPackageSelected?.call(package),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: packageColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and title
            Row(
              children: [
                // Logo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? package.nameAr : package.nameEn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (package.isPopular)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isArabic ? 'الأكثر شعبية' : 'Most Popular',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Star icon
                Icon(Icons.star, color: iconColor, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            // Features list
            ...package.features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkmark icon
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: checkmarkBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: checkmarkColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Feature text
                        Expanded(
                          child: Text(
                            isArabic
                                ? feature.descriptionAr
                                : feature.descriptionEn,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight:
                                  feature.isHighlighted
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                ,
            const SizedBox(height: 16),
            // Footer with MINAS logo
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MINAS',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
