import 'package:flutter/material.dart';

import 'package:hena_masr/core/constants/asset_paths.dart';
import 'package:hena_masr/core/theme/theme_context.dart';

/// About screen showcasing Hana Masr and official legal attribution for open datasets.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'عن التطبيق ومصادر البيانات' : 'About & Data Sources'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // App Logo & Branding Header
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(AssetPaths.appLogo, width: 90, height: 90),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'هنا مصر (Hana Masr)' : 'Hana Masr',
                  style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0+1 (Schema v2 - 2026.11)',
                  style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Section 1: Geographic Data Sources & Licences (Mandatory Attribution)
          Row(
            children: [
              Icon(Icons.map_rounded, color: context.hena.gold),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'مصادر البيانات الجغرافية والتراخيص' : 'Geographic Data Attribution',
                style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AttributionItem(
                    title: isArabic
                        ? 'الحدود الإدارية الرسمية (محافظات وأقسام ومراكز)'
                        : 'Egypt Subnational Administrative Boundaries (COD-AB)',
                    source: 'CAPMAS & OCHA via Humanitarian Data Exchange (HDX)',
                    licence: 'Creative Commons Attribution (CC BY-IGO)',
                  ),
                  const Divider(height: 24),
                  _AttributionItem(
                    title: isArabic
                        ? 'هيكلة المدن والمراكز والمدن الجديدة'
                        : 'Egypt Governorates, Cities & Villages Compilation',
                    source: 'Compiled by Zeyad Mohamed (v1.1.0) via GeoNames & OpenStreetMap',
                    licence: 'GeoNames (CC BY 4.0) & OpenStreetMap (ODbL)',
                  ),
                  const Divider(height: 24),
                  _AttributionItem(
                    title: isArabic
                        ? 'قناع حدود الدول المجاورة (Land Mask)'
                        : 'Neighboring Countries Land Mask',
                    source: 'Natural Earth GIS Project',
                    licence: 'Public Domain',
                  ),
                  const Divider(height: 24),
                  _AttributionItem(
                    title: isArabic
                        ? 'الوجهات والمعالم السياحية المنسقة (42 وجهة)'
                        : 'Curated Tourist Highlights (42 Destinations)',
                    source: 'Hana Masr Curated Field Database',
                    licence: 'Proprietary / In-house curation',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 2: Heritage Palette & Philosophy
          Row(
            children: [
              Icon(Icons.palette_outlined, color: context.hena.turquoiseText),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'هوية التصميم والتراث' : 'Heritage Design System',
                style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'لوحة ألوان مستوحاة من معادن وأصباغ الحضارة المصرية القديمة: الذهب المصري، وحجر اللازورد، والفيروز التركوازي، وحجر العقيق، وصخور البازلت والبردي.'
                : 'Colors inspired by authentic ancient Egyptian pigments: Egyptian Gold, Lapis Lazuli, Faience Turquoise, Carnelian, Papyrus, and Basalt.',
            style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AttributionItem extends StatelessWidget {
  const _AttributionItem({
    required this.title,
    required this.source,
    required this.licence,
  });

  final String title;
  final String source;
  final String licence;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Source: $source', style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5)),
        const SizedBox(height: 2),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            licence,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.brown),
          ),
        ),
      ],
    );
  }
}
