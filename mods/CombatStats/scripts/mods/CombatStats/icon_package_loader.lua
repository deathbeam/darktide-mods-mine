local mod = get_mod('CombatStats')

local PACKAGE_REF = 'CombatStatsIcons'

-- Icon/textures used by the combat stats view that live in HUD/inventory packages
-- the game doesn't always keep resident. Loaded while the view is open only.
local REQUIRED_PACKAGES = {
    'packages/ui/hud/player_weapon/player_weapon',
}

local function _package_is_available(package_name)
    local application = Application and Application.can_get_resource
    if not application then
        return false
    end
    local ok, exists = pcall(application, 'package', package_name)
    return ok and exists or false
end

local function _package_is_loaded(package_name)
    local package_manager = Managers and Managers.package
    if not package_manager or not package_manager.has_loaded then
        return false
    end
    local ok, is_loaded = pcall(package_manager.has_loaded, package_manager, package_name)
    return ok and is_loaded or false
end

-- Loads icon packages not already resident. Returns the load ids the caller must
-- release via release_icon_packages to keep the package manager's reference count clean.
function mod.load_icon_packages()
    local package_manager = Managers and Managers.package
    if not package_manager then
        return {}
    end

    local load_ids = {}
    for _, pkg in ipairs(REQUIRED_PACKAGES) do
        if _package_is_available(pkg) and not _package_is_loaded(pkg) then
            local ok, id = pcall(package_manager.load, package_manager, pkg, PACKAGE_REF, nil, true)
            if ok and id then
                load_ids[#load_ids + 1] = id
            end
        end
    end
    return load_ids
end

-- Releases the load ids from load_icon_packages so the package manager unloads them
-- when no other reference (game or mod) is holding them.
function mod.release_icon_packages(load_ids)
    local package_manager = Managers and Managers.package
    if not package_manager or not package_manager.release then
        return
    end
    for i = 1, #load_ids do
        pcall(package_manager.release, package_manager, load_ids[i])
    end
end

return PACKAGE_REF
