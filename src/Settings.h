#pragma once

struct Settings
{
	static void ReadSettings();

	// Controls
	static inline bool bUseSprintButton = true;
	static inline float fSprintHoldDuration = 0.25f;
    static inline std::uint32_t uDodgeKey = static_cast<std::uint32_t>(-1);

	// Stamina
	static inline bool bRequireStamina = true;

	// Mirrored from Dodge MCO-DXP's own MCM so the gate matches what it actually charges.
	static inline bool bCostIsPercentOfMax = false;
	static inline float fStaminaCost = 20.f;
};
