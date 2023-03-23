export type Sweeper = {
	Add: (Sweeper, object: Instance | RBXScriptConnection | (any) -> any) -> number,
	Sweep: (Sweeper) -> nil,
}

local conn = game.Destroying:Connect(function() end)
conn:Disconnect()

local Disconnect = conn.Disconnect
local Destroy = game.Destroy

local Sweeper = {}

local function cleanObject(object)
	local type = typeof(object)
	if type == "RBXScriptConnection" then
		Disconnect(object)
	elseif type == "Instance" then
		Destroy(object)
	end
end

local function newindex(self, k, v)
	local proxy = self.proxy
	local object = proxy[k]
	if object then
		cleanObject(object)
	end
	proxy[k] = v
end

local function index(self, k)
	return self.proxy[k]
end

local function Add(self, object)
	table.insert(self.proxy, object)
	return #self.proxy
end

local function Sweep(self)
	local proxy = self.proxy
	for k, object in pairs(proxy) do
		cleanObject(object)
		proxy[k] = nil
	end
end

local mt = {
	__newindex = newindex,
	__index = index,
}

function Sweeper.new(): Sweeper
	return setmetatable({
		proxy = {},
		Add = Add,
		Sweep = Sweep,
	}, mt)
end

return Sweeper
