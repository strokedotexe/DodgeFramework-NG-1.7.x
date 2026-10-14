# Changelog

## 1.0.0

Initial release. Built from [ArcEarth/DodgeFramework-NG](https://github.com/ArcEarth/DodgeFramework-NG)
at commit `3b7eb60`, with the following changes.

### Fixed

- Rebuilt against [alandtse/CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG) `v11.0.0`
  so the plugin loads on Skyrim SE/AE 1.7.99 and 1.7.104. The binary shipped with DMCO 2.1.21 was
  built against CommonLibSSE-NG v3.7.0, which cannot read the Address Library format introduced by
  Skyrim 1.7.x, so SKSE rejected it with *"must be recompiled for new address library"*. No game
  logic was changed for this; the plugin resolves a single address and it still exists.

### Added

- **Require Stamina** option in the Dodge Framework MCM, enabled by default. When on, a dodge is
  refused unless the player has at least as much stamina as the dodge costs. The cost is read from
  Dodge MCO-DXP's own MCM settings, so it follows both the percentage toggle and the cost slider
  rather than introducing a second number to keep in sync.

  Previously the plugin only refused a dodge at exactly zero stamina. Because DMCO charges the cost
  from Papyrus *after* the animation has started, and `DamageActorValue` clamps at zero, that left a
  free dodge available at the bottom of the bar. Turning the option off restores the original
  behaviour.

- Translations for the new strings in all ten languages shipped by DMCO.

### Changed

- Settings are read by layering `MCM/Settings/<mod>.ini` over `MCM/Config/<mod>/settings.ini`, the
  way MCM Helper resolves them, instead of reading only the former with hardcoded fallbacks.
- Debug symbols are emitted for the optimised build so crash logs can resolve frames in this plugin.
