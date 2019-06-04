local _C = {};

--[[
    @function 控制台调试输出 支持（table、number、string、boolean、nil）

    @param tbl 需要打印的table（必须）
    @param level 递归的层数（选填）（默认空）
    @param filteDefault 是否过滤打印构造函数（选填）（默认是）
    
    @return 控制台打印出table
]]--
function _C.dd(vars)
    if type(vars) == 'table' then
        local json = require("gurudin.json");
        local str = json.encodePretty(vars);
        
        print('\n'..string.gsub(string.gsub(str, ':', ' ='), '"', ''));
    else
        print(tostring(vars));
    end
end

--[[
    @function 字符串分隔成table

    @param separator 分隔符（必须）
    @param string 要分割的字符串（必须）

    @return table
]]--
function _C.explode(separator, string)
    local table = {};
    local count = 0;

    while(string.len(string) > 0) do
        local place = string.find(string, separator);

        if type(place) == 'number' then
            local tmpStr = string.sub(string, 1, place - 1);
            string = string.sub(string, place + 1);
            table[count] = tmpStr;
        else
            table[count] = string;
            string = '';
        end

        count = count + 1;
    end

    return table;
end

--[[
    @function table转换字符串

    @param separator 规定数组元素之间放置的内容
    @param table 要组合为字符串的数组（必须）

    @return string
]]--
function _C.implode(separator, table)
    local str = '';

    for i, v in pairs(table) do
        str = str .. separator .. v;
    end

    return string.sub(str, 2);
end

--[[
    @function 判断坐标是否在坐标域内

    @param topx 左上x坐标
    @param topy 左上y坐标
    @param bottomx 右下x坐标
    @param bottomy 右下y坐标
    @param x 需要判定的x坐标
    @param y 需要判定的y坐标

    @return number 0=否 1=是
]]--
function _C.inRect(topx, topy, bottomx, bottomy, x, y)
    local isIn = 0;
    if topx < x and bottomx > x and topy < y and bottomy > y then
        isIn = 1;
    end

    return isIn;
end

--[[
    @function table转换url参数

    @param table

    @return string
]]--
function _C.tableToParams(table)
    if type(table) ~= 'table' then
        return '';
    end

    local args = '';
    for k, v in pairs(table) do
        args = args..tostring(k)..'='..tostring(v)..'&';
    end

    return string.sub(args, 1, string.len(args) - 1);
end

--[[
    @function url参数转换table

    @param params url参数字符串

    @return table
]]--
function _C.paramsToTable(params)
    local table = {};

    for i, args in pairs(_C.explode("&", params)) do
        table[
            string.sub(args, 1, string.find(args, '=') - 1)
        ] = string.sub(
            args, string.find(args, '=') + 1, string.len(args)
        );
    end

    return table;
end

--[[
    @function 获取随机数

    @param min 最小值
    @param max 最大值

    @return number
]]--
function _C.random(min, max)
    math.randomseed(os.time());

    return math.random(min, max);
end

--[[
    @function 计算两点之间的距离
    
    @param point1 点1 {x = 0, y = 0}
    @param pintt2 点2 {x = 10, y = 10}

    @return number
]]--
function _C.twoPointsDist(point1, point2)
    local x = math.abs((point1.x - point2.x) * (point1.x - point2.x));
    local y = math.abs((point1.y - point2.y) * (point1.y - point2.y));
    local dist = math.sqrt(x + y);

    return tonumber(string.format("%.2f", dist));
end

--[[
    @function Url encode

    @param url

    @return string
]]--
function _C.urlEncode(s)
    local except = {'-', '.', '_', '~'}
    s = string.gsub(s, "([^%w%.%- ])", function(c)
        if _C.inTable(c, except) then
            return c;
        end

        return string.format("%%%02X", string.byte(c))
    end)

    return (string.gsub(s, " ", "+"));
end

--[[
    @function Url decode

    @param url

    @return string
]]--
function _C.urlDecode(s)
    s = string.gsub(
        s,
        '%%(%x%x)',
        function(h)
            return string.char(tonumber(h, 16))
        end
    );

   return s;
end

--[[
    @function table是否包含

    @param value 查询值
    @param tbl 查询talbe

    @return bool
]]--
function _C.inTable(value, tbl)
    for k,v in pairs(tbl) do
		if v == value then
			return true
		end
    end
    
	return false
end

--[[
    @function 获取table的所有key

    @param tbl 来源table

    @return table
]]--
function _C.keys(tbl)
    local keys = {}

    for k, _ in pairs(tbl) do
        keys[#keys + 1] = k;
    end

    return keys
end

--[[
    @function 获取table的所有value

    @param tbl 来源table

    @return table
]]--
function _C.values(tbl)
    local values = {}

    for _, v in pairs(tbl) do
        values[#values + 1] = v;
    end

    return values
end

--[[
    @function 去掉首尾空格

    @param s 来源字符串

    @return string
]]--
function _C.trim(s)
	return (tostring(s):gsub("^%s*(.-)%s*", "%1"));
end

--[[
    @function base64 encode

    @param s 需要encode字符串

    @return string
]]
function _C.base64Encode(s)
    local base64 = require("gurudin.lib.BASE64");

    return base64.encode(s);
end

--[[
    @function base64 decode

    @param s 需要decode字符串

    @return string
]]
function _C.base64Decode(s)
    local base64 = require("gurudin.lib.BASE64");

    return base64.decode(s);
end

--[[
    @function io方式读取文件
    
    @param filename 文件名称

    @return file
]]
function _C.ioRead(filename)
    local file = io.open(filename, 'r');
	local retbyte = file:read("*a");
    file:close();
    
	return retbyte;
end

return _C;
