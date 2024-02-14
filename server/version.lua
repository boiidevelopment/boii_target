--- Main script for the targeting system.
-- @script client/main.lua

--- @section Dependencies

--- Import utility library
utils = exports['boii_utils']:get_utils()

local opts = {
    resource_name = GetCurrentResourceName(),
    url_path = 'boiidevelopment/fivem_resource_versions/main/versions.json',
}
utils.version.check(opts)