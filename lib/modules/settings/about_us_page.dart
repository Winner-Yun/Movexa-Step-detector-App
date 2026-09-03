import 'package:flutter/material.dart';
import 'package:step_detector/core/localization/app_translations.dart';
import 'package:step_detector/core/theme/theme_colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ThemeColors.getScaffold(context),
      appBar: AppBar(
        backgroundColor: ThemeColors.getScaffold(context),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: ThemeColors.getText(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'aboutUs'.tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: ThemeColors.getText(context),
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,

              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset('assets/Movexa.png', fit: BoxFit.fill),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Movexa',
              style: textTheme.headlineMedium?.copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 0.1.0',
              style: textTheme.bodyMedium?.copyWith(
                color: ThemeColors.getMutedText(context),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context: context,
              title: 'ភាសាខ្មែរ',
              content:
                  'Movexa គឺជាកម្មវិធីរាប់ជំហានដ៏សាមញ្ញ និងមានប្រយោជន៍ ដែលបង្កើតឡើងសម្រាប់ការកម្សាន្ត និងការប្រើប្រាស់ប្រចាំថ្ងៃ។ វាជួយអ្នកតាមដានចំនួនជំហានដែលអ្នកបានដើរក្នុងមួយថ្ងៃ និងមើលសកម្មភាពរបស់អ្នកបានយ៉ាងងាយស្រួល។\n\n'
                  'Movexa គឺជាកម្មវិធី ឥតគិតថ្លៃ និងគ្មានការផ្សព្វផ្សាយពាណិជ្ជកម្ម។ យើងបង្កើតកម្មវិធីនេះឡើង ដើម្បីផ្តល់នូវបទពិសោធន៍ប្រើប្រាស់ដ៏សាមញ្ញ និងមិនមានការរំខានដែលមិនចាំបាច់។\n\n'
                  'Movexa ត្រូវបានបង្កើតឡើងដោយ Winner Yun ក្នុងឆ្នាំ 2026 ជាផ្នែកមួយនៃ Khansha Team។',
            ),
            const SizedBox(height: 24),
            _buildContactSection(
              context: context,
              title: 'ទំនាក់ទំនង',
              phone: '+855 81 513 746',
              email: 'winnerlegendpvh1426@gmail.com',
              facebook: 'Winner Yun',
              slogan: 'Movexa: ជំហានសាមញ្ញ ការតាមដានមានប្រយោជន៍។',
            ),

            const SizedBox(height: 32),
            Divider(color: ThemeColors.getScaffoldSoft(context)),
            const SizedBox(height: 32),

            _buildSection(
              context: context,
              title: 'English',
              content:
                  'Movexa is a simple and useful step detector created for fun and everyday use. It helps you track your daily steps and keep an eye on your activity in an easy and convenient way.\n\n'
                  'Movexa is completely free to use with no advertisements. We created it to provide a simple experience without unnecessary distractions.\n\n'
                  'Movexa was created by Winner Yun in 2026 as part of the Khansha Team.',
            ),
            const SizedBox(height: 24),
            _buildContactSection(
              context: context,
              title: 'Contact Us',
              phone: '+855 81 513 746',
              email: 'winnerlegendpvh1426@gmail.com',
              facebook: 'Winner Yun',
              slogan: 'Movexa: Simple steps, useful tracking.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: ThemeColors.getBrandAccent(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: ThemeColors.getText(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection({
    required BuildContext context,
    required String title,
    required String phone,
    required String email,
    required String facebook,
    required String slogan,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getText(context).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(context, Icons.phone_rounded, phone),
          const SizedBox(height: 12),
          _buildContactRow(context, Icons.email_rounded, email),
          const SizedBox(height: 12),
          _buildContactRow(context, Icons.facebook_rounded, facebook),
          const SizedBox(height: 16),
          Divider(color: ThemeColors.getScaffoldSoft(context)),
          const SizedBox(height: 12),
          Text(
            slogan,
            style: textTheme.bodySmall?.copyWith(
              color: ThemeColors.getBrandAccent(context),
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ThemeColors.getMutedText(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getText(context),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
