# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

The Micro Commerce team and community take security bugs seriously. We appreciate your efforts to responsibly disclose your findings, and will make every effort to acknowledge your contributions.

To report a security issue, please use the GitHub Security Advisory ["Report a Vulnerability"](https://github.com/SurasakSiangsai02/micro-commerce/security/advisories/new) tab.

The Micro Commerce team will send a response indicating the next steps in handling your report. After the initial reply to your report, the security team will keep you informed of the progress towards a fix and full announcement, and may ask for additional information or guidance.

### What to include in your report

Please include the following information in your security report:

- Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit the issue

This information will help us triage your report more quickly.

## Preferred Languages

We prefer all communications to be in English.

## Policy

- We will respond to your report within 72 hours with our evaluation of the report and an expected resolution date.
- If you have followed the instructions above, we will not take any legal action against you in regard to the report.
- We will handle your report with strict confidentiality, and not pass on your personal details to third parties without your permission.
- We will keep you informed of the progress towards resolving the problem.
- In the public information concerning the problem reported, we will give your name as the discoverer of the problem (unless you desire otherwise).

## Security Measures

### Current Security Features

- **Authentication**: Firebase Authentication with email/password
- **Authorization**: Role-based access control (Customer/Admin)
- **Data Validation**: Input validation on all user inputs
- **Secure Communication**: HTTPS only
- **Firebase Security Rules**: Properly configured Firestore and Storage rules
- **Payment Security**: Stripe integration with secure payment processing
- **Environment Variables**: Sensitive data stored in environment variables

### Best Practices

- Keep dependencies up to date
- Regular security audits
- Secure coding practices
- Proper error handling without information disclosure
- Input sanitization and validation
- Secure session management

## Known Security Considerations

### Mobile App Security

- App obfuscation in release builds
- Certificate pinning for API calls
- Secure storage for sensitive data
- Runtime Application Self-Protection (RASP)

### Firebase Security

- Proper security rules for Firestore
- Storage bucket security rules
- Authentication rules and validation
- API key restrictions

### Payment Security

- PCI DSS compliance through Stripe
- No storage of sensitive payment data
- Secure payment token handling
- Transaction monitoring

## Contact

For any security-related questions or concerns, please contact:

- Email: surasak.siangsai@example.com
- Create a security advisory: [GitHub Security Advisories](https://github.com/SurasakSiangsai02/micro-commerce/security/advisories)

Thank you for helping keep Micro Commerce and our users safe!