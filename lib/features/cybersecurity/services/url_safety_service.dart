import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/security/secure_http_client.dart';
import '../../../shared/security/audit_logger.dart';

final urlSafetyServiceProvider = Provider<UrlSafetyService>((ref) {
  return UrlSafetyService(ref.read(secureHttpClientProvider));
});

enum UrlSafetyStatus { safe, suspicious, malicious, error }

class UrlAnalysisResult {
  const UrlAnalysisResult({
    required this.url,
    required this.status,
    required this.riskScore, // 0 to 100
    required this.reasons,
    this.detectedCategory,
  });

  final String url;
  final UrlSafetyStatus status;
  final int riskScore;
  final List<String> reasons;
  final String? detectedCategory;
}

class UrlSafetyService {
  UrlSafetyService(this._httpClient);
  final SecureHttpClient _httpClient;

  // Known high-risk TLDs
  static const _highRiskTlds = {
    'zip', 'mov', 'tk', 'ml', 'ga', 'cf', 'gq', 'top', 'work', 'click',
    'fit', 'rest', 'surf', 'xyz', 'country', 'stream', 'download', 'link'
  };

  // Known phishing keywords in domain path
  static const _phishingKeywords = [
    'login', 'signin', 'verify', 'account', 'secure', 'update', 'banking',
    'paypa1', 'g00gle', 'micr0soft', 'app1e', 'support', 'billing', 'confirm'
  ];

  /// Analyzes a URL on-device using heuristic indicators and domain analysis.
  Future<UrlAnalysisResult> analyzeUrl(String rawUrl) async {
    final reasons = <String>[];
    int score = 0;

    String cleanUrl = rawUrl.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    Uri? uri;
    try {
      uri = Uri.parse(cleanUrl);
    } catch (_) {
      return UrlAnalysisResult(
        url: rawUrl,
        status: UrlSafetyStatus.error,
        riskScore: 100,
        reasons: const ['Invalid URL format'],
      );
    }

    final host = uri.host.toLowerCase();

    // 1. IP address hostname check
    final isIpHost = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host);
    if (isIpHost) {
      score += 40;
      reasons.add('URL uses raw IP address instead of domain name');
    }

    // 2. HTTP cleartext check
    if (uri.scheme == 'http') {
      score += 20;
      reasons.add('Unencrypted HTTP protocol (no SSL/TLS)');
    }

    // 3. High-risk TLD check
    final tld = host.split('.').last;
    if (_highRiskTlds.contains(tld)) {
      score += 25;
      reasons.add('High-risk top-level domain (.$tld)');
    }

    // 4. Typosquatting / Phishing keyword check
    for (final kw in _phishingKeywords) {
      if (host.contains(kw) && !_isLegitimateDomain(host, kw)) {
        score += 35;
        reasons.add('Domain contains spoofing keyword ("$kw")');
        break;
      }
    }

    // 5. Excessive subdomains or hyphens
    final subdomains = host.split('.');
    if (subdomains.length > 4) {
      score += 15;
      reasons.add('Excessive subdomain depth (${subdomains.length} levels)');
    }
    if (host.split('-').length > 3) {
      score += 15;
      reasons.add('Domain contains multiple hyphens (common in spoofing)');
    }

    // Determine status
    UrlSafetyStatus status;
    if (score >= 60) {
      status = UrlSafetyStatus.malicious;
      await AuditLogger.log(
        event: SecurityEvent.phishingBlocked,
        detail: 'url=$host risk_score=$score reasons=${reasons.join(", ")}',
      );
    } else if (score >= 25) {
      status = UrlSafetyStatus.suspicious;
    } else {
      status = UrlSafetyStatus.safe;
      reasons.add('No malicious indicators found');
    }

    return UrlAnalysisResult(
      url: cleanUrl,
      status: status,
      riskScore: score.clamp(0, 100),
      reasons: reasons,
      detectedCategory: status == UrlSafetyStatus.malicious ? 'Phishing' : null,
    );
  }

  bool _isLegitimateDomain(String host, String keyword) {
    // White-list official domains
    final legitimate = [
      'paypal.com', 'google.com', 'microsoft.com', 'apple.com', 'amazon.com',
      'github.com', 'bankofamerica.com', 'chase.com', 'wellsfargo.com'
    ];
    return legitimate.any((dom) => host == dom || host.endsWith('.$dom'));
  }
}
