# Scripts de génération de la machine virtuelle de référence pour les contrôles en ligne

Ces scripts sont utilisés par le service des contrôles de la CNIL afin de générer une machine virtuelle de référence qui servira, par la suite, de base pour les machines virtuelles de chaque contrôle en ligne.

Ces scripts sont exécutés en 3 temps :

1. `create_vm.bat` est utilisé pour créer la machine virtuelle elle-même et la lance ;
2. `preseed.cfg` est utilisé pour automatiser l'installation de Debian sur la machine virtuelle ;
3. Lors de la première connexion de l'utilisateur de contrôle, `cnf/auto_install.desktop` lance automatiquement `finalize_install.sh` afin de finaliser la préparation de la machine virtuelle.

Ces scripts sont publiés sous la licence [CeCILL 2.1][cecill].

Pour en savoir plus au sujet des contrôles menés par la CNIL, veuillez consulter la [charte des contrôles][charte_controles].

[charte_controles]: https://www.cnil.fr/fr/controles-de-la-cnil-une-charte-pour-tout-comprendre
[cecill]: http://cecill.info/
