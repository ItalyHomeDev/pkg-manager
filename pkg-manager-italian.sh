#!/usr/bin/env bash
#
# pkg-menu.sh — Gestore Interattivo APT Professionale
# Versione: 2.1
# Autore: Bocaletto Luca
# Licenza: MIT
#
# Descrizione:
#   Script in Bash (senza dipendenze) che offre un menu colorato
#   per gestire APT su Debian e derivate. Supporta operazioni singole
#   (update, upgrade, dist-upgrade…), modalità “auto”, flag CLI, spinner
#   per il feedback e log dettagliato in /var/log/pkg-menu-*.log.
#
# Uso:
#   sudo ./pkg-menu.sh [OPZIONI]
#
# Opzioni:
#   -h, --help     Mostra questo aiuto ed esce
#   -v, --version  Mostra la versione ed esce
#   -a, --auto     Esegue manutenzione completa (update → upgrade → dist-upgrade → autoremove → autoclean)
#
# Log:
#   /var/log/pkg-menu-YYYYMMDD-HHMMSS.log
#

set -Eeuo pipefail
IFS=$'\n\t'

### ── Configurazione & Logging ────────────────────────────────────────────────
readonly VERSIONE="2.1"
readonly LOG_DIR="/var/log"
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly LOG_FILE="${LOG_DIR}/pkg-menu-${TIMESTAMP}.log"

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"
# Duplica stdout/stderr su console e file di log
exec > >(tee -a "${LOG_FILE}") 2>&1

### ── Colori & Formattazione ─────────────────────────────────────────────────
_ROSSO=$(tput setaf 1);    _VERDE=$(tput setaf 2)
_GIALLO=$(tput setaf 3);   _BLU=$(tput setaf 4)
_GRAS=$(tput bold);         _RESET=$(tput sgr0)

info()    { printf "%s [ INFO ]%s %s\n" "${_BLU}${_GRAS}" "${_RESET}" "$*"; }
success() { printf "%s [  OK  ]%s %s\n" "${_VERDE}${_GRAS}" "${_RESET}" "$*"; }
warn()    { printf "%s [ WARN ]%s %s\n" "${_GIALLO}${_GRAS}" "${_RESET}" "$*"; }
error()   { printf "%s [ ERRORE ]%s %s\n" "${_ROSSO}${_GRAS}" "${_RESET}" "$*"; }

### ── Funzioni di Supporto ────────────────────────────────────────────────────
usage() {
  cat <<EOF
${_GRAS}pkg-menu.sh${_RESET} — Gestore Interattivo APT (v${VERSIONE})

Uso: sudo $0 [OPZIONI]

Opzioni:
  -h, --help       Mostra questo aiuto ed esce
  -v, --version    Mostra la versione ed esce
  -a, --auto       Esegue manutenzione completa:
                   update → upgrade → dist-upgrade → autoremove → autoclean
EOF
  exit 0
}

show_version() {
  echo "pkg-menu.sh versione ${VERSIONE}"
  exit 0
}

require_root() {
  (( EUID == 0 )) || { error "Devi eseguire come root."; exit 1; }
}

spinner() {
  local pid=$1 delay=0.1 spin='|/-\' 
  while kill -0 "$pid" 2>/dev/null; do
    for c in $spin; do
      printf "\r${_GIALLO}%s${_RESET}" "$c"
      sleep "$delay"
    done
  done
  printf "\r"
}

apt_cmd() {
  local cmd=("$@")
  info "Eseguo: ${cmd[*]}"
  "${cmd[@]}" -qq &
  spinner $!
  success "Comando completato: ${cmd[*]}"
}

pause() {
  echo
  read -n1 -s -r -p "Premi un tasto per tornare al menu…"  
  echo
}

### ── Operazioni APT ─────────────────────────────────────────────────────────
update_lists()        { apt_cmd apt-get update; }
upgrade_packages()    { apt_cmd DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; }
dist_upgrade()        { apt_cmd DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y; }
autoremove_packages() { apt_cmd apt-get autoremove --purge -y; }
autoclean_cache()     { apt_cmd apt-get autoclean -y; }

search_package() {
  read -rp "Parola chiave per ricerca: " kw
  info "Cerco pacchetti per '${kw}'…"
  apt-cache search "$kw" | sed '/^$/d'
}

install_package() {
  read -rp "Nome del pacchetto da installare: " pkg
  apt_cmd DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
}

remove_package() {
  read -rp "Nome del pacchetto da rimuovere: " pkg
  apt_cmd DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y "$pkg"
}

auto_all() {
  update_lists
  upgrade_packages
  dist_upgrade
  autoremove_packages
  autoclean_cache
  success "Manutenzione completa terminata."
}

### ── Parsing Argomenti CLI ──────────────────────────────────────────────────
if [[ $# -gt 0 ]]; then
  case "$1" in
    -h|--help)    usage          ;;
    -v|--version) show_version   ;;
    -a|--auto)    require_root; auto_all; exit 0 ;;
    *)            error "Opzione sconosciuta: $1"; usage ;;
  esac
fi

### ── Menu Interattivo ───────────────────────────────────────────────────────
require_root

while true; do
  clear
  echo "${_GRAS}${_BLU}============================================${_RESET}"
  echo "${_GRAS}${_BLU}       Gestore APT – v${VERSIONE}       ${_RESET}"
  echo "${_GRAS}${_BLU}============================================${_RESET}"
  cat <<EOF

 1) Aggiorna lista pacchetti
 2) Esegui upgrade pacchetti
 3) Esegui dist-upgrade (aggiornamento completo)
 4) Cerca pacchetto
 5) Installa pacchetto
 6) Rimuovi pacchetto
 7) Rimuovi pacchetti orfani
 8) Pulisci cache APT
 9) Manutenzione completa (auto)
 0) Esci

EOF
  read -rp "Seleziona [0–9]: " scelta
  echo
  case "$scelta" in
    1) update_lists        ; pause ;;
    2) upgrade_packages    ; pause ;;
    3) dist_upgrade        ; pause ;;
    4) search_package      ; pause ;;
    5) install_package     ; pause ;;
    6) remove_package      ; pause ;;
    7) autoremove_packages ; pause ;;
    8) autoclean_cache     ; pause ;;
    9) auto_all            ; pause ;;
    0) success "Uscita. Log salvato in ${LOG_FILE}"; exit 0 ;;
    *) warn "Scelta non valida: '${scelta}'"; pause ;;
  esac
done
