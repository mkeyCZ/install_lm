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

# Definice seznamu balíčků s přívětivými názvy
apt_packages=("Kodi" "VLC" "Audacity" "EasyTAG" "HandBrake" "Kdenlive" "OBS Studio" "GIMP" "Krita" "VirtualBox" "Microsoft TrueType Fonts (ttf-mscorefonts-installer)" "Midnight Commander" "Tmux" "Neofetch")
deb_packages=("Discord" "OnlyOffice Desktop Editors")
flatpak_packages=("com.spotify.Client" "com.visualstudio.code" "com.bitwarden.desktop")

# Seznam nechtěných balíčků k odinstalaci
unwanted_packages=("LibreOffice" "Celluloid" "Hypnotix" "Rhythmbox" "mintchat")

# Funkce pro zobrazení seznamu všech aplikací, které skript obsahuje
show_applications() {
  echo -e "${YELLOW}Tento skript nainstaluje následující aplikace:${NC}"
  echo ""
  echo -e "${GREEN}APT balíčky:${NC}"
  for package in "${apt_packages[@]}"; do
    echo "    $package"
  done
  echo ""
  echo -e "${GREEN}.deb balíčky:${NC}"
  for package in "${deb_packages[@]}"; do
    echo "    $package"
  done
  echo ""
  echo -e "${GREEN}Flatpak balíčky:${NC}"
  for package in "${flatpak_packages[@]}"; do
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    echo "    $app_name"
  done
  echo ""
  echo -e "${RED}Následující aplikace budou odinstalovány:${NC}"
  for package in "${unwanted_packages[@]}"; do
    echo "    $package"
  done
  echo ""
}

# Funkce pro odinstalaci nechtěných balíčků
remove_unwanted_packages() {
  echo -e "${YELLOW}Odinstalace nechtěných aplikací...${NC}"
  for package in "${unwanted_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
      echo -e "${YELLOW}Odinstalace $package...${NC}"
      if sudo apt remove --purge -y "$package"; then
        echo -e "${GREEN}$package byl úspěšně odinstalován.${NC}"
      else
        echo -e "${RED}Chyba při odinstalaci $package.${NC}" >&2
      fi
    else
      echo -e "${YELLOW}$package nebyl nalezen, přeskočeno.${NC}"
    fi
  done

  echo -e "${YELLOW}Odstranění dalších součástí LibreOffice...${NC}"
  sudo apt remove --purge -y libreoffice-core libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math libreoffice-base libreoffice-common
  echo -e "${GREEN}Odinstalace nechtěných aplikací dokončena.${NC}"
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
    # Převod názvu na název balíčku pro apt
    apt_package=$(echo "$package" | awk '{print tolower($1)}')
    if dpkg -l | grep -q "^ii  $apt_package "; then
      echo -e "${YELLOW}$package je již nainstalován, přeskočeno.${NC}"
    else
      if sudo apt install -y "$apt_package"; then
        echo -e "${GREEN}Instalace aplikace $package dokončena.${NC}"
      else
        echo -e "${RED}Chyba při instalaci $package.${NC}" >&2
      fi
    fi
  done
  echo -e "${GREEN}Instalace balíčků z apt dokončena.${NC}"
  echo ""
}

# Funkce pro stažení a instalaci Discord a OnlyOffice pomocí .deb balíčků
install_deb_packages() {
  echo -e "${YELLOW}Instalace balíčků z .deb...${NC}"
  total_packages=${#deb_packages[@]}

  for i in "${!deb_packages[@]}"; do
    package=${deb_packages[$i]}
    percentage=$(( (i + 1) * 100 / total_packages ))
    echo -e "[${GREEN}$percentage%${NC}] $package"
    
    # Kontrola instalace pomocí dpkg
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
    remove_unwanted_packages
    install_all_apt_packages
    install_deb_packages
    install_flatpak_if_not_in_apt
    ;;
  -ia|--install-all)
    show_applications
    prompt_continue_installation
    remove_unwanted_packages
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
