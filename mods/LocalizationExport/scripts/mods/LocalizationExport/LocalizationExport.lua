local mod = get_mod("LocalizationExport")
if not mod then
    return
end

local LocalizationManager = require("scripts/managers/localization/localization_manager")
local DMF = get_mod("DMF")

local _io = DMF:persistent_table("LocalizationExport_io")
_io.initialized = _io.initialized or false
if not _io.initialized then
    _io = DMF.deepcopy(Mods.lua.io)
    _io.initialized = true
end

local _os = DMF:persistent_table("LocalizationExport_os")
_os.initialized = _os.initialized or false
if not _os.initialized then
    _os = DMF.deepcopy(Mods.lua.os)
    _os.initialized = true
end

local type = type
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local string = string
local table = table
local Application = Application
local Localizer = Localizer
local Managers = Managers

local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local string_find = string.find
local string_gmatch = string.gmatch
local string_sub = string.sub
local table_sort = table.sort

local STRING_RESOURCE_NAMES = {
    "content/localization/ui",
    "content/localization/subtitles",
    "content/localization/items",
    "content/localization/path_of_trust/ui",
}

local REGION_LANGUAGE_LOOKUP = {
    ["en-gb"] = "en",
    ["en-us"] = "en",
    ["en"] = "en",
}

local LOCALIZATION_KEYS_FILE_PATH = "./../mods/LocalizationExport/scripts/mods/LocalizationExport/LocalizationKeys.lua"

mod.export_in_progress = false
mod.seen_localization_keys = mod.seen_localization_keys or {}

local function _count_entries(t)
    local count = 0

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

local function _is_valid_identifier(key)
    return type(key) == "string" and string_match(key, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function _is_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local count = 0
    local max_index = 0

    for key in pairs(tbl) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end

        count = count + 1

        if key > max_index then
            max_index = key
        end
    end

    return count == max_index
end

local function _escape_string(value)
    value = tostring(value)
    value = string_gsub(value, "\\", "\\\\")
    value = string_gsub(value, "\r", "\\r")
    value = string_gsub(value, "\n", "\\n")
    value = string_gsub(value, "\t", "\\t")
    value = string_gsub(value, "\"", "\\\"")

    return value
end

local function _sorted_keys(tbl)
    local keys = {}

    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end

    table_sort(keys, function(a, b)
        local type_a = type(a)
        local type_b = type(b)

        if type_a == type_b then
            if type_a == "number" or type_a == "string" then
                return a < b
            end

            return tostring(a) < tostring(b)
        end

        if type_a == "number" then
            return true
        elseif type_b == "number" then
            return false
        elseif type_a == "string" then
            return true
        elseif type_b == "string" then
            return false
        end

        return tostring(type_a) < tostring(type_b)
    end)

    return keys
end

local function _write_indent(file, depth)
    file:write(string.rep("    ", depth))
end

local function _write_key(file, key)
    local key_type = type(key)

    if key_type == "number" then
        file:write("[", tostring(key), "]")
    elseif _is_valid_identifier(key) then
        file:write(key)
    else
        file:write("[\"", _escape_string(key), "\"]")
    end
end

local function _write_lua_table(file, value, depth, seen)
    if type(value) ~= "table" then
        if type(value) == "string" then
            file:write("\"", _escape_string(value), "\"")
        elseif type(value) == "number" or type(value) == "boolean" then
            file:write(tostring(value))
        elseif value == nil then
            file:write("nil")
        else
            file:write("\"", _escape_string(tostring(value)), "\"")
        end

        return
    end

    if seen[value] then
        file:write("\"<cycle>\"")

        return
    end

    seen[value] = true
    file:write("{\n")

    if _is_array(value) then
        for i = 1, #value do
            _write_indent(file, depth + 1)
            _write_lua_table(file, value[i], depth + 1, seen)
            file:write(",\n")
        end
    else
        local keys = _sorted_keys(value)

        for i = 1, #keys do
            local key = keys[i]

            _write_indent(file, depth + 1)
            _write_key(file, key)
            file:write(" = ")
            _write_lua_table(file, value[key], depth + 1, seen)
            file:write(",\n")
        end
    end

    _write_indent(file, depth)
    file:write("}")
    seen[value] = nil
end

local function _exists(path)
    local ok, _, code = _os.rename(path, path)

    if not ok and code == 13 then
        return true
    end

    return ok
end

local function _is_dir(path)
    return _exists(path .. "/")
end

local function _sanitize_filename_fragment(value)
    value = tostring(value or "unknown")
    value = string_gsub(value, "[<>:\"/\\|%?%*]", "_")
    value = string_gsub(value, "%s+", "_")

    return value
end

local function _effective_language(region)
    region = string_lower(tostring(region or "en-gb"))

    return REGION_LANGUAGE_LOOKUP[region] or region
end

local function _set_language_preference(language)
    if language == "en" then
        Application.set_resource_property_preference_order("en")
    else
        Application.set_resource_property_preference_order(language, "en")
    end

    if type(Localizer.set_language) == "function" then
        Localizer.set_language(language)
    end
end

local function _create_localizers()
    local localizers = {}

    for i = 1, #STRING_RESOURCE_NAMES do
        local resource_name = STRING_RESOURCE_NAMES[i]

        localizers[i] = {
            resource_name = resource_name,
            localizer = Localizer(resource_name),
        }
    end

    return localizers
end

local function _release_localizers(localizers)
    for i = 1, #localizers do
        local data = localizers[i]
        local localizer = data.localizer

        if localizer then
            Localizer.release(localizer)
        end
    end
end

local function _lookup_in_localizers(localizers, key)
    for i = 1, #localizers do
        local data = localizers[i]
        local value = Localizer.lookup(data.localizer, key)

        if value then
            return value, data.resource_name
        end
    end

    return nil, nil
end

local function _add_key(keys, key, source)
    if type(key) ~= "string" or key == "" then
        return
    end

    if not keys[key] then
        keys[key] = {
            source = source,
        }
    end
end

local function _strip_line_comment(line)
    local comment_start = string_find(line, "%-%-")

    if comment_start then
        return string_sub(line, 1, comment_start - 1)
    end

    return line
end

local function _collect_keys_from_localization_keys_file(keys)
    local file = _io.open(LOCALIZATION_KEYS_FILE_PATH, "r")

    if not file then
        mod:error("Could not open LocalizationKeys.lua")

        return
    end

    for line in file:lines() do
        line = _strip_line_comment(line)

        local added_quoted_key = false
        local bracket_key = string_match(line, "^%s*%[%s*\"([^\"]+)\"%s*%]%s*=")

        if not bracket_key then
            bracket_key = string_match(line, "^%s*%[%s*'([^']+)'%s*%]%s*=")
        end

        if bracket_key then
            _add_key(keys, bracket_key, "LocalizationKeys.lua")
            added_quoted_key = true
        end

        if not added_quoted_key then
            local assignment_key = string_match(line, "^%s*([A-Za-z_][A-Za-z0-9_]*)%s*=")

            if assignment_key and assignment_key ~= "return" then
                _add_key(keys, assignment_key, "LocalizationKeys.lua")
                added_quoted_key = true
            end
        end

        if not added_quoted_key then
            for key in string_gmatch(line, "\"([^\"]+)\"") do
                _add_key(keys, key, "LocalizationKeys.lua")
                added_quoted_key = true
            end
        end

        if not added_quoted_key then
            for key in string_gmatch(line, "'([^']+)'") do
                _add_key(keys, key, "LocalizationKeys.lua")
                added_quoted_key = true
            end
        end

        if not added_quoted_key then
            local bare_key = string_match(line, "^%s*([A-Za-z0-9_%.%-%/:]+)%s*,?%s*$")

            if bare_key and bare_key ~= "return" and bare_key ~= "true" and bare_key ~= "false" then
                _add_key(keys, bare_key, "LocalizationKeys.lua")
            end
        end
    end

    file:close()
end

local function _collect_keys()
    local keys = {}

    _collect_keys_from_localization_keys_file(keys)

    for key in pairs(mod.seen_localization_keys) do
        _add_key(keys, key, "seen_localization_keys")
    end

    local localization_manager = Managers.localization
    local backend_localizations = localization_manager and localization_manager._backend_localizations

    if type(backend_localizations) == "table" then
        for key in pairs(backend_localizations) do
            _add_key(keys, key, "backend_localizations")
        end
    end

    return keys
end

function mod.export_directory_path()
    local appdata = _os.getenv("APPDATA")

    return appdata .. "/Fatshark/Darktide/localization_export/"
end

function mod.create_export_directory()
    local path = mod.export_directory_path()

    if not _is_dir(path) then
        _os.execute('mkdir "' .. path .. '"')
    end
end

function mod.current_timestamp()
    return _os.time(_os.date("*t"))
end

function mod.create_export_file_path(region, language)
    local timestamp = mod.current_timestamp()
    local safe_region = _sanitize_filename_fragment(region)
    local safe_language = _sanitize_filename_fragment(language)
    local file_name = string_format("localization_export_%s_effective_%s_%s.lua", safe_region, safe_language,
        tostring(timestamp))
    local full_path = mod.export_directory_path() .. file_name

    return full_path, file_name, timestamp
end

function mod.write_localization_export(region)
    local localization_manager = Managers.localization

    if not localization_manager then
        mod:echo(mod:localize("export_manager_unavailable"))
        mod.export_in_progress = false

        return
    end

    region = region or "en-gb"

    local export_language = _effective_language(region)
    local previous_language = localization_manager.language and localization_manager:language() or "en"

    mod.create_export_directory()

    _set_language_preference(export_language)

    local localizers = _create_localizers()
    local collected_keys = _collect_keys()
    local localizations = {}
    local missing_keys = {}

    for key, key_data in pairs(collected_keys) do
        local value, resource_name = _lookup_in_localizers(localizers, key)

        if not value then
            local backend_localizations = localization_manager._backend_localizations

            if type(backend_localizations) == "table" then
                value = backend_localizations[key]
                resource_name = value and "backend_localizations" or resource_name
            end
        end

        if value then
            localizations[key] = {
                string = value,
                source = resource_name,
                key_source = key_data.source,
            }
        else
            missing_keys[key] = {
                key_source = key_data.source,
            }
        end
    end

    _release_localizers(localizers)
    _set_language_preference(previous_language or "en")

    local full_path, file_name, timestamp = mod.create_export_file_path(region, export_language)
    local file = assert(_io.open(full_path, "w+"))

    local export_data = {
        metadata = {
            requested_region = region,
            effective_language = export_language,
            previous_language = previous_language,
            exported_at = _os.date("%Y-%m-%d %H:%M:%S", timestamp),
            exported_unix = timestamp,
            string_resource_names = STRING_RESOURCE_NAMES,
            key_count = _count_entries(collected_keys),
            exported_count = _count_entries(localizations),
            missing_count = _count_entries(missing_keys),
        },
        localizations = localizations,
        missing_keys = missing_keys,
    }

    file:write("return ")
    _write_lua_table(file, export_data, 0, {})
    file:write("\n")
    file:close()

    mod.export_in_progress = false
    mod:echo(mod:localize("export_completed", tostring(export_data.metadata.exported_count), file_name))
end

function mod.export_localization(region)
    if mod.export_in_progress then
        mod:echo(mod:localize("export_already_in_progress"))

        return
    end

    mod.export_in_progress = true
    mod:echo(mod:localize("export_started"))

    mod.write_localization_export(region or "en-gb")
end

mod:hook(LocalizationManager, "localize", function(func, self, key, no_cache, context)
    if type(key) == "string" and key ~= "" then
        mod.seen_localization_keys[key] = true
    end

    return func(self, key, no_cache, context)
end)

mod:command("export_localization", mod:localize("export_command_description"), function(region)
    mod.export_localization(region or "en-gb")
end)
