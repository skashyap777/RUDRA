import 'package:flutter/material.dart';

/// Generic reusable screen for displaying static text content (About, T&C, Privacy Policy)
class InfoScreen extends StatelessWidget {
  final String title;
  final List<InfoSection> sections;

  const InfoScreen({super.key, required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.heading != null) ...[
                  Text(
                    section.heading!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A237E),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  section.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    height: 1.65,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoSection {
  final String? heading;
  final String body;
  const InfoSection({this.heading, required this.body});
}

// ─────────────────────────────────────────────────────────────────────────────
// Content definitions
// ─────────────────────────────────────────────────────────────────────────────

class AboutPWDScreen extends StatelessWidget {
  const AboutPWDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScreen(
      title: 'About PWD Assam Initiative',
      sections: [
        InfoSection(
          heading: 'About RUDRA',
          body:
              'RUDRA is an initiative by the Public Works Department (PWD), Assam aimed at empowering citizens to actively participate in improving road infrastructure.\n\n'
              'By providing a simple and transparent platform for reporting potholes and road defects, the application helps bridge the gap between the public and government authorities.\n\n'
              'Through real-time reporting, geo-tagging, and efficient case management, RUDRA enables faster identification and resolution of road issues.\n\n'
              'This initiative reflects PWD, Assam\'s commitment to leveraging technology for better public services, safer roads, and more responsive infrastructure maintenance.',
        ),
      ],
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScreen(
      title: 'Terms & Conditions',
      sections: [
        InfoSection(
          heading: 'Terms and Conditions – RUDRA Application',
          body:
              'Welcome to RUDRA – Road User Defect Reporting Application, developed and managed by the Public Works Department (PWD), Assam. By accessing or using the RUDRA mobile application, you agree to comply with and be bound by the following Terms and Conditions. If you do not agree with these terms, please do not use the application.',
        ),
        InfoSection(
          heading: '1. Purpose of the Application',
          body:
              'RUDRA is a citizen reporting platform designed to enable users to report potholes and road defects to PWD, Assam. The application allows users to capture images, tag locations, and submit reports so that authorities can review and address the issues.\n\n'
              'The application is intended to improve road maintenance efficiency and encourage citizen participation in reporting infrastructure issues.',
        ),
        InfoSection(
          heading: '2. User Registration',
          body:
              'To use certain features of the RUDRA application, users must register using a valid mobile phone number. By registering, you agree that:\n\n'
              '• The phone number provided belongs to you.\n'
              '• The number may be used for authentication, verification, and communication related to your submitted reports.\n'
              '• The department may send OTP verification messages or service-related notifications.\n\n'
              'Users are responsible for maintaining the confidentiality of their account and for any activity performed through their registered number.',
        ),
        InfoSection(
          heading: '3.1 Location Access',
          body:
              'The application collects your location at the time of submitting a pothole report to accurately identify the affected road segment. Location data is used solely for:\n\n'
              '• Geo-tagging reported defects\n'
              '• Routing the report to the appropriate PWD, Assam authority\n'
              '• Improving maintenance response\n\n'
              'The application does not continuously track your location.',
        ),
        InfoSection(
          heading: '3.2 Camera Access',
          body:
              'The application requires camera permission so that users can capture photographs of potholes or road defects. These photographs are used to:\n\n'
              '• Provide visual evidence of the issue\n'
              '• Assist authorities in assessing the severity of the defect\n'
              '• Verify the authenticity of the report\n\n'
              'Photos submitted through the application become part of the official reporting system.',
        ),
        InfoSection(
          heading: '4. User Responsibilities',
          body:
              'Users agree to:\n\n'
              '• Submit accurate and genuine reports of road defects.\n'
              '• Avoid submitting false, misleading, or malicious reports.\n'
              '• Refrain from uploading inappropriate, offensive, or unrelated images.\n'
              '• Use the application only for its intended purpose.\n\n'
              'Any misuse of the application may result in restriction or suspension of access.',
        ),
        InfoSection(
          heading: '5. Data Usage',
          body:
              'Information collected through the application may include:\n\n'
              '• Mobile phone number\n'
              '• Reported location\n'
              '• Photographs submitted\n'
              '• Report details and timestamps\n\n'
              'This information is used strictly for processing and managing road defect reports, improving public infrastructure services, and administrative and operational purposes within PWD, Assam.\n\n'
              'The department will take reasonable measures to protect user data and ensure secure handling of information.',
        ),
        InfoSection(
          heading: '6. Report Processing',
          body:
              'Once a report is submitted, it is automatically geo-tagged and routed to the relevant PWD, Assam authority. Authorities will review and process the report based on priority, feasibility, and available resources.\n\n'
              'Submission of a report does not guarantee immediate action or repair. Users may track the progress of their reports through the Reports tab within the application.',
        ),
        InfoSection(
          heading: '9. Termination of Access',
          body:
              'The department may restrict or terminate user access if:\n\n'
              '• The application is misused\n'
              '• False or inappropriate reports are submitted\n'
              '• Terms and conditions are violated',
        ),
        InfoSection(
          heading: '10. Governing Authority',
          body:
              'The RUDRA application is operated under the authority of the Public Works Department (PWD), Assam and is governed by the applicable laws and regulations of the jurisdiction in which the department operates.',
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoScreen(
      title: 'Privacy Policy',
      sections: [
        InfoSection(
          heading: 'Privacy Policy – RUDRA',
          body:
              'The RUDRA (Road User Defect Reporting Application) is developed by the Public Works Department (PWD), Assam to allow citizens to report potholes and road defects.',
        ),
        InfoSection(
          heading: 'Information We Collect',
          body:
              '• Phone Number – Your phone number is collected during registration for user identification and verification.\n\n'
              '• Location – The application accesses your device location only when you submit a report in order to geo-tag the exact location of the pothole.\n\n'
              '• Camera Access – Camera permission is required so users can capture photos of potholes or road defects when submitting a report.',
        ),
        InfoSection(
          heading: 'How We Use Your Information',
          body:
              'The collected information is used only for processing reports and forwarding them to the appropriate authorities. Your personal information will not be sold or used for commercial purposes.',
        ),
        InfoSection(
          heading: 'Data Protection',
          body:
              'We take reasonable measures to protect user data and ensure it is used only for administrative and service-related purposes.',
        ),
        InfoSection(
          heading: 'Your Consent',
          body:
              'By using the RUDRA application, you agree to this privacy policy.',
        ),
      ],
    );
  }
}
