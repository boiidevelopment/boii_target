----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

target = target or {}

config = config or {}

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

-- Testing stuff -- can be removed if removing `client/test.lua` or just leave false and ignore.. will be removed once script is no longer a W.I.P
config.testing = true
testing_peds = {}
testing_ents = {}

-- Debug toggle
config.debug = false -- Toggle debugging stuff

-- Raycast settings
config.raycast_distance = 10.0

-- Target settings
config.target = {
    default_icon = 'fa-regular fa-circle'
}

-- Default bones
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

-- Default actions
config.default_actions = {
    vehicles = true, -- Toggle if default vehicle actions should be used or not. Defaults: Toggle doors, flip vehicle, push vehicle.
    players = false, -- Toggle if default player actions should be used or not. . Defaults: none currently
    peds = false, -- Toggle if default ped actions should be used or not. . Defaults: none currently
    zones = false -- Toggle if default zone actions should be used. Defaults: none currently
}
