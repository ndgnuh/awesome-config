local dir = os.getenv("HOME") .. "/.config/awesome/images"

return function(p)
	return dir .. "/" .. p
end
