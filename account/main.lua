local skynet = require "skynet"
local snax = require "snax"
local config = {
}
local user = {
}
local common = {
	{ name = "d_account2", key = "user", indexkey = "id" },
}
skynet.start(function()
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")
	
	local dbmgr = skynet.uniqueservice("dbmgr")
	skynet.call(dbmgr, "lua", "start", config, user, common)
 
    snax.uniqueservice("zhangHaodc")

	skynet.uniqueservice("account")		-- 启动登录服务器
end)

