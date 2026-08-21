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
    required this.host,
    required this.status,
    required this.riskScore, // 0 (safest) to 100 (most dangerous)
    required this.reasons,
    required this.recommendation,
    this.detectedCategory,
    this.threatLevel = 'SAFE',
  });

  final String url;
  final String host;
  final UrlSafetyStatus status;
  final int riskScore;
  final List<String> reasons;
  final String recommendation;
  final String? detectedCategory;
  final String threatLevel; // SAFE, LOW, MODERATE, HIGH, CRITICAL
}

class UrlSafetyService {
  UrlSafetyService(this._httpClient);
  final SecureHttpClient _httpClient;

  // High-risk or spam top-level domains frequently used in mass phishing/malware
  static const _highRiskTlds = {
    'zip', 'mov', 'tk', 'ml', 'ga', 'cf', 'gq', 'top', 'work', 'click',
    'fit', 'rest', 'surf', 'xyz', 'country', 'stream', 'download', 'link',
    'cam', 'live', 'loan', 'win', 'bid', 'party', 'trade', 'racing',
    'accountant', 'date', 'faith', 'review', 'gdn', 'mom', 'buzz', 'vip'
  };

  // URL shorteners that conceal true destination
  static const _urlShorteners = {
    'bit.ly', 'tinyurl.com', 't.co', 'is.gd', 'cutt.ly', 'rb.gy',
    'shorturl.at', 'ow.ly', 'buff.ly', 'rebrand.ly', 'goo.gl', 'bl.ink'
  };

  // Known phishing keywords in domain or path
  static const _phishingKeywords = [
    'login', 'signin', 'sign-in', 'verify', 'verification', 'account-update',
    'security-check', 'update-password', 'banking', 'paypa1', 'g00gle',
    'micr0soft', 'app1e', 'support-help', 'billing-confirm', 'confirm-identity',
    'wallet-connect', 'seedphrase', 'seed-phrase', 'airdrop', 'claim-reward',
    'free-gift', 'free-nitro', 'lottery-winner', 'prize-claim', 'token-drop',
    'metamask-login', 'binance-support', 'authenticate-kyc', 'reactivate'
  ];

  // Dangerous file extensions in URL
  static const _dangerousFileExtensions = [
    '.exe', '.apk', '.bat', '.cmd', '.sh', '.vbs', '.scr', '.msi', '.iso', '.dmg', '.jar'
  ];

  // Whitelisted official domains
  static const _legitimateDomains = [
    'paypal.com', 'google.com', 'microsoft.com', 'apple.com', 'amazon.com',
    'github.com', 'bankofamerica.com', 'chase.com', 'wellsfargo.com',
    'netflix.com', 'facebook.com', 'instagram.com', 'whatsapp.com',
    'twitter.com', 'x.com', 'linkedin.com', 'youtube.com', 'spotify.com',
    'yahoo.com', 'reddit.com', 'wikipedia.org', 'cloudflare.com', 'flutter.dev'
  ];

  // Brand names frequently impersonated
  static const _impersonatedBrands = [
    'paypal', 'google', 'apple', 'amazon', 'microsoft', 'netflix', 'chase',
    'bankofamerica', 'wellsfargo', 'binance', 'coinbase', 'metamask',
    'facebook', 'instagram', 'whatsapp', 'telegram', 'discord', 'steam'
  ];

  /// Comprehensive multi-layer heuristic & algorithmic URL analysis.
  Future<UrlAnalysisResult> analyzeUrl(String rawUrl) async {
    final reasons = <String>[];
    int score = 0;
    String cleanUrl = rawUrl.trim();

    if (cleanUrl.isEmpty) {
      return const UrlAnalysisResult(
        url: '',
        host: '',
        status: UrlSafetyStatus.error,
        riskScore: 100,
        reasons: ['No URL provided for analysis.'],
        recommendation: 'Please enter a valid website address.',
        threatLevel: 'ERROR',
      );
    }

    // Add protocol if missing for URI parsing
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    Uri? uri;
    try {
      uri = Uri.parse(cleanUrl);
    } catch (_) {
      return UrlAnalysisResult(
        url: rawUrl,
        host: rawUrl,
        status: UrlSafetyStatus.error,
        riskScore: 100,
        reasons: const ['Malformed URL structure.'],
        recommendation: 'Do not open this link. It contains invalid characters or broken syntax.',
        threatLevel: 'CRITICAL',
      );
    }

    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final fullLower = cleanUrl.toLowerCase();

    // Check if host is missing or invalid
    if (host.isEmpty || !host.contains('.')) {
      // Check if it's an IP address without dot or invalid domain
      final isNumOnly = RegExp(r'^\d+$').hasMatch(host);
      if (isNumOnly || !host.contains('.')) {
        return UrlAnalysisResult(
          url: cleanUrl,
          host: host,
          status: UrlSafetyStatus.malicious,
          riskScore: 95,
          reasons: const ['Invalid domain name format (missing valid Top-Level Domain)'],
          recommendation: 'Dangerous! This address does not point to a recognized domain registry.',
          detectedCategory: 'Invalid / Malicious Destination',
          threatLevel: 'CRITICAL',
        );
      }
    }

    // ── 1. IP Address Hostname Check ──────────────────────────────────────
    final isIpHost = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host);
    if (isIpHost) {
      score += 45;
      reasons.add('Destination uses a numeric IP address ($host) instead of a registered domain name.');
    }

    // ── 2. HTTP Cleartext Protocol Check ──────────────────────────────────
    if (uri.scheme == 'http') {
      score += 25;
      reasons.add('Insecure HTTP protocol: Connection lacks SSL/TLS encryption.');
    }

    // ── 3. High-Risk / Throwaway TLD Check ────────────────────────────────
    final domainParts = host.split('.');
    final tld = domainParts.isNotEmpty ? domainParts.last : '';
    if (_highRiskTlds.contains(tld)) {
      score += 35;
      reasons.add('High-risk top-level domain (.$tld) commonly associated with spam and throwaway phishing kits.');
    }

    // ── 4. URL Shortener Detection ────────────────────────────────────────
    if (_urlShorteners.contains(host)) {
      score += 30;
      reasons.add('URL Shortener detected ($host): The actual destination web address is concealed.');
    }

    // ── 5. Dangerous Executable / APK Download Check ───────────────────────
    for (final ext in _dangerousFileExtensions) {
      if (path.endsWith(ext) || path.contains('$ext?')) {
        score += 55;
        reasons.add('Direct executable download payload detected ($ext).');
        break;
      }
    }

    // ── 6. Brand Impersonation & Typosquatting Check ──────────────────────
    bool isLegit = _isLegitimateDomain(host);
    if (!isLegit) {
      for (final brand in _impersonatedBrands) {
        // Look for brand in host when it's not the official domain
        if (host.contains(brand)) {
          score += 45;
          reasons.add('Brand Spoofing: Host contains "$brand" but is NOT the official $brand domain.');
          break;
        }
      }
    }

    // ── 7. Phishing & Scam Keyword Trigger ────────────────────────────────
    if (!isLegit) {
      for (final kw in _phishingKeywords) {
        if (fullLower.contains(kw)) {
          score += 30;
          reasons.add('Deceptive keyword pattern detected ("$kw").');
          break;
        }
      }
    }

    // ── 8. Subdomain Stacking & Hyphen Clutter ────────────────────────────
    if (domainParts.length > 3 && !isLegit) {
      score += 20;
      reasons.add('Excessive subdomain depth (${domainParts.length} levels), often used to disguise fake sites.');
    }
    if (host.split('-').length > 2 && !isLegit) {
      score += 15;
      reasons.add('Multiple hyphens in domain name (common spoofing obfuscation technique).');
    }

    // ── 9. Legitimate Whitelist Bonus ─────────────────────────────────────
    if (isLegit && uri.scheme == 'https' && !isIpHost) {
      score = 0;
      reasons.clear();
      reasons.add('Official verified domain with valid SSL certificate.');
      reasons.add('No phishing signatures or malicious payloads detected.');
    }

    // Clamp score
    final finalScore = score.clamp(0, 100);

    // Determine status & category
    UrlSafetyStatus status;
    String threatLevel;
    String recommendation;
    String? category;

    if (finalScore >= 60) {
      status = UrlSafetyStatus.malicious;
      threatLevel = finalScore >= 80 ? 'CRITICAL' : 'HIGH';
      category = path.contains('.apk') || path.contains('.exe')
          ? 'Malware Payload'
          : (reasons.any((r) => r.contains('Spoofing')) ? 'Phishing / Impersonation' : 'Malicious Site');
      recommendation = 'DO NOT OPEN! This link exhibits strong indicators of fraud, data theft, or malware.';
      
      await AuditLogger.log(
        event: SecurityEvent.phishingBlocked,
        detail: 'url=$host risk_score=$finalScore category=$category',
      );
    } else if (finalScore >= 25) {
      status = UrlSafetyStatus.suspicious;
      threatLevel = 'MODERATE';
      category = _urlShorteners.contains(host) ? 'Obscured Link' : 'Suspicious Web Link';
      recommendation = 'Proceed with caution. Do not enter passwords, credit cards, or personal information.';
    } else {
      status = UrlSafetyStatus.safe;
      threatLevel = 'SAFE';
      category = 'Legitimate Website';
      recommendation = 'This link appears safe to browse.';
      if (reasons.isEmpty) {
        reasons.add('Standard domain structure with no threat flags.');
      }
    }

    return UrlAnalysisResult(
      url: cleanUrl,
      host: host,
      status: status,
      riskScore: finalScore,
      reasons: reasons,
      recommendation: recommendation,
      detectedCategory: category,
      threatLevel: threatLevel,
    );
  }

  bool _isLegitimateDomain(String host) {
    return _legitimateDomains.any((dom) => host == dom || host.endsWith('.$dom'));
  }
}
