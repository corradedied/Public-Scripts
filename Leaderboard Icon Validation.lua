do
	-- Executor detection
	local executor =
		(type(identifyexecutor) == "function" and identifyexecutor())
		or (type(getexecutorname) == "function" and getexecutorname())
		or (type(getexecutor) == "function" and getexecutor())
		or "Unknown Executor"

    -- Date & Time
	local now = DateTime.now()

	local local24 = now:FormatLocalTime("YYYY-MM-DD HH:mm:ss", "en-us")
	local local12 = now:FormatLocalTime("YYYY-MM-DD hh:mm:ss A", "en-us")

	local utc24   = now:FormatUniversalTime("YYYY-MM-DD HH:mm:ss", "en-us")
	local utc12   = now:FormatUniversalTime("YYYY-MM-DD hh:mm:ss A", "en-us")

	warn(
		"[LeaderboardIconsValidation] Script started\n" ..
		"  • Local Time : " .. local24 .. " | " .. local12 .. "\n" ..
		"  • UTC Time   : " .. utc24   .. " | " .. utc12   .. "\n" ..
		"  • Executor   : " .. tostring(executor)   .. "\n" ..
        "Developed by Corrade (@corradeknight)"
	)
end

-- ======================================================================================
-- GETCUSTOMASSET + FILESYSTEM FULL ICON TEST
-- ======================================================================================

local ICON_DIR = "Celestial ScriptHub/TestIcons"

local ICONS = {
	Intern = { "Intern.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/jdz29v4y.png" },
	Trophy = { "Trophy.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/uznzgpa9.png" },
	Tilt = { "Tilt.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/wam7vqzp.png" },
	Verified = { "Verified.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/kq6j9gs6.png" },
	Developer = { "Developer.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/z5ik4jy5.png" },
	Premium = { "Premium.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/n88ux4n6.png" },
	Starcode = { "Starcode.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/88ei7l5q.png" },
	StarcodeAlt = { "StarcodeAlt.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/8dl5i993.png" },
	Celestial = { "Celestial.png", "https://r2.e-z.host/9b6f8218-86a0-4fc8-a9a9-2365de9ff132/m6t7rsrc.png" },
}

-- --------------------------------------------------
-- Helpers
-- --------------------------------------------------
local function part(icon, msg)
	print(("🔹 [%s] %s"):format(icon, msg))
end

local function ok(icon, msg)
	print(("✅ [%s] %s"):format(icon, msg))
end

local function fail(icon, msg)
	warn(("❌ [%s] %s"):format(icon, msg))
end

-- --------------------------------------------------
-- Environment checks
-- --------------------------------------------------
if typeof(getcustomasset) ~= "function" then
	error("getcustomasset is NOT supported in this environment")
end

if not isfolder("Celestial ScriptHub") then
	makefolder("Celestial ScriptHub")
end

if not isfolder(ICON_DIR) then
	makefolder(ICON_DIR)
end

-- --------------------------------------------------
-- Per-icon test loop
-- --------------------------------------------------
local RESULTS = {}

for name, data in pairs(ICONS) do
	local filename, url = data[1], data[2]
	local path = ICON_DIR .. "/" .. filename

	print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🧪 Testing Icon:", name)

	-- 1. HTTP
	part(name, "Downloading via HttpGet")
	local body
	local okHttp, err = pcall(function()
		body = game:HttpGet(url)
	end)

	if not okHttp or not body then
		fail(name, "HttpGet failed")
		RESULTS[name] = false
		continue
	end
	ok(name, "HttpGet success (" .. #body .. " bytes)")

	-- 2. PNG validation
	part(name, "Validating PNG header")
	if body:sub(1, 8) ~= "\137PNG\r\n\26\n" then
		fail(name, "Invalid PNG signature")
		RESULTS[name] = false
		continue
	end
	ok(name, "PNG signature valid")

	-- 3. writefile
	part(name, "Writing file to disk")
	writefile(path, body)

	if not isfile(path) then
		fail(name, "writefile failed")
		RESULTS[name] = false
		continue
	end
	ok(name, "File written successfully")

	-- 4. readfile
	part(name, "Reading file back")
	local read = readfile(path)
	if not read or #read ~= #body then
		fail(name, "readfile mismatch")
		RESULTS[name] = false
		continue
	end
	ok(name, "readfile validated")

	-- 5. getcustomasset
	part(name, "Calling getcustomasset")
	task.wait()

	local okAsset, asset = pcall(getcustomasset, path)
	if not okAsset or not asset then
		fail(name, "getcustomasset failed")
		RESULTS[name] = false
		continue
	end

	ok(name, "getcustomasset success → " .. tostring(asset))
	RESULTS[name] = true
end

-- --------------------------------------------------
-- Summary
-- --------------------------------------------------
print("\n==================== SUMMARY ====================")
for icon, success in pairs(RESULTS) do
	if success then
		print("✅", icon, "PASSED")
	else
		warn("❌", icon, "FAILED")
	end
end
print("================================================")
