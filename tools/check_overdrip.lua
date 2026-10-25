-- Check that the overdrip API used across the config exists in lib/overdrip.
--
-- Runs with plain Lua outside of the compositor:
--   luajit tools/check_overdrip.lua
-- Set SOMEWM_LUA to point at somewm's lua directory if it is not installed
-- in /usr/local/share/somewm/lua.

local somewm_lua = os.getenv("SOMEWM_LUA") or "/usr/local/share/somewm/lua"
package.path = table.concat({
	"./?.lua",
	"./?/init.lua",
	somewm_lua .. "/?.lua",
	somewm_lua .. "/?/init.lua",
	package.path,
}, ";")

-- Same stubs as tests/test_overdrip_re.lua
package.preload["gears"] = function()
	return {
		object = require("gears.object"),
		table = require("gears.table"),
	}
end
package.preload["wibox"] = function()
	return { container = { place = function() return {} end } }
end
_G.awesome = { connect_signal = function() end }
local original_require = require
_G.require = setmetatable({
	rel = function(name)
		return original_require("lib.overdrip." .. name)
	end,
}, {
	__call = function(_, ...)
		return original_require(...)
	end,
})

local overdrip = require("lib.overdrip")
local Provider = overdrip.provider
local Ref = require.rel("ref")

-- Files that use overdrip, skipping the module itself, tests and old code
local files = {}
local find = io.popen(
	"grep -rl --include='*.lua' 'lib.overdrip' . "
		.. "| grep -vE '^\\./(attic|references|types|tests|tools)/|^\\./lib/overdrip'"
)
for path in find:lines() do
	table.insert(files, path)
end
find:close()

local problems = 0
local function report(path, lnum, msg)
	problems = problems + 1
	print(string.format("%s:%d: %s", path, lnum, msg))
end

for _, path in ipairs(files) do
	local lnum = 0
	for line in io.lines(path) do
		lnum = lnum + 1
		-- module functions: overdrip.foo
		for name in line:gmatch("overdrip%.([%w_]+)") do
			if overdrip[name] == nil then
				report(path, lnum, "overdrip." .. name .. " does not exist")
			end
		end
		-- provider methods: foo_provider:bar(
		for name in line:gmatch("_provider%s*:%s*([%w_]+)%s*%(") do
			if type(Provider[name]) ~= "function" then
				report(path, lnum, "Provider:" .. name .. "() does not exist")
			end
		end
		-- ref methods: ref.watch( must be ref:watch(
		for sep, name in line:gmatch("%f[%w_]ref%s*([.:])%s*([%w_]+)%s*%(") do
			if type(Ref[name]) ~= "function" then
				report(path, lnum, "Ref:" .. name .. "() does not exist")
			elseif sep == "." then
				report(path, lnum, "ref." .. name .. "() should be ref:" .. name .. "()")
			end
		end
		-- direct state writes do not notify dependents, use :set()
		if line:match("_provider%.state%s*=[^=]") then
			report(path, lnum, "provider.state is assigned directly, use provider:set()")
		end
	end
end

print(string.format("\n%d problem(s) in %d file(s) checked", problems, #files))
os.exit(problems == 0 and 0 or 1)
