local _J = {
    json = require("gurudin.lib.JSON"),
};

--[[
    @function table转换json
    
    @param table 需要转换的table

    @return json
]]--
function _J.encode(table)
    return _J.json:encode(table);
end

--[[
    @function json转换table

    @param json 需要转换的json

    @return table
]]--
function _J.decode(json)
    return _J.json:decode(json);
end

--[[
    @function table 格式化json
    
    @param table 需要转换的table

    @return json
]]--
function _J.encodePretty(table)
    return _J.json:encode_pretty(table);
end

return _J;
