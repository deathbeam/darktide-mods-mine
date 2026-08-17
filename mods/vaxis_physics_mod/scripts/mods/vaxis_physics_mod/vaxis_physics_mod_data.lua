local mod = get_mod("vaxis_physics_mod")

return {
    name = "VAXIS's RAGDOLL COLLISION MOD",
    description = "Dynamic Ragdoll Collision Settings:",
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "push_radius",
                type = "numeric",
                default_value = 1.0,
                range = {0.1, 5.0},
                decimals_number = 1,
            },
            {
                setting_id = "base_push_force",
                type = "numeric",
                default_value = 10,
                range = {1, 100},
            }
        }
    }
}