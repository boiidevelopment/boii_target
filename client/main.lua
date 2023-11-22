----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Locals
local player_ped = PlayerPedId()
local is_targeting = false

-- Function to handle debug logging
function debug_log(type, message)
    if config.debug and utils.debugging[type] then
        utils.debugging[type](message)
    end
end

-- Function to get current cam details
local function get_camera_details()
    local rendering_cam = false
    if not IsGameplayCamRendering() then
        rendering_cam = GetRenderingCam()
    end
    local cam_rot = not rendering_cam and GetGameplayCamRot() or GetCamRot(rendering_cam, 2)
    local cam_coord = not rendering_cam and GetGameplayCamCoord() or GetCamCoord(rendering_cam)
    return cam_rot, cam_coord
end

-- Function to perform a ray cast from the gameplay camera
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
    local player_pos = GetEntityCoords(player_ped)
    local _, hit, coords, _, entity = GetShapeTestResult(StartShapeTestRay(new_cam_coord.x, new_cam_coord.y, new_cam_coord.z, destination.x, destination.y, destination.z, -1, player_ped, 0))
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

-- Function to get the closest bone for a targetted entity
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

-- Function to check a target entity for registered actions
local function check_entity_for_actions(entity, hit_coords)
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
    if entity_type == 1 then -- Pedestrian
        local actions, zone = (IsPedAPlayer(entity)) and get_closest_bone(entity, hit_coords, targets.players) or get_closest_bone(entity, hit_coords, targets.peds)
        if actions and (not zone.actions.can_interact or zone.actions.can_interact()) then
            return true, actions, zone.icon
        end
    elseif entity_type == 2 then -- Vehicle
        local actions, zone = get_closest_bone(entity, hit_coords, targets.vehicles)
        if actions and (not zone.actions.can_interact or zone.actions.can_interact()) then
            return true, actions, zone.icon
        end
    end
    return false, nil
end

-- Function to handle interactions in zones
local function check_zones_for_actions(coords)
    for zone_type, zones in pairs(targets.zones) do
        for _, zone in pairs(zones) do
            local in_zone = false
            if zone_type == 'circle' then
                in_zone = utils.geometry.is_point_in_circle({x = coords.x, y = coords.y}, zone.coords, zone.radius)
            elseif zone_type == 'sphere' then
                in_zone = utils.geometry.is_point_in_sphere(coords, zone.coords, zone.radius)
            elseif zone_type == 'box' then
                in_zone = utils.geometry.is_point_in_box(coords, {
                    x = zone.coords.x, y = zone.coords.y, z = zone.coords.z,
                    width = zone.width, height = zone.height, depth = zone.depth
                })
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

-- Function to draw debug line
local function draw_debug_line()
    while is_targeting and config.debug do
        local player_pos = GetEntityCoords(player_ped)
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

-- Function to handle disable/enable controls
local function disabled_controls()
    while is_targeting do 
        SetPauseMenuActive(false)
        DisableAllControlActions(0)
        EnableControlAction(0, 30, true)
        EnableControlAction(0, 31, true)
        if not has_focus then
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end
        Wait(0)
    end
end

-- Function to filter interactable actions
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
            interactable_actions[#interactable_actions + 1] = action_copy
        end
    end
    return interactable_actions
end

-- Modify the handle_targeting function
local function handle_targeting()
    local has_focus = false
    CreateThread(draw_debug_line)
    CreateThread(disabled_controls)
    while is_targeting do
        local hit, coords, hit_entity, raycast_coords = ray_cast_game_play_camera(config.raycast_distance)
        local is_target, actions, icon, targeted_entity = false, nil, nil, nil
        if hit then
            is_target, actions, icon = check_entity_for_actions(hit_entity, coords)
            targeted_entity = hit_entity
        else
            is_target, actions, icon = check_zones_for_actions(raycast_coords)
            targeted_entity = nil  -- No specific entity for zones
        end
        if is_target then
            local target_icon = icon or config.target.default_icon
            local interactable_actions = filter_interactable_actions(actions, targeted_entity)
            SendNUIMessage({ action = 'activate_target', icon = target_icon })
            if IsDisabledControlPressed(0, 238) and actions then
                SetCursorLocation(0.5, 0.5)
                SetNuiFocus(true, true)
                SetNuiFocusKeepInput(true)
                has_focus = true
                SendNUIMessage({ action = 'populate_actions', data = interactable_actions })
            end
        else
            SendNUIMessage({ action = 'deactivate_target' })
        end
        Wait(100)
    end
end

--[[
    ZONE FUNCTIONS
]]

-- Function to draw a sprite at the location of zone or entity
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
            local player_coords = GetEntityCoords(player_ped)
            local distance = #(player_coords - current_coords)
            if distance < render_distance then
                local r, g, b, a = table.unpack(options.colour or {255, 255, 255, 255})
                SetDrawOrigin(current_coords.x, current_coords.y, current_coords.z, 0)
                DrawSprite("shared", "emptydot_32", 0, 0, 0.02, 0.035, 0, r, g, b, a)
                ClearDrawOrigin()
            end
            Wait(0)
        end
        SetStreamedTextureDictAsNoLongerNeeded("shared")
    end)
end

-- Function to handle debug drawing for zones
local function draw_debug(zone_type, options)
    local render_distance = 50.0
    CreateThread(function()
        while options.debug do
            local player_coords = GetEntityCoords(player_ped)
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

-- Function to add a circle zone
local function add_circle_zone(options)
    targets.zones.circle = targets.zones.circle or {}
    targets.zones.circle[options.id] = options
    if options.debug then
        draw_debug('circle', options)
    end
    if options.sprite then
        draw_sprite(options)
    end
end

-- Function to add a box zone
local function add_box_zone(options)
    targets.zones.box = targets.zones.box or {}
    targets.zones.box[options.id] = options
    if options.debug then
        draw_debug('box', options)
    end
    if options.sprite then
        draw_sprite(options)
    end
end

-- Function to add a sphere zone
local function add_sphere_zone(options)
    targets.zones.sphere = targets.zones.sphere or {}
    targets.zones.sphere[options.id] = options
    if options.debug then
        draw_debug('sphere', options)
    end
    if options.sprite then
        draw_sprite(options)
    end
end

-- Function to add a entity zone
local function add_entity_zone(entities, options)
    targets.zones.entity = targets.zones.entity or {}
    for _, entity in ipairs(entities) do
        if DoesEntityExist(entity) then
            local min, max = GetModelDimensions(GetEntityModel(entity))
            local length = max.y - min.y
            local width = max.x - min.x
            local height = max.z - min.z
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
                draw_sprite(options)
            end
        end
    end
end

-- Function to add a target model
local function add_model(models, options)
    targets.zones.models = targets.zones.models or {}
    for _, model in ipairs(models) do
        local hash = GetHashKey(model)
        targets.zones.models[hash] = options
    end
end

--[[
    NUI CALLBACKS
]]

-- Register NUI callback for exiting NUI
RegisterNUICallback('exit_nui', function()
    if config.debug then debug_log('debug', 'exit_nui fired') end
    SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end)

-- Register NUI callback for triggering action events
RegisterNUICallback('trigger_action_event', function(data)
    if config.debug then debug_log('debug', 'trigger_action_event fired with data: '..json.encode(data)) end
    if data.action_type == 'server_event' then
        TriggerServerEvent(data.action, data.params)
    elseif data.action_type == 'client_event' then
        TriggerEvent(data.action, data.params)
    end
    SetNuiFocus(false, false)
end)

--[[
    KEYMAPPING
]]

-- Register key mapping for toggling targeting
RegisterKeyMapping('+toggle_target', 'Toggle target.', 'keyboard', 'LMENU')

-- Register command for enabling targeting
RegisterCommand('+toggle_target', function()
    is_targeting = true
    SendNUIMessage({ action = 'show_target', icon = config.target.default_icon })
    while is_targeting do
        handle_targeting()
        Wait(0)
    end
end, false)

-- Register command for disabling targeting
RegisterCommand('-toggle_target', function()
    is_targeting = false
    SendNUIMessage({ action = 'hide_target' })
    SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end, false)

--[[
    RESOURCE EVENTS
]]

-- Handle resource clean up on resource stop
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

--[[
    ASSIGN LOCALS
]]

target.add_circle_zone = add_circle_zone
target.add_box_zone = add_box_zone
target.add_sphere_zone = add_sphere_zone
target.add_entity_zone = add_entity_zone
target.add_model = add_model

--[[
    EXPORTS
]]

exports('add_circle_zone', add_circle_zone)
exports('add_box_zone', add_box_zone)
exports('add_sphere_zone', add_sphere_zone)
exports('add_entity_zone', add_entity_zone)
exports('add_model', add_model)