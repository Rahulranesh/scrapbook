import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5DC),
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF8B4513),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5F5DC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfo(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Legal',
            children: [
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () => _showPrivacyPolicy(context),
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () => _showTermsOfService(context),
              ),
              _buildListTile(
                icon: Icons.gavel,
                title: 'Licenses',
                onTap: () => showLicensePage(context: context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Support',
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Help & FAQ',
                onTap: () => _showHelp(context),
              ),
              _buildListTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                onTap: _sendFeedback,
              ),
              _buildListTile(
                icon: Icons.star,
                title: 'Rate App',
                onTap: _rateApp,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Connect',
            children: [
              _buildListTile(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'www.memoraapp.com',
                onTap: () => _launchURL('https://www.memoraapp.com'),
              ),
              _buildListTile(
                icon: Icons.email,
                title: 'Contact Us',
                subtitle: 'support@memoraapp.com',
                onTap: () => _launchURL('mailto:support@memoraapp.com'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2026 Memora\nAll rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF8B4513).withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories,
              size: 50,
              color: Color(0xFFF5F5DC),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $_version',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8B4513).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create beautiful vintage-style scrapbooks to preserve your precious memories',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8B4513).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B4513).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
                fontFamily: 'serif',
              ),
            ),
          ),
          const Divider(
            color: Color(0xFF8B4513),
            height: 1,
            thickness: 1,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B4513)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B4513),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF8B4513).withOpacity(0.7),
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF8B4513),
      ),
      onTap: onTap,
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildLegalDialog(
        title: 'Privacy Policy',
        content: '''
Last updated: February 2026

1. Information We Collect
We collect information you provide directly to us when using Memora, including photos, notes, and other content you create.

2. How We Use Your Information
- To provide and maintain our service
- To improve and personalize your experience
- To communicate with you about updates and features

3. Data Storage
All your data is stored locally on your device. We do not collect or store your personal information on our servers.

4. Third-Party Services
We may use third-party services for analytics and crash reporting to improve our app.

5. Your Rights
You have the right to access, update, or delete your information at any time through the app settings.

6. Children's Privacy
Our service is not directed to children under 13. We do not knowingly collect information from children.

7. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy in the app.

8. Contact Us
If you have questions about this privacy policy, please contact us at support@memoraapp.com
''',
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildLegalDialog(
        title: 'Terms of Service',
        content: '''
Last updated: February 2026

1. Acceptance of Terms
By accessing and using Memora, you accept and agree to be bound by these Terms of Service.

2. Use License
We grant you a personal, non-transferable license to use the app for personal, non-commercial purposes.

3. User Content
You retain all rights to the content you create using our app. You are responsible for the content you upload and share.

4. Prohibited Uses
You may not use the app for any illegal or unauthorized purpose. You must not violate any laws in your jurisdiction.

5. Disclaimer
The app is provided "as is" without warranties of any kind, either express or implied.

6. Limitation of Liability
We shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the app.

7. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of modified terms.

8. Termination
We may terminate or suspend your access to the app immediately, without prior notice, for any breach of these Terms.

9. Governing Law
These Terms shall be governed by and construed in accordance with applicable laws.

10. Contact
For questions about these Terms, contact us at support@scrapbookmemories.com
''',
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildLegalDialog(
        title: 'Help & FAQ',
        content: '''
Frequently Asked Questions

Q: How do I create a new scrapbook?
A: Tap the "New Board" button on the home screen, enter a name, and choose a theme.

Q: How do I add items to my scrapbook?
A: Open a scrapbook and tap the "+" button in the top right corner. Choose from photos, notes, or stickers.

Q: Can I edit items after adding them?
A: Yes! Tap and hold any item to see editing options like duplicate, rotate, or delete.

Q: How do I export my scrapbook?
A: Tap the camera icon in the scrapbook to save it as an image to your gallery.

Q: Can I share my scrapbooks?
A: Yes! After exporting, you'll have the option to share via your device's share menu.

Q: How do I change the theme of a scrapbook?
A: Tap the edit icon (pencil) in the scrapbook and select a new theme.

Q: Where is my data stored?
A: All your data is stored locally on your device for privacy and security.

Q: How do I backup my scrapbooks?
A: Use the export feature to save your scrapbooks as images, which you can then backup to cloud storage.

Q: Can I use my own photos?
A: Yes! When adding a photo, you can choose from your device's gallery.

Q: How do I delete a scrapbook?
A: Long press on a scrapbook on the home screen and select "Delete" from the menu.

Need more help?
Contact us at support@scrapbookmemories.com
''',
      ),
    );
  }

  Widget _buildLegalDialog({
    required String title,
    required String content,
  }) {
    return Dialog(
      backgroundColor: const Color(0xFFF5F5DC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF8B4513), width: 3),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF8B4513),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5F5DC),
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFF5F5DC)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B4513),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    final uri = Uri.parse('mailto:support@scrapbookmemories.com?subject=Feedback');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _rateApp() async {
    // In production, this would open the app store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your support!'),
        backgroundColor: Color(0xFF8B4513),
      ),
    );
  }
}
