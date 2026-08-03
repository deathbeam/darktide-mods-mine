return {
	mod_name = {
		en = "First Person Body",
	},
	mod_description = {
		en = "Shows your own body in first person: correctly animated legs, hips and lower torso when you look down. The head, upper body and third person weapons stay hidden so nothing blocks the camera, and your normal first person arms and weapon are untouched. Includes an optional look-down limit with a soft resistance zone and a separate sprint limit, plus a look-down FOV tweak. Compatible with Perspectives.",
	},
	fp_lower_body = {
		en = "Show your body in first person",
	},
	fp_fov_boost = {
		en = "Look-down FOV change (percent)",
	},
	fp_fov_boost_tooltip = {
		en = "Changes the field of view as you look down, reaching this percentage at straight down. NEGATIVE values narrow the view, rendering your legs larger and closer. Positive values widen it, showing more ground but pushing the body away. Eased so normal play is unaffected. 0 disables.",
	},
	fp_ads_reveal = {
		en = "Keep body visible when aiming steeply down",
	},
	fp_ads_reveal_tooltip = {
		en = "While you aim down sights, the mod normally steps aside so your sights stay perfectly aligned, which hides the body. With this on, aiming steeper down than the angle below (or aiming during a slide) keeps the body visible instead, at the cost of a slight sight offset in exactly those moments. Turn it off for perfect sight alignment at every angle; the body then always hides while aiming.",
	},
	fp_ads_angle = {
		en = "Aiming reveal angle (degrees down)",
	},
	fp_ads_angle_tooltip = {
		en = "The downward pitch, in degrees below the horizon, past which aiming keeps the body visible. Releases about 8 degrees shallower so the switch does not flicker at the boundary.",
	},
	fp_pitch_clamp = {
		en = "Limit how far down you can look",
	},
	fp_pitch_clamp_tooltip = {
		en = "Stops the camera pitching so far down that it clips into your own torso. Below the soft limit you look around freely. Between the soft and hard limits the camera resists further downward input, and at the hard limit it stops entirely. While sprinting a separate, higher limit applies, which also keeps your backside out of view without hiding the body. Trades a small slice of straight-down aim for immersion.",
	},
	fp_pitch_soft = {
		en = "Soft limit (degrees down)",
	},
	fp_pitch_soft_tooltip = {
		en = "The pitch angle, in degrees below the horizon, where downward camera movement starts meeting resistance.",
	},
	fp_pitch_hard = {
		en = "Hard limit (degrees down)",
	},
	fp_pitch_hard_tooltip = {
		en = "The pitch angle, in degrees below the horizon, past which the camera will not go at all. Must be at or below the soft limit on screen, that is, a larger number of degrees.",
	},
	fp_pitch_sprint = {
		en = "Sprint limit (degrees down)",
	},
	fp_pitch_sprint_tooltip = {
		en = "While sprinting the camera is held above this pitch angle. If you were already looking further down when the sprint starts, the camera glides up to this limit instead of snapping.",
	},
	fp_fx_sources = {
		en = "Keep effects on your first person hands",
	},
	fp_fx_sources_tooltip = {
		en = "Visual effects attach to named points that exist on both your first person viewmodel and your third person body. While the body is shown, the game moves them to the third person copy, which sits slightly lower, so hand effects (Psyker warp effects, the Thunder Hammer charge and similar) appear below where they belong. This keeps them on the viewmodel where you see them. Leave on unless an effect misbehaves.",
	},
	fp_deep_weapon_wake = {
		en = "Force every weapon part visible",
	},
	fp_deep_weapon_wake_tooltip = {
		en = "Off by default, and best left off. When the body is shown, this mod wakes your first person weapon back up using the same channel the game uses, which leaves parts that other mods have deliberately hidden alone. Turning this on additionally forces every mesh and light on the weapon visible, which can reveal replaced parts twice over and lock flashlights on when weapon customization mods are installed. Only turn it on if part of your weapon is invisible in first person.",
	},
	fp_diagnostics = {
		en = "Write the diagnostics file",
	},
	fp_diagnostics_tooltip = {
		en = "Writes the mod's internal state to fpb_diag.txt in the mod folder every few seconds, for troubleshooting. Off by default; leave it off unless you are chasing a problem. The /fpb chat command reports the same information on demand either way.",
	},
	fp_lower_body_tooltip = {
		en = "While the camera is in first person, the game keeps rendering your third person body: correctly posed and animated legs, hips and lower torso, visible when you look down. Head, upper body and stowed weapons are hidden so they cannot block the view. Applies immediately, no respawn needed.",
	},
}
