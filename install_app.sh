#!/bin/bash

# Skript pro aktualizaci systému, instalaci balíčků pomocí apt, flatpak a deb,
# odinstalaci nepotřebných balíčků, vyčištění systému a nastavení VLC jako výchozího přehrávače

# Funkce pro kontrolu, zda je skript spuštěn s právy superuživatele
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Tento skript musí být spuštěn s právy superuživatele (sudo) pro operace s apt."
    exit 1
  fi
}

# Funkce pro zobrazení progresu
show_progress() {
  local current=$1
  local total=$2
  local app_name=$3
  local source=$4

  local percent=$(( (current * 100) / total ))
  echo -ne "[$percent%] $app_name z $source...\r"
}

# Funkce pro aktualizaci systému pomocí apt
update_system_apt() {
  echo "Aktualizace systému pomocí apt..."
  if sudo apt update -y &>/dev/null && sudo apt upgrade -y &>/dev/null; then
    echo "Systém byl úspěšně aktualizován pomocí apt."
  else
    echo "Chyba při aktualizaci systému pomocí apt." >&2
  fi
}

# Funkce pro aktualizaci aplikací nainstalovaných pomocí flatpak
update_system_flatpak() {
  echo "Aktualizace aplikací nainstalovaných pomocí flatpak..."
  if flatpak update -y &>/dev/null; then
    echo "Aplikace nainstalované pomocí flatpak byly úspěšně aktualizovány."
  else
    echo "Chyba při aktualizaci aplikací pomocí flatpak." >&2
  fi
}

# Seznam balíčků pro apt (bez grub-customizer)
apt_packages=("kodi" "vlc" "audacity" "easytag" "handbrake" "kdenlive" "obs-studio" "gimp" "krita" "virtualbox")

# Funkce pro instalaci všech balíčků pomocí apt s kontrolou nainstalovaných balíčků
install_all_apt_packages() {
  echo "Instalace balíčků z apt..."
  local total=${#apt_packages[@]}
  for i in "${!apt_packages[@]}"; do
    package=${apt_packages[$i]}
    if dpkg -l | grep -q "^ii  $package "; then
      show_progress $((i+1)) $total $package "APT (již nainstalováno)"
    else
      show_progress $((i+1)) $total $package "APT"
      sudo apt install -y "$package" &>/dev/null
    fi
  done
  echo -e "\nInstalace balíčků z apt dokončena."
}

# Funkce pro stažení a instalaci Discord a OnlyOffice pomocí .deb balíčků
install_deb_packages() {
  echo "Instalace balíčků z .deb..."
  
  # Seznam .deb balíčků
  deb_packages=("discord" "onlyoffice-desktopeditors")
  local total=${#deb_packages[@]}

  # Discord
  if dpkg -l | grep -q "^ii  discord "; then
    show_progress 1 $total "Discord" ".deb (již nainstalováno)"
  else
    show_progress 1 $total "Discord" ".deb"
    wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb" &>/dev/null
    sudo dpkg -i discord.deb &>/dev/null
    sudo apt-get install -f -y &>/dev/null  # Řešení závislostí
    rm discord.deb
  fi

  # OnlyOffice Desktop Editors
  if dpkg -l | grep -q "^ii  onlyoffice-desktopeditors "; then
    show_progress 2 $total "OnlyOffice Desktop Editors" ".deb (již nainstalováno)"
  else
    show_progress 2 $total "OnlyOffice Desktop Editors" ".deb"
    wget -O onlyoffice-desktopeditors.deb "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb" &>/dev/null
    sudo dpkg -i onlyoffice-desktopeditors.deb &>/dev/null
    sudo apt-get install -f -y &>/dev/null  # Řešení závislostí
    rm onlyoffice-desktopeditors.deb
  fi

  echo -e "\nInstalace balíčků z .deb dokončena."
}

# Funkce pro instalaci aplikací pomocí flatpak s kontrolou nainstalovaných balíčků
install_flatpak_if_not_in_apt() {
  flatpak_packages=("com.github.tchx84.Flatseal" "com.spotify.Client" "com.visualstudio.code" "com.bitwarden.desktop" "net.subtitleedit.SubtitleEdit")

  echo "Instalace balíčků z Flathub..."
  local total=${#flatpak_packages[@]}
  for i in "${!flatpak_packages[@]}"; do
    package=${flatpak_packages[$i]}
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    
    # Zkontrolujeme, zda je již balíček nainstalován přes flatpak
    if flatpak list | grep -q "$package"; then
      show_progress $((i+1)) $total $app_name "Flathub (již nainstalováno)"
    else
      show_progress $((i+1)) $total $app_name "Flathub"
      flatpak install -y "$package" &>/dev/null
    fi
  done
  echo -e "\nInstalace balíčků z Flathub dokončena."
}

# Funkce pro odinstalaci nepotřebných balíčků
remove_unwanted_packages() {
  echo "Odinstalace nepotřebných balíčků..."
  unwanted_packages=("matrix" "libreoffice*" "celluloid" "hypnotix" "rhythmbox")
  local total=${#unwanted_packages[@]}
  for i in "${!unwanted_packages[@]}"; do
    package=${unwanted_packages[$i]}
    if dpkg -l | grep -q "^ii  $package"; then
      show_progress $((i+1)) $total $package "Odinstalace"
      sudo apt purge -y "$package" &>/dev/null
      sudo apt autoremove -y &>/dev/null
    else
      show_progress $((i+1)) $total $package "Odinstalace (již odstraněno)"
    fi
  done
  echo -e "\nOdinstalace nepotřebných balíčků dokončena."
}

# Funkce pro vyčištění systému
clean_system() {
  echo "Čištění systému..."
  sudo apt autoremove -y &>/dev/null
  sudo apt autoclean -y &>/dev/null
  sudo apt clean -y &>/dev/null
  echo "Systém byl úspěšně vyčištěn."
}

# Funkce pro nastavení VLC jako výchozího přehrávače pro multimédia
set_vlc_as_default() {
  echo "Nastavení VLC jako výchozího přehrávače pro multimédia..."
  xdg-mime default vlc.desktop video/mp4 video/x-matroska video/webm video/x-flv video/mpeg audio/x-mpegurl audio/x-wav audio/mpeg
  echo "VLC byl úspěšně nastaven jako výchozí přehrávač."
}

# Funkce pro zobrazení nápovědy
show_help() {
  echo "Použití: $0 [volba]"
  echo "  -u, --update         Aktualizovat systém pomocí apt a flatpak"
  echo "  -i, --install        Instalace balíčků pomocí apt, flatpak a .deb"
  echo "  -ia, --install-all   Nainstalovat všechny balíčky, odinstalovat nepotřebné, vyčistit systém a nastavit VLC"
  echo "  -r, --remove         Odinstalovat nepotřebné balíčky"
  echo "  -c, --clean          Vyčistit systém"
  echo "  -v, --vlc            Nastavit VLC jako výchozí přehrávač pro multimédia"
  echo "  -h, --help           Zobrazit tuto nápovědu"
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
    remove_unwanted_packages
    clean_system
    set_vlc_as_default
    ;;
  -r|--remove)
    remove_unwanted_packages
    ;;
  -c|--clean)
    clean_system
    ;;
  -v|--vlc)
    set_vlc_as_default
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
