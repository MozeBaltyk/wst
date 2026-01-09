<p align="center">
 <img src="assets/logo.png" alt="Project Logo" width="120">
</p>

<p align="center">
  WST is a reproducible way to bootstrap a clean and consistent admin or development environment on WSL.
</p>


## ✨ What’s inside?

This repository provides tools to quickly set up a workstation using **WSL**:

- 🪟 **PowerShell script** to install and configure WSL distributions via an interactive menu
- 🐧 **Bash scripts** to bootstrap a Linux environment using  
  - [`arkade`](https://github.com/alexellis/arkade) for tool installation  
  - [`just`](https://github.com/casey/just) as a task runner

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

1. Clone the repository on your windows

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
├── linux                 # Everything related to Ubuntu
│   ├── bin               # Custom WSL commands and scripts
│   ├── bootstrap         # Linux installation logic
│   ├── bootstrap.sh      # Prepares prerequisites before running just
│   └── justfile
├── nixos                 # Everything related to NixOS
└── windows               # Everything related to Windows
    ├── localSettings     # Windows debloating and prerequisites
    └── manageDistrib     # WSL distribution management scripts
```