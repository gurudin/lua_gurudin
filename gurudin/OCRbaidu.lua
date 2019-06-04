local OCR = {
    http = require("gurudin.http"),
    json = require("gurudin.json"),
    common = require("gurudin.common"),
    sha256 = require("gurudin.lib.HMAC-SHA256"),
    config = {
        AK = '', -- 获取的 Access Key
        SK = '', -- 获取的 Secret Key
    },
};

local BCE_AUTH_VERSION = "bce-auth-v1";
local BCE_PREFIX       = 'x-bce-';
local defaultHeadersToSign = {
    "host"
};

local __URL = {
    --[[
        请求access_token接口地址
        @uri http://ai.baidu.com/docs#/Auth/top
    ]]
    ['access_token'] = 'http://aip.baidubce.com/oauth/2.0/token';
    --[[
        接口请求地址
    ]]
    ['host'] = 'aip.baidubce.com';
    --[[
        通用文字识别
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.E9.80.9A.E7.94.A8.E6.96.87.E5.AD.97.E8.AF.86.E5.88.AB
    ]]
    ['general_basic'] = '/rest/2.0/ocr/v1/general_basic';
    --[[
        通用文字识别（高精度版）
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.EC.DF.48.27.9B.69.A4.2C.54.1B.DC.95.67.DB.1D.3C
    ]]
    ['accurate_basic'] = '/rest/2.0/ocr/v1/accurate_basic';
    --[[
        通用文字识别（含位置信息版）
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.AD.45.25.42.6F.4C.89.80.FE.B7.28.00.A2.07.E8.17
    ]]
    ['general'] = '/rest/2.0/ocr/v1/general';
    --[[
        通用文字识别（含位置高精度版）
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.F0.87.30.C9.B7.77.0D.5B.56.11.74.66.5C.71.F8.AA
    ]]
    ['accurate'] = '/rest/2.0/ocr/v1/accurate';
    --[[
        通用文字识别（含生僻字版）
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.CC.97.73.06.FD.A1.D8.DE.4F.1F.5E.CF.E4.1A.E6.B9
    ]]
    ['general_enhanced'] = '/rest/2.0/ocr/v1/general_enhanced';
    --[[
        手写文字识别
        @uri https://cloud.baidu.com/doc/OCR/OCR-API.html#.E8.AF.B7.E6.B1.82.E8.AF.B4.E6.98.8E
    ]]
    ['handwriting'] = '/rest/2.0/ocr/v1/handwriting';
};

--[[
    @function 初始化类

    @param config 配置 {client_id = 'client_id', client_secret = 'client_secret'}
]]--
function OCR:new(conf)
    self.config.AK = conf.AK;
    self.config.SK = conf.SK;
end

local function urlEncodeExceptSlash(s)
    return (string.gsub(OCR.common.urlEncode(s), '%%2F', "/"))
end

-- 生成标准化QueryString
local function getCanonicalQueryString(parameters)
    -- 没有参数，直接返回空串
    if not parameters then
        return ''
    end

    local parameterStrings = {}
    for k, v in pairs(parameters) do
        -- 跳过Authorization字段
    	if string.find(k, 'Authorization') == nil then
        	if v then
                -- 对于有值的，编码后放在=号两边
                table.insert(parameterStrings, OCR.common.urlEncode(k) .. '=' .. OCR.common.urlEncode(v))
            else
                -- 对于没有值的，只将key编码后放在=号的左边，右边留空
                table.insert(parameterStrings, OCR.common.urlEncode(k) .. '=')
            end
        end
    end

    -- 按照字典序排序
    table.sort(parameterStrings)

    -- 使用'&'符号连接它们
    return table.concat(parameterStrings, '&')
end

local function isDefaultHeaderToSign(header)
    header = string.lower(OCR.common.trim(header))

    if OCR.common.inTable(header, defaultHeadersToSign) then
        return true
    end

    local prefix = string.sub(header, 1, string.len(BCE_PREFIX))
    if prefix == BCE_PREFIX then
        return true
    else
        return false
    end
end

local function getHeadersToSign(headers)
    ret = {}

    for k, v in pairs(headers) do
        if string.len(OCR.common.trim(v)) > 0 then
            if isDefaultHeaderToSign(k) then
                ret[k] = v
            end
        end
    end
    return ret
end

-- 生成标准化http请求头串
local function getCanonicalHeaders(headers)
    if not headers then
        return ''
    end

    local headerStrings = {}
    for k, v in pairs(headers) do
        if k ~= nil then
	        if v == nil then
	            v = ''
	        end
	        
	        table.insert(
                headerStrings,
                OCR.common.urlEncode(string.lower(OCR.common.trim(k))) .. ':' .. OCR.common.urlEncode(OCR.common.trim(v))
            );
        end
    end

    table.sort(headerStrings)

    return table.concat(headerStrings, "\n")
end

-- 获取Authorization签名
function OCR:getSign(interface, array, headers)
    local expires_in           = 1800; -- 有效时间（秒）
    local timestamp            = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 当前时间
    local authString           = BCE_AUTH_VERSION .. '/' .. OCR.config.AK .. '/' .. timestamp .. '/' .. expires_in;
    local signingKey           = HMAC_SHA256_MAC(OCR.config.SK, authString);
    local canonicalURI         = urlEncodeExceptSlash(__URL[interface]);
    local canonicalQueryString = '';
    local headersToSign        = getHeadersToSign(headers)
    local canonicalHeader      = getCanonicalHeaders(headersToSign)

    headersToSign = OCR.common.keys(headersToSign)
    table.sort(headersToSign)

    -- 整理headersToSign，以';'号连接
    local signedHeaders = string.lower((table.concat(headersToSign, ';')))

    -- 组成标准请求串
    local canonicalRequest = "POST" .. "\n" .. canonicalURI .. "\n" .. canonicalQueryString .. "\n" .. canonicalHeader
    local signature = HMAC_SHA256_MAC(signingKey, canonicalRequest)
    local authorizationHeader = authString .. '/' .. signedHeaders .. '/' .. signature

    return authorizationHeader;
end


--[[
    请求百度ocr接口

    @param interface 接口名称
    @param table 请求参数

    @return code, type, body 返回码, 返回类型, 百度ocr返回数据
]]
function OCR.call(interface, table)
    if type(table) ~= 'table' then
        return -1, nil, nil;
    end

    if __URL[interface] == nil then
        return -2, nil, nil;
    end
    
    local post_data = OCR.common.tableToParams(table);
    local headers = {
        ['host']           = __URL['host'],
        ['Content-Type']   = 'application/x-www-form-urlencoded',
        ['Content-Length'] = #post_data,
    };
    
    headers['Authorization'] = OCR:getSign(interface, table, headers);

    return OCR.http.post(
        'http://' .. __URL['host'] .. __URL[interface],
        table,
        headers
    );
end

return OCR;
