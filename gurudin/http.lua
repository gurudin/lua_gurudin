local _H = {
    http = require("gurudin.lib.socket.http"),
    ltn12 = require("gurudin.lib.socket.ltn12"),
    common = require("gurudin.common")
};

--[[
    @function http get请求

    @param url 请求url
    @param params 参数

    @return code, body 返回码 返回体
]]--
function _H.get(url, params)
    if type(params) == 'table' then
        url = url..'?'.._H.common.tableToParams(params);
    end
    local res, code = _H.http.request(url);

    return code, res;
end

--[[
    @function http post请求

    @param url 请求url
    @param params 参数table
    @param headers headers table

    @return code, type, body 返回码 返回类型 返回体
]]--
function _H.post(url, params, headers)
    local request_body    = _H.common.tableToParams(params);
    local response_body   = {}
    local request_headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded";
        ["Content-Length"] = #request_body;
    };
    if type(headers) == 'table' then
        for k, v in pairs(headers) do
            request_headers[k] = v;
        end
    end

    local res, code, response_headers = _H.http.request{
        url = url,
        method = "POST",
        headers = request_headers,
        source = _H.ltn12.source.string(request_body),
        sink = _H.ltn12.sink.table(response_body),
    }

    if type(response_body) == "table" then
        return code, type(response_body), table.concat(response_body);
    else
        return code, type(response_body), response_body;
    end
end

return _H;
