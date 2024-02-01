--- This script handles converting qb-target exports into usable exports by the target system.
-- This allows qb-target to be removed entirely and replaced with boii_target without the need to edit every target export currently used. 
-- @script client/wrapper/qb-target.lua

--- @section Local functions

--- Intercepts exports to replace with conversion functions
-- @lfunction export_handler
-- @param export_name string: The name of the export function.
-- @param func function: The function to be called when this export is triggered.
local function export_handler(export_name, func)
    AddEventHandler(('__cfx_export_qb-target_%s'):format(export_name), function(set_cb)
        set_cb(func)
    end)
end

--- Adds an action to the actions table..
-- @lfunction add_action
-- @param actions table: The table of actions to which the new action will be added.
-- @param option table: The option table containing details about the action.
-- @param index number: The index of the action (used for generating function labels if needed).
local function add_action(actions, option, index)
    local action_entry = {
        label = option.label or "No Label",
        icon = option.icon or "fa-regular fa-circle",
        action_type = option.action_type or (option.event and (option.type or 'client') or 'function'),
        action = option.action or option.event,
        params = option.params or {},
        can_interact = option.can_interact or function() return true end,
        item = option.item,
        item_amount = option.item_amount or 1
    }
    if type(action_entry.action) == 'table' and action_entry.action.__cfx_functionReference then
        local function_label = action_entry.label or "function_" .. index
        register_function(function_label, action_entry.action)
        action_entry.action = function_label
        action_entry.action_type = 'function'
    end
    actions[#actions + 1] = action_entry
end

--- Creates an entity zone with provided options.
-- @function create_entity_zone
-- @param entity number: The entity for which the zone is created.
-- @param qb_options table: Options passed to the qb-target.
-- @param target_options table: Options specifically for the target handling.
-- @return table: The boii_options for the created entity zone.
local function create_entity_zone(entity, qb_options, target_options)
    if not DoesEntityExist(entity) then
        print("Entity does not exist.")
        return
    end
    target_options = target_options or qb_options
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local size_modifier = target_options.size_modifier or {x = 1.0, y = 1.0, z = 1.0}
    local length = (max.y - min.y) * size_modifier.y
    local width = (max.x - min.x) * size_modifier.x
    local height = (max.z - min.z) * size_modifier.z
    local pos = GetEntityCoords(entity)
    local boii_options = {
        entity = entity,
        coords = pos,
        length = length,
        width = width,
        height = height,
        debug = qb_options.debug_poly or false,
        distance = target_options.distance or 1.5,
        actions = {}
    }
    for i, option in ipairs(target_options.options) do
        add_action(boii_options.actions, option, i)
    end
    return boii_options
end

--- Function to handle the creation and export of an entity zone.
-- This function creates an entity zone and exports it for external use.
-- @function entity_zone
-- @param name string: The name identifier for the entity zone.
-- @param entity number: The entity for which the zone is created.
-- @param qb_options table: Options passed to the qb-target.
-- @param target_options table: Options specifically for the target handling.
local function entity_zone(name, entity, qb_options, target_options)
    local boii_options = create_entity_zone(entity, qb_options, target_options)
    if boii_options then
        exports['boii_target']:add_entity_zone({entity}, boii_options)
    end
end
export_handler('AddEntityZone', entity_zone)

--- Handles the spawning of a ped and creating an entity zone for it.
-- After creating the zone, it adds it to the 'boii_target' exports.
-- @function handle_spawn_ped
-- @param data table: The data containing information about the ped to spawn and the target options.
local function handle_spawn_ped(data)
    local function get_entity_from_spawn_data(data)
        if not data or not data.model or not data.coords then
            print("Invalid data for spawning ped.")
            return nil
        end
        local model_hash = GetHashKey(data.model)
        if not IsModelInCdimage(model_hash) or not IsModelValid(model_hash) then
            print("Invalid model.")
            return nil
        end
        utils.requests.model(model_hash)
        local ped = CreatePed(1, model_hash, data.coords.x, data.coords.y, data.coords.z-1, data.coords.w, false, false)
        if data.minusOne then
            SetEntityAsMissionEntity(ped, true, false)
        end
        if data.freeze then
            FreezeEntityPosition(ped, true)
        end
        if data.invincible then
            SetEntityInvincible(ped, true)
        end
        if data.blockevents then
            SetBlockingOfNonTemporaryEvents(ped, true)
        end
        if data.scenario then
            TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        elseif data.animDict and data.anim then
            RequestAnimDict(data.animDict)
            while not HasAnimDictLoaded(data.animDict) do
                Wait(1)
            end
            TaskPlayAnim(ped, data.animDict, data.anim, 8.0, -8.0, -1, data.flag or 1, 0, false, false, false)
        end
        SetModelAsNoLongerNeeded(model_hash)
        return ped
    end
    local entity = get_entity_from_spawn_data(data)
    local boii_options = create_entity_zone(entity, data, data.target)
    if boii_options then
        exports['boii_target']:add_entity_zone({entity}, boii_options)
    end
end
export_handler('SpawnPed', handle_spawn_ped)

--- Adds a target entity and creates an entity zone for it.
-- After creating the zone, it adds it to the 'boii_target' exports.
-- @function add_target_entity
-- @param entity number: The entity for which the target zone is being created.
-- @param qb_options table: Options passed to the qb-target.
local function add_target_entity(entity, qb_options)
    local boii_options = create_entity_zone(entity, qb_options)
    if boii_options then
        exports['boii_target']:add_entity_zone({entity}, boii_options)
    end
end
export_handler('AddTargetEntity', add_target_entity)

--- Adds a target model.
-- @function add_target_model
-- @param models table: A table of models for which the target zones are being created.
-- @param target_options table: Options specifically for the target handling.
local function add_target_model(models, target_options)
    if type(models) ~= 'table' then
        models = {models}
    end
    if not target_options or not target_options.options then
        print("No target options provided.")
        return
    end
    for _, model in ipairs(models) do
        local actions = {}
        for i, option in ipairs(target_options.options) do
            add_action(actions, option, i)
        end
        local model_target_options = {
            id = "target_model_" .. model,
            icon = "fa-regular fa-circle",
            distance = target_options.distance or 1.5,
            actions = actions
        }
        exports['boii_target']:add_model({model}, model_target_options)
    end
end
export_handler('AddTargetModel', add_target_model)

--- Adds a circle zone.
-- @function add_circle_zone
-- @param name string: The name of the circle zone.
-- @param coords table: The coordinates of the center of the circle.
-- @param radius number: The radius of the circle.
-- @param zone_options table: Options for the zone.
-- @param target_options table: Options specifically for the target handling.
local function add_circle_zone(name, coords, radius, zone_options, target_options)
    local boii_options = {
        id = name,
        icon = target_options.icon or "fa-regular fa-circle",
        coords = coords,
        radius = radius,
        distance = target_options.distance or 2.0,
        debug = zone_options.debug_poly or false,
        sprite = zone_options.sprite or false,
        actions = {}
    }
    for i, option in ipairs(target_options.options or {}) do
        add_action(boii_options.actions, option, i)
    end
    exports['boii_target']:add_circle_zone(boii_options)
end
export_handler('AddCircleZone', add_circle_zone)

--- Adds a box zone.
-- @function add_box_zone
-- @param name string: The name of the box zone.
-- @param center_coords table: The coordinates of the center of the box.
-- @param length number: The length of the box.
-- @param width number: The width of the box.
-- @param qb_options table: Options passed to the qb-target.
-- @param target_options table: Options specifically for the target handling.
local function add_box_zone(name, center_coords, length, width, qb_options, target_options)
    local zone_options = qb_options or {}
    target_options = target_options or {}
    local depth = (zone_options.max_z or 0) - (zone_options.min_z or 0)
    local boii_options = {
        id = name,
        icon = "fa-regular fa-circle",
        coords = center_coords,
        length = length,
        width = width,
        depth = depth,
        height = zone_options.height or 1.0,
        heading = zone_options.heading or 0,
        distance = target_options.distance or 2.0,
        debug = zone_options.debug_poly or false,
        sprite = zone_options.sprite or false,
        actions = {}
    }
    for i, option in ipairs(target_options.options or {}) do
        add_action(boii_options.actions, option, i)
    end
    exports['boii_target']:add_box_zone(boii_options)
end
export_handler('AddBoxZone', add_box_zone)