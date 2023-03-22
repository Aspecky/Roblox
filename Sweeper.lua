export type Sweeper = {
	Add: (Sweeper, object: Instance | RBXScriptConnection | (any) -> any) -> number,
	Sweep: (Sweeper) -> nil,
}

local Sweeper = {}

local function newindex(self, k, v)
	local proxy = self.proxy
	local object = proxy[k]
	if object then
		local type = typeof(object)
		if type == "Instance" then
			object:Destroy()
		elseif type == "RBXScriptConnection" then
			object:Disconnect()
		end
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
	for k, object in pairs(self.proxy) do
		local type = typeof(object)
		if type == "Instance" then
			object:Destroy()
		elseif type == "RBXScriptConnection" then
			object:Disconnect()
		end
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
