# Scripts de génération de la machine virtuelle de référence pour les contrôles en ligne

Ces scripts sont utilisés par le service des contrôles de la CNIL afin de générer une machine virtuelle de référence qui servira, par la suite, de base pour les machines virtuelles de chaque contrôle en ligne.

Ces scripts sont exécutés en plusieurs temps :

1. `create_vm.bat` est utilisé pour créer la machine virtuelle elle-même et la lance ;
2. `bootstrap.sh` est utilisé pour installer le système et lance `configure.sh` dès que le système est prêt ;
3. `configure.sh` est utilisé pour configurer le système et préparer la finalisation, notamment en installant `finalize_install.sh` et les données qui lui sont liées ;
4. `finalize_install.sh` est automatiquement lancé lors de la première connexion à la machine virtuelle et permet d’effectuer les derniers réglages, notamment l’installation de l’extension CNIL-Cookies-List et la vérification anti-malwares.

L'image ISO attendue lors de l'exécution de `create_vm.bat` est celle d’[ArchLinux][archlinux_download].

Ces scripts sont publiés sous la licence [CeCILL 2.1][cecill].

Pour en savoir plus au sujet des contrôles menés par la CNIL, veuillez consulter la [charte des contrôles][charte_controles].

[archlinux_download]: https://archlinux.org/download/
[cecill]: https://cecill.info/
[charte_controles]: https://www.cnil.fr/fr/controles-de-la-cnil-une-charte-pour-tout-comprendre