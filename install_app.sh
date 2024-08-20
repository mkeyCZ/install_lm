#!/bin/bash

# Barvy pro lepší vizuální vzhled
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funkce pro kontrolu, zda je skript spuštěn s právy superuživatele
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Tento skript musí být spuštěn s právy superuživatele (sudo) pro operace s apt.${NC}"
    exit 1
  fi
}

# Definice seznamu balíčků
apt_packages=("kodi" "vlc" "audacity" "easytag" "handbrake" "kdenlive" "obs-studio" "gimp" "krita" "virtualbox" "ttf-mscorefonts-installer")
deb_packages=("Discord" "OnlyOffice Desktop Editors" "Subtitle Edit")
flatpak_packages=("com.spotify.Client" "com.visualstudio.code" "com.bitwarden.desktop")

# Funkce pro zobrazení seznamu všech aplikací, které skript obsahuje
show_applications() {
  echo -e "${YELLOW}Tento skript nainstaluje následující aplikace:${NC}"
  echo ""
  echo -e "${GREEN}APT balíčky:${NC}"
  for package in "${apt_packages[@]}"; do
    echo "- $package"
  done
  echo ""
  echo -e "${GREEN}.deb balíčky:${NC}"
  for package in "${deb_packages[@]}"; do
    echo "- $package"
  done
  echo ""
  echo -e "${GREEN}Flatpak balíčky:${NC}"
  for package in "${flatpak_packages[@]}"; do
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    echo "- $app_name"
  done
  echo ""
  echo -e "${GREEN}Microsoft fonty:${NC}"
  echo "- ttf-mscorefonts-installer"
  echo ""
}

# Funkce pro uživatelskou volbu pokračování s instalací
prompt_continue_installation() {
  read -p "Chcete pokračovat s instalací těchto balíčků? (y/n): " choice
  case "$choice" in 
    y|Y ) echo -e "${GREEN}Pokračujeme s instalací...${NC}";;
    n|N ) echo -e "${YELLOW}Instalace byla zrušena uživatelem.${NC}"; exit;;
    * ) echo -e "${RED}Neplatná volba. Instalační proces ukončen.${NC}"; exit 1;;
  esac
}

# Funkce pro aktualizaci systému pomocí apt
update_system_apt() {
  echo -e "${YELLOW}Aktualizace systému pomocí apt...${NC}"
  if sudo apt update && sudo apt upgrade -y; then
    echo -e "${GREEN}Systém byl úspěšně aktualizován pomocí apt.${NC}"
  else
    echo -e "${RED}Chyba při aktualizaci systému pomocí apt.${NC}" >&2
  fi
  echo ""
}

# Funkce pro aktualizaci aplikací nainstalovaných pomocí flatpak
update_system_flatpak() {
  echo -e "${YELLOW}Aktualizace aplikací nainstalovaných pomocí flatpak...${NC}"
  if flatpak update -y; then
    echo -e "${GREEN}Aplikace nainstalované pomocí flatpak byly úspěšně aktualizovány.${NC}"
  else
    echo -e "${RED}Chyba při aktualizaci aplikací pomocí flatpak.${NC}" >&2
  fi
  echo ""
}

# Funkce pro instalaci všech balíčků pomocí apt s kontrolou nainstalovaných balíčků
install_all_apt_packages() {
  total_packages=${#apt_packages[@]}
  echo -e "${YELLOW}Instalace balíčků z apt...${NC}"
  for i in "${!apt_packages[@]}"; do
    package=${apt_packages[$i]}
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo -e "[${GREEN}$percentage%${NC}] $package"
    if dpkg -l | grep -q "^ii  $package "; then
      echo -e "${YELLOW}$package je již nainstalován, přeskočeno.${NC}"
    else
      if sudo apt install -y "$package"; then
        echo -e "${GREEN}Instalace aplikace $package dokončena.${NC}"
      else
        echo -e "${RED}Chyba při instalaci $package.${NC}" >&2
      fi
    fi
  done
  echo -e "${GREEN}Instalace balíčků z apt dokončena.${NC}"
  echo ""
}

# Funkce pro stažení a instalaci Discord, OnlyOffice, a Subtitle Edit pomocí .deb balíčků
install_deb_packages() {
  echo -e "${YELLOW}Instalace balíčků z .deb...${NC}"
  total_packages=${#deb_packages[@]}

  for i in "${!deb_packages[@]}"; do
    package=${deb_packages[$i]}
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo -e "[${GREEN}$percentage%${NC}] $package"
    
    if dpkg -l | grep -q "^ii  ${package,,} "; then
      echo -e "${YELLOW}$package je již nainstalován, přeskočeno.${NC}"
    else
      if [ "$package" == "Discord" ]; then
        echo -e "${YELLOW}Stahování Discord...${NC}"
        wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        echo -e "${YELLOW}Instalace Discord...${NC}"
        sudo dpkg -i discord.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm discord.deb
      elif [ "$package" == "OnlyOffice Desktop Editors" ]; then
        echo -e "${YELLOW}Stahování OnlyOffice Desktop Editors...${NC}"
        wget -O onlyoffice-desktopeditors.deb "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
        echo -e "${YELLOW}Instalace OnlyOffice Desktop Editors...${NC}"
        sudo dpkg -i onlyoffice-desktopeditors.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm onlyoffice-desktopeditors.deb
      elif [ "$package" == "Subtitle Edit" ]; then
        echo -e "${YELLOW}Stahování Subtitle Edit...${NC}"
        wget -O subtitleedit.deb "https://github.com/SubtitleEdit/subtitleedit/releases/download/3.6.13/subtitleedit_3.6.13-1_amd64.deb"
        echo -e "${YELLOW}Instalace Subtitle Edit...${NC}"
        sudo dpkg -i subtitleedit.deb
        sudo apt-get install -f -y  # Řešení závislostí
        rm subtitleedit.deb
      fi
      echo -e "${GREEN}Instalace aplikace $package dokončena.${NC}"
    fi
  done
  echo -e "${GREEN}Instalace balíčků z .deb dokončena.${NC}"
  echo ""
}

# Funkce pro instalaci aplikací pomocí flatpak s kontrolou nainstalovaných balíčků
install_flatpak_if_not_in_apt() {
  total_packages=${#flatpak_packages[@]}
  echo -e "${YELLOW}Instalace balíčků z Flathub...${NC}"
  
  for i in "${!flatpak_packages[@]}"; do
    package=${flatpak_packages[$i]}
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo -e "[${GREEN}$percentage%${NC}] $app_name"
    
    # Zkontrolujeme, zda je balíček dostupný v apt
    if ! apt-cache show "$app_name" &>/dev/null; then
      # Zkontrolujeme, zda je již balíček nainstalován přes flatpak
      if flatpak list | grep -q "$package"; then
        echo -e "${YELLOW}$app_name je již nainstalován pomocí flatpak, přeskočeno.${NC}"
      else
        if flatpak install -y "$package"; then
          echo -e "${GREEN}Instalace aplikace $app_name dokončena.${NC}"
        else
          echo -e "${RED}Chyba při instalaci $app_name pomocí flatpak.${NC}" >&2
        fi
      fi
    else
      echo -e "${YELLOW}$app_name je dostupný v apt. Přeskočeno.${NC}"
    fi
  done
  echo -e "${GREEN}Instalace balíčků z Flathub dokončena.${NC}"
  echo ""
}

# Funkce pro zobrazení nápovědy
show_help() {
  echo -e "${YELLOW}Použití: $0 [volba]${NC}"
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
    show_applications
    prompt_continue_installation
    install_all_apt_packages
    install_deb_packages
    install_flatpak_if_not_in_apt
    ;;
  -ia|--install-all)
    show_applications
    prompt_continue_installation
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
    echo -e "${RED}Neplatná volba: $1${NC}"
    show_help
    exit 1
    ;;
esac

# Odkaz na autora skriptu
echo ""
echo -e "${GREEN}---------------------------------------------${NC}"
echo -e "${GREEN}  Operace dokončena! Děkuji za použití tohoto skriptu.${NC}"
echo ""
echo "  Další informace a projekty najdete zde:"
echo ""
echo "  🖥️  Fórum:    https://forum.linuxdoma.cz/u/mates/activity"
echo "  📚  Wiki:     https://wiki.matejserver.cz"
echo "  💻  GitHub:   https://github.com/mkeyCZ/"
echo -e "${GREEN}---------------------------------------------${NC}"
echo ""
