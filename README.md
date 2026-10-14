# Dodge Framework NG — Skyrim 1.7.x Update

A rebuilt `DodgeFramework.dll` for **Dodge - MCO (DMCO)** that loads on Skyrim Special Edition
1.7.99 and 1.7.104, plus an optional stamina requirement for dodging.

The DMCO release from November 2023 still carries a plugin built against a CommonLibSSE-NG version
that predates Skyrim 1.7.x, so SKSE refuses to load it and the dodge key does nothing. This is a
drop-in replacement for that one file.

## What is replaced

Only the SKSE plugin and the Dodge Framework MCM pages. Everything that makes DMCO *DMCO* — the
animations, the Nemesis/Pandora behaviours, the Papyrus scripts, the plugins, the sounds — is
independent of the game version and keeps working untouched. **DMCO itself is still required**; it
is not redistributed here.

```
SKSE/Plugins/DodgeFramework.dll
MCM/Config/DodgeFramework/config.json
MCM/Config/DodgeFramework/settings.ini
Interface/Translations/DodgeFramework_<language>.txt
```

## Why the original stopped loading

Skyrim 1.7.x introduced a new **Address Library format (format 5)**: a 96-byte header
(`format`, `version[4]`, `name[64]`, `pointerSize`, `dataFormat`, `offsetCount`) followed by a dense
`uint32` array indexed directly by ID, replacing the delta-compressed format 2. The 2023 binary was
built against CharmedBaryon's CommonLibSSE-NG v3.7.0, which only reads formats 1 and 2, so SKSE
rejects it with *"must be recompiled for new address library"*.

DMCO needs exactly **one** address from the executable, the `SprintHandler` vtable
(Address Library ID 263057), and it is still there on the new runtimes:

| Runtime  | offset of ID 263057 |
| -------- | ------------------- |
| 1.6.640  | `0x19b57e0`         |
| 1.6.1170 | `0x1b0f370`         |
| 1.7.99   | `0x1b98f60`         |
| 1.7.104  | `0x1b98f80`         |

So nothing had to be reverse engineered or reimplemented. Recompiling against a CommonLibSSE that
reads format 5 was enough.

## Require Stamina

A toggle on the Dodge Framework MCM page, **on by default**. When on, a dodge is refused unless the
player has at least as much stamina as the dodge costs. The cost is read from Dodge MCO-DXP's own
MCM settings, so it follows both the percentage toggle and the cost slider — there is no second
number to keep in sync.

Upstream only refuses a dodge at exactly zero stamina. Since DMCO charges the cost from Papyrus
*after* the animation starts, and `DamageActorValue` clamps at zero, that leaves a free dodge
available at the bottom of the bar. Turn the option off to get the original behaviour back.

Changing the cost on the *Dodge MCO-DXP* page is picked up on the next game load, or the next time
the *Dodge Framework* page is opened and closed, because MCM Helper raises `OnConfigClose` per page.

## Installation

Install as a separate mod and let it load **after** DMCO so it wins the conflict on those four
paths. With Mod Organizer 2 that means placing it above `Dodge MCO-DXP` in the left pane.

Requires Skyrim SE/AE 1.6.x–1.7.104, SKSE, Address Library for SKSE Plugins, MCM Helper and a DMCO
install.

## Building

Needs Visual Studio with the C++ workload (MSVC, Windows SDK, CMake, Ninja) and a bootstrapped
[vcpkg](https://github.com/microsoft/vcpkg).

```powershell
git clone --recurse-submodules https://github.com/strokedotexe/DodgeFramework-NG-1.7.x.git
cd DodgeFramework-NG-1.7.x
$env:VCPKG_ROOT = 'C:\path\to\vcpkg'
.\build.ps1
.\package.ps1 -Zip
```

`build.ps1` produces `build/release/DodgeFramework.dll`; `package.ps1` assembles `dist/` into the
layout above. SE and AE are built into one binary. VR is off because DMCO ships no VR behaviours,
which also means the `openvr` submodule of CommonLibSSE-NG is not needed.

### Layout

| Path                   | Contents                                                        |
| ---------------------- | --------------------------------------------------------------- |
| `src/`                 | Plugin sources                                                    |
| `extern/CommonLibSSE-NG`| Submodule, [alandtse/CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG) `v11.0.0` — the actively maintained fork that reads format 5 |
| `mcm/Config/`          | MCM Helper page definition and shipped defaults                   |
| `mcm/Translations/`    | Translation files, UTF-16 LE with BOM as Skyrim requires          |
| `mcm/new-strings.tsv`  | The strings this project adds, per language                       |
| `mcm/add-strings.ps1`  | Regenerates `mcm/Translations` from a set of upstream files       |

## Credits

Ersh wrote [DodgeFramework](https://github.com/ersh1/DodgeFramework). ArcEarth ported it to
CommonLibSSE-NG as [DodgeFramework-NG](https://github.com/ArcEarth/DodgeFramework-NG), which is what
DMCO ships and what `src/` here comes from. Distar and Shikyo Kira built DMCO around it.

Licensed under the Apache License 2.0, inherited from DodgeFramework-NG. See `LICENSE` for the terms
and `NOTICE` for the full attribution chain, and `CHANGELOG.md` for the changes made here.
