local _C = {
    json = require("gurudin.lib.JSON"),
};

--[[
    @function 控制台 递归打印table的内容

    @param tbl 需要打印的table（必须）
    @param level 递归的层数（选填）（默认空）
    @param filteDefault 是否过滤打印构造函数（选填）（默认是）
    
    @return 控制台打印出table
]]--
function _C.dd(tbl, level, filteDefault)
    local msg = ""
    filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
    level = level or 1
    local indent_str = ""
    for i = 1, level do
      indent_str = indent_str.."  "
    end
  
    print(indent_str .. "{")
    for k,v in pairs(tbl) do
      if filteDefault then
        if k ~= "_class_type" and k ~= "DeleteMe" then
          local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
          print(item_str)
          if type(v) == "table" then
            PrintTable(v, level + 1)
          end
        end
      else
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          PrintTable(v, level + 1)
        end
      end
    end
    print(indent_str .. "}")
end

--[[
    @function 字符串分隔

    @param separator 分隔符（必须）
    @param string 要分割的字符串（必须）

    @return table
]]--
function _C.explode(separator, string)
    
end

--[[
    @function 判断坐标是否在坐标域内

    @param topx 左上x坐标
    @param topy 左上y坐标
    @param bottomx 右下x坐标
    @param bottomy 右下y坐标
    @param x 需要判定的x坐标
    @param y 需要判定的y坐标

    @return int 0=否 1=是
]]--
function _C.inRect(topx, topy, bottomx, bottomy, x, y)
    local isIn = 0;
    if topx < x and bottomx > x and topy < y and bottomy > y then
        isIn = 1;
    end

    return isIn;
end

return _C;
