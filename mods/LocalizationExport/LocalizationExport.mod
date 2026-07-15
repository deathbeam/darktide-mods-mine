return {
    run = function ()
        fassert(rawget(_G, "new_mod"), "`LocalizationExport` encountered an error loading the Darktide Mod Framework.")

        new_mod("LocalizationExport", {
            mod_script = "LocalizationExport/scripts/mods/LocalizationExport/LocalizationExport",
            mod_data = "LocalizationExport/scripts/mods/LocalizationExport/LocalizationExport_data",
            mod_localization = "LocalizationExport/scripts/mods/LocalizationExport/LocalizationExport_localization",
        })
    end,
    packages = {},
}