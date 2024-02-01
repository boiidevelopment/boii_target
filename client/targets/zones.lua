--- This script handles any default target settings pre defined within the target system.
-- @script client/targets/zones.lua

if config.default_actions.zones then
    targets.zones.circle = {}
    targets.zones.box = {}
    targets.zones.sphere = {}
    targets.zones.entity = {}
    targets.zones.models = {}
end