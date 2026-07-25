return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`PlayerOutlines` encountered an error loading the Darktide Mod Framework.")

        new_mod("PlayerOutlines", {
            mod_script       = "PlayerOutlines/scripts/mods/PlayerOutlines/PlayerOutlines",
            mod_data         = "PlayerOutlines/scripts/mods/PlayerOutlines/PlayerOutlines_data",
            mod_localization = "PlayerOutlines/scripts/mods/PlayerOutlines/PlayerOutlines_localization",
        })
    end,
    packages = {},
}
