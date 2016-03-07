local account = require "snax.account_server"
local skynet = require "skynet"
local snax = require "snax"

local server = {
	host = "0.0.0.0",
	port = tonumber(skynet.getenv("port")),
	name = "account",
}
local account_dc
local function register(name,password)

	local uid = account_dc.req.get_nextid()
    if uid == "nil" then 
        logError(0,"register account get nextid failed")
        return nil
    end 
	if uid < 1 then
		logError(0,"register account get nextid failed")
		return nil
	end
	local row = { id = uid, user = name, passwd = password}
	local ret = account_dc.req.add(row)

	if not ret then
		logError(0,"register account failed")
		return nil
	end
	return uid
end

local function auth(name)
	if not account_dc then
		account_dc = snax.uniqueservice("zhangHaodc")
	end
	local account = account_dc.req.get(name)
	return account
end
local function createRedisKey(token)
    local result =  account_dc.req.CreateKey(token)
    if result == "nil" then 
       return false
    else
       return true 
    end 
end 
function server.token_auth(token)
    if not account_dc then
        account_dc = snax.uniqueservice("zhangHaodc")
    end
    local result =   account_dc.req.GetToken(token)
    if result == "nil" then 
        return "nil"
    else 
        return result
    end 
end 
function server.account_auth(name,password,isLogin)
    local account = auth(name)
    local id 
    local err 
    if isLogin then 
    	---登录
    	if not table.empty(account) then 
    		if account.passwd == password then 
	    		id = account.id
	    		err = 1 --登录正常
	    	else 
                id = 0
	    		err = 2 --密码错误
	    	end 
    	else 
            logInfo(0,"%s 不存在",name)
            id = register(name,password)
            if id == nil then 
                logInfo(0,"注册不成功")
                id  = 0
                err = 3 --登录错误
            else 
                logInfo(0,"注册成功")
                err = 1 --登录正常
            end 
    	end 
    end 
    if err == 1 then 
        if not createRedisKey(id) then 
            err = 3 -- --登录错误
        end 
    end 
    if id == nil then 
        id = 0
    end 
    return id,err
end 


account(server)	-- 启动账号服务器
