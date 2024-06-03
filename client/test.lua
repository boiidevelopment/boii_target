--[[
     ____   ____ _____ _____   _   _____  ________      ________ _      ____  _____  __  __ ______ _   _ _______ 
    |  _ \ / __ \_   _|_   _| | | |  __ \|  ____\ \    / /  ____| |    / __ \|  __ \|  \/  |  ____| \ | |__   __|
    | |_) | |  | || |   | |   | | | |  | | |__   \ \  / /| |__  | |   | |  | | |__) | \  / | |__  |  \| |  | |   
    |  _ <| |  | || |   | |   | | | |  | |  __|   \ \/ / |  __| | |   | |  | |  ___/| |\/| |  __| | . ` |  | |   
    | |_) | |__| || |_ _| |_  | | | |__| | |____   \  /  | |____| |___| |__| | |    | |  | | |____| |\  |  | |   
    |____/ \____/_____|_____| | | |_____/|______|   \/   |______|______\____/|_|    |_|  |_|______|_| \_|  |_|   
                              | |                                                                                
                              |_|                 TARGET
]]

--- Section covers some test functions this will be removed post development.
-- @script client/test.lua

if config.testing then
    
    -- Creating a test circle zone
    target.add_circle_zone({
        id = "test_circle_zone",
        icon = "fa-solid fa-circle",
        coords = vector3(-254.09, -971.48, 31.22),
        radius = 2.0,
        distance = 2.0,
        debug = true,
        sprite = false,
        actions = {
            {
                label = "Test Circle Zone",
                icon = "fa-solid fa-circle",
                action_type = "client",
                action = "test_circle_action",
                params = {},
                can_interact = function(player) return true end,
            }
        }
    })

    -- Creating a test box zone
    target.add_box_zone({
        id = "test_box_zone",
        icon = "fa-solid fa-square",
        coords = vector3(-241.74, -990.81, 29.29),
        width = 3,
        height = 3,
        depth = 3,
        heading = 45,
        distance = 2.0,
        debug = true,
        sprite = false,
        actions = {
            {
                label = "Test Box Zone",
                icon = "fa-solid fa-square",
                action_type = "client",
                action = "test_box_action",
                params = {},
                can_interact = function(player) return true end,
            }
        }
    })

    -- Creating a test sphere zone
    target.add_sphere_zone({
        id = "test_sphere_zone",
        icon = "fa-solid fa-globe",
        coords = vector3(-261.38, -978.18, 31.22),
        radius = 2.0,
        distance = 2.0,
        debug = true,
        sprite = false,
        actions = {
            {
                label = "Test Sphere Zone",
                icon = "fa-solid fa-globe",
                action_type = "client",
                action = "test_sphere_action",
                params = {},
                can_interact = function(player) return true end
            }
        }
    })

    local function test_add_model()
        local models = {'a_m_m_business_01'}
        for _, model in ipairs(models) do
            local ped_data = {
                base_data = {
                    model = model,
                    coords = vector4(-249.07, -1001.14, 29.15, 337.32),
                    scenario = 'WORLD_HUMAN_AA_COFFEE',
                    networked = false
                }
            }
            local test_ped = utils.peds.create_ped(ped_data)
            testing_peds[#testing_peds + 1] = test_ped
        end
        target.add_model(models, {
            id = "test_model",
            icon = "fa-solid fa-coffee",
            coords = vector4(-249.07, -1001.14, 29.15, 337.32),
            distance = 2.5,
            actions = {
                {
                    label = "Test Model",
                    icon = "fa-solid fa-coffee",
                    action_type = "client",
                    action = "your_event_name",
                    params = {},
                    can_interact = function(entity)
                        return not IsPedAPlayer(entity) and IsEntityDead(entity)
                    end
                },
            },
        })
    end
    test_add_model()

    local function test_entity_zone()
        local vehicle_data = {
            model = 'adder', -- Example model
            coords = vector4(-242.23, -1004.29, 28.98, 159.01),
            is_network = true,
            net_mission_entity = true,
        }
        local vehicle = utils.vehicles.spawn_vehicle(vehicle_data)
        testing_ents[#testing_ents + 1] = vehicle
        if DoesEntityExist(vehicle) then
            target.add_entity_zone({vehicle}, {
                id = "test_vehicle_zone",
                icon = "fa-solid fa-car",
                distance = 2.5,
                debug = true,
                sprite = false,
                actions = {
                    {
                        label = "Test Entity Zone",
                        icon = "fa-solid fa-car",
                        action_type = "client",
                        action = "your_event_name_for_vehicle",
                        params = {},
                        can_interact = function(entity)
                            return entity == vehicle 
                        end
                    },
                }
            })
        end
    end
    test_entity_zone()

    local function test_entity_zone_function()
        local vehicle_data = {
            model = 'adder',
            coords = vector4(-234.79, -986.17, 29.18, 335.52),
            is_network = true,
            net_mission_entity = true,
        }
        local vehicle = utils.vehicles.spawn_vehicle(vehicle_data)
        testing_ents[#testing_ents + 1] = vehicle
        if DoesEntityExist(vehicle) then
            target.add_entity_zone({vehicle}, {
                id = "test_vehicle_zone",
                icon = "fa-solid fa-car",
                distance = 2.5,
                debug = true,
                sprite = false,
                actions = {
                    {
                        label = "Test Entity Zone",
                        icon = "fa-solid fa-car",
                        action_type = "function",
                        action = function()
                            print('Function triggered from target action')
                        end,
                        can_interact = function(entity)
                            return entity == vehicle 
                        end,
                        jobs = {
                            { id = 'unemployed', grades = { 0 }, on_duty = true }
                        }
                    },
                }
            })
        end
    end
    test_entity_zone_function()

    local function test_add_ped()
        target.add_ped({
            icon = 'fa-solid fa-gear',
            distance = 2.5,
            disabled_types = { 28, 29, 30, 31 },
            actions = {
                label = 'Test Global Ped',
                icon = 'fa-solid fa-comment',
                action_type = 'client',
                action = 'target:test_event',
                params = {}
            }
        })
    end

    test_add_ped()
end
