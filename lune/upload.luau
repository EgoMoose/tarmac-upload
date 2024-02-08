--!strict

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local datetime = require("@lune/datetime")

local UDim2 = (roblox :: any).UDim2

local ROOT_FOLDER = "assets"
local MAX_SCREEN_WIDTH = 1000

type Dictionary<K, V> = { [K]: V }

type Node = {
	path: { string },
	parent: Dictionary<string, any>,
}

local function compareBytes(a: { number }, b: { number })
	return table.concat(a, ",") == table.concat(b, ",")
end

local function isPng(content: string)
	return (
		compareBytes({ string.byte(content, 1, 8) }, { 137, 80, 78, 71, 13, 10, 26, 10 })
		and compareBytes({ string.byte(content, 12, 16) }, { 13, 73, 72, 68, 82 })
	)
end

local function getImageSize(path: string)
	local w, h = 0, 0
	local content = fs.readFile(path)

	if isPng(content) then
		w, h = string.unpack(">ii", string.sub(content, 17, 25))
	end

	return {
		w = w,
		h = h,
	}
end

local function getTimestampFilename(): string
	local now = datetime.now()
	return now:formatLocalTime("%Y-%m-%d_%H-%M-%S", "en")
end

local function convertToRBXM()
	local generated = require("../generated")

	-- stylua: ignore
	local queue: { Node } = {{
		path = { ROOT_FOLDER },
		parent = generated,
	}}

	local screen = roblox.Instance.new("ScreenGui")
	screen.Name = getTimestampFilename()
	print(screen.Name)

	local function findByPath(path: { string }): Instance
		-- ignore root folder
		local parent = screen
		for i = 2, #path do
			parent = parent[path[i]]
		end
		return parent
	end

	local currentWidth = 0
	local currentHeight = 0
	local maxHeight = 0

	while #queue > 0 do
		local popped = table.remove(queue) :: Node

		for name, value in popped.parent do
			local valueType = type(value)

			local path = table.clone(popped.path)
			table.insert(path, name)

			if valueType == "table" then
				-- folder
				-- stylua: ignore
				table.insert(queue, {
					path = path,
					parent = value,
				})

				local folder = roblox.Instance.new("Folder")
				folder.Name = name
				folder.Parent = findByPath(popped.path)
			elseif valueType == "string" then
				-- asset id
				local strPath = table.concat(path, "/") .. ".png"
				local size = getImageSize(strPath)

				if currentWidth + size.w > MAX_SCREEN_WIDTH then
					currentHeight = currentHeight + maxHeight
					maxHeight = 0
					currentWidth = 0
				end

				local label = roblox.Instance.new("ImageLabel")
				label.Name = name
				label.Position = UDim2.fromOffset(currentWidth, currentHeight)
				label.Size = UDim2.fromOffset(size.w, size.h)
				label.Image = value
				label.BackgroundTransparency = 1
				label.Parent = findByPath(popped.path)

				currentWidth = currentWidth + size.w
				maxHeight = math.max(maxHeight, size.h)
			end
		end
	end

	fs.writeFile(`output/{screen.Name}.rbxm`, roblox.serializeModel({ screen }))
end

local function uploadTarmac()
	local cookie = process.args[1]

	if not cookie then
		error("No auth cookie provided!")
	end

	-- stylua: ignore
	local result = process.spawn("tarmac", {
		"sync",
		"--target", "roblox",
		"--retry", "100",
		"--retry-delay", "60",
		"--auth", cookie,
	})

	if result.ok then
		print(result.stdout)
		print("Tarmac successfully ran")
	else
		error(result.stderr)
	end

	convertToRBXM()
end

uploadTarmac()
