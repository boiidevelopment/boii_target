![image](https://github.com/boiidevelopment/boii_target/assets/90377400/4bc66bf4-6286-431c-ba78-8942be204f40)

# BOII | Development - Utility: Target System (W.I.P)

Here we have exactly what everyone wanted, another targetting resource...
So why make another target resource? The short answer.. Why not? 
Script functions like a targeting system should, create a zone, model or entity and attach a set of actions to it you can access through the target. Simple realy.
Currently supports box zones, circle, sphere plus included support for target models and entity zones.
Additional features may be added in the future as this will be used heavily throughout our resource catalogue if we need something it will be added.
Enjoy!

### Dependencies

- `boii_utils` - https://github.com/boiidevelopment/boii_utils

### Install 

1. Script Customisation:

- Customise `client/config.lua` to meet your requirements, you can disable the provided default actions here.
- Customise `html/css/root.css` to edit the style of the target system 

2. Script Installation:

- Drag and drop `boii_target` into your server resources.
- Add `ensure boii_target` to your server.cfg and make sure to add `ensure boii_utils` above. e.g.

    ```
        ensure boii_utils
        ensure boii_target
    ```

3. Restart Server:

- Once you have completed step 1 & 2 you are ready to restart your server and the resource should be running correctly.

### How to

1. Accessing target functions

- To access the targeting functions you have two options available. 

1. Import all the target functions into your client side files using the following; 

```lua
    local target = exports['boii_target']:get_target()
``` 

Once the above line has been added you can then use the following functions within your resource; 

```lua
    target.add_circle_zone({...})
    target.add_box_zone({...})
    target.add_sphere_zone({...})
    target.add_entity_zone({...})
    target.add_model({...})
```

2. If you only wish to use one or two of the target functions you can instead export directly using the following; 

```lua
    exports['boii_target']:get_target()
    exports('add_circle_zone', add_circle_zone)
    exports('add_box_zone', add_box_zone)
    exports('add_sphere_zone', add_sphere_zone)
    exports('add_entity_zone', add_entity_zone)
    exports('add_model', add_model)
```

2. Example usage:

- Circle zone

```lua
target.add_circle_zone({
    id = "test_circle_zone",
    icon = "fa-solid fa-circle",
    coords = vector3(-254.09, -971.48, 31.22),
    radius = 2.0,
    distance = 2.0,
    debug = false,
    sprite = true,
    actions = {
        {
            label = "Test Circle Zone",
            icon = "fa-solid fa-circle",
            action_type = "client_event",
            action = "test_circle_action",
            params = {},
            can_interact = function(player) return true end,
        }
    }
})
```

- Boz zone

```lua
target.add_box_zone({
    id = "test_box_zone",
    icon = "fa-solid fa-square",
    coords = vector3(-241.74, -990.81, 29.29),
    width = 3,
    height = 3,
    depth = 3,
    heading = 45,
    distance = 2.0,
    debug = false,
    sprite = true,
    actions = {
        {
            label = "Test Box Zone",
            icon = "fa-solid fa-square",
            action_type = "client_event",
            action = "test_box_action",
            params = {},
            can_interact = function(player) return true end,
        }
    }
})
```

- Sphere zone

```lua
target.add_sphere_zone({
    id = "test_sphere_zone",
    icon = "fa-solid fa-globe",
    coords = vector3(-261.38, -978.18, 31.22),
    radius = 2.0,
    distance = 2.0,
    debug = false,
    sprite = true,
    actions = {
        {
            label = "Test Sphere Zone",
            icon = "fa-solid fa-globe",
            action_type = "client_event",
            action = "test_sphere_action",
            params = {},
            can_interact = function(player) return true end
        }
    }
})
```

- Target model

```lua
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
                action_type = "client_event",
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
```

- Entity zone 

```lua
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
            debug = false,
            sprite = true,
            actions = {
                {
                    label = "Test Entity Zone",
                    icon = "fa-solid fa-car",
                    action_type = "client_event",
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
```

### PREVIEW
![image](https://github.com/boiidevelopment/boii_target/assets/90377400/05e87368-5ba6-4dd3-8c53-86572b9e1178)


### SUPPORT
https://discord.gg/boiidevelopment
