/* jshint ignore:start */

/******************************************************************************
 * SECTION: Privacy                                                              *
 ******************************************************************************/

// PREF: Anti-fingerprinting features
// user_pref("privacy.resistFingerprinting", true);

// PREF: Enable tracking protection
user_pref("privacy.trackingprotection.enabled", true);

// PREF: Disable telemetry
user_pref("toolkit.telemetry.enabled", false);

// PREF: Enable the Do Not Track header (DNT)
user_pref("privacy.donottrackheader.enabled", true);

// PREF: Disable the Trusted Recursive Resolver
user_pref("network.trr.mode", 5);

// PREF: Disable Safe Browsing services
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);

// PREF: Change the user agent and platform to those used by the Tor browser
/* user_pref("general.useragent.override", "Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0"); */
/* user_pref("general.platform.override", "Win32"); */

/******************************************************************************
 * SECTION: Misc                                                              *
 ******************************************************************************/

// PREF: Enable the use of userChrome.css
user_pref("toolkit.legacyUserProfileCustomizations.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// PREF: Disable extension recommendations
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);

// PREF: Force Adwaita light theme for widgets
user_pref("widget.content.gtk-theme-override", "Adwaita:light");

// PREF: Enable WebRender
// user_pref("gfx.webrender.all", true);

// PREF: Disable face detection
user_pref("camera.control.face_detection.enabled", false);

// PREF: Disable GeoIP lookup on your address to set default search engine region
// https://trac.torproject.org/projects/tor/ticket/16254
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_geolocation-for-default-search-engine
user_pref("browser.search.geoip.url", "");
// user_pref("browser.search.region", "US");

// PREF: Set Accept-Language HTTP header to en-US regardless of Firefox localization
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language
// user_pref("intl.accept_languages", "en-US, en");

// PREF: Don't use OS values to determine locale, force using Firefox locale setting
// http://kb.mozillazine.org/Intl.locale.matchOS
// user_pref("intl.locale.matchOS", false);

// PREF: Don't use Mozilla-provided location-specific search engines
user_pref("browser.search.geoSpecificDefaults", false);

// PREF: Send DNS request through SOCKS when SOCKS proxying is in use
// https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO/WebBrowsers
user_pref("network.proxy.socks_remote_dns", true);

// PREF: Don't reveal build ID
// Value taken from Tor Browser
// https://bugzilla.mozilla.org/show_bug.cgi?id=583181
user_pref("general.buildID.override", "20100101");
user_pref("browser.startup.homepage_override.buildID", "20100101");

// PREF: Prevent font fingerprinting
// https://browserleaks.com/fonts
// https://github.com/pyllyukko/user.js/issues/120
user_pref("browser.display.use_document_fonts", 0);

// PREF: Set the UI density to "compact"
user_pref("browser.uidensity", 1);

// PREF: Enable JPEG-XL support
user_pref("image.jxl.enabled", true);

/******************************************************************************
 * SECTION: Extensions / plugins                                              *
 ******************************************************************************/

// PREF: Don't process incoming add-on enabled/disabled status
// https://wiki.mozilla.org/Services/Sync/Addon_Sync#Can_I_have_different_enabled_states_on_different_machines.3F
user_pref("services.sync.addons.ignoreUserEnabledChanges", true);

// PREF: Ensure you have a security delay when installing add-ons (milliseconds)
// http://kb.mozillazine.org/Disable_extension_install_delay_-_Firefox
// http://www.squarefree.com/2004/07/01/race-conditions-in-security-dialogs/
user_pref("security.dialog_enable_delay", 1000);

// PREF: Opt-out of add-on metadata updates
// https://blog.mozilla.org/addons/how-to-opt-out-of-add-on-metadata-updates/
// user_pref("extensions.getAddons.cache.enabled", false);

// PREF: Opt-out of themes (Persona) updates
// https://support.mozilla.org/t5/Firefox/how-do-I-prevent-autoamtic-updates-in-a-50-user-environment/td-p/144287
// user_pref("lightweightThemes.update.enabled", false);

// PREF: Disable Gnome Shell Integration NPAPI plugin
// user_pref("plugin.state.libgnome-shell-browser-plugin", 0);

// PREF: Updates addons automatically
// https://blog.mozilla.org/addons/how-to-turn-off-add-on-updates/
user_pref("extensions.update.enabled", true);

// PREF: Enable add-on and certificate blocklists (OneCRL) from Mozilla
// https://wiki.mozilla.org/Blocklisting
// https://blocked.cdn.mozilla.net/
// http://kb.mozillazine.org/Extensions.blocklist.enabled
// http://kb.mozillazine.org/Extensions.blocklist.url
// https://blog.mozilla.org/security/2015/03/03/revoking-intermediate-certificates-introducing-onecrl/
// Updated at interval defined in extensions.blocklist.interval (default: 86400)
user_pref("extensions.blocklist.enabled", true);
user_pref("services.blocklist.update_enabled", true);

// PREF: Decrease system information leakage to Mozilla blocklist update servers
// https://trac.torproject.org/projects/tor/ticket/16931
user_pref("extensions.blocklist.url", "https://blocklist.addons.mozilla.org/blocklist/3/%APP_ID%/%APP_VERSION%/");

/******************************************************************************
 * SECTION: Automatic connections                                             *
 ******************************************************************************/

// PREF: Disable search suggestions in the search bar
// http://kb.mozillazine.org/Browser.search.suggest.enabled
user_pref("browser.search.suggest.enabled", false);

// PREF: Disable "Show search suggestions in location bar results"
user_pref("browser.urlbar.suggest.searches", false);
// PREF: When using the location bar, don't suggest URLs from browsing history
user_pref("browser.urlbar.suggest.history", false);

// PREF: Disable downloading homepage snippets/messages from Mozilla
// https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections#w_mozilla-content
// https://wiki.mozilla.org/Firefox/Projects/Firefox_Start/Snippet_Service
user_pref("browser.aboutHomeSnippets.updateUrl", "");

/******************************************************************************
 * SECTION: HTTP                                                              *
 ******************************************************************************/

// PREF: Disallow NTLMv1
// https://bugzilla.mozilla.org/show_bug.cgi?id=828183
user_pref("network.negotiate-auth.allow-insecure-ntlm-v1", false);
// it is still allowed through HTTPS. uncomment the following to disable it completely.
//user_pref("network.negotiate-auth.allow-insecure-ntlm-v1-https", false);

// PREF: Enable CSP 1.1 script-nonce directive support
// https://bugzilla.mozilla.org/show_bug.cgi?id=855326
user_pref("security.csp.experimentalEnabled", true);

// PREF: Enable Content Security Policy (CSP)
// https://developer.mozilla.org/en-US/docs/Web/Security/CSP/Introducing_Content_Security_Policy
// https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
user_pref("security.csp.enable", true);

// PREF: Enable Subresource Integrity
// https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity
// https://wiki.mozilla.org/Security/Subresource_Integrity
user_pref("security.sri.enable", true);

/*******************************************************************************
 * SECTION: UI related                                                         *
 *******************************************************************************/

// PREF: Enable insecure password warnings (login forms in non-HTTPS pages)
// https://blog.mozilla.org/tanvi/2016/01/28/no-more-passwords-over-http-please/
// https://bugzilla.mozilla.org/show_bug.cgi?id=1319119
// https://bugzilla.mozilla.org/show_bug.cgi?id=1217156
user_pref("security.insecure_password.ui.enabled", true);

// PREF: Disable the "new tab page" feature and show a blank tab instead
// https://wiki.mozilla.org/Privacy/Reviews/New_Tab
// https://support.mozilla.org/en-US/kb/new-tab-page-show-hide-and-customize-top-sites#w_how-do-i-turn-the-new-tab-page-off
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.url", "about:blank");

// PREF: Disable Activity Stream
// https://wiki.mozilla.org/Firefox/Activity_Stream
user_pref("browser.newtabpage.activity-stream.enabled", false);

// PREF: Do not check if Firefox is the default browser
user_pref("browser.shell.checkDefaultBrowser", false);

// PREF: Display a notification bar when websites offer data for offline use
// http://kb.mozillazine.org/Browser.offline-apps.notify
user_pref("browser.offline-apps.notify", true);

/******************************************************************************
 * SECTION: Cryptography                                                      *
 ******************************************************************************/

// PREF: Enable HSTS preload list (pre-set HSTS sites list provided by Mozilla)
// https://blog.mozilla.org/security/2012/11/01/preloading-hsts/
// https://wiki.mozilla.org/Privacy/Features/HSTS_Preload_List
// https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
user_pref("network.stricttransportsecurity.preloadlist", true);

// PREF: Enable Online Certificate Status Protocol
// https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol
// https://www.imperialviolet.org/2014/04/19/revchecking.html
// https://www.maikel.pro/blog/current-state-certificate-revocation-crls-ocsp/
// https://wiki.mozilla.org/CA:RevocationPlan
// https://wiki.mozilla.org/CA:ImprovingRevocation
// https://wiki.mozilla.org/CA:OCSP-HardFail
// https://news.netcraft.com/archives/2014/04/24/certificate-revocation-why-browsers-remain-affected-by-heartbleed.html
// https://news.netcraft.com/archives/2013/04/16/certificate-revocation-and-the-performance-of-ocsp.html
// NOTICE: OCSP leaks your IP and domains you visit to the CA when OCSP Stapling is not available on visited host
// NOTICE: OCSP is vulnerable to replay attacks when nonce is not configured on the OCSP responder
// NOTICE: OCSP adds latency (performance)
// NOTICE: Short-lived certificates are not checked for revocation (security.pki.cert_short_lifetime_in_days, default:10)
// CIS Version 1.2.0 October 21st, 2011 2.2.4
user_pref("security.OCSP.enabled", 1);

// PREF: Enable OCSP Stapling support
// https://en.wikipedia.org/wiki/OCSP_stapling
// https://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox/
// https://www.digitalocean.com/community/tutorials/how-to-configure-ocsp-stapling-on-apache-and-nginx
user_pref("security.ssl.enable_ocsp_stapling", true);

// PREF: Enable OCSP Must-Staple support (Firefox >= 45)
// https://blog.mozilla.org/security/2015/11/23/improving-revocation-ocsp-must-staple-and-short-lived-certificates/
// https://www.entrust.com/ocsp-must-staple/
// https://github.com/schomery/privacy-settings/issues/40
// NOTICE: Firefox falls back on plain OCSP when must-staple is not configured on the host certificate
user_pref("security.ssl.enable_ocsp_must_staple", true);

// PREF: Require a valid OCSP response for OCSP enabled certificates
// https://groups.google.com/forum/#!topic/mozilla.dev.security/n1G-N2-HTVA
// Disabling this will make OCSP bypassable by MitM attacks suppressing OCSP responses
// NOTICE: `security.OCSP.require` will make the connection fail when the OCSP responder is unavailable
// NOTICE: `security.OCSP.require` is known to break browsing on some [captive portals](https://en.wikipedia.org/wiki/Captive_portal)
user_pref("security.OCSP.require", true);

// PREF: Disable TLS Session Tickets
// https://www.blackhat.com/us-13/briefings.html#NextGen
// https://media.blackhat.com/us-13/US-13-Daigniere-TLS-Secrets-Slides.pdf
// https://media.blackhat.com/us-13/US-13-Daigniere-TLS-Secrets-WP.pdf
// https://bugzilla.mozilla.org/show_bug.cgi?id=917049
// https://bugzilla.mozilla.org/show_bug.cgi?id=967977
user_pref("security.ssl.disable_session_identifiers", true);

// PREF: Only allow TLS 1.[0-3]
// http://kb.mozillazine.org/Security.tls.version.*
// 1 = TLS 1.0 is the minimum required / maximum supported encryption protocol. (This is the current default for the maximum supported version.)
// 2 = TLS 1.1 is the minimum required / maximum supported encryption protocol.
// 3 = TLS 1.2 is the minimum required / maximum supported encryption protocol.
// 4 = TLS 1.3 is the minimum required / maximum supported encryption protocol.
user_pref("security.tls.version.min", 1);
user_pref("security.tls.version.max", 4);

// PREF: Disable insecure TLS version fallback
// https://bugzilla.mozilla.org/show_bug.cgi?id=1084025
// https://github.com/pyllyukko/user.js/pull/206#issuecomment-280229645
user_pref("security.tls.version.fallback-limit", 3);

// PREF: Enforce Public Key Pinning
// https://en.wikipedia.org/wiki/HTTP_Public_Key_Pinning
// https://wiki.mozilla.org/SecurityEngineering/Public_Key_Pinning
// "2. Strict. Pinning is always enforced."
user_pref("security.cert_pinning.enforcement_level", 2);

// PREF: Disallow SHA-1
// https://bugzilla.mozilla.org/show_bug.cgi?id=1302140
// https://shattered.io/
user_pref("security.pki.sha1_enforcement_level", 1);

// PREF: Warn the user when server doesn't support RFC 5746 ("safe" renegotiation)
// https://wiki.mozilla.org/Security:Renegotiation#security.ssl.treat_unsafe_negotiation_as_broken
// https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2009-3555
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);

// PREF: Disable automatic reporting of TLS connection errors
// https://support.mozilla.org/en-US/kb/certificate-pinning-reports
// we could also disable security.ssl.errorReporting.enabled, but I think it's
// good to leave the option to report potentially malicious sites if the user
// chooses to do so.
// you can test this at https://pinningtest.appspot.com/
user_pref("security.ssl.errorReporting.automatic", false);

// PREF: Pre-populate the current URL but do not pre-fetch the certificate in the "Add Security Exception" dialog
// http://kb.mozillazine.org/Browser.ssl_override_behavior
// https://github.com/pyllyukko/user.js/issues/210
user_pref("browser.ssl_override_behavior", 1);

/******************************************************************************
 * SECTION: Cipher suites                                                     *
 ******************************************************************************/

// PREF: Disable null ciphers
user_pref("security.ssl3.rsa_null_sha", false);
user_pref("security.ssl3.rsa_null_md5", false);
user_pref("security.ssl3.ecdhe_rsa_null_sha", false);
user_pref("security.ssl3.ecdhe_ecdsa_null_sha", false);
user_pref("security.ssl3.ecdh_rsa_null_sha", false);
user_pref("security.ssl3.ecdh_ecdsa_null_sha", false);

// PREF: Disable SEED cipher
// https://en.wikipedia.org/wiki/SEED
user_pref("security.ssl3.rsa_seed_sha", false);

// PREF: Disable 40/56/128-bit ciphers
// 40-bit ciphers
user_pref("security.ssl3.rsa_rc4_40_md5", false);
user_pref("security.ssl3.rsa_rc2_40_md5", false);
// 56-bit ciphers
user_pref("security.ssl3.rsa_1024_rc4_56_sha", false);
// 128-bit ciphers
user_pref("security.ssl3.rsa_camellia_128_sha", false);
user_pref("security.ssl3.ecdhe_rsa_aes_128_sha", false);
user_pref("security.ssl3.ecdhe_ecdsa_aes_128_sha", false);
user_pref("security.ssl3.ecdh_rsa_aes_128_sha", false);
user_pref("security.ssl3.ecdh_ecdsa_aes_128_sha", false);
user_pref("security.ssl3.dhe_rsa_camellia_128_sha", false);
user_pref("security.ssl3.dhe_rsa_aes_128_sha", false);

// PREF: Disable RC4
// https://developer.mozilla.org/en-US/Firefox/Releases/38#Security
// https://bugzilla.mozilla.org/show_bug.cgi?id=1138882
// https://rc4.io/
// https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2013-2566
user_pref("security.ssl3.ecdh_ecdsa_rc4_128_sha", false);
user_pref("security.ssl3.ecdh_rsa_rc4_128_sha", false);
user_pref("security.ssl3.ecdhe_ecdsa_rc4_128_sha", false);
user_pref("security.ssl3.ecdhe_rsa_rc4_128_sha", false);
user_pref("security.ssl3.rsa_rc4_128_md5", false);
user_pref("security.ssl3.rsa_rc4_128_sha", false);
user_pref("security.tls.unrestricted_rc4_fallback", false);

// PREF: Disable 3DES (effective key size is < 128)
// https://en.wikipedia.org/wiki/3des#Security
// http://en.citizendium.org/wiki/Meet-in-the-middle_attack
// http://www-archive.mozilla.org/projects/security/pki/nss/ssl/fips-ssl-ciphersuites.html
user_pref("security.ssl3.dhe_dss_des_ede3_sha", false);
user_pref("security.ssl3.dhe_rsa_des_ede3_sha", false);
user_pref("security.ssl3.ecdh_ecdsa_des_ede3_sha", false);
user_pref("security.ssl3.ecdh_rsa_des_ede3_sha", false);
user_pref("security.ssl3.ecdhe_ecdsa_des_ede3_sha", false);
user_pref("security.ssl3.ecdhe_rsa_des_ede3_sha", false);
user_pref("security.ssl3.rsa_des_ede3_sha", false);
user_pref("security.ssl3.rsa_fips_des_ede3_sha", false);

// PREF: Disable ciphers with ECDH (non-ephemeral)
user_pref("security.ssl3.ecdh_rsa_aes_256_sha", false);
user_pref("security.ssl3.ecdh_ecdsa_aes_256_sha", false);

// PREF: Disable 256 bits ciphers without PFS
user_pref("security.ssl3.rsa_camellia_256_sha", false);

// PREF: Enable ciphers with ECDHE and key size > 128bits
user_pref("security.ssl3.ecdhe_rsa_aes_256_sha", true);
user_pref("security.ssl3.ecdhe_ecdsa_aes_256_sha", true);

// PREF: Enable GCM ciphers (TLSv1.2 only)
// https://en.wikipedia.org/wiki/Galois/Counter_Mode
user_pref("security.ssl3.ecdhe_ecdsa_aes_128_gcm_sha256", true);
user_pref("security.ssl3.ecdhe_rsa_aes_128_gcm_sha256", true);

// PREF: Enable ChaCha20 and Poly1305 (Firefox >= 47)
// https://www.mozilla.org/en-US/firefox/47.0/releasenotes/
// https://tools.ietf.org/html/rfc7905
// https://bugzilla.mozilla.org/show_bug.cgi?id=917571
// https://bugzilla.mozilla.org/show_bug.cgi?id=1247860
// https://cr.yp.to/chacha.html
user_pref("security.ssl3.ecdhe_ecdsa_chacha20_poly1305_sha256", true);
user_pref("security.ssl3.ecdhe_rsa_chacha20_poly1305_sha256", true);

// PREF: Disable ciphers susceptible to the logjam attack
// https://weakdh.org/
user_pref("security.ssl3.dhe_rsa_camellia_256_sha", false);
user_pref("security.ssl3.dhe_rsa_aes_256_sha", false);

// PREF: Disable ciphers with DSA (max 1024 bits)
user_pref("security.ssl3.dhe_dss_aes_128_sha", false);
user_pref("security.ssl3.dhe_dss_aes_256_sha", false);
user_pref("security.ssl3.dhe_dss_camellia_128_sha", false);
user_pref("security.ssl3.dhe_dss_camellia_256_sha", false);

// PREF: Fallbacks due compatibility reasons
user_pref("security.ssl3.rsa_aes_256_sha", true);
user_pref("security.ssl3.rsa_aes_128_sha", true);

/******************************************************************************
 * SECTION: Keybindings                                                       *
 ******************************************************************************/

// PREF: Disable forward / back on the side mouse buttons since they are usually
// used for push-to-talk in other applications
user_pref("mousebutton.4th.enabled", false);
user_pref("mousebutton.5th.enabled", false);

/******************************************************************************
 * SECTION: DevTools                                                       *
 ******************************************************************************/

// PREF: Keep the network monitor entries on refresh
user_pref("devtools.netmonitor.persistlog", true);

// PREF: Keep the console logs on refresh
user_pref("devtools.webconsole.persistlog", true);

/* jshint ignore:end */
