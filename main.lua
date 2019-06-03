init("0", 0);

local _C = require("gurudin.common");

-- 控制台 递归打印table的内容
_C.dd({name = 'Gurudin', age = 20});

-- 判定坐标是否在区域之内
local res = _C.inRect(0, 0, 100, 100, 90, 90);
print(res);

-- 字符串分隔

