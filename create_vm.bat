@echo off

:: Documentation de l'interface en ligne de commande de VirtualBox
:: https://www.virtualbox.org/manual/ch08.html

:: Récupération des informations
set /p VmName=Indiquez le nom de la machine virtuelle : 
set /p IsoPath=Indiquez le chemin vers l'image ISO : 

:: Création de la VM
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name "%VmName%" --ostype "ArchLinux_64" --register

:: Paramétrage de la VM
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --memory 32086
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --cpus 8
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --pae on
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --graphicscontroller vmsvga
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --nic1 bridged
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --bridgeadapter1 "Realtek PCIe GbE Family Controller"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --usbxhci on
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --clipboard-mode bidirectional
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VmName%" --vram 128

:: Disque dur
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl "%VmName%" --name "SATA" --add sata --controller IntelAhci
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createmedium disk --format VDI --size 20000 --filename "%UserProfile%\VirtualBox VMs\%VmName%\%VmName%.vdi"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "%VmName%" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "%UserProfile%\VirtualBox VMs\%VmName%\%VmName%.vdi"

:: Image ISO du système
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl "%VmName%" --name "IDE" --add ide --controller PIIX4
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach "%VmName%" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "%IsoPath%"

:: Dossier partagé
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" sharedfolder add "%VmName%" --name "PiecesNumeriques" --hostpath "C:\PiecesNumeriques" --automount

:: Démarrage de la VM
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "%VmName%"
