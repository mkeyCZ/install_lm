#!/bin/bash

# Skript pro aktualizaci systému a instalaci balíčků pomocí apt a flatpak

# Funkce pro kontrolu, zda je skript spuštěn s právy superuživatele
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Tento skript musí být spuštěn s právy superuživatele (sudo) pro operace s apt."
    exit 1
  fi
}

# Přidání potřebných PPA repozitářů
add_ppa_repositories() {
  echo "Přidávání PPA repozitářů pro onlyoffice-desktopeditors, grub-customizer a discord..."
  
  # PPA pro OnlyOffice Desktop Editors
  sudo add-apt-repository ppa:onlyoffice/desktopeditors -y
  
  # PPA pro Grub Customizer
  sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
  
  # PPA pro Discord
  sudo add-apt-repository ppa:ubuntu-desktop/ubuntu-make -y
  
  sudo apt update
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

# Seznam balíčků pro apt a flatpak
apt_packages=("kodi" "vlc" "audacity" "easytag" "handbrake" "kdenlive" "obs-studio" "onlyoffice-desktopeditors" "gimp" "krita" "virtualbox" "grub-customizer" "discord")
flatpak_packages=("com.github.tchx84.Flatseal" "com.spotify.Client" "com.visualstudio.code" "com.discordapp.Discord" "com.bitwarden.desktop")

# Funkce pro instalaci všech balíčků pomocí apt s kontrolou nainstalovaných balíčků
install_all_apt_packages() {
  echo "Instalace všech balíčků pomocí apt..."
  for package in "${apt_packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
      echo "$package je již nainstalován, přeskočeno."
    else
      echo "Instalace $package..."
      if sudo apt install -y "$package"; then
        echo "$package byl úspěšně nainstalován."
      else
        echo "Chyba při instalaci $package." >&2
      fi
    fi
  done
}

# Funkce pro instalaci aplikací pomocí flatpak s kontrolou nainstalovaných balíčků
install_flatpak_if_not_in_apt() {
  for package in "${flatpak_packages[@]}"; do
    app_name=$(echo "$package" | awk -F '.' '{print $NF}')
    
    # Zkontrolujeme, zda je balíček dostupný v apt
    if ! apt-cache show "$app_name" &>/dev/null; then
      # Zkontrolujeme, zda je již balíček nainstalován přes flatpak
      if flatpak list | grep -q "$package"; then
        echo "$app_name je již nainstalován pomocí flatpak, přeskočeno."
      else
        echo "$app_name není dostupný v apt. Instalace pomocí flatpak..."
        if flatpak install -y "$package"; then
          echo "$app_name byl úspěšně nainstalován pomocí flatpak."
        else
          echo "Chyba při instalaci $app_name pomocí flatpak." >&2
        fi
      fi
    else
      echo "$app_name je dostupný v apt. Přeskočeno."
    fi
  done
}

# Interaktivní výběr balíčků k instalaci pomocí apt
select_apt_packages() {
  echo "Vyberte balíčky, které chcete nainstalovat pomocí apt:"
  selected_packages=()

  for package in "${apt_packages[@]}"; do
    read -p "Chcete nainstalovat $package? (y/n) " yn
    case $yn in
      [Yy]*) selected_packages+=("$package");;
      [Nn]*) ;;
      *) echo "Neplatná volba. Přeskočeno.";;
    esac
  done

  if [ ${#selected_packages[@]} -eq 0 ]; then
    echo "Žádné balíčky k instalaci pomocí apt nebyly vybrány."
  else
    echo "Instalace vybraných balíčků pomocí apt..."
    for package in "${selected_packages[@]}"; do
      if dpkg -l | grep -q "^ii  $package "; then
        echo "$package je již nainstalován, přeskočeno."
      else
        echo "Instalace $package..."
        if sudo apt install -y "$package"; then
          echo "$package byl úspěšně nainstalován."
        else
          echo "Chyba při instalaci $package." >&2
        fi
      fi
    done
  fi
}

# Funkce pro zobrazení nápovědy
show_help() {
  echo "Použití: $0 [volba]"
  echo "  -u, --update       Aktualizovat systém pomocí apt a flatpak"
  echo "  -i, --install      Nabídne interaktivní instalaci balíčků pomocí apt a flatpak"
  echo "  -ia, --install-all Nainstalovat všechny balíčky pomocí apt a flatpak"
  echo "  -h, --help         Zobrazit tuto nápovědu"
}

# Zpracování argumentů příkazové řádky
case "$1" in
  -u|--update)
    update_system_apt
    update_system_flatpak
    ;;
  -i|--install)
    select_apt_packages
    install_flatpak_if_not_in_apt
    ;;
  -ia|--install-all)
    add_ppa_repositories
    install_all_apt_packages
    install_flatpak_if_not_in_apt
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
