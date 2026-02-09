<p align="center">
 <img src="assets/logo.png" alt="Project Logo" width="120">
</p>

<p align="center">
  WST is a reproducible way to bootstrap a clean and consistent admin or development environment on WSL.
</p>


## ✨ What’s inside?

This repository provides tools to quickly set up a workstation using **WSL**:

- 🪟 **PowerShell script** to :
  - install and configure WSL distributions via an interactive menu
  - Few cleanup or setup actions on Windows
- 🐧 **Bash scripts** to bootstrap a Linux environment using  
  - [`arkade`](https://github.com/alexellis/arkade) for tool installation  
  - [`just`](https://github.com/casey/just) as a task runner
- 🧰 **Dotfiles** optimized for Linux.
Since they are POSIX-compliant, they should also work on macOS or BSD (as long as the required packages are available).

---

## 🧑‍💻 Who is this for?

- Developers or administrators who want a **clean, consistent WSL setup**
- Teams that need a **reproducible environment** across all members
- Anyone tired of manually configuring tools on every new machine

---

## 📋 Requirements

- Git
- Windows Subsystem for Linux (WSL)

## 🚀 Getting Started

1. Clone the repository on your windows (or Fork it if you want to customize dotfile)

2. From powershell, just run the *menu*, it should show the way...

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File menu.ps1
.\menu.ps1
```  

3. If you already have Ubuntu installed on WSL (or not), you can still clone this project and use `bootstrap.sh` from terminal...

```bash
git clone https://github.com/MozeBaltyk/wst.git
cd wst/linux

just all        # Runs the full setup
just --list     # These commands show all available tasks defined in your justfile
just update     # Refreshes components or pulls latest
```

## 📁 Repository Structure

```bash
tree -L 2
.
├── menu.ps1              # Menu and main orchestrator
├── dotfiles              # Dotfiles shared across Linux systems
│   ├── .config
│   ├── .local/bin
├── linux                 # Everything related to Linux OS
│   ├── bootstrap         # Linux installation logic
│   ├── bootstrap.sh      # Prepares prerequisites before running just
│   └── justfile
├── nixos                 # Everything related to NixOS
└── windows               # Everything related to Windows
    ├── localSettings     # Script to setup Windows (debloating, install apps, etc)
    └── manageDistrib     # WSL distribution management scripts
```

## Measure Pert

```bash
vim --startuptime /tmp/log
```

## Nice Inspirations

* [Khuedoan dotfiles](https://github.com/khuedoan/dotfiles)

* [How core git dev configure their git?](https://blog.gitbutler.com/how-git-core-devs-configure-git)

* [Foot Terminal](https://medspx.fr/blog/Sysadmin/foot_terminal/): This one could be fun to create some custom popup...

* [Customize k9s skin](https://k9scli.io/topics/skins/)