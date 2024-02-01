--- This section simply exports the target table for use in other resources.
-- @script client/export.lua

--- Exports a function to get a deep copy of the target object.
-- This exported function allows other scripts to safely access and manipulate their own copy of the target object without affecting the original global state.
-- @function get_object
-- @usage local target = exports['boii_target']:get_target()
-- @return table: A deep copy of the utils object, ensuring isolated state and no side effects on the original target object.
exports('get_target', function() 
    return utils.tables.deep_copy(target) 
end)