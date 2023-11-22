----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Locals
local player_ped = PlayerPedId()

-- Vehicle targets
if config.default_actions.vehicles then
    targets.vehicles = {
        ['door_dside_f'] = {
            id = 'vehicle_door_dside_f',
            bone = 'door_dside_f',
            icon = 'fa-solid fa-door-open',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Drivers Door',
                    icon = 'fa-solid fa-door-closed',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 0 },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        },
        ['door_pside_f'] = {
            id = 'vehicle_door_pside_f',
            bone = 'door_pside_f',
            icon = 'fa-regular fa-circle',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Passenger Door',
                    icon = 'fa-solid fa-door-closed',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 1 },
                    can_interact = function(vehicle)
                        return true 
                    end
                }
            }
        },
        ['door_dside_r'] = {
            id = 'vehicle_door_dside_r',
            bone = 'door_dside_r',
            icon = 'fa-regular fa-circle',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Rear Driver\'s Door',
                    icon = 'fa-solid fa-door-closed',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 2 },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        },
        ['door_pside_r'] = {
            id = 'vehicle_door_pside_r',
            bone = 'door_pside_r',
            icon = 'fa-regular fa-circle',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Rear Passenger Door',
                    icon = 'fa-solid fa-door-closed',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 3 },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        },
        ['bonnet'] = {
            id = 'vehicle_bonnet',
            bone = 'bonnet',
            icon = 'fa-solid fa-car',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Bonnet',
                    icon = 'fa-solid fa-car-side',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 4 },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        },
        ['boot'] = {
            id = 'vehicle_boot',
            bone = 'boot',
            icon = 'fa-solid fa-car-rear',
            distance = 0.6,
            actions = { 
                {
                    label = 'Toggle Boot',
                    icon = 'fa-solid fa-car-rear',
                    action_type = 'client_event',
                    action = 'boii_target:cl:toggle_vehicle_door',  
                    params = { door_index = 5 },
                    can_interact = function(vehicle)
                        return true
                    end
                },
                {
                    label = 'Push Vehicle',
                    icon = 'fa-solid fa-hand-rock',
                    action_type = 'client_event',
                    action = 'boii_target:cl:push_vehicle',
                    params = { is_front = false },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        },
        ['engine'] = {
            id = 'vehicle_engine',
            bone = 'engine',
            icon = 'fa-solid fa-gear',
            distance = 1.5,
            actions = {
                {
                    label = 'Flip Vehicle',
                    icon = 'fa-solid fa-undo',
                    action_type = 'client_event',
                    action = 'boii_target:cl:flip_vehicle',
                    can_interact = function(vehicle)
                        return not IsVehicleOnAllWheels(vehicle)
                    end
                },
                {
                    label = 'Push Vehicle',
                    icon = 'fa-solid fa-hand-rock',
                    action_type = 'client_event',
                    action = 'boii_target:cl:push_vehicle',
                    params = { is_front = true },
                    can_interact = function(vehicle)
                        return true
                    end
                }
            }
        }
    }
end

-- Function to toggle vehicle door
local function toggle_door(vehicle, door_index)
    if GetVehicleDoorAngleRatio(vehicle, door_index) > 0.0 then
        SetVehicleDoorShut(vehicle, door_index, false)
    else
        SetVehicleDoorOpen(vehicle, door_index, false, false)
    end
end

-- Event to trigger toggle door function on closest vehicle
RegisterNetEvent('boii_target:cl:toggle_vehicle_door', function(data)
    local vehicle_data = utils.vehicles.get_vehicle_details(false)
    toggle_door(vehicle_data.vehicle, data.door_index)
end)

-- Function to flip a vehicle
local function flip_vehicle(vehicle)
    utils.requests.anim('mini@repair')
    TaskPlayAnim(player_ped, 'mini@repair', 'fixing_a_ped', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
    Wait(10 * 1000)
    local vehicle_rotation = GetEntityRotation(vehicle, 2)
    SetEntityRotation(vehicle, vehicle_rotation.x, 0, vehicle_rotation.z, 2, true)
    SetVehicleOnGroundProperly(vehicle)
    ClearPedTasks(player_ped)
    if config.debug then
        debug_log('debug', 'Flipped a vehicle successfully.')
    end
end

-- Event to flip the closest vehicle thats upside down to the player
RegisterNetEvent('boii_target:cl:flip_vehicle', function()
    local vehicle_data = utils.vehicles.get_vehicle_details(false)
    if not IsVehicleOnAllWheels(vehicle_data.vehicle) then
        flip_vehicle(vehicle_data.vehicle)
    end
end)

-- Function to push a vehicle
local function push_vehicle(vehicle, is_front)
    local min, max = GetModelDimensions(GetEntityModel(vehicle))
    local offset, heading
    local z_offset = 0.5 
    if not is_front then
        offset = vector3(0.0, min.y - 0.6, z_offset)
        heading = GetEntityHeading(vehicle) + 30.0
    else
        offset = vector3(0.0, max.y + 0.4, z_offset)
        heading = GetEntityHeading(vehicle) + 210.0 
    end
    utils.requests.anim('missfinale_c2ig_11')
    TaskPlayAnim(player_ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
    AttachEntityToEntity(player_ped, vehicle, 0, offset.x, offset.y, offset.z, 0.0, 0.0, heading, false, false, false, false, true)
    while true do
        if IsControlPressed(0, 38) then
            local speed = GetFrameTime() * 50
            local angle = 0.0
            if IsDisabledControlJustPressed(0, 34) then
                angle = angle + speed
            elseif IsDisabledControlJustPressed(0, 35) then
                angle = angle - speed
            end
            angle = math.min(math.max(angle, -15.0), 15.0)
            SetVehicleSteeringAngle(vehicle, angle)
            SetVehicleForwardSpeed(vehicle, is_front and -1.0 or 1.0)
        elseif IsControlJustReleased(0, 38) then
            break
        end
        Wait(5)
    end
    DetachEntity(player_ped, true, false)
    ClearPedTasksImmediately(player_ped)
end

-- Register the event for pushing the vehicle
RegisterNetEvent('boii_target:cl:push_vehicle', function(data)
    local vehicle_data = utils.vehicles.get_vehicle_details(false)
    if vehicle_data then
        push_vehicle(vehicle_data.vehicle, data.is_front)
    end
end)
