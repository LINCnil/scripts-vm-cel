// Démarre sur une page blanche
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "about:blank");

// Désactive l'option "Afficher les suggestions de rechercher"
user_pref("browser.search.suggest.enabled", false);

// Supprime la barre de recherche de l'écran principal
user_pref("browser.search.widget.inNavBar", false);

// Masque les moteurs de recherche autre que Wikipédia
user_pref("browser.search.hiddenOneOffs", "Google,Amazon.fr,Bing,DuckDuckGo,eBay,Qwant");

// Empêche Firefox d’envoyer les URL tapées dans la barre de recherche à un service externe s’il n’arrive pas à les identifier correctement
user_pref("keyword.enabled", false);

// Désactive l'utilisation de Pocket (service sponsorisé)
user_pref("extensions.pocket.enabled", false);

// Désactive les mises à jour auto des extensions
user_pref("extensions.update.autoUpdateDefault", false);

// Conserve l'historique selectionnée (par défaut);
user_pref("places.history.enabled", true);
user_pref("browser.formfill.enable", true);

// Désactiver toutes les protections contre le pistage
user_pref("browser.contentblocking.category", "custom");
user_pref("pref.privacy.disable_button.tracking_protection_exceptions", false);
user_pref("privacy.trackingprotection.pbmode.enabled", false);

// Désactive le Header "Do not Track"
user_pref("privacy.donottrackheader.enabled", false);

// Désactive le blocage des popups
user_pref("dom.disable_open_during_load", false);

// Désactive les options de blocage de contenus trompeurs/dangereux
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("brower.safebrowsing.phising.enabled", false);

// Désactive les envois de rapports de plantage
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

// Pas de proxy
user_pref("network.proxy.type", 0);

// Désactive la MaJ auto des moteurs de recherche
user_pref("browser.search.update", false);

// Désactive la restrictions des sites par Mozilla
// https://support.mozilla.org/fr/kb/quarantaine-domaines
user_pref("extensions.quarantinedDomains.enabled", false);