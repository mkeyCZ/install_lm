#!/bin/bash

# Skript pro aktualizaci systému a instalaci balíčků pomocí apt, flatpak a .deb

# Funkce pro kontrolu, zda je skript spuštěn s právy superuživatele
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Tento skript musí být spuštěn s právy superuživatele (sudo) pro operace s apt."
    exit 1
  fi
}

# Funkce pro zobrazení seznamu všech aplikací, které skript obsahuje
show_applications() {
  echo "Tento skript obsahuje následující aplikace k instalaci:"
  echo ""
  echo "APT balíčky:"
  for package in "${apt_packages[@]}"; do
    echo "- $package"
  done
  echo ""
  echo ".deb balíčky:"
  echo "- Discord"
  echo "- OnlyOffice Desktop Editors"
  echo "- Subtitle Edit"
  echo ""
  echo "Flatpak balíčky:"
  for package in "${flatpak_packages[@]}"; do
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    echo "- $app_name"
  done
  echo ""
  echo "Microsoft fonty:"
  echo "- ttf-mscorefonts-installer"
  echo ""
}

# Funkce pro aktualizaci systému pomocí apt
update_system_apt() {
  echo "Aktualizace systému pomocí apt..."
  if sudo apt update && sudo apt upgrade -y; then
    echo "Systém byl úspěšně aktualizován pomocí apt."
  else
    echo "Chyba při aktualizaci systému pomocí apt." >&2
  fi
}

# Funkce pro aktualizaci aplikací nainstalovaných pomocí flatpak
update_system_flatpak() {
  echo "Aktualizace aplikací nainstalovaných pomocí flatpak..."
  if flatpak update -y; then
    echo "Aplikace nainstalované pomocí flatpak byly úspěšně aktualizovány."
  else
    echo "Chyba při aktualizaci aplikací pomocí flatpak." >&2
  fi
}

# Seznam balíčků pro apt (včetně Microsoft fontů)
apt_packages=("kodi" "vlc" "audacity" "easytag" "handbrake" "kdenlive" "obs-studio" "gimp" "krita" "virtualbox" "ttf-mscorefonts-installer")

# Funkce pro instalaci všech balíčků pomocí apt s kontrolou nainstalovaných balíčků
install_all_apt_packages() {
  total_packages=${#apt_packages[@]}
  echo "Instalace balíčků z apt..."
  for i in "${!apt_packages[@]}"; do
    package=${apt_packages[$i]}
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo "[$percentage%] $package"
    if dpkg -l | grep -q "^ii  $package "; then
      echo "$package je již nainstalován, přeskočeno."
    else
      if sudo apt install -y "$package"; then
        echo "Instalace aplikace $package dokončena."
      else
        echo "Chyba při instalaci $package." >&2
      fi
    fi
  done
  echo "Instalace balíčků z apt dokončena."
}

# Funkce pro stažení a instalaci Discord, OnlyOffice, a Subtitle Edit pomocí .deb balíčků
install_deb_packages() {
  echo "Instalace balíčků z .deb..."
  # Discord, OnlyOffice Desktop Editors, a Subtitle Edit
  deb_packages=("discord" "onlyoffice-desktopeditors" "subtitleedit")
  total_packages=${#deb_packages[@]}

  # Stažení a instalace balíčků
  for i in "${!deb_packages[@]}"; do
    percentage=$(( (i + 1) * 100 / total_packages ))
    package=${deb_packages[$i]}
    echo "[$percentage%] $package"
    
    if dpkg -l | grep -q "^ii  $package "; then
      echo "$package je již nainstalován, přeskočeno."
    else
      if [ "$package" == "discord" ]; then
        echo "Stahování Discord..."
        wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        echo "Instalace Discord..."
        sudo dpkg -i discord.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm discord.deb
      elif [ "$package" == "onlyoffice-desktopeditors" ]; then
        echo "Stahování OnlyOffice Desktop Editors..."
        wget -O onlyoffice-desktopeditors.deb "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
        echo "Instalace OnlyOffice Desktop Editors..."
        sudo dpkg -i onlyoffice-desktopeditors.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm onlyoffice-desktopeditors.deb
      elif [ "$package" == "subtitleedit" ]; then
        echo "Stahování Subtitle Edit..."
        wget -O subtitleedit.deb "https://github.com/SubtitleEdit/subtitleedit/releases/download/3.6.13/subtitleedit_3.6.13-1_amd64.deb"
        echo "Instalace Subtitle Edit..."
        sudo dpkg -i subtitleedit.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm subtitleedit.deb
      fi
      echo "Instalace aplikace $package dokončena."
    fi
  done
  echo "Instalace balíčků z .deb dokončena."
}

# Funkce pro instalaci aplikací pomocí flatpak s kontrolou nainstalovaných balíčků
install_flatpak_if_not_in_apt() {
  flatpak_packages=("com.spotify.Client" "com.visualstudio.code" "com.bitwarden.desktop")
  total_packages=${#flatpak_packages[@]}
  echo "Instalace balíčků z Flathub..."
  
  for i in "${!flatpak_packages[@]}"; do
    package=${flatpak_packages[$i]}
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo "[$percentage%] $app_name"
    
    # Zkontrolujeme, zda je balíček dostupný v apt
    if ! apt-cache show "$app_name" &>/dev/null; then
      # Zkontrolujeme, zda je již balíček nainstalován přes flatpak
      if flatpak list | grep -q "$package"; then
        echo "$app_name je již nainstalován pomocí flatpak, přeskočeno."
      else
        if flatpak install -y "$package"; then
          echo "Instalace aplikace $app_name dokončena."
        else
          echo "Chyba při instalaci $app_name pomocí flatpak." >&2
        fi
      fi
    else
      echo "$app_name je dostupný v apt. Přeskočeno."
    fi
  done
  echo "Instalace balíčků z Flathub dokončena."
}

# Funkce pro zobrazení nápovědy
show_help() {
  echo "Použití: $0 [volba]"
  echo "  -u, --update       Aktualizovat systém pomocí apt a flatpak"
  echo "  -i, --install      Nabídne interaktivní instalaci balíčků pomocí apt, flatpak a .deb"
  echo "  -ia, --install-all Nainstalovat všechny balíčky pomocí apt, flatpak a .deb"
  echo "  -a, --apps         Zobrazit seznam aplikací zahrnutých ve skriptu"
}

# Zpracování argumentů příkazové řádky
case "$1" in
  -u|--update)
    update_system_apt
    update_system_flatpak
    ;;
  -i|--install)
    install_all_apt_packages
    install_deb_packages
    install_flatpak_if_not_in_apt
    ;;
  -ia|--install-all)
    install_all_apt_packages
    install_deb_packages
    install_flatpak_if_not_in_apt
    ;;
  -a|--apps)
    show_applications
    ;;
  -h|--help)
    show_help
    ;;
  *)
    echo "Neplatná volba: $1"
    show_help
    exit 1
    ;;
esac

# Odkaz na autora skriptu
echo ""
echo "---------------------------------------------"
echo "  Operace dokončena! Děkuji za použití tohoto skriptu."
echo ""
echo "  Další informace a projekty najdete zde:"
echo ""
echo "  🖥️  Fórum:    https://forum.linuxdoma.cz/u/mates/activity"
echo "  📚  Wiki:     https://wiki.matejserver.cz"
echo "  💻  GitHub:   https://github.com/mkeyCZ/"
echo "---------------------------------------------"
echo ""
