<?php
$lang = isset($_GET['lang']) ? $_GET['lang'] : null;
if (!$lang) {
    $browser_lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'en', 0, 2);
    $supported_langs = ['tr', 'de', 'en'];
    $lang = in_array($browser_lang, $supported_langs) ? $browser_lang : 'en';
}
$appName = "Last updated: November 14, 2025";
$content = [
    'tr' => [
        'title' => 'Gizlilik Politikası - ' . $appName,
        'home' => 'Anasayfa',
        'effective_date' => 'Yürürlük Tarihi',
        'intro_title' => 'Giriş',
        'intro_text' => '41Software olarak gizliliğinize önem veriyoruz.',
        'collect_title' => 'Toplanan Veriler',
        'points' => '<h3>Privacy Policy - PDF Toolkit</h3>
<li><strong>Last updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<p>41 Software ("we", "our", or "us") operates the PDF Toolkit mobile application (the "Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service.</p>
<h3>Information Collection and Use</h3>
<h3>Personal Information</h3>
<li>PDF Toolkit does not collect, store, or transmit any personal information to external servers. All PDF processing operations are performed locally on your device.</li>
<h3>File Access</h3>
<li>The app requires access to your device\'s storage to:</li>
<li>Read PDF files you select for viewing and processing</li>
<li>Save processed PDF files to your chosen location</li>
<li>Access images for PDF conversion</li>
<h3>Permissions Required</h3>
<li><strong>Storage Access</strong>: To read and write PDF files</li>
<h3>Data Storage</h3>
<li>All PDF files and processed documents remain on your device. We do not:</li>
<li>Upload your files to any server</li>
<li>Store copies of your files</li>
<li>Share your files with third parties</li>
<h3>Children\'s Privacy</h3>
<li>Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.</li>
<h3>Changes to This Privacy Policy</h3>
<li>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li>Email: info@41software.com</li>
<li>Website: www.41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Access your data (all data is stored locally on your device)</li>
<li>Delete your data (uninstall the app)</li>
<li>© 2025 41 Software. All rights reserved.</li>',
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
        'points' => '<h3>Privacy Policy - PDF Toolkit</h3>
<li><strong>Last updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<p>41 Software ("we", "our", or "us") operates the PDF Toolkit mobile application (the "Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service.</p>
<h3>Information Collection and Use</h3>
<h3>Personal Information</h3>
<li>PDF Toolkit does not collect, store, or transmit any personal information to external servers. All PDF processing operations are performed locally on your device.</li>
<h3>File Access</h3>
<li>The app requires access to your device\'s storage to:</li>
<li>Read PDF files you select for viewing and processing</li>
<li>Save processed PDF files to your chosen location</li>
<li>Access images for PDF conversion</li>
<h3>Permissions Required</h3>
<li><strong>Storage Access</strong>: To read and write PDF files</li>
<h3>Data Storage</h3>
<li>All PDF files and processed documents remain on your device. We do not:</li>
<li>Upload your files to any server</li>
<li>Store copies of your files</li>
<li>Share your files with third parties</li>
<h3>Children\'s Privacy</h3>
<li>Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.</li>
<h3>Changes to This Privacy Policy</h3>
<li>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li>Email: info@41software.com</li>
<li>Website: www.41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Access your data (all data is stored locally on your device)</li>
<li>Delete your data (uninstall the app)</li>
<li>© 2025 41 Software. All rights reserved.</li>',
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
        'points' => '<h3>Privacy Policy - PDF Toolkit</h3>
<li><strong>Last updated:</strong> November 14, 2025</li>
<h3>Introduction</h3>
<p>41 Software ("we", "our", or "us") operates the PDF Toolkit mobile application (the "Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service.</p>
<h3>Information Collection and Use</h3>
<h3>Personal Information</h3>
<li>PDF Toolkit does not collect, store, or transmit any personal information to external servers. All PDF processing operations are performed locally on your device.</li>
<h3>File Access</h3>
<li>The app requires access to your device\'s storage to:</li>
<li>Read PDF files you select for viewing and processing</li>
<li>Save processed PDF files to your chosen location</li>
<li>Access images for PDF conversion</li>
<h3>Permissions Required</h3>
<li><strong>Storage Access</strong>: To read and write PDF files</li>
<h3>Data Storage</h3>
<li>All PDF files and processed documents remain on your device. We do not:</li>
<li>Upload your files to any server</li>
<li>Store copies of your files</li>
<li>Share your files with third parties</li>
<h3>Children\'s Privacy</h3>
<li>Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.</li>
<h3>Changes to This Privacy Policy</h3>
<li>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li>Email: info@41software.com</li>
<li>Website: www.41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Access your data (all data is stored locally on your device)</li>
<li>Delete your data (uninstall the app)</li>
<li>© 2025 41 Software. All rights reserved.</li>',
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