#!/bin/bash

# Skript pro aktualizaci systému a instalaci balíčků pomocí apt a flatpak

# Funkce pro kontrolu, zda je skript spuštěn s právy superuživatele
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Tento skript musí být spuštěn s právy superuživatele (sudo) pro operace s apt."
    exit 1
  fi
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

# Seznam balíčků pro apt a flatpak (přidán Discord a Bitwarden)
apt_packages=("kodi" "vlc" "audacity" "easytag" "handbrake" "kdenlive" "obs-studio" "onlyoffice-desktopeditors" "gimp" "krita" "virtualbox" "grub-customizer" "discord")
flatpak_packages=("com.github.tchx84.Flatseal" "com.spotify.Client" "com.visualstudio.code" "org.videolan.VLC" "org.gimp.GIMP" "com.discordapp.Discord" "com.bitwarden.desktop")

# Funkce pro instalaci všech balíčků pomocí apt
install_all_apt_packages() {
  echo "Instalace všech balíčků pomocí apt..."
  if sudo apt install -y "${apt_packages[@]}"; then
    echo "Všechny balíčky byly úspěšně nainstalovány pomocí apt."
  else
    echo "Chyba při instalaci balíčků pomocí apt." >&2
  fi
}

# Funkce pro instalaci všech balíčků pomocí flatpak
install_all_flatpak_packages() {
  echo "Instalace všech balíčků pomocí flatpak..."
  if flatpak install -y "${flatpak_packages[@]}"; then
    echo "Všechny balíčky byly úspěšně nainstalovány pomocí flatpak."
  else
    echo "Chyba při instalaci balíčků pomocí flatpak." >&2
  fi
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
    if sudo apt install -y "${selected_packages[@]}"; then
      echo "Vybrané balíčky byly úspěšně nainstalovány."
    else
      echo "Chyba při instalaci vybraných balíčků." >&2
    fi
  fi
}

# Interaktivní výběr balíčků k instalaci pomocí flatpak
select_flatpak_packages() {
  echo "Vyberte balíčky, které chcete nainstalovat pomocí flatpak:"
  selected_packages=()

  for package in "${flatpak_packages[@]}"; do
    read -p "Chcete nainstalovat $package? (y/n) " yn
    case $yn in
      [Yy]*) selected_packages+=("$package");;
      [Nn]*) ;;
      *) echo "Neplatná volba. Přeskočeno.";;
    esac
  done

  if [ ${#selected_packages[@]} -eq 0 ]; then
    echo "Žádné balíčky k instalaci pomocí flatpak nebyly vybrány."
  else
    echo "Instalace vybraných balíčků pomocí flatpak..."
    if flatpak install -y "${selected_packages[@]}"; then
      echo "Vybrané balíčky byly úspěšně nainstalovány."
    else
      echo "Chyba při instalaci vybraných balíčků." >&2
    fi
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
    select_flatpak_packages
    ;;
  -ia|--install-all)
    install_all_apt_packages
    install_all_flatpak_packages
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
