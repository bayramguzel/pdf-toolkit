<?php
$lang = isset($_GET['lang']) ? $_GET['lang'] : null;
if (!$lang) {
    $browser_lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'en', 0, 2);
    $supported_langs = ['tr', 'de', 'en'];
    $lang = in_array($browser_lang, $supported_langs) ? $browser_lang : 'en';
}
$appName = "Last Updated: November 14, 2025";
$content = [
    'tr' => [
        'title' => 'Gizlilik Politikası - ' . $appName,
        'home' => 'Anasayfa',
        'effective_date' => 'Yürürlük Tarihi',
        'intro_title' => 'Giriş',
        'intro_text' => '41Software olarak gizliliğinize önem veriyoruz.',
        'collect_title' => 'Toplanan Veriler',
        'points' => '<h3>Privacy Policy for PDF Toolkit</h3>
<li><strong>Effective Date:</strong> November 14, 2025</li>
<li><strong>Last Updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<li>PDF Toolkit ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how PDF Toolkit handles your information when you use our mobile application.</li>
<h3>Information We Collect</h3>
<h3>Data Processed Locally</h3>
<p>PDF Toolkit processes all PDF files and documents <strong>locally on your device</strong>. We do not upload, store, or transmit any of your PDF files, documents, images, or personal data to our servers or any third-party servers.</p>
<li>The app may access:</li>
<li>PDF files you select for processing</li>
<li>Device storage (with your permission) to save processed files</li>
<li>Camera or photo gallery (with your permission) when using certain features</li>
<h3>How We Use Your Information</h3>
<li><strong>File Processing:</strong> All PDF operations (merge, split, compress, encrypt, etc.) happen entirely on your device</li>
<li><strong>Settings Storage:</strong> Your app preferences (theme, save location) are stored locally using SharedPreferences</li>
<h3>Data Sharing</h3>
<li>We <strong>do not sell, rent, or share</strong> your personal information or PDF content with third parties, except:</li>
<li><strong>Legal Requirements:</strong> If required by law or to protect our rights</li>
<h3>Your Rights and Choices</h3>
<li>You have the right to:</li>
<li><strong>Delete Data:</strong> Uninstall the app to remove all locally stored data</li>
<li><strong>Control Permissions:</strong> Manage storage and file access permissions in device settings</li>
<li><strong>Contact Us:</strong> Request information about your data</li>
<h3>Data Security</h3>
<li>All file processing happens <strong>offline</strong> on your device</li>
<li>No PDF content is transmitted over the internet</li>
<li>App settings are stored securely using encrypted SharedPreferences</li>
<li>We implement industry-standard security measures</li>
<h3>Children\'s Privacy</h3>
<li>PDF Toolkit does not knowingly collect information from children under 13. If you are a parent or guardian and believe your child has provided us with information, please contact us.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Changes will be posted on our website and within the app. Continued use of the app after changes constitutes acceptance of the updated policy.</li>
<h3>Contact Us</h3>
<li>If you have any questions or concerns about this Privacy Policy or your data:</li>
<li><strong>41 Software</strong></li>
<li>Website: [www.41software.com](https://www.41software.com)</li>
<li>Email: [info@41software.com](mailto:info@41software.com)</li>
<li>Privacy Policy URL: [https://www.41software.com/privacy/privacy_pdftoolkit.pdf](https://www.41software.com/privacy/privacy_pdftoolkit.pdf)</li>
<li><strong>Summary:</strong></li>
<li>✅ All PDF files are processed locally on your device</li>
<li>✅ No PDF content is uploaded to servers</li>
<li>✅ You control your data and permissions</li>',
        'security_title' => 'Güvenlik',
        'security_text' => 'Verileriniz cihazınızda yerel olarak saklanır.',
        'contact_title' => 'İletişim',
        'contact_text' => 'Sorularınız için bizimle iletişime geçebilirsiniz.',
        'last_updated' => 'Son Güncelleme:'
    ],
    'en' => [
        'title' => 'Privacy Policy - ' . $appName,
        'home' => 'Home',
        'effective_date' => 'Effective Date',
        'intro_title' => 'Introduction',
        'intro_text' => 'At 41Software, we value your privacy.',
        'collect_title' => 'Information Collected',
        'points' => '<h3>Privacy Policy for PDF Toolkit</h3>
<li><strong>Effective Date:</strong> November 14, 2025</li>
<li><strong>Last Updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<li>PDF Toolkit ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how PDF Toolkit handles your information when you use our mobile application.</li>
<h3>Information We Collect</h3>
<h3>Data Processed Locally</h3>
<p>PDF Toolkit processes all PDF files and documents <strong>locally on your device</strong>. We do not upload, store, or transmit any of your PDF files, documents, images, or personal data to our servers or any third-party servers.</p>
<li>The app may access:</li>
<li>PDF files you select for processing</li>
<li>Device storage (with your permission) to save processed files</li>
<li>Camera or photo gallery (with your permission) when using certain features</li>
<h3>How We Use Your Information</h3>
<li><strong>File Processing:</strong> All PDF operations (merge, split, compress, encrypt, etc.) happen entirely on your device</li>
<li><strong>Settings Storage:</strong> Your app preferences (theme, save location) are stored locally using SharedPreferences</li>
<h3>Data Sharing</h3>
<li>We <strong>do not sell, rent, or share</strong> your personal information or PDF content with third parties, except:</li>
<li><strong>Legal Requirements:</strong> If required by law or to protect our rights</li>
<h3>Your Rights and Choices</h3>
<li>You have the right to:</li>
<li><strong>Delete Data:</strong> Uninstall the app to remove all locally stored data</li>
<li><strong>Control Permissions:</strong> Manage storage and file access permissions in device settings</li>
<li><strong>Contact Us:</strong> Request information about your data</li>
<h3>Data Security</h3>
<li>All file processing happens <strong>offline</strong> on your device</li>
<li>No PDF content is transmitted over the internet</li>
<li>App settings are stored securely using encrypted SharedPreferences</li>
<li>We implement industry-standard security measures</li>
<h3>Children\'s Privacy</h3>
<li>PDF Toolkit does not knowingly collect information from children under 13. If you are a parent or guardian and believe your child has provided us with information, please contact us.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Changes will be posted on our website and within the app. Continued use of the app after changes constitutes acceptance of the updated policy.</li>
<h3>Contact Us</h3>
<li>If you have any questions or concerns about this Privacy Policy or your data:</li>
<li><strong>41 Software</strong></li>
<li>Website: [www.41software.com](https://www.41software.com)</li>
<li>Email: [info@41software.com](mailto:info@41software.com)</li>
<li>Privacy Policy URL: [https://www.41software.com/privacy/privacy_pdftoolkit.pdf](https://www.41software.com/privacy/privacy_pdftoolkit.pdf)</li>
<li><strong>Summary:</strong></li>
<li>✅ All PDF files are processed locally on your device</li>
<li>✅ No PDF content is uploaded to servers</li>
<li>✅ You control your data and permissions</li>',
        'security_title' => 'Security',
        'security_text' => 'Your data is stored locally on your device.',
        'contact_title' => 'Contact Us',
        'contact_text' => 'For questions and support regarding our privacy policy.',
        'last_updated' => 'Last Updated:'
    ],
    'de' => [
        'title' => 'Datenschutzerklärung - ' . $appName,
        'home' => 'Startseite',
        'effective_date' => 'Gültig ab',
        'intro_title' => 'Einführung',
        'intro_text' => 'Bei 41Software legen wir Wert auf Ihre Privatsphäre.',
        'collect_title' => 'Gesammelte Daten',
        'points' => '<h3>Privacy Policy for PDF Toolkit</h3>
<li><strong>Effective Date:</strong> November 14, 2025</li>
<li><strong>Last Updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<li>PDF Toolkit ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how PDF Toolkit handles your information when you use our mobile application.</li>
<h3>Information We Collect</h3>
<h3>Data Processed Locally</h3>
<p>PDF Toolkit processes all PDF files and documents <strong>locally on your device</strong>. We do not upload, store, or transmit any of your PDF files, documents, images, or personal data to our servers or any third-party servers.</p>
<li>The app may access:</li>
<li>PDF files you select for processing</li>
<li>Device storage (with your permission) to save processed files</li>
<li>Camera or photo gallery (with your permission) when using certain features</li>
<h3>How We Use Your Information</h3>
<li><strong>File Processing:</strong> All PDF operations (merge, split, compress, encrypt, etc.) happen entirely on your device</li>
<li><strong>Settings Storage:</strong> Your app preferences (theme, save location) are stored locally using SharedPreferences</li>
<h3>Data Sharing</h3>
<li>We <strong>do not sell, rent, or share</strong> your personal information or PDF content with third parties, except:</li>
<li><strong>Legal Requirements:</strong> If required by law or to protect our rights</li>
<h3>Your Rights and Choices</h3>
<li>You have the right to:</li>
<li><strong>Delete Data:</strong> Uninstall the app to remove all locally stored data</li>
<li><strong>Control Permissions:</strong> Manage storage and file access permissions in device settings</li>
<li><strong>Contact Us:</strong> Request information about your data</li>
<h3>Data Security</h3>
<li>All file processing happens <strong>offline</strong> on your device</li>
<li>No PDF content is transmitted over the internet</li>
<li>App settings are stored securely using encrypted SharedPreferences</li>
<li>We implement industry-standard security measures</li>
<h3>Children\'s Privacy</h3>
<li>PDF Toolkit does not knowingly collect information from children under 13. If you are a parent or guardian and believe your child has provided us with information, please contact us.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Changes will be posted on our website and within the app. Continued use of the app after changes constitutes acceptance of the updated policy.</li>
<h3>Contact Us</h3>
<li>If you have any questions or concerns about this Privacy Policy or your data:</li>
<li><strong>41 Software</strong></li>
<li>Website: [www.41software.com](https://www.41software.com)</li>
<li>Email: [info@41software.com](mailto:info@41software.com)</li>
<li>Privacy Policy URL: [https://www.41software.com/privacy/privacy_pdftoolkit.pdf](https://www.41software.com/privacy/privacy_pdftoolkit.pdf)</li>
<li><strong>Summary:</strong></li>
<li>✅ All PDF files are processed locally on your device</li>
<li>✅ No PDF content is uploaded to servers</li>
<li>✅ You control your data and permissions</li>',
        'security_title' => 'Sicherheit',
        'security_text' => 'Ihre Daten werden lokal auf Ihrem Gerät gespeichert.',
        'contact_title' => 'Kontakt',
        'contact_text' => 'Bei Fragen wenden Sie sich bitte an uns.',
        'last_updated' => 'Aktualisiert am:'
    ]
];
$c = $content[$lang];
?>
<!DOCTYPE html>
<html lang="<?php echo $lang; ?>">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $c['title']; ?></title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            line-height: 1.6;
            padding: 20px;
            background: #f4f7f9;
            color: #333;
        }

        .container {
            max-width: 850px;
            margin: auto;
            background: #fff;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }

        h1 {
            color: #1e3a8a;
            border-bottom: 3px solid #3b82f6;
            padding-bottom: 10px;
        }

        h2 {
            color: #1e40af;
            margin-top: 30px;
            border-left: 5px solid #3b82f6;
            padding-left: 15px;
        }

        h3 {
            color: #374151;
            background: #f3f4f6;
            padding: 10px;
            border-radius: 5px;
        }

        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 20px 0;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-block;
            padding: 12px 24px;
            text-decoration: none;
            background: #3b82f6;
            color: white;
            border-radius: 8px;
            font-weight: bold;
            transition: 0.3s;
        }

        .btn:hover {
            background: #1d4ed8;
            transform: translateY(-2px);
        }

        .lang-switch {
            text-align: right;
            margin-bottom: 15px;
        }

        .btn-lang {
            padding: 6px 15px;
            background: #fff;
            border: 1px solid #ddd;
            font-size: 0.8em;
        }

        .btn-lang.active {
            background: #3b82f6;
            color: #fff;
        }

        ul {
            list-style-type: none;
            padding: 0;
        }

        li {
            margin-bottom: 12px;
            padding-left: 30px;
            position: relative;
        }

        li::before {
            content: "🔹";
            position: absolute;
            left: 0;
        }

        hr {
            margin: 40px 0;
            border: 0;
            border-top: 1px solid #eee;
        }
    </style>
</head>

<body>
    <div class="lang-switch">
        <a href="?lang=tr" class="btn btn-lang <?php echo $lang == 'tr' ? 'active' : ''; ?>">TR</a>
        <a href="?lang=de" class="btn btn-lang <?php echo $lang == 'de' ? 'active' : ''; ?>">DE</a>
        <a href="?lang=en" class="btn btn-lang <?php echo $lang == 'en' ? 'active' : ''; ?>">EN</a>
    </div>
    <div class="container">
        <div class="nav-buttons">
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (TR)</a>
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (DE)</a>
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (EN)</a>
        </div>
        <h1><?php echo $c['title']; ?></h1>
        <p><strong><?php echo $c['effective_date']; ?>:</strong> <?php echo date('d.m.Y'); ?></p>
        <h2><?php echo $c['intro_title']; ?></h2>
        <p><?php echo $c['intro_text']; ?></p>
        <h2><?php echo $c['collect_title']; ?></h2>
        <div class="policy-content">
            <ul><?php echo $c['points']; ?></ul>
        </div>
        <h2><?php echo $c['security_title']; ?></h2>
        <p><?php echo $c['security_text']; ?></p>
        <h2><?php echo $c['contact_title']; ?></h2>
        <p><?php echo $c['contact_text']; ?></p>
        <p><strong>41Software</strong><br><a href="https://www.41software.com">www.41software.com</a><br>Email: info@41software.com</p>
        <div class="nav-buttons">
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (TR)</a>
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (DE)</a>
            <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (EN)</a>
        </div>
        <hr>
        <div class="footer-info">
            <p>&copy; <?php echo date('Y'); ?> 41Software</p>
        </div>
    </div>
</body>

</html>