# 🛠️ Setup your Workstation 
This repository contains:

- Powershell script to install and auto-setup WSL hosts all display in a menu

- bash scripts for bootstrapping an environment with [`arkade`](https://github.com/alexellis/arkade) and [`just`](https://github.com/casey/just).

---

# 🧑‍💻 Who is this for?
Everybody who need a clean, consistent admin and/or dev setup on WSL.

Teams that want a reproducible way to configure their environment and get the similar env between team's members


# 📋 Requirements
- Git

- WSL for Windows


## 🚀 Getting Started

# ⚙️ How do I install and run it?
Clone the repository:

```bash
git clone https://...
cd wst
```  

If on Windows, run this PowerShell script to install Ubuntu LTS in WSL
If you already have Ubuntu (WSL) installed just open your WSL terminal and continue to the next step.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File menu.ps1
.\menu.ps1
```  

🧪 What can I do with it? (Using just)

Once the environment is bootstrapped, on your host inside `worstation` directory, use `just` to run tasks.

Examples:

```bash
just all        # Runs the full setup
just --list     # These commands show all available tasks defined in your justfile
just update     # Refreshes components or pulls latest
```