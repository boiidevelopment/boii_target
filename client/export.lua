----------------------------------
--<!>-- BOII | DEVELOPMENT --<!>--
----------------------------------

-- Export to get all utils
-- local target = exports['boii_target']:get_target()
exports('get_target', function() 
    return utils.tables.deep_copy(target) 
end)