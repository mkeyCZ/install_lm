# Instalační skript pro Linux Mint

*Skript byl testován na distribuci [Linux Mint](https://linuxmint.com/)*

![Linux Doma Logo](https://forum.linuxdoma.sk/uploads/default/original/1X/31a5d004a75873ce6dfdd07333ce730b6cc7f013.png)

## Popis

Tento skript je určen pro uživatele Linux Mint a automatizuje proces aktualizace systému a instalace softwaru pomocí `apt`, `.deb` balíčků a `flatpak`. Skript nabízí možnost nainstalovat všechny balíčky najednou nebo si interaktivně vybrat, které balíčky chcete nainstalovat.

## Funkce

- **Aktualizace systému**: Automaticky aktualizuje systém pomocí `apt`.
- **Instalace všech balíčků**: Instalace všech předdefinovaných balíčků najednou.
- **Interaktivní výběr balíčků**: Umožňuje interaktivní výběr balíčků k instalaci.
- **Instalace z `.deb` souborů**: Automatické stažení a instalace specifického softwaru pomocí `.deb` balíčků (např. Discord, OnlyOffice).
- **Podpora Flatpaku**: Instalace dalšího softwaru z Flathubu, pokud není dostupný přes `apt`.
- **Instalace Microsoft fontů**: Instalace Microsoft TrueType fontů pomocí `ttf-mscorefonts-installer`.

## Seznam aplikací

### APT balíčky

- Kodi
- VLC
- Audacity
- EasyTAG
- HandBrake
- Kdenlive
- OBS Studio
- GIMP
- Krita
- VirtualBox
- Microsoft TrueType Fonts (ttf-mscorefonts-installer)

### `.deb` balíčky

- Discord
- Subtitle edit
- OnlyOffice Desktop Editors

### Flatpak balíčky

- Spotify
- Visual Studio Code
- Bitwarden

## Instalace a použití

### 1. Klonování repozitáře

Klonujte tento repozitář do vašeho systému:

```bash
git clone https://github.com/mkeyCZ/install_lm.git
cd install_lm
```

### 2. Spuštění skriptu

Ujistěte se, že máte potřebná oprávnění ke spuštění skriptu. Podle vašich potřeb můžete skript spustit s různými volbami:

- **Aktualizace systému:**

  ```bash
  sudo ./install_app.sh --update
  ```

- **Instalace všech balíčků:**

  ```bash
  sudo ./install_app.sh --install-all
  ```

- **Interaktivní výběr balíčků:**

  ```bash
  sudo ./install_app.sh --install
  ```

- **Zobrazení seznamu zahrnutých aplikací:**

  ```bash
  ./install_app.sh --apps
  ```

### 3. Poznámky

- Skript vyžaduje práva superuživatele (`sudo`) pro operace s `apt`.
- `.deb` balíčky jsou stahovány z oficiálních zdrojů a instalovány lokálně.
- Pro další aplikace, které nejsou dostupné přes `apt`, se využívá `flatpak`.

## Chyby a zpětná vazba

Pokud narazíte na chyby nebo máte návrhy na vylepšení, neváhejte mě kontaktovat. Uvítám jakoukoliv zpětnou vazbu, včetně logů chyb.

## Autor

Další informace a projekty naleznete na:

- Fórum: [Linuxdoma](https://forum.linuxdoma.cz/u/mates/activity)
- Wiki: [Wiki](https://wiki.matejserver.cz)
- GitHub: [GitHub](https://github.com/mkeyCZ/)
