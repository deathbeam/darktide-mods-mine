return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`vaxis_physics_mod` encountered an error loading the Darktide Mod Framework.")

        new_mod("vaxis_physics_mod", {
            mod_script       = "vaxis_physics_mod/scripts/mods/vaxis_physics_mod/vaxis_physics_mod",
            mod_data         = "vaxis_physics_mod/scripts/mods/vaxis_physics_mod/vaxis_physics_mod_data",
            mod_localization = "vaxis_physics_mod/scripts/mods/vaxis_physics_mod/vaxis_physics_mod_localization",
        })
    end,
    packages = {},
}