--- Client configuration for the target system.
-- @script client/config.lua

-- Global target variable
target = target or {}

-- Global config variable
config = config or {}

-- Global targets variable containing specific target types
targets = targets or {}
targets.vehicles = targets.vehicles or {}
targets.peds = targets.peds or {}
targets.players = targets.players or {}
targets.zones = targets.zones or {}
targets.zones.circle = targets.zones.circle or {}
targets.zones.box = targets.zones.box or {}
targets.zones.sphere = targets.zones.sphere or {}
targets.zones.entity = targets.zones.entity or {}
targets.zones.models = targets.zones.models or {}

--- Testing configurations (to be removed post-development)
-- @field testing boolean: Enables or disables test mode
-- @field testing_peds table: Stores testing peds
-- @field testing_ents table: Stores testing entities
config.testing = false
testing_peds = {}
testing_ents = {}

--- Debug configuration
-- @field debug boolean: Enables or disables debug mode
config.debug = false

--- Raycast configuration
-- @field raycast_distance number: Maximum distance for the raycast
config.raycast_distance = 5.0

--- Target system configuration
-- @field default_icon string: Default icon for the target system
-- @field keys table: Contains key bindings for showing targets and opening the menu
config.target = {
    default_icon = 'fa-regular fa-circle',
    keys = {
        show_target = 'lmenu',
        menu_open = 'mouse2'
    }
}

--- Default bones configuration
-- @field peds table: Contains default bones for peds
-- @field vehicles table: Contains default bones for vehicles
config.bones = {
    peds = {
        'IK_Head', 'SKEL_Spine_Chest', 'SKEL_Spine3', 'SKEL_Spine2',
        'SKEL_Spine1', 'SKEL_L_UpperArm', 'SKEL_R_UpperArm', 'SKEL_L_Forearm',
        'SKEL_R_Forearm', 'SKEL_L_Hand', 'SKEL_R_Hand', 'SKEL_L_Thigh',
        'SKEL_R_Thigh', 'SKEL_L_Calf', 'SKEL_R_Calf', 'SKEL_L_Foot',
        'SKEL_R_Foot', 'SKEL_Pelvis', 'SKEL_L_Clavicle', 'SKEL_R_Clavicle'
    },
    vehicles = {
        'chassis', 'windscreen', 'seat_pside_r', 'seat_dside_r', 
        'bodyshell', 'suspension_lm', 'suspension_lr', 'platelight', 
        'attach_female', 'attach_male', 'bonnet', 'boot', 'chassis_dummy', 
        'chassis_Control', 'door_dside_f', 'door_dside_r', 'door_pside_f', 
        'door_pside_r', 'Gun_GripR', 'windscreen_f', 'platelight', 
        'VFX_Emitter', 'window_lf', 'window_lr', 'window_rf', 
        'window_rr', 'engine', 'gun_ammo', 'ROPE_ATTATCH', 
        'wheel_lf', 'wheel_lr', 'wheel_rf', 'wheel_rr', 
        'exhaust', 'overheat', 'seat_dside_f', 'seat_pside_f', 
        'Gun_Nuzzle', 'seat_r'
    }
}

--- Default actions configuration
-- @field vehicles boolean: Enables or disables default vehicle actions
-- @field players boolean: Enables or disables default player actions
-- @field peds boolean: Enables or disables default ped actions
-- @field zones boolean: Enables or disables default zone actions
config.default_actions = {
    vehicles = true,
    players = true,
    peds = true,
    zones = true
}
