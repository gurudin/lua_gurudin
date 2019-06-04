# 叉叉助手公共库

#### 借鉴代码
- https://github.com/asasadasss/baidu-ocr-on-xxzhushou
- https://github.com/boyliang/lua_badboy

#### 示例
- main.lua

### 使用方法
- 下载代码
- 放入src目录下即可使用

#### 包含方法

##### 文件: gurudin/common.lua
```
local _C = require("gurudin.common");

-- 控制台调试输出 支持（table、number、string、boolean、nil）
_C.dd({name = 'Gurudin', gender = 'male', addr = {city = 'BJ', area = 'HD'}});
_C.dd(nil);

-- 字符串分隔成table
_C.dd(
    _C.explode('@', '金@木@水@火')
); -- Output: {0 = 金, 1 = 木, 2 = 水, 3 = 火}

-- table转换字符串
_C.dd(
    _C.implode(',', {"one", "two", "three"})
); -- Output: one,two,three

-- 判定坐标是否在区域之内
local result = _C.inRect(0, 0, 100, 100, 90, 90);
print(result); -- Output: 1

-- table转换url参数
local result = _C.tableToParams({name = 'Gurudin', gender = 'male'});
print(result); -- Ourput: name=Gurudin&gender=male

-- url参数转换table
local result = _C.paramsToTable('name=Gurudin&gender=male');
_C.dd(result);
--[[
    Output:
    {
        gender = male,
        name = Gurudin
    }
]]--

-- 获取随机数
local random = _C.random(0, 10);
print(random);

-- 计算两点之间的距离
local dist = _C.twoPointsDist({x = 0, y = 0}, {x = 0, y = 10});
print(dist); -- Output: 10

-- Url encode
_C.dd(
    _C.urlEncode('https://www.baidu.com') -- Output: https%3A%2F%2Fwww.baidu.com
);

-- Url decode
_C.dd(
    _C.urlDecode('https%3A%2F%2Fwww.baidu.com') -- Output: https://www.baidu.com
);

-- table是否包含
_C.dd(
    _C.inTable('Gurudin', {'Tony', 'Gurudin', 'Jack'}) -- Output: true
);

-- 获取table的所有key
_C.dd(
    _C.keys({name = 'Gurudin', age = 20}) -- Output: [ name, age ]
);

-- 获取table所有的value
_C.dd(
    _C.values({name = 'Gurudin', age = 20}) -- Output: [ Gurudin, 20 ]
);

-- 去掉首尾空格
_C.dd(
    _C.trim(' Gurudin ') -- Output: Gurudin
);

-- base64 encode
print(
    _C.base64Encode('Gurudin') -- Output: R3VydWRpbg==
);

-- base64 decode
print(
    _C.base64Decode('R3VydWRpbg==') -- Output: Gurudin
);

-- io方式读取文件
-- 可配合截图与百度识图使用 例子：请查看”百度OCR方法“
-- Output: byte文件
_C.dd(
    _C.ioRead(filename)
);
```


##### 文件: gurudin/json.lua
```
-- table转换json
print(
    _J.encode({name = 'Gurudin', gender = 'male'})
); -- Output: {"gender":"male","name":"Gurudin"}

-- json转换table
local result = _J.decode('{"gender":"male", "name":"Gurudin"}');
print(result.name); -- Output: "Gurudin"
print(result.gender); -- Output: "male"

-- table转换json并格式化json
local result = _J.encodePretty({name = 'Gurudin', gender = 'male'});
print(result);
--[[
    Output:
    {
        "gender": "male",
        "name": "Gurudin"
    }
]]--
```

##### 文件: gurudin/http.lua
```
local _H = require("gurudin.http");

-- http get请求
local code, body = _H.get('https://aip.baidubce.com/oauth/2.0/token');
print(code);
_C.dd(body);

-- http post请求
local code, type, body = _H.post('https://aip.baidubce.com/oauth/2.0/token');
print(code);
print(type);
_C.dd(body);
```


##### 文件: gurudin/OCRbaidu.lua
```
--[[
    百度OCR 使用方法

    AK、SK 获取位置: 管理控制台 -> 右上角头像 -> 安全认证

    Ocr:new('AK','SK'); -- 初始化配置 或 在OCRbaidu.lua 文件中配置可以不调用new()方法
    Ocr.call('api接口名称', 'api接口参数');
    参照百度api方式填写
]]--
local Ocr = require("gurudin.OCRbaidu");
Ocr:new({AK = '您的Access Key', SK = '您的Secret Key'});
local code, type, body = Ocr.call('general_basic', {
    url = 'https://www.baidu.com/img/bd_logo1.png'
});
_C.dd(body);

--[[
    例：截图并调用百度ocr”通用文字识别“api
    接口文档 https://cloud.baidu.com/doc/OCR/OCR-API.html#.E9.80.9A.E7.94.A8.E6.96.87.E5.AD.97.E8.AF.86.E5.88.AB
]]

-- Step 1 (调用叉叉助手截图方法)
local filename = '[public]temp.png';
snapshot(filename, 0, 800, 1080, 1500);

-- Step 2 (io方式打开文件 -> base64编码 -> urlEncode)
local imgByte   = _C.ioRead(filename);
local imgBase64 = _C.base64Encode(imgByte);
local imgEncode = _C.urlEncode(imgBase64);

if imgEncode == nil or #imgEncode <= 0 then
    print('读取截图失败');

    return false;
end

-- Step 3 调用百度ocr”通用文字识别“api
Ocr:new({AK = '您的Access Key', SK = '您的Secret Key'});
local code, type, body = Ocr.call('general_basic', {
    image = imgEncode
});
_C.dd(body);
-- Output:
--[[
    {"log_id": 3670285097603161572, "words_result_num": 2, "words_result": [{"words": "码"}, {"words": "用短信验证码登录"}]}
]]
```