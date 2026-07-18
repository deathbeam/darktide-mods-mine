local breeds_data = {}

breeds_data.blacklist = {
  human = true,
  ogryn = true,
  chaos_mutator_daemonhost = true,
  chaos_mutator_ritualist = true,
  sand_vortex = true,

  chaos_hound_mutator = true,
  cultist_mutant_mutator = true,
  renegade_flamer_mutator = true,
  companion_dog = true,
  companion_servo_skull = true,
  cryptic = true,

  nurgle_flies = true,
}

breeds_data.categories = {
  attack_valkyrie = {
    "misc",
  },
  chaos_armored_hound = {
    "regular",
    "specialist"
  },
  chaos_armored_infected = {
    "regular",
  },
  chaos_beast_of_nurgle = {
    "regular",
    "boss"
  },
  chaos_daemonhost = {
    "regular",
    "boss"
  },
  chaos_hound = {
    "regular",
    "specialist"
  },
  chaos_hound_mutator = {
    "misc",
  },
  chaos_lesser_mutated_poxwalker = {
    "regular",
  },
  chaos_newly_infected = {
    "regular"
  },
  chaos_ogryn_bulwark = {
    "regular",
    "elite"
  },
  chaos_ogryn_executor = {
    "regular",
    "elite"
  },
  chaos_ogryn_gunner = {
    "regular",
    "elite"
  },
  chaos_ogryn_houndmaster = {
    "regular",
    "boss"
  },
  chaos_plague_ogryn = {
    "regular",
    "boss"
  },
  chaos_plague_ogryn_sprayer = {
    "regular",
    "boss"
  },
  chaos_poxwalker = {
    "regular"
  },
  chaos_poxwalker_bomber = {
    "regular",
    "specialist"
  },
  chaos_mutator_daemonhost = {
    "misc",
    "boss",
  },
  chaos_mutator_ritualist = {
    "misc",
  },
  chaos_spawn = {
    "regular",
    "boss"
  },
  companion_dog = {
    "misc",
  },
  companion_servo_skull = {
    "misc",
  },
  cryptic = {
    "misc",
  },
  cultist_assault = {
    "regular"
  },
  cultist_berzerker = {
    "regular",
    "elite"
  },
  cultist_captain = {
    "misc",
    "boss"
  },
  cultist_flamer = {
    "regular",
    "specialist"
  },
  cultist_grenadier = {
    "regular",
    "specialist"
  },
  cultist_gunner = {
    "regular",
    "elite"
  },
  cultist_melee = {
    "regular"
  },
  cultist_mutant = {
    "regular",
    "specialist"
  },
  cultist_mutant_mutator = {
    "misc",
  },
  chaos_mutated_poxwalker = {
    "regular",
  },
  cultist_ritualist = {
    "misc",
  },
  cultist_shocktrooper = {
    "regular",
    "elite"
  },
  cultist_vanguard = {
    "regular",
    "elite",
  },
  nurgle_flies = {
    "regular",
  },
  renegade_assault = {
    "regular"
  },
  renegade_berzerker = {
    "regular",
    "elite"
  },
  renegade_captain = {
    "misc",
    "boss"
  },
  renegade_executor = {
    "regular",
    "elite"
  },
  renegade_flamer = {
    "regular",
    "specialist"
  },
  renegade_flamer_mutator = {
    "misc",
  },
  renegade_grenadier = {
    "regular",
    "specialist"
  },
  renegade_gunner = {
    "regular",
    "elite"
  },
  renegade_melee = {
    "regular"
  },
  renegade_netgunner = {
    "regular",
    "specialist"
  },
  renegade_plasma_gunner = {
    "regular",
    "elite",
  },
  renegade_radio_operator = {
    "regular",
    "elite",
  },
  renegade_rifleman = {
    "regular"
  },
  renegade_shocktrooper = {
    "regular",
    "elite"
  },
  renegade_sniper = {
    "regular",
    "specialist"
  },
  renegade_twin_captain = {
    "misc",
    "boss"
  },
  renegade_twin_captain_two = {
    "misc",
    "boss"
  },
  renegade_vanguard = {
    "regular",
    "elite",
  },
  sand_vortex = {
    "misc",
  },
}

breeds_data.category_order = { "regular", "elite", "specialist", "boss", "misc" }
breeds_data.category_label = { regular = "Infantry", elite = "Elites", specialist = "Specialists", boss = "Monstrosities", misc = "Misc" }

return breeds_data