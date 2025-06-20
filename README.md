# pkg-menu.sh

> **Professional Interactive APT Package Manager (v2.1)**

<p align="center">
  <a href="https://github.com/bocaletto-luca/pkg-menu.sh/blob/main/pkg-menu.sh">
    <img src="https://img.shields.io/badge/version-2.1-blue.svg" alt="Version 2.1" />
  </a>
  <a href="https://github.com/bocaletto-luca/pkg-menu.sh/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="MIT License" />
  </a>
</p>

---

## 📋 Description

`pkg-menu.sh` is a zero-dependency Bash script that provides an interactive, colorized menu to manage APT on Debian, Ubuntu, Mint and other derivatives.  
It supports single-step operations (update, upgrade, dist-upgrade, etc.), a full “auto” maintenance mode, CLI flags, a spinner for progress feedback, and logs every action with timestamps under `/var/log/pkg-menu-*.log`.

---

## ⚙️ Prerequisites

- Debian, Ubuntu, Mint or any APT-based distribution  
- Bash 4.0 or newer  
- Run as root (script enforces privilege check)  
- No external packages required (uses only coreutils, `apt-get`, `tput`, `tee`)

---

## 🚀 Installation

## bash
# Clone the repo
    git clone https://github.com/bocaletto-luca/pkg-menu.sh.git
    cd pkg-menu.sh

# Make executable
    chmod +x pkg-menu.sh

# (Optional) Install globally
    sudo mv pkg-menu.sh /usr/local/bin/pkg-menu.sh

## 🛠️ Usage
#### Command-line Flags

    sudo pkg-menu.sh [OPTIONS]

    -h, --help Show help and exit

    -v, --version Show version and exit

    -a, --auto Run full maintenance (update → upgrade → dist-upgrade → autoremove → autoclean)

## Interactive Menu

#### Simply run without flags:
    sudo pkg-menu.sh

#### Use the numeric menu to select:

1) Update package list
2) Upgrade packages
3) Dist-upgrade (full upgrade)
4) Search for a package
5) Install a package
6) Remove a package
7) Autoremove orphaned packages
8) Autoclean apt cache
9) Run full maintenance (auto)
0) Exit

## 🔧 Examples
#### Update only
    sudo pkg-menu.sh --update

#### Full interactive maintenance
    sudo pkg-menu.sh

#### One-shot auto maintenance
    sudo pkg-menu.sh --auto

## 📂 Logs

#### All operations are logged to:
    /var/log/pkg-menu-<YYYYMMDD>-<HHMMSS>.log
##### Review these files for audit or troubleshooting.

## 👤 Author

#### Bocaletto Luca

Co-authored-by: Bocaletto Luca <bocaletto-luca@users.noreply.github.com>

---

## 📄 License

#### This project is licensed under the MIT License.
