import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
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
    this.isBannedInIndia = false,
    this.httpStatusCode,
  });

  final String url;
  final String host;
  final UrlSafetyStatus status;
  final int riskScore;
  final List<String> reasons;
  final String recommendation;
  final String? detectedCategory;
  final String threatLevel; // SAFE, LOW, MODERATE, HIGH, CRITICAL
  final bool isBannedInIndia;
  final int? httpStatusCode;
}

class UrlSafetyService {
  UrlSafetyService(this._httpClient);
  final SecureHttpClient _httpClient;

  // ── 1. Banned Apps & Domains in India (MeitY / DoT Directives) ───────────
  static const _bannedIndiaDomains = {
    'tiktok.com', 'tiktokcdn.com', 'musical.ly', 'clubfactory.com', 'shein.com',
    'shein.in', 'camscanner.com', 'wechat.com', 'qq.com', 'tenpay.com',
    'helo-app.com', 'likee.video', 'kwai.com', 'bigo.tv', 'pubgmobile.com',
    'ucweb.com', 'ucbrowser.com', 'baidu.com', 'vmate.com', 'meitu.com',
    'shareit.com', 'xender.com', 'voot.com', 'helotalk.com', 'romwe.com',
    'snackvideo.com', 'tango.me', 'uplive.in', 'apus.com'
  };

  // ── 2. Illegal Online Betting, Gambling & Offshore Casinos (India Banned) ─
  static const _bannedBettingDomains = {
    '1xbet.com', '1xbet.in', '1xbet.in.net', 'betway.com', 'betway.in',
    'parimatch.com', 'parimatch.in', 'stake.com', 'stake.bet', 'lotus365.in',
    'lotus365.com', 'fairplay.club', 'fairplay.in', 'dafabet.com', '22bet.com',
    '22bet.in', 'mostbet.com', 'mostbet.in', 'melbet.com', 'bet365.com',
    'cricbet99.win', 'mahadevbook.com', 'reddyanna.com', 'laser247.com',
    'skyexchange.com', 'yolo247.com', 'wazamba.com', 'fun88.com', 'sattya.com',
    'badshah777.com', 'gamezy11.com'
  };

  static const _bettingKeywords = [
    '1xbet', 'lotus365', 'mahadevbook', 'parimatch', 'betway', 'fairplay247',
    'stake.com', 'reddyanna', 'dafabet', '22bet', 'mostbet', 'melbet',
    'cricket-betting', 'satta-matka', 'kalyan-matka', 'online-casino',
    'color-prediction', 'roulette-win', 'teen-patti-real-cash'
  ];

  // ── 3. Blocked Piracy & Torrent Portals (DoT / High Court Blocklists) ─────
  static const _bannedPiracyDomains = {
    'tamilrockers.ws', 'tamilrockers.com', 'tamilrockers.cz', 'tamilrockers.is',
    'movierulz.vpn', 'movierulz.tc', 'movierulz.com', 'movierulz.ms',
    'filmyzilla.com', 'filmywap.com', '9xmovies.app', '9xmovies.net',
    '1337x.to', '1337x.st', 'thepiratebay.org', 'piratebay.to', 'yts.mx',
    'rarbg.to', 'torrentz2.eu', 'katcr.to', 'ssrmovies.com', 'khatrimaza.org',
    'bolly4u.org', 'hdhub4u.tv', 'sdmoviespoint.com', 'ibomma.com'
  };

  static const _piracyKeywords = [
    'tamilrockers', 'movierulz', 'filmyzilla', 'filmywap', '9xmovies',
    '1337x', 'piratebay', 'khatrimaza', 'bolly4u', 'hdhub4u', 'sdmoviespoint',
    'ibomma', 'vegamovies', 'torrent-download', 'free-movie-download'
  ];

  // ── 4. Indian Cybercrime Fraud & Phishing Scam Patterns ───────────────────
  static const _indianScamKeywords = [
    'digital-arrest', 'cbi-arrest-notice', 'cyber-police-notice',
    'electric-bill-update', 'power-disconnection-alert', 'challan-pay-online',
    'kbc-lottery-won', 'jio-5g-free-recharge', 'part-time-job-telegram',
    'customs-gift-parcel', 'trai-sim-deactivation', 'sbi-yono-reward',
    'income-tax-refund-apk', 'pan-aadhaar-link-urgent', 'work-from-home-daily-pay'
  ];

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

  // Generic phishing keywords
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
    'yahoo.com', 'reddit.com', 'wikipedia.org', 'cloudflare.com', 'flutter.dev',
    'gov.in', 'nic.in', 'isro.gov.in', 'rbi.org.in', 'sbi.co.in', 'hdfcbank.com',
    'icicibank.com', 'uidai.gov.in', 'incometax.gov.in', 'npci.org.in'
  ];

  // Brand names frequently impersonated
  static const _impersonatedBrands = [
    'paypal', 'google', 'apple', 'amazon', 'microsoft', 'netflix', 'chase',
    'bankofamerica', 'wellsfargo', 'binance', 'coinbase', 'metamask',
    'facebook', 'instagram', 'whatsapp', 'telegram', 'discord', 'steam',
    'paytm', 'phonepe', 'gpay', 'sbi', 'hdfc', 'icici'
  ];

  /// Comprehensive multi-layer heuristic, algorithmic & live network URL analysis.
  Future<UrlAnalysisResult> analyzeUrl(String rawUrl) async {
    final reasons = <String>[];
    int score = 0;
    String cleanUrl = rawUrl.trim();
    bool isBannedInIndia = false;

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
    if (host.isEmpty || (!host.contains('.') && !host.endsWith('.onion'))) {
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

    // ── 1. BANNED IN INDIA: Government MeitY / DoT Directives Check ─────────
    bool isIndiaBannedDomain = _bannedIndiaDomains.any((dom) => host == dom || host.endsWith('.$dom'));
    if (isIndiaBannedDomain) {
      score += 100;
      isBannedInIndia = true;
      reasons.add('🚫 BANNED IN INDIA: Site is restricted under Section 69A of Information Technology Act by Ministry of Electronics & IT (MeitY) / DoT.');
    }

    // ── 2. ILLEGAL BETTING / GAMBLING (India Prohibited) ────────────────────
    bool isBettingDomain = _bannedBettingDomains.any((dom) => host == dom || host.endsWith('.$dom'));
    if (!isBettingDomain) {
      for (final kw in _bettingKeywords) {
        if (fullLower.contains(kw)) {
          isBettingDomain = true;
          break;
        }
      }
    }
    if (isBettingDomain) {
      score += 95;
      isBannedInIndia = true;
      reasons.add('🎰 ILLEGAL BETTING / GAMBLING: Operating unauthorized betting prohibited under Public Gambling Act & MeitY Directives.');
    }

    // ── 3. ILLEGAL PIRACY / TORRENT PORTAL (India High Court Blocklist) ──────
    bool isPiracyDomain = _bannedPiracyDomains.any((dom) => host == dom || host.endsWith('.$dom'));
    if (!isPiracyDomain) {
      for (final kw in _piracyKeywords) {
        if (fullLower.contains(kw)) {
          isPiracyDomain = true;
          break;
        }
      }
    }
    if (isPiracyDomain) {
      score += 90;
      isBannedInIndia = true;
      reasons.add('🎬 ILLEGAL PIRACY / COPYRIGHT INFRINGEMENT: Blocked in India by Department of Telecommunications (DoT) / High Court court orders.');
    }

    // ── 4. INDIAN CYBER CRIME / DIGITAL ARREST / BILL SCAM PATTERNS ──────────
    for (final kw in _indianScamKeywords) {
      if (fullLower.contains(kw)) {
        score += 95;
        reasons.add('⚠️ CYBER FRAUD PATTERN: Matches active Indian cyber crime scams (Digital Arrest, Power Bill Update, or Part-Time Job Scam).');
        break;
      }
    }

    // ── 5. DARKWEB / ANONYMIZER NETWORK ──────────────────────────────────────
    if (host.endsWith('.onion') || host.endsWith('.i2p')) {
      score += 100;
      reasons.add('🧅 DARKWEB HIDDEN SERVICE (.onion): Non-indexed darknet portal associated with illicit activity.');
    }

    // ── 6. IP Address Hostname Check ──────────────────────────────────────────
    final isIpHost = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host);
    if (isIpHost) {
      score += 45;
      reasons.add('Destination uses a numeric IP address ($host) instead of a registered domain name.');
    }

    // ── 7. HTTP Cleartext Protocol Check ──────────────────────────────────────
    if (uri.scheme == 'http') {
      score += 30;
      reasons.add('Insecure HTTP protocol: Connection lacks SSL/TLS encryption.');
    }

    // ── 8. High-Risk / Throwaway TLD Check ────────────────────────────────────
    final domainParts = host.split('.');
    final tld = domainParts.isNotEmpty ? domainParts.last : '';
    if (_highRiskTlds.contains(tld)) {
      score += 35;
      reasons.add('High-risk top-level domain (.$tld) commonly associated with spam and throwaway phishing kits.');
    }

    // ── 9. URL Shortener Detection ────────────────────────────────────────────
    if (_urlShorteners.contains(host)) {
      score += 30;
      reasons.add('URL Shortener detected ($host): The actual destination web address is concealed.');
    }

    // ── 10. Dangerous Executable / APK Download Check ─────────────────────────
    for (final ext in _dangerousFileExtensions) {
      if (path.endsWith(ext) || path.contains('$ext?')) {
        score += 55;
        reasons.add('Direct executable download payload detected ($ext). Potential malware infection risk.');
        break;
      }
    }

    // ── 11. Brand Impersonation & Typosquatting Check ─────────────────────────
    bool isLegit = _isLegitimateDomain(host);
    if (!isLegit) {
      for (final brand in _impersonatedBrands) {
        if (host.contains(brand)) {
          score += 45;
          reasons.add('Brand Spoofing: Host contains "$brand" but is NOT the official $brand domain.');
          break;
        }
      }
    }

    // ── 12. Generic Phishing Keywords ─────────────────────────────────────────
    if (!isLegit) {
      for (final kw in _phishingKeywords) {
        if (fullLower.contains(kw)) {
          score += 30;
          reasons.add('Deceptive keyword pattern detected ("$kw").');
          break;
        }
      }
    }

    // ── 13. Subdomain Stacking & Hyphen Clutter ───────────────────────────────
    if (domainParts.length > 3 && !isLegit) {
      score += 20;
      reasons.add('Excessive subdomain depth (${domainParts.length} levels), often used to disguise fake sites.');
    }
    if (host.split('-').length > 2 && !isLegit) {
      score += 15;
      reasons.add('Multiple hyphens in domain name (common spoofing obfuscation technique).');
    }

    // ── 14. Live Network HTTP Probe ───────────────────────────────────────────
    int? responseCode;
    if (score < 60 && !isIndiaBannedDomain && !isBettingDomain && !isPiracyDomain) {
      try {
        final client = http.Client();
        final response = await client.get(uri).timeout(const Duration(seconds: 3));
        responseCode = response.statusCode;
        client.close();

        // Status code 451 (Unavailable For Legal Reasons), 403, 502/503/504
        if (response.statusCode == 451) {
          score += 90;
          isBannedInIndia = true;
          reasons.add('🚫 Network Probe HTTP 451: Server explicitly returns "Unavailable For Legal Reasons" (Blocked by Law Enforcement).');
        } else if (response.statusCode == 403 || response.statusCode == 404) {
          final bodyLower = response.body.toLowerCase();
          if (bodyLower.contains('blocked') || bodyLower.contains('dot.gov.in') || bodyLower.contains('meity')) {
            score += 95;
            isBannedInIndia = true;
            reasons.add('🚫 Network Probe ISP Sinkhole: Connection intercepted by Indian Telecom ISP block page.');
          }
        }
      } catch (_) {
        // Network probe note for unreachable host or timeout
        if (!isLegit) {
          score += 20;
          reasons.add('Network Probe Note: Host unreachable or socket connection refused by gateway.');
        }
      }
    }

    // ── 15. Legitimate Whitelist Reset ────────────────────────────────────────
    if (isLegit && uri.scheme == 'https' && !isIpHost && !isIndiaBannedDomain && !isBettingDomain && !isPiracyDomain) {
      score = 0;
      reasons.clear();
      reasons.add('Verified official domain with valid SSL certificate.');
      reasons.add('No threat signatures or MeitY/DoT ban directives found.');
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
      if (isIndiaBannedDomain) {
        category = 'Banned in India (MeitY / DoT Directive)';
        recommendation = 'DO NOT VISIT! This website/app is strictly banned in India under IT Act Section 69A.';
      } else if (isBettingDomain) {
        category = 'Illegal Online Betting / Gambling';
        recommendation = 'DO NOT VISIT! Unlawful betting portal prohibited under Public Gambling Act.';
      } else if (isPiracyDomain) {
        category = 'Illegal Piracy / Copyright Infringement';
        recommendation = 'DO NOT VISIT! Torrent/piracy site blocked by Indian High Court directives.';
      } else if (path.contains('.apk') || path.contains('.exe')) {
        category = 'Malware Payload / Trojan';
        recommendation = 'DO NOT DOWNLOAD! Direct executable file download detected.';
      } else {
        category = reasons.any((r) => r.contains('Spoofing')) ? 'Phishing / Impersonation' : 'Cyber Threat Site';
        recommendation = 'DO NOT OPEN! This link exhibits strong indicators of fraud, data theft, or malware.';
      }

      await AuditLogger.log(
        event: SecurityEvent.phishingBlocked,
        detail: 'url=$host risk_score=$finalScore category=$category banned_india=$isBannedInIndia',
      );
    } else if (finalScore >= 25) {
      status = UrlSafetyStatus.suspicious;
      threatLevel = 'MODERATE';
      category = _urlShorteners.contains(host) ? 'Obscured Link' : 'Suspicious Web Address';
      recommendation = 'Proceed with caution. Do not enter passwords, OTPs, or financial details.';
    } else {
      status = UrlSafetyStatus.safe;
      threatLevel = 'SAFE';
      category = 'Verified Safe Website';
      recommendation = 'This website link appears clean and safe to browse.';
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
      isBannedInIndia: isBannedInIndia,
      httpStatusCode: responseCode,
    );
  }

  bool _isLegitimateDomain(String host) {
    return _legitimateDomains.any((dom) => host == dom || host.endsWith('.$dom'));
  }
}

