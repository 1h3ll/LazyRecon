# Recon & URL Pipeline Script

> **One‑click(ish) domain recon → crawling → URL reduction → XSS prep**

This README documents the interactive Bash script you shared. It automates common web‑recon steps: tool installation, subdomain enumeration, alive/valid filtering, crawling with multiple engines, URL normalization/deduplication, and preparing focused URL sets for parameter/XSS testing.

> ⚠️ **Legal & Ethical**
>
> Use only on assets you own or have explicit written permission to test.

---

## Features at a Glance

* **Menu‑driven workflow (1–8)**: install tools → set domain → enumerate → crawl → filter → prep for Arjun/SQLi → prep for XSS
* **Multi‑source subdomains**: dnsbruter + subdominator (+ live‑check with subprober)
* **Multi‑crawler URL harvesting**: gospider, hakrawler, katana, urlfinder, waybackurls, gau
* **Aggressive URL reduction**: `uro` normalization, regex extension filtering, domain scoping, param‑similarity collapse
* **Alive/valid filtering**: HTTP status filtering via subprober
* **Artifacts & hand‑off**: creates consolidated files like `urls/<domain>-links-final.txt`, `<domain>-links.txt`, `<domain>-query.txt`, `urls-ready.txt`
* **Resilient flow**: background process monitoring, cleanup, and optional auto‑advance between steps

---

## Tested/Assumed Environment

* Debian/Ubuntu‑like host with `apt` and `sudo`
* Internet access to fetch Go/Python packages & GitHub repos
* Sufficient disk/RAM/CPU for parallel crawling

> ℹ️ The script installs system‑wide and alters shells. Review before running on production hosts.

---

## Tools the Script Manages

**Go binaries**: gospider, hakrawler, katana, waybackurls, gau, httpx, subfinder, urlfinder, gf

**Python/apt**: arjun, uro, ghauri (+ requirements), pip/pipx, Python 3.12

**Custom**: dnsbruter, subdominator, subprober (+ patterns & wordlists), SecLists clone

It also copies **`katana`/`waybackurls`/`gau`** into `/usr/local/bin` (and sometimes `/usr/bin`).

---

## Quick Start

```bash
# 1) Make it executable
chmod +x recon.sh

# 2) Run it (you will be prompted)
./recon.sh
```

Recommended order from the menu:

1. **Install all tools**
2. **Enter a domain name** (e.g., `example.com`)
3. **Enumerate & filter domains** (produces `<domain>-domains.txt`)
4. **Crawl & filter URLs** (produces `urls/<domain>-links-final.txt`)
5. **Filtering all** (aggressive URL reduction → `<domain>-links.txt`)
6. **Create files for Arjun & SQLi** (produces `arjun-final.txt`, `urls-ready.txt`)
7. **Prep for XSS / query strings** (produces `<domain>-query.txt`, `<domain>-ALL-links.txt`)
8. **Exit**

---

## What Each Menu Option Does

### 1) Install all tools

* Updates apt, installs core deps (`golang-go`, `python3-full`, `pip`, `pipx`, `wget`, etc.)
* Installs Go 1.22.5 under `/usr/local/go` and exports PATH
* Installs/updates many Go and Python recon tools system‑wide
* Sets shell aliases for `reflection.py` and `path-reflection.py`
* Creates/updates GF patterns and clones helper repos (SecLists, ghauri, etc.)

> **Heads‑up**
>
> * Uses `sudo pip install ... --break-system-packages` and renames `/usr/lib/python3.12/EXTERNALLY-MANAGED`. This bypasses vendor protections and can complicate future package management. Prefer using **venv**/**pipx** if you want a cleaner system.
> * Copies binaries into privileged paths; ensure they’re trusted.

### 2) Enter a domain name

Prompts you for the target **apex** (e.g., `example.com`). You can auto‑proceed to step 3.

### 3) Enumerate & filter domains

* Passive fuzzing via **dnsbruter** + active enumeration via **subdominator**
* Merges results → `<domain>-domains.txt`
* Dedupes, removes `www.` and schemes, then **alive check** via **subprober**
* Final list saved back to `<domain>-domains.txt` (scoped, alive URLs with scheme)
* Optional Y/N prompt to auto‑continue to step 4

### 4) Crawl & filter URLs

* Crawls with **gospider**, **hakrawler**, **katana**, **urlfinder**, **waybackurls**, **gau**
* Extracts `http...` tokens and normalizes each tool’s output with **uro**
* Merges all into `urls/<domain>-links-final.txt`
* Cleans intermediate artifacts and prints total merged URLs
* Auto‑continues to step 5

### 5) Filtering all (aggressive reduction)

* Drops non‑actionable extensions (images, media, fonts, archives, docs, etc.)
* Re‑scopes results to the original domain
* Runs **uro** again for normalization/dedup
* Collapses near‑duplicate parameter sets (keeps diverse param names)
* Alive/valid filter with **subprober**; outputs final **`<domain>-links.txt`**
* Auto‑continues to step 6

### 6) Create separated files for Arjun & SQLi

* Splits tech‑stack URLs (`.php`, `.asp`, `.aspx`, `.cfm`, `.jsp`) into:

  * `arjun-urls.txt` (no query yet) → feed to **Arjun**
  * `output-php-links.txt` (already has `?`)
* Runs **Arjun** (wordlist `parametri.txt`) and merges results → `arjun-final.txt`
* Creates **`urls-ready.txt`** by combining `<domain>-links.txt` + `arjun-final.txt`
* Auto‑continues to step 7

### 7) Getting ready for XSS & query strings

* `grep '='` from `urls-ready.txt` → **`<domain>-query.txt`**
* Renames remainder to **`<domain>-ALL-links.txt`**
* **Heuristic parameter diversity filter** to keep representative URLs (reduces repeated param combos)

### 8) Exit

Quit the script.

---

## Output Files (key hand‑off points)

| File                            | Purpose                                              |
| ------------------------------- | ---------------------------------------------------- |
| `<domain>-domains.txt`          | Alive/scoped subdomains with scheme                  |
| `urls/<domain>-links-final.txt` | All merged URLs from crawlers before heavy reduction |
| `<domain>-links.txt`            | Highly reduced, alive URLs for general testing       |
| `arjun-final.txt`               | URLs enhanced with parameters discovered by Arjun    |
| `urls-ready.txt`                | Union of `<domain>-links.txt` and `arjun-final.txt`  |
| `<domain>-query.txt`            | Query‑string URLs ready for XSS testing              |
| `<domain>-ALL-links.txt`        | Everything else (non‑query)                          |

A running log of fatal step errors is appended to `error.log`.

---

## Usage Tips

* Start with **one domain** and validate outputs between steps; the pipeline is aggressive.
* Tune crawler depths/concurrency in the script for very large scopes.
* Review the large **extension blacklist**—adjust if your target serves APIs or assets through unusual extensions.
* Keep an eye on rate‑limits and be a good netizen.

---

## Troubleshooting

* **`command not found` after install** → open a new shell or ensure PATH includes `/usr/local/go/bin` and `~/go/bin`. The script moves most binaries to `/usr/local/bin`.
* **Go/Python version conflicts** → prefer `pipx`/virtualenvs for Python tools and keep one Go toolchain on the box.
* **`--break-system-packages` warnings** → consider refactoring installs into a venv/pipx to avoid system Python breakage.
* **Permission denied** → many steps use `sudo`. Run the script from a user with sudo privileges.

---

## Safety Review Checklist

* [ ] I have written authorization to test this domain/scope.
* [ ] I’ve reviewed the install section and accept system‑wide changes.
* [ ] I’ve read the extension filter and domain scoping patterns.
* [ ] I will throttle appropriately (concurrency/depth) to avoid service impact.

---

## Uninstall / Cleanup (manual)

* Remove installed Go toolchain: `/usr/local/go`
* Remove moved binaries from `/usr/local/bin` (katana, gau, waybackurls, etc.)
* Optionally remove `~/go` and cloned repos under `~/git`
* Revert Python packages or recreate a clean venv/host

---

## License

Add a license file of your choice (MIT recommended for permissive distribution).

---

### Appendix: Script‑Specific Notes

* The script writes shell aliases for `ref` and `path` (reflection helpers) into both `.bashrc` and `.zshrc`.
* It creates a `urls/` directory (chmod 777) to stash merged URLs.
* It uses `subprober` status codes `200,301,302,307,308,403` (or includes `401` earlier) — tweak if you want stricter live sets.
* It temporarily deletes `/root/.gau.toml` to use default `gau` providers.

If you want, I can generate a **minimal variant** that:

* installs into a **Python venv** or via **pipx** only,
* avoids modifying `/usr/lib/python*/EXTERNALLY-MANAGED`, and
* exports a reproducible `requirements.txt`/`go install` list.

Thanks : https://github.com/xss0r/xssorRecon
