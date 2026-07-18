local W = {}

W.presets = {
    { id = "gunner_line",  group = { renegade_gunner = 5, chaos_ogryn_gunner = 2 } },
    { id = "melee_rush",   group = { chaos_poxwalker = 10, renegade_berzerker = 3 } },
    { id = "elite_squad",  group = { chaos_ogryn_executor = 2, renegade_executor = 2, chaos_ogryn_bulwark = 1 } },
    { id = "specialists",  group = { renegade_netgunner = 1, renegade_sniper = 1, renegade_flamer = 1, cultist_mutant = 1, chaos_poxwalker_bomber = 1 } },
    { id = "monsters",     group = { chaos_beast_of_nurgle = 1, chaos_spawn = 1, chaos_plague_ogryn = 1 } },
    { id = "mixed_horde",  group = { chaos_poxwalker = 12, renegade_gunner = 2, renegade_berzerker = 2, cultist_mutant = 1 } },
}

W.trials = {
    {
        id = "disabler", advance = "clear",
        waves = {
            { renegade_netgunner = 1, chaos_hound = 1 },
            { renegade_netgunner = 1, cultist_mutant = 1, chaos_hound = 1 },
            { renegade_netgunner = 2, cultist_mutant = 1, chaos_hound = 2 },
        },
    },
    {
        id = "ranged", advance = "timer",
        waves = {
            { renegade_gunner = 3 },
            { renegade_gunner = 4, renegade_sniper = 1 },
            { renegade_gunner = 5, renegade_sniper = 1, chaos_ogryn_gunner = 1 },
        },
    },
    {
        id = "boss_rush", advance = "clear",
        waves = {
            { chaos_spawn = 1 },
            { chaos_beast_of_nurgle = 1 },
            { chaos_plague_ogryn = 1 },
            { chaos_daemonhost = 1 },
        },
    },
    {
        id = "endless", advance = "clear", endless = true,
        waves = {
            { chaos_poxwalker = 8 },
            { chaos_poxwalker = 10, renegade_gunner = 1 },
            { chaos_poxwalker = 12, renegade_gunner = 2, renegade_berzerker = 1 },
        },
    },
}

return W
