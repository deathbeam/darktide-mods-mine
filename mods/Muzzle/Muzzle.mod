return {
    run = function()
    fassert(rawget(_G, "new_mod"), "`Muzzle` encountered an error loading the Darktide Mod Framework.")

        new_mod("Muzzle", {
            mod_script       = "Muzzle/scripts/mods/Muzzle/Muzzle",
            mod_data         = "Muzzle/scripts/mods/Muzzle/Muzzle_data",
            mod_localization = "Muzzle/scripts/mods/Muzzle/Muzzle_localization",
        })
    end,
    packages = {},
}
