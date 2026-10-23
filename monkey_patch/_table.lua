--- Patching table module to have some cool functions

function table.keys(tbl)
	local keys = {}
	for k, _ in pairs(tbl) do
		table.insert(keys, k)
	end
	return keys
end

function table.index_of(tbl, item)
	for i = 1, #tbl do
		if tbl[i] == item then
			return i
		end
	end
end

---Cycle the index of a table
---@param tbl table The table
---@param i integer Current index
---@param delta integer? Index offset, default to 1
function table.cycle_index(tbl, i, delta)
	delta = delta or 1
	local j = i + delta
	local n = #tbl
	if j > n then
		return 1
	elseif j <= 0 then
		return n
	else
		return j
	end
end

---Remove and item from a table.
---This fucntion is value based. If there are multiple keys in the
---table the refers to the same value, they are all removed.
---@param tbl table The table containing items.
---@param item any The item value to be removed.
function table.remove_item(tbl, item)
	for i, v in pairs(tbl) do
		if item == v then
			table.remove_at(tbl, i)
		end
	end
end

---Remove an item at a specific index from a table.
---This fucntion is value based. If there are multiple keys in the
---table the refers to the same value, they are all removed.
---@param tbl table The table containing items.
---@param index integer The index of the to-be-removed item.
function table.remove_at(tbl, index)
	local n = #tbl
	for i = index, n do
		tbl[i] = tbl[i + 1]
	end
	tbl[n] = nil
end

---Push an index in the table to the last position
---@param tbl table The table containing items.
---@param idx integer The index to be pushed.
function table.push_to_last(tbl, idx)
	local item = tbl[idx]
	table.remove_at(tbl, idx)
	table.insert(tbl, item)
end

---Push an item in the table to the last position
---If the item is not in the table, append the table
---otherwise, push it to the "top" and shift other items
---@generic T
---@param tbl T[] The table that contain items.
---@param item T The item to be pushed.
function table.push_item_to_last(tbl, item)
	local idx = table.index_of(tbl, item)
	if idx then
		table.remove_at(tbl, idx)
	end
	table.insert(tbl, item)
end
