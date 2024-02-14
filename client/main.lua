--- Main script for the targeting system.
-- @script client/main.lua

--- @section Dependencies

--- Import utility library
utils = exports['boii_utils']:get_utils()

--- @section Tables

local registered_functions = {}

--- @section Variables

local is_targeting = false
local has_focus = false


--- @section Global functions

--- Registers a function under a label to allow NUI to trigger.
-- @function register_function
-- @param label string: The label under which the function is registered.
-- @param func function: The function to register.
function register_function(label, func)
    registered_functions[label] = func
end

--- Calls a registered function by its label.
-- @function call_registered_function
-- @param label string: The label of the function to call.
function call_registered_function(label)
    if registered_functions[label] then
        registered_functions[label]()
    else
        print('Function with label ' .. label .. ' not found.')
    end
end

--- Handles debug logging.
-- @function debug_log
-- @param type string: The type of debug message.
-- @param message string: The debug message.
function debug_log(type, message)
    if config.debug and utils.debugging[type] then
        utils.debugging[type](message)
    end
end

--- @section Local functions

--- Gets the closest bone for a targeted entity.
-- @function get_closest_bone
-- @param entity number: The targeted entity.
-- @param hit_coords table: The hit coordinates.
-- @param targets_table table: The targets table.
-- @return table, table: Returns the closest zone actions and the closest zone.
local function get_closest_bone(entity, hit_coords, targets_table)
    local closest_bone_name = nil
    local min_distance = math.huge
    local closest_zone = nil
    for bone_name, zone in pairs(targets_table) do
        local bone_index = (GetEntityType(entity) == 1) and GetPedBoneIndex(entity, bone_name) or GetEntityBoneIndexByName(entity, bone_name)
        if bone_index ~= -1 then
            local bone_coords = GetWorldPositionOfEntityBone(entity, bone_index)
            local distance = utils.geometry.distance_3d(hit_coords, bone_coords)
            if distance < min_distance then
                min_distance = distance
                closest_bone_name = bone_name
                closest_zone = zone
            end
        end
    end
    if closest_bone_name and min_distance < 5.0 then
        return closest_zone.actions, closest_zone
    else
        return nil, nil
    end
end

--- Checks a target entity for registered actions.
-- @function check_entity_for_actions
-- @param entity number: The targeted entity.
-- @param hit_coords table: The hit coordinates.
-- @return boolean, table, string: Returns if it's a target, actions, and icon.
local function check_entity_for_actions(entity, hit_coords)
    if not DoesEntityExist(entity) then return false, nil end
    local entity_type = GetEntityType(entity)
    local entity_model = GetEntityModel(entity)
    local model_options = targets.zones.models[entity_model]
    local entity_zone_options = targets.zones.entity[entity]
    if entity_zone_options then
        if entity_zone_options.actions and (not entity_zone_options.actions.can_interact or entity_zone_options.actions.can_interact()) then
            return true, entity_zone_options.actions, entity_zone_options.icon
        end
    end
    if model_options then
        if model_options.actions and (not model_options.actions.can_interact or model_options.actions.can_interact()) then
            return true, model_options.actions, model_options.icon
        end
    end
    if entity_type == 1 then
        local actions, zone = (IsPedAPlayer(entity)) and get_closest_bone(entity, hit_coords, targets.players) or get_closest_bone(entity, hit_coords, targets.peds)
        if actions and (not zone.actions.can_interact or zone.actions.can_interact()) then
            return true, actions, zone.icon
        end
    elseif entity_type == 2 then
        local actions, zone = get_closest_bone(entity, hit_coords, targets.vehicles)
        if actions and (not zone.actions.can_interact or zone.actions.can_interact()) then
            return true, actions, zone.icon
        end
    end
    return false, nil
end

--- Handles interactions in zones.
-- @function check_zones_for_actions
-- @param coords table: The coordinates to check for zone interactions.
-- @return boolean, table, string: Returns if it's a target, actions, and icon.
local function check_zones_for_actions(coords)
    for zone_type, zones in pairs(targets.zones) do
        for _, zone in pairs(zones) do
            local in_zone = false
            if zone_type == 'circle' then
                in_zone = utils.geometry.is_point_in_circle({x = coords.x, y = coords.y}, zone.coords, zone.radius)
            elseif zone_type == 'sphere' then
                in_zone = utils.geometry.is_point_in_sphere(coords, zone.coords, zone.radius)
            elseif zone_type == 'box' then
                in_zone = utils.geometry.is_point_in_oriented_box(coords, zone)
            end
            if in_zone then
                if (not zone.actions.can_interact or zone.actions.can_interact()) then
                    return true, zone.actions, zone.icon
                end
            end
        end
    end
    return false, nil
end

--- Gets current camera details.
-- @function get_camera_details
-- @return table, table: Returns camera rotation and camera coordinates.
local function get_camera_details()
    local rendering_cam = false
    if not IsGameplayCamRendering() then
        rendering_cam = GetRenderingCam()
    end
    local cam_rot = not rendering_cam and GetGameplayCamRot() or GetCamRot(rendering_cam, 2)
    local cam_coord = not rendering_cam and GetGameplayCamCoord() or GetCamCoord(rendering_cam)
    return cam_rot, cam_coord
end

--- Performs a ray cast from the gameplay camera.
-- @function ray_cast_game_play_camera
-- @param max_distance number: The maximum distance for the raycast.
-- @return boolean, table, number, table: Returns if hit, hit coordinates, entity, and destination.
local function ray_cast_game_play_camera(max_distance)
    local cam_rot, cam_coord = get_camera_details()
    local direction = utils.geometry.rotation_to_direction(cam_rot)
    local offset = 0.6
    local new_cam_coord = vector3(cam_coord.x, cam_coord.y, cam_coord.z + offset)
    local destination = {
        x = new_cam_coord.x + direction.x * max_distance,
        y = new_cam_coord.y + direction.y * max_distance,
        z = new_cam_coord.z + direction.z * max_distance
    }
    local player_pos = GetEntityCoords(PlayerPedId())
    local _, hit, coords, _, entity = GetShapeTestResult(StartShapeTestRay(new_cam_coord.x, new_cam_coord.y, new_cam_coord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    if hit then
        local entity_pos = GetEntityCoords(entity)
        local distance = utils.geometry.distance_3d(player_pos, entity_pos)
        if distance <= max_distance then
            return hit, coords, entity, destination
        end
    else
        local is_target, actions = check_zones_for_actions(destination)
        if is_target then
            return true, destination, nil, destination
        end
    end
    return false, nil, nil, destination
end

--- Draws debug line.
-- @function draw_debug_line
local function draw_debug_line()
    while is_targeting and config.debug do
        local player_pos = GetEntityCoords(PlayerPedId())
        local cam_rot, cam_coord = get_camera_details()
        local direction = utils.geometry.rotation_to_direction(cam_rot)
        local new_cam_coord = vector3(cam_coord.x, cam_coord.y, cam_coord.z + 0.6)
        local destination = {
            x = new_cam_coord.x + direction.x * config.raycast_distance,
            y = new_cam_coord.y + direction.y * config.raycast_distance,
            z = new_cam_coord.z + direction.z * config.raycast_distance
        }
        utils.draw.line({ start_pos = player_pos, end_pos = destination, colour = {255, 255, 255, 255} })
        Wait(0)
    end
end

--- Handles disabling/enabling controls.
-- @function disabled_controls
local function disabled_controls()
    repeat
        SetPauseMenuActive(false)
        DisableAllControlActions(0)
        EnableControlAction(0, 30, true)
        EnableControlAction(0, 31, true)
        if not has_focus then
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end

        Wait(0)
    until not is_targeting
end

--- Filters interactable actions and registers function actions.
-- @function filter_interactable_actions
-- @param actions table: The actions to filter.
-- @param entity number: The entity for which the actions are filtered.
-- @return table: Returns interactable actions.
local function filter_interactable_actions(actions, entity)
    local interactable_actions = {}
    for _, action in ipairs(actions) do
        if not action.can_interact or action.can_interact(entity) then
            local action_copy = {}
            for key, value in pairs(action) do
                if key ~= 'can_interact' then
                    action_copy[key] = value
                end
            end
            if action_copy.action_type == 'function' and type(action_copy.action) == 'function' then
                local func_identifier = action_copy.label
                register_function(func_identifier, action_copy.action)
                action_copy.action = func_identifier
            end
            interactable_actions[#interactable_actions + 1] = action_copy
        end
    end
    return interactable_actions
end

--- Handles targeting.
-- @function handle_targeting
local function handle_targeting()
    has_focus = false
    CreateThread(draw_debug_line)
    CreateThread(disabled_controls)
    while is_targeting do
        local hit, coords, hit_entity, raycast_coords = ray_cast_game_play_camera(config.raycast_distance)
        local is_target, actions, icon, targeted_entity
        if hit then
            is_target, actions, icon = check_entity_for_actions(hit_entity, coords)
            targeted_entity = hit_entity
        end
        if not is_target then
            is_target, actions, icon = check_zones_for_actions(raycast_coords)
        end
        if is_target then
            local action_copy = actions[1] -- Assuming there's only one action
            if action_copy and action_copy.item and type(action_copy.item) == 'string' then
                utils.fw.has_item(action_copy.item, action_copy.item_amount or 1, function(success)
                    if success then
                        local target_icon = icon or config.target.default_icon
                        local interactable_actions = filter_interactable_actions(actions, targeted_entity)
                        SendNUIMessage({ action = 'activate_target', icon = target_icon })
                        local key = utils.keys.get_key(config.target.keys.menu_open)
                        if IsDisabledControlPressed(0, key) and actions and not has_focus then
                            SetCursorLocation(0.5, 0.5)
                            SetNuiFocus(true, true)
                            SetNuiFocusKeepInput(true)
                            SendNUIMessage({ action = 'populate_actions', data = interactable_actions })
                            has_focus = true
                        end
                    else
                        SendNUIMessage({ action = 'deactivate_target' })
                    end
                end)
            else
                local target_icon = icon or config.target.default_icon
                local interactable_actions = filter_interactable_actions(actions, targeted_entity)
                SendNUIMessage({ action = 'activate_target', icon = target_icon })
                local key = utils.keys.get_key(config.target.keys.menu_open)
                if IsDisabledControlPressed(0, key) and actions and not has_focus then
                    SetCursorLocation(0.5, 0.5)
                    SetNuiFocus(true, true)
                    SetNuiFocusKeepInput(true)
                    SendNUIMessage({ action = 'populate_actions', data = interactable_actions })
                    has_focus = true
                end
            end
        else
            SendNUIMessage({ action = 'deactivate_target' })
        end
        Wait(100)
    end
end

--- Draws a sprite at the location of a zone or entity.
-- @function draw_sprite
-- @param options table: Options for the sprite, including entity, coords, colour, and sprite state.
local function draw_sprite(options)
    local render_distance = 20.0
    CreateThread(function()
        utils.requests.texture('shared', true)
        while options.sprite do
            local current_coords
            if options.entity then
                current_coords = GetEntityCoords(options.entity)
            else
                current_coords = options.coords
            end
            local player_coords = GetEntityCoords(PlayerPedId()) or {x = 0, y = 0, z = 0}
            local distance = #(player_coords - current_coords)
            if distance < render_distance then
                local r, g, b, a = table.unpack(options.colour or {255, 255, 255, 255})
                SetDrawOrigin(current_coords.x, current_coords.y, current_coords.z, 0)
                DrawSprite('shared', 'emptydot_32', 0, 0, 0.02, 0.035, 0, r, g, b, a)
                ClearDrawOrigin()
            end
            Wait(0)
        end
        SetStreamedTextureDictAsNoLongerNeeded('shared')
    end)
end

--- Handles debug drawing for different types of zones (circle, box, sphere, entity).
-- @function draw_debug
-- @param zone_type string: The type of the zone ('circle', 'box', 'sphere', 'entity').
-- @param options table: Options for drawing the debug visuals.
local function draw_debug(zone_type, options)
    local render_distance = 50.0
    CreateThread(function()
        while options.debug do
            local player_coords = GetEntityCoords(PlayerPedId())
            local distance = #(player_coords - options.coords)
            if distance < render_distance then
                if zone_type == 'circle' then
                    utils.draw.marker({
                        type = 1,
                        coords = vector3(options.coords.x, options.coords.y, options.coords.z - 1.0),
                        dir = vector3(0.0, 0.0, 1.0),
                        rot = vector3(90.0, 0.0, 0.0),
                        scale = vector3(options.radius * 2, options.radius * 2, 1.0),
                        colour = {77, 203, 194, 100},
                        bob = false,
                        face_cam = false,
                        p19 = 2,
                        rotate = false,
                        texture_dict = nil,
                        texture_name = nil,
                        draw_on_ents = false
                    })
                elseif zone_type == 'box' then
                    local dimensions = {
                        width = options.width,
                        length = options.depth,
                        height = options.height
                    }
                    utils.draw.draw_3d_cuboid(options.coords, dimensions, options.heading, {77, 203, 194, 100})
                elseif zone_type == 'sphere' then
                    utils.draw.sphere({
                        coords = options.coords,
                        radius = options.radius,
                        colour = {77, 203, 194, 100}
                    })
                elseif zone_type == 'entity' then
                    local entity_coords = GetEntityCoords(options.entity)
                    local heading = GetEntityHeading(options.entity)
                    local dimensions = {width = options.width, length = options.length, height = options.height}
                    utils.draw.draw_3d_cuboid(entity_coords, dimensions, heading-90, {77, 203, 194, 100})
                end
            end
            Wait(0)
        end
    end)
end

--- Adds a circle zone to the targets.
-- @function add_circle_zone
-- @param options table: Options for the circle zone including id, debug state, and sprite state.
local function add_circle_zone(options)
    targets.zones.circle = targets.zones.circle or {}
    targets.zones.circle[options.id] = options
    if options.debug then
        draw_debug('circle', options)
    end
    if options.sprite then
        --draw_sprite(options)
    end
end

--- Adds a box zone to the targets.
-- @function add_box_zone
-- @param options table: Options for the box zone including id, debug state, and sprite state.
local function add_box_zone(options)
    targets.zones.box = targets.zones.box or {}
    targets.zones.box[options.id] = options
    if options.debug then
        draw_debug('box', options)
    end
    if options.sprite then
        --draw_sprite(options)
    end
end

--- Adds a sphere zone to the targets.
-- @function add_sphere_zone
-- @param options table: Options for the sphere zone including id, debug state, and sprite state.
local function add_sphere_zone(options)
    targets.zones.sphere = targets.zones.sphere or {}
    targets.zones.sphere[options.id] = options
    if options.debug then
        draw_debug('sphere', options)
    end
    if options.sprite then
        --draw_sprite(options)
    end
end

--- Adds an entity zone with size modifier to the targets.
-- @function add_entity_zone
-- @param entities table: The entities for which the zones are created.
-- @param options table: Options for the entity zone including entity, coords, size modifier, debug state, and sprite state.
local function add_entity_zone(entities, options)
    targets.zones.entity = targets.zones.entity or {}
    local size_modifier = options.modifiers or {x = 0.0, y = 0.0, z = 0.0}
    for _, entity in ipairs(entities) do
        if DoesEntityExist(entity) then
            local min, max = GetModelDimensions(GetEntityModel(entity))
            local length = (max.y - min.y) * size_modifier.y
            local width = (max.x - min.x) * size_modifier.x
            local height = (max.z - min.z) * size_modifier.z
            local pos = GetEntityCoords(entity)
            options.entity = entity
            options.coords = pos
            options.length = length
            options.width = width
            options.height = height
            targets.zones.entity[entity] = options
            if options.debug then
                draw_debug('entity', options)
            end
            if options.sprite then
                --draw_sprite(options)
            end
        end
    end
end

--- Adds a target model to the targets.
-- @function add_model
-- @param models table: The models for which the targets are created.
-- @param options table: Options for the target model, including actions and interaction details.
local function add_model(models, options)
    targets.zones.models = targets.zones.models or {}
    for _, model in ipairs(models) do
        local hash = GetHashKey(model)
        targets.zones.models[hash] = options
    end
end

--- Adds a player interaction target based on a specific bone.
-- @function add_player
-- @param bone string: The bone name to attach the interaction to (e.g., 'head' for talking, 'hand_l' for trading).
-- @param options table: A table containing the interaction details such as ID, icon, distance, and actions to be taken.
local function add_player(bone, options)
    targets.players = targets.players or {}
    targets.players[bone] = options
end

--- Adds a vehicle interaction target based on a specific bone.
-- @function add_vehicle
-- @param bone string: The bone name to attach the interaction to (e.g., 'door_dside_f' for the driver's door).
-- @param options table: A table containing the interaction details such as ID, icon, distance, and actions to be taken.
local function add_vehicle(bone, options)
    targets.vehicles = targets.vehicles or {}
    targets.vehicles[bone] = options
end

-- Removes a target based on ID from any target category.
-- @param targetId string: The ID of the target to remove.
local function remove_target(targetId)
    -- A helper function to remove target from a specific collection
    local function remove(collection)
        if collection[targetId] then
            collection[targetId] = nil
            return true
        end
        return false
    end
    if remove(targets.vehicles) then return end
    if remove(targets.peds) then return end
    if remove(targets.players) then return end
    for _, zoneType in pairs({ 'circle', 'box', 'sphere', 'entity', 'models' }) do
        if remove(targets.zones[zoneType]) then return end
    end
    print('Target with ID: '..targetId..' not found in any category.')
end

--- @section NUI Callbacks

--- Handles the event when NUI is exited.
-- @event exit_nui
RegisterNUICallback('exit_nui', function()
    debug_log('info', 'exit_nui fired')
    has_focus = false
    SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end)

--- Triggers an action event and handles the response.
-- @event trigger_action_event
-- @param data table: Data containing action details.
-- @param cb function: Callback function to handle the response.
RegisterNUICallback('trigger_action_event', function(data, cb)
    if not data or not data.action then
        debug_log('err', 'Error: '..data..' or '..data.action..' is nil.')
        return
    end
    if data.action_type == 'function' then
        call_registered_function(data.action)
    elseif data.action_type == 'server' then
        TriggerServerEvent(data.action, data.params)
    elseif data.action_type == 'client' then
        TriggerEvent(data.action, data.params)
    else
        debug_log('err', 'Error: Unknown action_type.')
    end
    SetNuiFocus(false, false)
    if cb then
        cb('ok')
    end
end)

--- @section Keymapping

--- Registers a key mapping for toggling targeting.
-- @function RegisterKeyMapping
-- @usage RegisterKeyMapping('+toggle_target', 'Toggle target.', 'keyboard', config.target.keys.show_target)
RegisterKeyMapping('+toggle_target', 'Toggle target.', 'keyboard', config.target.keys.show_target)

--- Registers a command for enabling targeting.
-- @function RegisterCommand
-- @usage RegisterCommand('+toggle_target', function() { /* ... */ }, false)
RegisterCommand('+toggle_target', function()
    is_targeting = true
    SendNUIMessage({ action = 'show_target', icon = config.target.default_icon })
    while is_targeting do
        handle_targeting()
        Wait(0)
    end
end, false)

--- Registers a command for disabling targeting.
-- @function RegisterCommand
-- @usage RegisterCommand('-toggle_target', function() { /* ... */ }, false)
RegisterCommand('-toggle_target', function()
    is_targeting = false
    has_focus = false
    SendNUIMessage({ action = 'hide_target' })
    SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end, false)

--- @section Event handlers

--- Handles resource cleanup when a resource stops.
-- @event onResourceStop
-- @param res string: The name of the resource that stopped.
AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    targets = {}
    for _, ped in ipairs(testing_peds) do
        utils.peds.remove_ped(ped)
    end
    for _, ent in ipairs(testing_ents) do
        DeleteEntity(ent)
    end
end)

--- @section Assign local functions

target.add_circle_zone = add_circle_zone
target.add_box_zone = add_box_zone
target.add_sphere_zone = add_sphere_zone
target.add_entity_zone = add_entity_zone
target.add_model = add_model
target.add_player = add_player
target.add_vehicle = add_vehicle
target.remove_target = remove_target

--- @section Exports

exports('add_circle_zone', add_circle_zone)
exports('add_box_zone', add_box_zone)
exports('add_sphere_zone', add_sphere_zone)
exports('add_entity_zone', add_entity_zone)
exports('add_model', add_model)
exports('add_player', add_player)
exports('add_vehicle', add_vehicle)
exports('remove_target', remove_target)
