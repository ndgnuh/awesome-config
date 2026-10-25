-- Behaviour tests for lib/overdrip2/overdrip_re.lua
--
-- Runs with plain Lua outside of the compositor:
--   luajit tests/test_overdrip_re.lua
-- Set SOMEWM_LUA to point at somewm's lua directory if it is not installed
-- in /usr/local/share/somewm/lua.
--
-- The API mirrors lib/overdrip.lua (see tests/test_overdrip.lua):
--   Provider.new(value_or_builder) -> provider
--   provider:flush()                -- current value, building it if needed
--   provider:set(value)             -- set the value
--   ref:watch(p), ref:read(p), ref:invalidate(p), ref:invalidate_self()
-- Unlike overdrip, rebuilds are batched and run on the awesome "refresh"
-- signal, and there are no subscriber callbacks: a dependent provider is
-- used to observe changes instead.

local somewm_lua = os.getenv("SOMEWM_LUA") or "/usr/local/share/somewm/lua"
package.path = table.concat({
	"./?.lua",
	"./?/init.lua",
	somewm_lua .. "/?.lua",
	somewm_lua .. "/?/init.lua",
	package.path,
}, ";")

-- The full `gears` module pulls in lgi/cairo, so only expose the pure Lua
-- parts overdrip needs.
package.preload["gears"] = function()
	return {
		object = require("gears.object"),
		table = require("gears.table"),
	}
end

-- Fake the `awesome` global, only signals are needed.
local signals = {}
_G.awesome = {
	connect_signal = function(name, fn)
		signals[name] = signals[name] or {}
		table.insert(signals[name], fn)
	end,
	disconnect_signal = function(name, fn)
		for i, f in ipairs(signals[name] or {}) do
			if f == fn then
				table.remove(signals[name], i)
				return
			end
		end
	end,
	emit_signal = function(name, ...)
		for _, fn in ipairs(signals[name] or {}) do
			fn(...)
		end
	end,
}

-- Simulate one iteration of the event loop.
local function refresh()
	awesome.emit_signal("refresh")
end

-- `require.rel` comes from monkey_patch/require.lua, which needs the
-- compositor's configuration dir. Resolve siblings of overdrip_re directly.
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

local Provider = require("lib.overdrip").Provider

-- Minimal test harness ------------------------------------------------------

local tests = {}
local function test(name, fn)
	tests[#tests + 1] = { name = name, fn = fn }
end

local function eq(actual, expected, msg)
	if actual ~= expected then
		error(string.format("%s: expected %s, got %s", msg or "assert_eq", tostring(expected), tostring(actual)), 2)
	end
end

-- A provider watching `target`, counting the rebuilds after the first one.
local function spy(target)
	local s = { n = -1, last = nil }
	s.provider = Provider.new(function(ref)
		s.n = s.n + 1
		s.last = ref:watch(target)
		return s.last
	end)
	s.provider:flush()
	return s
end

-- Plain providers -----------------------------------------------------------

test("module returns the Provider class", function()
	eq(type(Provider), "table", "module type")
	eq(type(Provider.new), "function", "Provider.new")
end)

test("constant provider returns its value", function()
	eq(Provider.new(42):flush(), 42)
	eq(Provider.new("x"):flush(), "x")
end)

test("falsy constants are preserved", function()
	eq(Provider.new(false):flush(), false)
	eq(Provider.new(nil):flush(), nil)
end)

test("function builder is lazy and cached", function()
	local calls = 0
	local p = Provider.new(function()
		calls = calls + 1
		return "built"
	end)
	eq(calls, 0, "builder called before flush")
	eq(p:flush(), "built")
	eq(p:flush(), "built")
	refresh()
	eq(p:flush(), "built")
	eq(calls, 1, "builder calls")
end)

test("providers do not share state", function()
	local a = Provider.new(1)
	local b = Provider.new(2)
	a:flush()
	b:flush()
	a:set(10)
	refresh()
	eq(a:flush(), 10)
	eq(b:flush(), 2)
end)

test("providers do not share dependents or dependencies", function()
	local a = Provider.new(1)
	local b = Provider.new(2)
	local d = Provider.new(function(ref)
		return ref:watch(a)
	end)
	d:flush()
	assert(a.dependents ~= b.dependents, "dependents table is shared")
	assert(a.dependencies ~= d.dependencies, "dependencies table is shared")
end)

test("set updates dependents on refresh", function()
	local p = Provider.new(1)
	local s = spy(p)
	eq(s.last, 1)
	p:set(2)
	eq(s.n, 0, "rebuilt before refresh")
	refresh()
	eq(p:flush(), 2)
	eq(s.n, 1, "rebuilds")
	eq(s.last, 2, "seen value")
end)

test("setting the same value does not rebuild dependents", function()
	local p = Provider.new(1)
	local s = spy(p)
	p:set(1)
	refresh()
	eq(s.n, 0, "rebuilds")
end)

test("watching twice from the same builder rebuilds once", function()
	local p = Provider.new(1)
	local calls = 0
	local d = Provider.new(function(ref)
		calls = calls + 1
		return ref:watch(p) + ref:watch(p)
	end)
	eq(d:flush(), 2)
	p:set(2)
	refresh()
	eq(d:flush(), 4)
	eq(calls, 2, "builder calls")
end)

test("several sets in one iteration rebuild once with the last value", function()
	local p = Provider.new(1)
	local s = spy(p)
	p:set(2)
	p:set(3)
	p:set(4)
	refresh()
	eq(s.n, 1, "rebuilds")
	eq(s.last, 4, "seen value")
end)

test("refresh with nothing scheduled is a no-op", function()
	local calls = 0
	local p = Provider.new(function()
		calls = calls + 1
		return calls
	end)
	local s = spy(p)
	refresh()
	refresh()
	eq(calls, 1, "builder calls")
	eq(s.n, 0, "rebuilds")
end)

-- Derived providers ---------------------------------------------------------

test("derived provider recomputes when a watched provider changes", function()
	local base = Provider.new(2)
	local calls = 0
	local double = Provider.new(function(ref)
		calls = calls + 1
		return ref:watch(base) * 2
	end)
	local s = spy(double)
	eq(s.last, 4)

	base:set(5)
	refresh()
	eq(double:flush(), 10)
	eq(calls, 2, "builder calls")
	eq(s.n, 1, "dependent rebuilds")
	eq(s.last, 10)
end)

test("changes propagate through a chain in one refresh", function()
	local a = Provider.new(1)
	local b = Provider.new(function(ref)
		return ref:watch(a) + 1
	end)
	local c = Provider.new(function(ref)
		return ref:watch(b) * 10
	end)
	local s = spy(c)
	eq(s.last, 20)
	a:set(4)
	refresh()
	eq(s.n, 1, "rebuilds")
	eq(s.last, 50, "seen value")
	eq(b:flush(), 5)
	eq(c:flush(), 50)
end)

test("derived provider watching several providers", function()
	local x = Provider.new(1)
	local y = Provider.new(2)
	local sum = Provider.new(function(ref)
		return ref:watch(x) + ref:watch(y)
	end)
	eq(sum:flush(), 3)
	x:set(10)
	refresh()
	eq(sum:flush(), 12)
	y:set(20)
	refresh()
	eq(sum:flush(), 30)
end)

test("diamond dependency recomputes the bottom provider once", function()
	-- a <- b, (a, b) <- c
	local a = Provider.new(1)
	local b = Provider.new(function(ref)
		return ref:watch(a) + 1
	end)
	local calls = 0
	local c = Provider.new(function(ref)
		calls = calls + 1
		return ref:watch(a) + ref:watch(b)
	end)
	eq(c:flush(), 3)
	a:set(10)
	refresh()
	eq(c:flush(), 21)
	eq(calls, 2, "bottom builder calls")
end)

test("unchanged result does not rebuild dependents", function()
	local n = Provider.new(2)
	local is_even = Provider.new(function(ref)
		return ref:watch(n) % 2 == 0
	end)
	local s = spy(is_even)
	eq(s.last, true)
	n:set(4)
	refresh()
	eq(s.n, 0, "rebuilds")
	n:set(5)
	refresh()
	eq(s.n, 1, "rebuilds")
	eq(s.last, false)
end)

test("ref:read does not create a dependency", function()
	local base = Provider.new(1)
	local calls = 0
	local p = Provider.new(function(ref)
		calls = calls + 1
		return ref:read(base)
	end)
	eq(p:flush(), 1)
	base:set(2)
	refresh()
	eq(calls, 1, "builder calls")
	eq(p:flush(), 1, "stale value is kept")
end)

test("dependencies that are no longer watched stop triggering recompute", function()
	local use_a = Provider.new(true)
	local a = Provider.new("a")
	local b = Provider.new("b")
	local calls = 0
	local pick = Provider.new(function(ref)
		calls = calls + 1
		if ref:watch(use_a) then
			return ref:watch(a)
		end
		return ref:watch(b)
	end)
	eq(pick:flush(), "a")

	use_a:set(false)
	refresh()
	eq(pick:flush(), "b")
	local calls_before = calls

	a:set("a2")
	refresh()
	eq(calls, calls_before, "recomputed after unwatched dependency changed")
	eq(pick:flush(), "b")

	b:set("b2")
	refresh()
	eq(pick:flush(), "b2")
end)

test("watching itself is an error", function()
	local p
	p = Provider.new(function(ref)
		return ref:watch(p)
	end)
	local ok, err = pcall(p.flush, p)
	eq(ok, false, "pcall result")
	assert(tostring(err):find("Cannot watch itself"), "unexpected error: " .. tostring(err))
end)

test("ref:invalidate_self re-runs the builder on refresh", function()
	local calls = 0
	local saved_ref
	local p = Provider.new(function(ref)
		calls = calls + 1
		saved_ref = ref
		return calls
	end)
	eq(p:flush(), 1)
	saved_ref:invalidate_self()
	eq(calls, 1, "rebuilt before refresh")
	refresh()
	eq(p:flush(), 2)
end)

test("ref:invalidate re-runs another provider's builder on refresh", function()
	local calls = 0
	local other = Provider.new(function()
		calls = calls + 1
		return calls
	end)
	local saved_ref
	local p = Provider.new(function(ref)
		saved_ref = ref
		return true
	end)
	eq(other:flush(), 1)
	p:flush()
	saved_ref:invalidate(other)
	refresh()
	eq(other:flush(), 2)
end)

-- Runner --------------------------------------------------------------------

local failed = 0
for _, t in ipairs(tests) do
	local ok, err = xpcall(t.fn, debug.traceback)
	if ok then
		print("ok   " .. t.name)
	else
		failed = failed + 1
		print("FAIL " .. t.name .. "\n     " .. tostring(err):gsub("\n", "\n     "))
	end
end

print(string.format("\n%d passed, %d failed", #tests - failed, failed))
os.exit(failed == 0 and 0 or 1)
