#include "Settings.h"

namespace
{
	// MCM Helper ships a mod's defaults in MCM/Config/<mod>/settings.ini but writes only the
	// keys the player actually changed to MCM/Settings/<mod>.ini, so a lookup has to fall back
	// from the second file to the first.
	class LayeredIni
	{
	public:
		LayeredIni(const wchar_t* a_defaults, const wchar_t* a_overrides)
		{
			_defaults.SetUnicode();
			_defaults.LoadFile(a_defaults);
			_overrides.SetUnicode();
			_overrides.LoadFile(a_overrides);
		}

		bool GetBool(const char* a_section, const char* a_key, bool a_fallback) const
		{
			return _overrides.GetBoolValue(a_section, a_key,
				_defaults.GetBoolValue(a_section, a_key, a_fallback));
		}

		double GetDouble(const char* a_section, const char* a_key, double a_fallback) const
		{
			return _overrides.GetDoubleValue(a_section, a_key,
				_defaults.GetDoubleValue(a_section, a_key, a_fallback));
		}

		long GetLong(const char* a_section, const char* a_key, long a_fallback) const
		{
			return _overrides.GetLongValue(a_section, a_key,
				_defaults.GetLongValue(a_section, a_key, a_fallback));
		}

	private:
		CSimpleIniA _defaults;
		CSimpleIniA _overrides;
	};
}

void Settings::ReadSettings()
{
	const LayeredIni ini(
		L"Data/MCM/Config/DodgeFramework/settings.ini",
		L"Data/MCM/Settings/DodgeFramework.ini");

	bUseSprintButton = ini.GetBool("Controls", "bUseSprintButton", true);
	fSprintHoldDuration = (float)ini.GetDouble("Controls", "fSprintHoldDuration", 0.25);
	uDodgeKey = static_cast<uint32_t>(ini.GetLong("Controls", "uDodgeKey", -1));
	bRequireStamina = ini.GetBool("Stamina", "bRequireStamina", true);

	// Dodge MCO-DXP charges the dodge from Papyrus after the animation has already started,
	// so the cost cannot be observed and is read from that mod's settings instead.
	const LayeredIni dmco(
		L"Data/MCM/Config/Dodge_MCO-DXP/settings.ini",
		L"Data/MCM/Settings/Dodge_MCO-DXP.ini");

	bCostIsPercentOfMax = dmco.GetBool("Main", "bdodgeMcoDxp_usePercent", false);
	fStaminaCost = (float)dmco.GetDouble("Main", "idodgeMcoDxp_staminaCost", 20.0);

	logger::info("Settings loaded: requireStamina={}, dodgeCost={}{}",
		bRequireStamina, fStaminaCost, bCostIsPercentOfMax ? "% of max" : " points");
}
