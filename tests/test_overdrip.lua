-- Behaviour tests for lib/overdrip.lua
--
-- Runs with plain Lua outside of the compositor:
--   luajit tests/test_overdrip.lua
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

-- The full `gears` and `wibox` modules pull in lgi/cairo, so only expose the
-- pure Lua parts overdrip needs, and fake the place container.
package.preload["gears"] = function()
	return {
		object = require("gears.object"),
		table = require("gears.table"),
	}
end

package.preload["wibox"] = function()
	local place = function()
		local container = { widget = nil, set_count = 0 }
		function container:set_widget(w)
			self.widget = w
			self.set_count = self.set_count + 1
		end
		return container
	end
	return { container = { place = place } }
end

local overdrip = require("lib.overdrip")

-- Minimal test harness ------------------------------------------------------

local tests = {}
local function test(name, fn)
	tests[#tests + 1] = { name = name, fn = fn }
end

local function eq(actual, expected, msg)
	if actual ~= expected then
		error(
			string.format("%s: expected %s, got %s", msg or "assert_eq", tostring(expected), tostring(actual)),
			2
		)
	end
end

local function counter()
	local c = { n = 0, last = nil }
	c.fn = function(_, value)
		c.n = c.n + 1
		c.last = value
	end
	return c
end

-- Plain providers -----------------------------------------------------------

test("constant provider returns its value", function()
	eq(overdrip.provider(42):get(), 42)
	eq(overdrip.provider("x").state, nil, "state before first get")
end)

test("falsy constants are preserved", function()
	eq(overdrip.provider(false):get(), false)
	eq(overdrip.provider(nil):get(), nil)
end)

test("function builder is lazy and cached", function()
	local calls = 0
	local p = overdrip.provider(function()
		calls = calls + 1
		return "built"
	end)
	eq(calls, 0, "builder called before get")
	eq(p:get(), "built")
	eq(p:get(), "built")
	eq(calls, 1, "builder calls")
end)

test("providers do not share state", function()
	local a = overdrip.provider(1)
	local b = overdrip.provider(2)
	a:get()
	b:get()
	a.state = 10
	eq(a:get(), 10)
	eq(b:get(), 2)
end)

test("assigning state updates value and notifies subscribers", function()
	local p = overdrip.provider(1)
	local sub = counter()
	eq(p:get(sub.fn), 1)
	p.state = 2
	eq(p:get(), 2)
	eq(sub.n, 1, "notifications")
	eq(sub.last, 2, "notified value")
end)

test("assigning the same value does not notify", function()
	local p = overdrip.provider(1)
	local sub = counter()
	p:get(sub.fn)
	p.state = 1
	eq(sub.n, 0, "notifications")
end)

test("subscribing twice with the same callback notifies once", function()
	local p = overdrip.provider(1)
	local sub = counter()
	p:get(sub.fn)
	p:get(sub.fn)
	p.state = 2
	eq(sub.n, 1, "notifications")
end)

-- Derived providers ---------------------------------------------------------

test("derived provider recomputes when a watched provider changes", function()
	local base = overdrip.provider(2)
	local calls = 0
	local double = overdrip.provider(function(ref)
		calls = calls + 1
		return ref.watch(base) * 2
	end)
	local sub = counter()
	eq(double:get(sub.fn), 4)

	base.state = 5
	eq(double:get(), 10)
	eq(calls, 2, "builder calls")
	eq(sub.n, 1, "derived subscriber notifications")
	eq(sub.last, 10)
end)

test("changes propagate through a chain of providers", function()
	local a = overdrip.provider(1)
	local b = overdrip.provider(function(ref)
		return ref.watch(a) + 1
	end)
	local c = overdrip.provider(function(ref)
		return ref.watch(b) * 10
	end)
	eq(c:get(), 20)
	a.state = 4
	eq(b:get(), 5)
	eq(c:get(), 50)
end)

test("derived provider watching several providers", function()
	local x = overdrip.provider(1)
	local y = overdrip.provider(2)
	local sum = overdrip.provider(function(ref)
		return ref.watch(x) + ref.watch(y)
	end)
	eq(sum:get(), 3)
	x.state = 10
	eq(sum:get(), 12)
	y.state = 20
	eq(sum:get(), 30)
end)

test("derived subscriber is not notified when the result is unchanged", function()
	local n = overdrip.provider(2)
	local is_even = overdrip.provider(function(ref)
		return ref.watch(n) % 2 == 0
	end)
	local sub = counter()
	eq(is_even:get(sub.fn), true)
	n.state = 4
	eq(sub.n, 0, "notifications")
	n.state = 5
	eq(sub.n, 1, "notifications")
	eq(sub.last, false)
end)

test("ref.read does not create a dependency", function()
	local base = overdrip.provider(1)
	local calls = 0
	local p = overdrip.provider(function(ref)
		calls = calls + 1
		return ref.read(base)
	end)
	eq(p:get(), 1)
	base.state = 2
	eq(calls, 1, "builder calls")
	eq(p:get(), 1, "stale value is kept")
end)

test("dependencies that are no longer watched stop triggering recompute", function()
	local use_a = overdrip.provider(true)
	local a = overdrip.provider("a")
	local b = overdrip.provider("b")
	local calls = 0
	local pick = overdrip.provider(function(ref)
		calls = calls + 1
		if ref.watch(use_a) then
			return ref.watch(a)
		end
		return ref.watch(b)
	end)
	eq(pick:get(), "a")

	use_a.state = false
	eq(pick:get(), "b")
	local calls_before = calls

	a.state = "a2"
	eq(calls, calls_before, "recomputed after unwatched dependency changed")
	eq(pick:get(), "b")

	b.state = "b2"
	eq(pick:get(), "b2")
end)

test("watching itself is an error", function()
	local p
	p = overdrip.provider(function(ref)
		return ref.watch(p)
	end)
	local ok, err = pcall(p.get, p)
	eq(ok, false, "pcall result")
	assert(tostring(err):find("Cannot watch itself"), "unexpected error: " .. tostring(err))
end)

test("ref.invalidateSelf re-runs the builder", function()
	local calls = 0
	local saved_ref
	local p = overdrip.provider(function(ref)
		calls = calls + 1
		saved_ref = ref
		return calls
	end)
	eq(p:get(), 1)
	saved_ref.invalidateSelf()
	eq(p:get(), 2)
end)

test("ref.invalidate re-runs another provider's builder", function()
	local calls = 0
	local other = overdrip.provider(function()
		calls = calls + 1
		return calls
	end)
	local saved_ref
	local p = overdrip.provider(function(ref)
		saved_ref = ref
		return true
	end)
	eq(other:get(), 1)
	p:get()
	saved_ref.invalidate(other)
	eq(other:get(), 2)
end)

-- notify_all ----------------------------------------------------------------

test("notify_all notifies subscribers and queues re-subscriptions", function()
	local p = overdrip.provider(1)
	local seen = {}
	local late = counter()
	local function resubscriber(self, value)
		seen[#seen + 1] = value
		self:get(late.fn)
	end
	p:get(resubscriber)

	p:notify_all()
	eq(#seen, 1, "first notify")
	eq(late.n, 0, "late subscriber called during the same emit")

	p:notify_all()
	eq(#seen, 2, "second notify")
	eq(late.n, 1, "late subscriber after being attached")
end)

test("notify_all re-raises subscriber errors and recovers", function()
	local p = overdrip.provider(1)
	p:get(function()
		error("boom")
	end)
	local ok, err = pcall(p.notify_all, p)
	eq(ok, false, "pcall result")
	assert(tostring(err):find("boom"), "unexpected error: " .. tostring(err))
	eq(rawget(p, "_notifying"), false, "_notifying flag reset")
end)

-- consumer_widget -----------------------------------------------------------

test("consumer_widget builds once and rebuilds on watched change", function()
	local p = overdrip.provider("hello")
	local builds = 0
	local w = overdrip.consumer_widget(function(ref)
		builds = builds + 1
		return { text = ref.watch(p) }
	end)
	eq(builds, 1, "initial build")
	eq(w.widget.text, "hello")

	p.state = "world"
	eq(builds, 2, "rebuild")
	eq(w.widget.text, "world")
	eq(w.set_count, 2, "set_widget calls")
end)

test("consumer_widget ref.read does not rebuild", function()
	local p = overdrip.provider("a")
	p:get()
	local builds = 0
	local w = overdrip.consumer_widget(function(ref)
		builds = builds + 1
		return { text = ref.read(p) }
	end)
	eq(w.widget.text, "a")
	p.state = "b"
	eq(builds, 1, "builds")
end)

test("consumer_widget follows derived providers", function()
	local base = overdrip.provider(1)
	local label = overdrip.provider(function(ref)
		return "#" .. ref.watch(base)
	end)
	local w = overdrip.consumer_widget(function(ref)
		return { text = ref.watch(label) }
	end)
	eq(w.widget.text, "#1")
	base.state = 7
	eq(w.widget.text, "#7")
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
