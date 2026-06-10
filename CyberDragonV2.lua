-- ========== EXECUTION GUARD ==========
if getgenv()._CyberDragon_Reloading then
    return
end
getgenv()._CyberDragon_Reloading = true

-- ========== EXECUTOR DIAGNOSTIC ==========
local function RunDiagnostics()
    local results = {}

    -- Test 1: loadstring availability
    local testFunc, testErr = loadstring("return 42")
    results.loadstring = testFunc and testFunc() == 42

    -- Test 2: game:HttpGet availability  
    results.httpget = pcall(function()
        local test = game:HttpGet("https://github.com/makarmatvij7-svg/LunoriaaLib/blob/main/Library.lua")
        return test and #test > 1000
    end)

    -- Test 3: getgc availability (for weapon mods)
    results.getgc = pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then break end
        end
    end)

    -- Test 4: hookmetamethod availability
    results.hookmeta = pcall(function()
        return hookmetamethod ~= nil
    end)

    -- Test 5: Drawing library
    results.drawing = pcall(function()
        return Drawing ~= nil
    end)

    -- Test 6: getrawmetatable
    results.rawmeta = pcall(function()
        return getrawmetatable ~= nil
    end)

    -- Print results
    print("=== Cyber Dragon Executor Diagnostics ===")
    for name, ok in pairs(results) do
        print("[" .. (ok and "OK" or "FAIL") .. "] " .. name)
    end
    print("========================================")

    return results
end

local diag = RunDiagnostics()
if not diag.httpget then
    warn("CRITICAL: game:HttpGet is not working! The script cannot load UI libraries.")
    warn("Try using a different executor or loading libraries locally.")
end

-- ========== SAFE LIBRARY LOADER ==========
local function _SafeLoadLibrary(url, name)
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        if not code or code == "" then
            error("Empty response from " .. url)
        end
        local func, err = loadstring(code)
        if not func then
            error("Compile error in " .. name .. ": " .. tostring(err))
        end
        local ok, lib = pcall(func)
        if not ok then
            error("Runtime error in " .. name .. ": " .. tostring(lib))
        end
        return lib
    end)

    if success then
        return result
    else
        warn("[Cyber Dragon] Failed to load " .. name .. ": " .. tostring(result))
        return nil
    end
end


-- ========== LUA 5.1 COMPATIBILITY POLYFILLS ==========
if not math.clamp then
    function math.clamp(n, min, max)
        return math.max(min, math.min(max, n))
    end
end

-- ========== EXECUTOR COMPATIBILITY FALLBACKS ==========
local _compat = {}

_compat.getrawmetatable = function(obj)
    local ok, mt = pcall(getrawmetatable, obj)
    if ok then return mt end
    ok, mt = pcall(getmetatable, obj)
    if ok then return mt end
    return nil
end

_compat.setreadonly = function(tbl, readonly)
    local ok = pcall(setreadonly, tbl, readonly)
    if not ok then
        -- Fallback: try __metatable manipulation
        local mt = getmetatable(tbl)
    if mt then
            pcall(function() mt.__metatable = readonly and "locked" or nil end)
        end
    end
end

_compat.newcclosure = newcclosure or function(func)
    return func
end

_compat.getnamecallmethod = getnamecallmethod or function()
    return nil
end

_compat.hookmetamethod = hookmetamethod or function(obj, method, hook)
    warn("[Cyber Dragon] hookmetamethod not supported on this executor")
    return nil
end

_compat.cloneref = cloneref or function(ref)
    return ref
end

_compat.setclipboard = setclipboard or function(text)
    warn("[Cyber Dragon] setclipboard not supported on this executor")
end

_compat.firetouchinterest = firetouchinterest or function(part1, part2, num)
    -- Fallback: no-op
end

_compat.Drawing = Drawing or nil

-- ========== SAFE LIBRARY LOADER ==========
local function SafeLoadLibrary(url, name)
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        if not code or code == "" then
            error("Empty response from " .. url)
        end
        local func, err = loadstring(code)
        if not func then
            error("Compile error in " .. name .. ": " .. tostring(err))
        end
        local ok, lib = pcall(func)
        if not ok then
            error("Runtime error in " .. name .. ": " .. tostring(lib))
        end
        return lib
    end)

    if success then
        return result
    else
        warn("[Cyber Dragon] Failed to load " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Cleanup previous instance if exists
if getgenv()._CyberDragon_Cleanup then
    pcall(getgenv()._CyberDragon_Cleanup)
    task.wait(0.5)
end

-- ========== KEY SYSTEM WITH EXPIRATION (FIXED) ==========
local KeySystem = {}

local KEY_CONFIG = {
    ValidKeys = {
        -- Permanent keys (16 total)
        ["ILOVETHIS"] = {ExpiresAt = nil, Duration = nil},
        ["BESTSCRIPTEVER"] = {ExpiresAt = nil, Duration = nil},
        ["MYMAINACCOUNT"] = {ExpiresAt = nil, Duration = nil},
        ["GOTTHISFROMFRIEND"] = {ExpiresAt = nil, Duration = nil},
        ["TRUSTEDUSER"] = {ExpiresAt = nil, Duration = nil},
        ["REALOG"] = {ExpiresAt = nil, Duration = nil},
        ["WORTHIT"] = {ExpiresAt = nil, Duration = nil},
        ["NOCAPFRFR"] = {ExpiresAt = nil, Duration = nil},
        ["BIGFANHERE"] = {ExpiresAt = nil, Duration = nil},
        ["THANKSDEV"] = {ExpiresAt = nil, Duration = nil},
        ["CYBER2026"] = {ExpiresAt = nil, Duration = nil},
        ["DRAGONVIP"] = {ExpiresAt = nil, Duration = nil},
        ["BETAACCESS"] = {ExpiresAt = nil, Duration = nil},
        ["PREMIUM"] = {ExpiresAt = nil, Duration = nil},
        ["OWNERKEY"] = {ExpiresAt = nil, Duration = nil},
        ["KEYFORFREE"] = {ExpiresAt = nil, Duration = nil},
        
        -- Timed keys (16 total)
        ["JUSTTESTING"] = {ExpiresAt = nil, Duration = 24},
        ["QUICKLOOK"] = {ExpiresAt = nil, Duration = 6},
        ["MAYBEBUYLATER"] = {ExpiresAt = nil, Duration = 48},
        ["ONEDAYPASS"] = {ExpiresAt = nil, Duration = 24},
        ["WEEKENDVIBES"] = {ExpiresAt = nil, Duration = 72},
        ["NOTSUREYET"] = {ExpiresAt = nil, Duration = 12},
        ["GONNATRYIT"] = {ExpiresAt = nil, Duration = 24},
        ["SHORTTRY"] = {ExpiresAt = nil, Duration = 6},
        ["ALMOSTBOUGHT"] = {ExpiresAt = nil, Duration = 48},
        ["LONGWEEKEND"] = {ExpiresAt = nil, Duration = 96},
        ["FREETRIAL"] = {ExpiresAt = nil, Duration = 12},
        ["BETAFREEHAHA"] = {ExpiresAt = nil, Duration = 10},
    },
    KeyFile = "CyberDragon/key.txt",
    ExpiryFile = "CyberDragon/key_expiry.txt",
    UsedKeysFile = "CyberDragon/used_keys.txt",
    HWIDKeysFile = "CyberDragon/hwid_keys.txt",
    AutoSave = true,
    MaxAttempts = 5,
    Attempts = 0,
    KeyLength = {Min = 6, Max = 20}
}

-- ========== UNIQUE KEY GENERATOR ==========
local KeyGenerator = {}

function KeyGenerator:GenerateRandomKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key = "CYBER"
    for i = 1, 6 do
        local rand = math.random(1, #chars)
        key = key .. chars:sub(rand, rand)
    end
    return key
end

function KeyGenerator:GetUsedKeys()
    if not readfile or not isfile then return {} end
    if not isfile(KEY_CONFIG.UsedKeysFile) then return {} end
    local success, data = pcall(readfile, KEY_CONFIG.UsedKeysFile)
    if not success or not data or data == "" then return {} end
    local ok, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if ok and type(decoded) == "table" then
        return decoded
    end
    return {}
end

function KeyGenerator:SaveUsedKeys(usedKeys)
    if not writefile then return end
    pcall(function()
        makefolder("CyberDragon")
        writefile(KEY_CONFIG.UsedKeysFile, game:GetService("HttpService"):JSONEncode(usedKeys))
    end)
end

function KeyGenerator:GetHWIDKeyMap()
    if not readfile or not isfile then return {} end
    if not isfile(KEY_CONFIG.HWIDKeysFile) then return {} end
    local success, data = pcall(readfile, KEY_CONFIG.HWIDKeysFile)
    if not success or not data or data == "" then return {} end
    local ok, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if ok and type(decoded) == "table" then
        return decoded
    end
    return {}
end

function KeyGenerator:SaveHWIDKeyMap(hwidMap)
    if not writefile then return end
    pcall(function()
        makefolder("CyberDragon")
        writefile(KEY_CONFIG.HWIDKeysFile, game:GetService("HttpService"):JSONEncode(hwidMap))
    end)
end

function KeyGenerator:GetOrCreateKeyForHWID(hwid)
    local hwidMap = self:GetHWIDKeyMap()

    -- If this HWID already has a key assigned, return it
    if hwidMap[hwid] then
        return hwidMap[hwid], true
    end

    -- Generate a new unique key
    local usedKeys = self:GetUsedKeys()
    local maxAttempts = 100
    local newKey = nil

    for i = 1, maxAttempts do
        local candidate = self:GenerateRandomKey()
        if not usedKeys[candidate] and not KEY_CONFIG.ValidKeys[candidate] then
            newKey = candidate
            break
        end
    end

    if not newKey then
        return nil, false
    end

    -- Mark key as used
    usedKeys[newKey] = true
    self:SaveUsedKeys(usedKeys)

    -- Assign to HWID
    hwidMap[hwid] = newKey
    self:SaveHWIDKeyMap(hwidMap)

    -- Add to valid keys (12 hour duration by default)
    KEY_CONFIG.ValidKeys[newKey] = {ExpiresAt = nil, Duration = 12}

    return newKey, false
end

function KeyGenerator:IsKeyUsed(key)
    local usedKeys = self:GetUsedKeys()
    return usedKeys[key] == true
end

function KeyGenerator:MarkKeyUsed(key)
    local usedKeys = self:GetUsedKeys()
    usedKeys[key] = true
    self:SaveUsedKeys(usedKeys)
end

function KeySystem:GetCurrentTimestamp()
    return os.time()
end

function KeySystem:FormatTimeRemaining(seconds)
    if seconds <= 0 then return "EXPIRED" end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, mins, secs)
    elseif mins > 0 then
        return string.format("%dm %ds", mins, secs)
    else
        return string.format("%ds", secs)
    end
end

function KeySystem:ValidateKey(key)
    if not key or key == "" then return false, "Empty key" end
    local len = #key
    if len < KEY_CONFIG.KeyLength.Min or len > KEY_CONFIG.KeyLength.Max then return false, "Invalid length" end

    local upperKey = key:upper()
    local keyData = KEY_CONFIG.ValidKeys[upperKey]

    if not keyData then return false, "Invalid key" end

    -- Check if this key was generated for another HWID
    local hwid = self:GetHWID()
    local hwidMap = KeyGenerator:GetHWIDKeyMap()
    local assignedHWID = nil

    for savedHWID, savedKey in pairs(hwidMap) do
        if savedKey:upper() == upperKey then
            assignedHWID = savedHWID
            break
        end
    end

    -- If key is assigned to a different HWID, reject it
    if assignedHWID and assignedHWID ~= hwid then
        return false, "Key already used by another player"
    end

    -- If key exists in ValidKeys but not assigned to any HWID, assign it now
    if not assignedHWID then
        local usedKeys = KeyGenerator:GetUsedKeys()
        if not usedKeys[upperKey] then
            usedKeys[upperKey] = true
            KeyGenerator:SaveUsedKeys(usedKeys)
        end
        hwidMap[hwid] = upperKey
        KeyGenerator:SaveHWIDKeyMap(hwidMap)
    end

    -- FIXED: Check saved expiry FIRST (from previous session), then check keyData.ExpiresAt
    local savedExpiry = self:LoadKeyExpiry()
    if savedExpiry and savedExpiry.key == upperKey then
        local now = self:GetCurrentTimestamp()
        if now >= savedExpiry.expiresAt then
            self:ClearSavedKey()
            self:ClearKeyExpiry()
            return false, "Key expired"
        end
        return true, "Valid", savedExpiry.expiresAt - now
    end

    -- FIXED: If keyData has ExpiresAt set, check it
    if keyData.ExpiresAt then
        local now = self:GetCurrentTimestamp()
        if now >= keyData.ExpiresAt then
            KEY_CONFIG.ValidKeys[upperKey] = nil
            return false, "Key expired"
        end
        return true, "Valid", keyData.ExpiresAt - now
    end

    -- FIXED: If keyData has Duration but no ExpiresAt, this is FIRST USE — set expiry now
    if keyData.Duration then
        local newExpiry = self:GetCurrentTimestamp() + (keyData.Duration * 3600)
        KEY_CONFIG.ValidKeys[upperKey].ExpiresAt = newExpiry
        return true, "Valid", newExpiry - self:GetCurrentTimestamp()
    end

    -- Permanent key
    return true, "Valid (Permanent)", nil
end

function KeySystem:SaveKey(key, expiryInfo)
    if not writefile then return end
    pcall(function()
        makefolder("CyberDragon")
        writefile(KEY_CONFIG.KeyFile, key)
        if expiryInfo then
            writefile(KEY_CONFIG.ExpiryFile, game:GetService("HttpService"):JSONEncode(expiryInfo))
        end
    end)
end

function KeySystem:LoadSavedKey()
    if not readfile or not isfile then return nil end
    if not isfile(KEY_CONFIG.KeyFile) then return nil end
    local success, key = pcall(readfile, KEY_CONFIG.KeyFile)
    if success and key and key ~= "" then return key end
    return nil
end

function KeySystem:LoadKeyExpiry()
    if not readfile or not isfile then return nil end
    if not isfile(KEY_CONFIG.ExpiryFile) then return nil end
    local success, data = pcall(readfile, KEY_CONFIG.ExpiryFile)
    if success and data and data ~= "" then
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        if ok then return decoded end
    end
    return nil
end

function KeySystem:ClearSavedKey()
    if not isfile or not delfile then return end
    pcall(function()
        if isfile(KEY_CONFIG.KeyFile) then delfile(KEY_CONFIG.KeyFile) end
    end)
end

function KeySystem:ClearKeyExpiry()
    if not isfile or not delfile then return end
    pcall(function()
        if isfile(KEY_CONFIG.ExpiryFile) then delfile(KEY_CONFIG.ExpiryFile) end
    end)
end

function KeySystem:GetHWID()
    local hwid = ""
    pcall(function()
        local svc = game:GetService("RbxAnalyticsService")
        if svc and svc.GetClientId then
            hwid = svc:GetClientId()
        end
    end)
    if hwid == "" then hwid = tostring(game.PlaceId) .. "_" .. tostring(game.GameId) end
    return hwid
end

-- ========== KEY VALIDATION STATE ==========
getgenv()._CyberDragon_KeyValid = false
getgenv()._CyberDragon_CurrentKey = nil
getgenv()._CyberDragon_KeyExpiry = nil
getgenv()._CyberDragon_TimeRemaining = nil

local savedKey = KeySystem:LoadSavedKey()
if savedKey then
    local valid, msg, timeRemaining = KeySystem:ValidateKey(savedKey)
    if valid then
        getgenv()._CyberDragon_KeyValid = true
        getgenv()._CyberDragon_CurrentKey = savedKey:upper()
        getgenv()._CyberDragon_TimeRemaining = timeRemaining
        if timeRemaining then
            getgenv()._CyberDragon_KeyExpiry = KeySystem:GetCurrentTimestamp() + timeRemaining
        end
    else
        KeySystem:ClearSavedKey()
        KeySystem:ClearKeyExpiry()
        print("[Cyber Dragon] Saved key expired or invalid: " .. msg)
    end
end

-- ========== MAIN SCRIPT ==========
local function RunCyberDragon()
    if getgenv()._CyberDragon_Running then return end
    getgenv()._CyberDragon_Running = true
    getgenv()._CyberDragon_Reloading = false

    math.randomseed(os.time())

    getgenv()._CyberDragon_Connections = {}
    getgenv()._CyberDragon_Hooks = {}
    getgenv()._CyberDragon_Originals = {}

    local function addConnection(conn)
        if conn then
            table.insert(getgenv()._CyberDragon_Connections, conn)
        end
        return conn
    end

    -- ========== KEY EXPIRY CHECKER ==========
    local function checkKeyExpiry()
        if not getgenv()._CyberDragon_KeyExpiry then return true end
        local now = KeySystem:GetCurrentTimestamp()
        local remaining = getgenv()._CyberDragon_KeyExpiry - now
        if remaining <= 0 then
            return false
        end
        getgenv()._CyberDragon_TimeRemaining = remaining
        return true
    end

    task.spawn(function()
        while getgenv()._CyberDragon_Running do
            if not checkKeyExpiry() then
                if getgenv()._CyberDragon_Library then
                    pcall(function()
                        getgenv()._CyberDragon_Library:Notify("KEY EXPIRED! Unloading in 10s...", 10)
                    end)
                end
                task.wait(10)
                if getgenv()._CyberDragon_Cleanup then
                    pcall(getgenv()._CyberDragon_Cleanup)
                end
                return
            end
            task.wait(30)
        end
    end)

    task.wait(1)

    -- ========== SAFE ANTI-KICK (With Fallbacks) ==========
    do
        local lp = game:GetService("Players").LocalPlayer
        local antiKickActive = false

        -- Method 1: getrawmetatable + setreadonly (best)
        local mtOk, mt = pcall(getrawmetatable, game)
        if mtOk and mt then
            local oldOk, old = pcall(function() return mt.__namecall end)
            if oldOk and old then
                local setOk = pcall(setreadonly, mt, false)
                if setOk then
                    mt.__namecall = newcclosure(function(self, ...)
                        local method = getnamecallmethod()
                        if method and (method:lower():find("kick") or method == "Shutdown") then
                            if self == lp or self == game then
                                return
                            end
                        end
                        return old(self, ...)
                    end)
                    pcall(setreadonly, mt, true)
                    antiKickActive = true
                    print("[Cyber Dragon] AntiKick Method 1 active")
                end
            end
        end

        -- Method 2: hookmetamethod (fallback)
        if not antiKickActive and hookmetamethod then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if method and (method:lower():find("kick") or method == "Shutdown") then
                    if self == lp or self == game then
                        return
                    end
                end
                return oldNamecall(self, ...)
            end)
            antiKickActive = true
            print("[Cyber Dragon] AntiKick Method 2 active")
        end

        -- Method 3: hookfunction on Kick (last resort)
        if not antiKickActive then
            local kickOk, kickFunc = pcall(function()
                return lp.Kick
            end)
            if kickOk and kickFunc then
                pcall(function()
                    hookfunction(kickFunc, function(self, ...)
                        if self == lp then
                            warn("[Cyber Dragon] Blocked Kick attempt")
                            return
                        end
                        return kickFunc(self, ...)
                    end)
                end)
                antiKickActive = true
                print("[Cyber Dragon] AntiKick Method 3 active")
            end
        end

        if not antiKickActive then
            warn("[Cyber Dragon] No anti-kick method available on this executor")
        end
    end
    -- ========== DISABLE COSMETICS UNLOCK ==========
    local function DisableCosmeticsUnlock()
        local originals = getgenv()._CyberDragon_Originals
        if not originals then
            warn("[Cyber Dragon] No originals stored to restore")
            return
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local plr = game:GetService("Players").LocalPlayer

        local CosmeticLibrary
        pcall(function()
            CosmeticLibrary = require(ReplicatedStorage.Modules:FindFirstChild("CosmeticLibrary"))
        end)
        if CosmeticLibrary then
            if originals.OwnsCosmeticNormally then CosmeticLibrary.OwnsCosmeticNormally = originals.OwnsCosmeticNormally end
            if originals.OwnsCosmeticUniversally then CosmeticLibrary.OwnsCosmeticUniversally = originals.OwnsCosmeticUniversally end
            if originals.OwnsCosmeticForWeapon then CosmeticLibrary.OwnsCosmeticForWeapon = originals.OwnsCosmeticForWeapon end
            if originals.OwnsCosmetic then CosmeticLibrary.OwnsCosmetic = originals.OwnsCosmetic end
        end

        local DataController
        pcall(function()
            local ps = plr:FindFirstChild("PlayerScripts")
            if ps then
                local ctrl = ps:FindFirstChild("Controllers")
                if ctrl then
                    DataController = require(ctrl:FindFirstChild("PlayerDataController"))
                end
            end
        end)
        if DataController then
            if originals.DataControllerGet then DataController.Get = originals.DataControllerGet end
            if originals.DataControllerGetWeaponData then DataController.GetWeaponData = originals.DataControllerGetWeaponData end
        end

        getgenv()._CyberDragon_unlockOnce = false
        getgenv()._CyberDragon_unlockRan = false
        print("[Cyber Dragon] Cosmetics restored to normal")
    end

    -- ========== UNLOCK ALL COSMETICS (FIXED - NO INFINITE LOOPS) ==========
    getgenv()._CyberDragon_unlockOnce = false
    getgenv()._CyberDragon_unlockRan = false

    local function UnlockAll()
        if getgenv()._CyberDragon_unlockOnce then return end
        getgenv()._CyberDragon_unlockOnce = true

        local plr = game:GetService("Players").LocalPlayer
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local HttpService = game:GetService("HttpService")
        local playerScripts = plr.PlayerScripts
        local controllers = playerScripts.Controllers

        local EnumLibrary, CosmeticLibrary, ItemLibrary, DataController
        local success1, result1 = pcall(function()
            return require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 3))
        end)
        if success1 then EnumLibrary = result1 end

        local success2, result2 = pcall(function()
            local lib = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 3))
            if lib and lib.WaitForEnumBuilder then
                local _enumBuilt = false
                task.delay(2, function() _enumBuilt = true end)
            end
            return lib
        end)
        if success2 then CosmeticLibrary = result2 end

        local success3, result3 = pcall(function()
            return require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 3))
        end)
        if success3 then ItemLibrary = result3 end

        local success4, result4 = pcall(function()
            return require(controllers:WaitForChild("PlayerDataController", 3))
        end)
        if success4 then DataController = result4 end

        if not CosmeticLibrary or not DataController then
            warn("[Cyber Dragon] Failed to load required modules for UnlockAll")
            return
        end

        local equipped, favorites = {}, {}
        local constructingWeapon, viewingProfile = nil, nil
        local lastUsedWeapon = nil

        local function cloneCosmetic(name, cosmeticType, options)
            if not CosmeticLibrary.Cosmetics then return nil end
            local base = CosmeticLibrary.Cosmetics[name]
            if not base then return nil end
            local data = {}
            for key, value in pairs(base) do data[key] = value end
            data.Name = name
            data.Type = data.Type or cosmeticType
            data.Seed = data.Seed or math.random(1, 1000000)
            if EnumLibrary and EnumLibrary.ToEnum then
                local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
                if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
            end
            if options then
                if options.inverted ~= nil then data.Inverted = options.inverted end
                if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
            end
            return data
        end

        local saveFile = "unlockall/config.json"
        local function saveConfig()
            if not writefile then return end
            pcall(function()
                local config = {equipped = {}, favorites = favorites}
                for weapon, cosmetics in pairs(equipped) do
                    config.equipped[weapon] = {}
                    for cosmeticType, cosmeticData in pairs(cosmetics) do
                        if cosmeticData and cosmeticData.Name then
                            config.equipped[weapon][cosmeticType] = {
                                name = cosmeticData.Name,
                                seed = cosmeticData.Seed,
                                inverted = cosmeticData.Inverted
                            }
                        end
                    end
                end
                makefolder("unlockall")
                writefile(saveFile, HttpService:JSONEncode(config))
            end)
        end

        local function loadConfig()
            if not readfile or not isfile or not isfile(saveFile) then return end
            pcall(function()
                local config = HttpService:JSONDecode(readfile(saveFile))
                if config.equipped then
                    for weapon, cosmetics in pairs(config.equipped) do
                        equipped[weapon] = {}
                        for cosmeticType, cosmeticData in pairs(cosmetics) do
                            local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                            if cloned then cloned.Seed = cosmeticData.seed; equipped[weapon][cosmeticType] = cloned end
                        end
                    end
                end
                favorites = config.favorites or {}
            end)
        end

        if not getgenv()._CyberDragon_Originals.OwnsCosmeticNormally then
            getgenv()._CyberDragon_Originals.OwnsCosmeticNormally = CosmeticLibrary.OwnsCosmeticNormally
        end
        if not getgenv()._CyberDragon_Originals.OwnsCosmeticUniversally then
            getgenv()._CyberDragon_Originals.OwnsCosmeticUniversally = CosmeticLibrary.OwnsCosmeticUniversally
        end
        if not getgenv()._CyberDragon_Originals.OwnsCosmeticForWeapon then
            getgenv()._CyberDragon_Originals.OwnsCosmeticForWeapon = CosmeticLibrary.OwnsCosmeticForWeapon
        end
        if not getgenv()._CyberDragon_Originals.OwnsCosmetic then
            getgenv()._CyberDragon_Originals.OwnsCosmetic = CosmeticLibrary.OwnsCosmetic
        end
        if not getgenv()._CyberDragon_Originals.DataControllerGet then
            getgenv()._CyberDragon_Originals.DataControllerGet = DataController.Get
        end
        if not getgenv()._CyberDragon_Originals.DataControllerGetWeaponData then
            getgenv()._CyberDragon_Originals.DataControllerGetWeaponData = DataController.GetWeaponData
        end

        -- FIXED: Don't use function equality (always false in Lua)
        if not getgenv()._CyberDragon_Originals._ownsCosmeticNormallyHooked then
            getgenv()._CyberDragon_Originals._ownsCosmeticNormallyHooked = true
            CosmeticLibrary.OwnsCosmeticNormally = function() return true end
        end
        if not getgenv()._CyberDragon_Originals._ownsCosmeticUniversallyHooked then
            getgenv()._CyberDragon_Originals._ownsCosmeticUniversallyHooked = true
            CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
        end
        if not getgenv()._CyberDragon_Originals._ownsCosmeticForWeaponHooked then
            getgenv()._CyberDragon_Originals._ownsCosmeticForWeaponHooked = true
            CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end
        end

        local originalOwnsCosmetic = getgenv()._CyberDragon_Originals.OwnsCosmetic
        local ownsCosmeticLocked = false
        CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
            if ownsCosmeticLocked then return originalOwnsCosmetic(self, inventory, name, weapon) end
            if name:find("MISSING_") then 
                ownsCosmeticLocked = true
                local result = originalOwnsCosmetic(self, inventory, name, weapon)
                ownsCosmeticLocked = false
                return result
            end
            return true
        end

        local originalGet = getgenv()._CyberDragon_Originals.DataControllerGet
        DataController.Get = function(self, key)
            local data = originalGet(self, key)
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in pairs(data) do proxy[k] = v end end
                return setmetatable(proxy, {__index = function() return true end})
            end
            if key == "FavoritedCosmetics" then
                local result = {}
                if data then
                    for k, v in pairs(data) do
                        result[k] = v
                    end
                end
                for weapon, favs in pairs(favorites) do
                    result[weapon] = result[weapon] or {}
                    for name, isFav in pairs(favs) do result[weapon][name] = isFav end
                end
                return result
            end
            return data
        end

        local originalGetWeaponData = getgenv()._CyberDragon_Originals.DataControllerGetWeaponData
        DataController.GetWeaponData = function(self, weaponName)
            local data = originalGetWeaponData(self, weaponName)
            if not data then return nil end
            local merged = {}
            for key, value in pairs(data) do merged[key] = value end
            merged.Name = weaponName
            if equipped[weaponName] then
                for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
            end
            return merged
        end

        local FighterController
        pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 3)) end)

        if hookmetamethod then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
            local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
            local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")

            if equipRemote then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                    local args = {...}
                    if useItemRemote and self == useItemRemote then
                        local objectID = args[1]
                        if FighterController then
                            pcall(function()
                                local fighter = FighterController:GetFighter(plr)
                                if fighter and fighter.Items then
                                    for _, item in pairs(fighter.Items) do
                                        if item:Get("ObjectID") == objectID then
                                            lastUsedWeapon = item.Name
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                    end
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                            local inventory = DataController:Get("CosmeticInventory")
                            if inventory and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                        end
                        equipped[weaponName] = equipped[weaponName] or {}
                        if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                            equipped[weaponName][cosmeticType] = nil
                            if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                        else
                            local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites})
                            if cloned then equipped[weaponName][cosmeticType] = cloned end
                        end
                        task.defer(function()
                            pcall(function() 
                                if DataController.CurrentData then
                                    DataController.CurrentData:Replicate("WeaponInventory") 
                                end
                            end)
                            task.wait(0.2)
                            saveConfig()
                        end)
                        return
                    end
                    if self == favoriteRemote then
                        favorites[args[1]] = favorites[args[1]] or {}
                        favorites[args[1]][args[2]] = args[3] or nil
                        saveConfig()
                        task.spawn(function() 
                            pcall(function() 
                                if DataController.CurrentData then
                                    DataController.CurrentData:Replicate("FavoritedCosmetics") 
                                end
                            end) 
                        end)
                        return
                    end
                    return oldNamecall(self, ...)
                end)
                getgenv()._CyberDragon_Hooks.NamecallHook = oldNamecall
            end
        end

        local ClientItem
        pcall(function() 
            ClientItem = require(plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) 
        end)
        if ClientItem and ClientItem._CreateViewModel and not getgenv()._CyberDragon_Originals.CreateViewModel then
            getgenv()._CyberDragon_Originals.CreateViewModel = ClientItem._CreateViewModel
            local originalCreateViewModel = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == plr) and weaponName or nil
                if weaponPlayer == plr and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
                    local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                    if viewmodelRef[dataKey] then
                        viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                        viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                    elseif viewmodelRef.Data then
                        viewmodelRef.Data.Skin = equipped[weaponName].Skin
                        viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                    end
                end
                local result = originalCreateViewModel(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end

        local viewModelModule = plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if viewModelModule then
            local ClientViewModel = require(viewModelModule)
            if ClientViewModel.GetWrap and not getgenv()._CyberDragon_Originals.GetWrap then
                getgenv()._CyberDragon_Originals.GetWrap = ClientViewModel.GetWrap
                local originalGetWrap = ClientViewModel.GetWrap
                ClientViewModel.GetWrap = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == plr and equipped[weaponName] and equipped[weaponName].Wrap then
                        return equipped[weaponName].Wrap
                    end
                    return originalGetWrap(self)
                end
            end
            if ClientViewModel.new and not getgenv()._CyberDragon_Originals.ViewModelNew then
                getgenv()._CyberDragon_Originals.ViewModelNew = ClientViewModel.new
                local originalNew = ClientViewModel.new
                ClientViewModel.new = function(replicatedData, clientItem)
                    local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                    local weaponName = constructingWeapon or clientItem.Name
                    if weaponPlayer == plr and equipped[weaponName] then
                        local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
                        local dataKey = ReplicatedClass:ToEnum("Data")
                        replicatedData[dataKey] = replicatedData[dataKey] or {}
                        local cosmetics = equipped[weaponName]
                        if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                        if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                        if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
                    end
                    local result = originalNew(replicatedData, clientItem)
                    if weaponPlayer == plr and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                        result:_UpdateWrap()
                        task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
                    end
                    return result
                end
            end
        end

        if ItemLibrary and not getgenv()._CyberDragon_Originals.GetViewModelImage then
            getgenv()._CyberDragon_Originals.GetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
            local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
            ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
                if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
                local weaponName = weaponData.Name
                local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == plr and equipped[weaponName] and equipped[weaponName].Skin)
                if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                    local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
                    if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
                end
                return originalGetViewModelImage(self, weaponData, highRes)
            end
        end

        pcall(function()
            local ViewProfile = require(plr.PlayerScripts.Modules.Pages.ViewProfile)
            if ViewProfile and ViewProfile.Fetch and not getgenv()._CyberDragon_Originals.ViewProfileFetch then
                getgenv()._CyberDragon_Originals.ViewProfileFetch = ViewProfile.Fetch
                local originalFetch = ViewProfile.Fetch
                ViewProfile.Fetch = function(self, targetPlayer)
                    viewingProfile = targetPlayer
                    return originalFetch(self, targetPlayer)
                end
            end
        end)

        local ClientEntity
        pcall(function() ClientEntity = require(plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity) end)
        if ClientEntity and ClientEntity.ReplicateFromServer and not getgenv()._CyberDragon_Originals.ClientEntityReplicate then
            getgenv()._CyberDragon_Originals.ClientEntityReplicate = ClientEntity.ReplicateFromServer
            local originalReplicateFromServer = ClientEntity.ReplicateFromServer
            ClientEntity.ReplicateFromServer = function(self, action, ...)
                if action == "FinisherEffect" then
                    local args = {...}
                    local killerName = args[3]
                    local decodedKiller = killerName
                    if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                        local ok, decoded = pcall(EnumLibrary.FromEnum, EnumLibrary, killerName)
                        if ok and decoded then decodedKiller = decoded end
                    end
                    local isOurKill = tostring(decodedKiller) == plr.Name or tostring(decodedKiller):lower() == plr.Name:lower()
                    if isOurKill and lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                        local finisherData = equipped[lastUsedWeapon].Finisher
                        local finisherEnum = finisherData.Enum
                        if not finisherEnum and EnumLibrary then
                            local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, finisherData.Name)
                            if ok and result then finisherEnum = result end
                        end
                        if finisherEnum then
                            args[4] = finisherEnum
                            return originalReplicateFromServer(self, action, unpack(args))
                        end
                    end
                end
                return originalReplicateFromServer(self, action, ...)
            end
        end

        loadConfig()
        getgenv()._CyberDragon_unlockRan = true
        print("All cosmetics unlocked!")
    end

    -- ========== SERVICES & STATE ==========
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local plr = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local state = {
        NoRecoil = false, NoSpread = false, AutoDrop = false, ESP = false,
        ThirdPerson = false, AntiKatana = false, NoBounds = false, JumpBug = false,
        AutoStrafe = false, RapidFire = false, AutoWeapon = false, InstantScope = false,
        AlwaysBackstab = false, RemoveKillers = false, NoFireDamage = false,
        AntiFreeze = false, Fly = false, Noclip = false, AntiAim = false,
        AutoFarm = false, TornadoAnim = false, HitNotif = true, NoAnimation = false
    }
    local settings = {WalkSpeed = 16, JumpPower = 50, StrafeIntensity = 50, FlySpeed = 50, TornadoAnimSpeed = 1}
    local farmPosition = "Behind"

-- ========== WEAPON MODS (OPTIMIZED - NO LAG) ==========

getgenv()._CyberDragon_WeaponModConnection = nil

-- Weapon Mods - Reliable Approach
-- Instead of caching tables (which may become stale), we scan getgc every time
-- This is slightly slower but guarantees we find the CURRENT weapon data tables

-- Store original values for restoration
local _weaponModData = {}

-- ========== OPTIMIZED getgc SCANNING (NO TIMEOUT) ==========
local _weaponTableCache = {}
local _lastScanTime = 0
local CACHE_DURATION = 5
local SCAN_YIELD_INTERVAL = 1000

-- Scan getgc with yielding to prevent timeout
local function findWeaponTablesAsync(propertyName)
    local found = {}
    local count = 0
    local gcObjects = getgc(true)

    for _, gcVal in pairs(gcObjects) do
        if type(gcVal) == "table" then
            local val = rawget(gcVal, propertyName)
            if val ~= nil and type(val) == "number" then
                table.insert(found, gcVal)
            end
        end

        count = count + 1
        if count % SCAN_YIELD_INTERVAL == 0 then
            task.wait() -- Yield to prevent timeout
        end
    end

    return found
end

-- Cached wrapper for findWeaponTables
local function findWeaponTables(propertyName)
    local now = tick()
    local cacheKey = propertyName

    -- Check cache first
    if _weaponTableCache[cacheKey] and (now - _lastScanTime) < CACHE_DURATION then
        return _weaponTableCache[cacheKey]
    end

    -- Run async scan in background
    local scanResults = nil
    task.spawn(function()
        scanResults = findWeaponTablesAsync(propertyName)
        _weaponTableCache[cacheKey] = scanResults
        _lastScanTime = now
    end)

    -- Wait for results with timeout protection
    local waitStart = tick()
    while not scanResults and (tick() - waitStart) < 2 do
        task.wait(0.05)
    end

    return scanResults or {}
end

-- Clear cache on weapon change
local function clearWeaponCache()
    _weaponTableCache = {}
    _lastScanTime = 0
end

-- Apply a mod: set property to 0 and store original for restoration
-- Stores direct table references so we can restore even if getgc finds different tables later
local function applyMod(propertyName)
    local tables = findWeaponTables(propertyName)
    _weaponModData[propertyName] = _weaponModData[propertyName] or {}

    for _, tbl in ipairs(tables) do
        -- Check if we already tracked this table
        local alreadyTracked = false
        for _, entry in ipairs(_weaponModData[propertyName]) do
            if entry.tbl == tbl then
                alreadyTracked = true
                break
            end
        end

        if not alreadyTracked then
            table.insert(_weaponModData[propertyName], {
                tbl = tbl,
                original = rawget(tbl, propertyName)
            })
        end

        rawset(tbl, propertyName, 0)
    end
end

-- Restore a mod: set property back to original using stored table references
local function restoreMod(propertyName)
    local entries = _weaponModData[propertyName]
    if not entries then return end

    for i = #entries, 1, -1 do
        local entry = entries[i]
        -- Use pcall because the table might have been garbage collected
        local ok = pcall(function()
            if entry.tbl and type(entry.tbl) == "table" then
                rawset(entry.tbl, propertyName, entry.original)
            end
        end)
        if not ok then
            -- Table was garbage collected, remove from tracking
            table.remove(entries, i)
        end
    end
end

-- Full restore: restore ALL known properties
local function restoreAllMods()
    restoreMod("ShootRecoil")
    restoreMod("ShootSpread")
    restoreMod("ShootCooldown")
    restoreMod("ScopeTime")
end

-- Apply all enabled mods
local function applyAllMods()
    if state.NoRecoil then applyMod("ShootRecoil") else restoreMod("ShootRecoil") end
    if state.NoSpread then applyMod("ShootSpread") else restoreMod("ShootSpread") end
    if state.RapidFire then applyMod("ShootCooldown") else restoreMod("ShootCooldown") end
    if state.InstantScope then applyMod("ScopeTime") else restoreMod("ScopeTime") end
end

-- Start weapon mods: apply enabled mods and start heartbeat
local function startWeaponMods()
    task.spawn(function()
        applyAllMods()
    end)

    -- Start heartbeat that continuously applies/restores
    if getgenv()._CyberDragon_WeaponModConnection then
        getgenv()._CyberDragon_WeaponModConnection:Disconnect()
        getgenv()._CyberDragon_WeaponModConnection = nil
    end
    getgenv()._CyberDragon_WeaponModConnection = addConnection(RunService.Heartbeat:Connect(function()
        applyAllMods()
    end))
end

-- Stop weapon mods: restore everything and stop heartbeat
local function stopWeaponMods()
    if getgenv()._CyberDragon_WeaponModConnection then
        getgenv()._CyberDragon_WeaponModConnection:Disconnect()
        getgenv()._CyberDragon_WeaponModConnection = nil
    end
    clearWeaponCache() -- Clear cached weapon tables
    restoreAllMods()
end

-- For weapon re-equip events
local function rescanAndApply()
    clearWeaponCache()
    task.spawn(function()
        task.wait(0.1) -- Small delay for weapon to initialize
        applyAllMods()
    end)
end

-- Apply when equipping new weapons (rescans once, then uses cache)
addConnection(plr.CharacterAdded:Connect(function(char)
    addConnection(char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.15)
            rescanAndApply()
        end
    end))
end))
if plr.Character then
    addConnection(plr.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.15)
            rescanAndApply()
        end
    end))
end

    -- Auto Weapon
    getgenv()._CDautoWeapConn = nil
    local function enableAutoWeapon()
        if getgenv()._CDautoWeapConn then return end
        getgenv()._CDautoWeapConn = addConnection(RunService.Heartbeat:Connect(function()
            if not state.AutoWeapon then return end
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
            local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end))
    end
    local function disableAutoWeapon()
        if getgenv()._CDautoWeapConn then getgenv()._CDautoWeapConn:Disconnect(); getgenv()._CDautoWeapConn = nil end
    end

    -- Always Backstab
    local function applyAlwaysBackstab(char)
        if not state.AlwaysBackstab then return end
        if not char:FindFirstChild("BackstabBonus") then
            local flag = Instance.new("BoolValue")
            flag.Name = "BackstabBonus"
            flag.Value = true
            flag.Parent = char
        end
    end
    addConnection(plr.CharacterAdded:Connect(applyAlwaysBackstab))
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            addConnection(p.CharacterAdded:Connect(applyAlwaysBackstab))
            if p.Character then applyAlwaysBackstab(p.Character) end
        end
    end
    if plr.Character then applyAlwaysBackstab(plr.Character) end

    -- Anti Katana
    getgenv()._CDantiKatConn = nil
    local function enableAntiKatana()
        if getgenv()._CDantiKatConn then return end
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if not remotes then return end
        local parryRemote = remotes:FindFirstChild("Parry") or remotes:FindFirstChild("KatanaParry")
        if parryRemote then getgenv()._CDantiKatConn = addConnection(parryRemote.OnClientEvent:Connect(function() end)) end
    end
    local function disableAntiKatana()
        if getgenv()._CDantiKatConn then getgenv()._CDantiKatConn:Disconnect(); getgenv()._CDantiKatConn = nil end
    end

    -- ========== MOVEMENT ==========
    -- Fly
    getgenv()._CDflyConn, getgenv()._CDflyVel, getgenv()._CDflyGyro = nil, nil, nil
    local function enableFly()
        local char = plr.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        hum.PlatformStand = true
        getgenv()._CDflyVel = Instance.new("BodyVelocity")
        getgenv()._CDflyVel.Velocity = Vector3.zero
        getgenv()._CDflyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        getgenv()._CDflyVel.P = 10000
        getgenv()._CDflyVel.Parent = hrp
        getgenv()._CDflyGyro = Instance.new("BodyGyro")
        getgenv()._CDflyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        getgenv()._CDflyGyro.P = 10000
        getgenv()._CDflyGyro.D = 100
        getgenv()._CDflyGyro.CFrame = hrp.CFrame
        getgenv()._CDflyGyro.Parent = hrp
        getgenv()._CDflyConn = addConnection(RunService.RenderStepped:Connect(function()
            if not state.Fly then return end
            local c = plr.Character
            if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local speed = settings.FlySpeed
            local dir = Vector3.zero
            local camCF = camera.CFrame
            local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
            local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir = dir - Vector3.new(0, 1, 0)
            end
            if dir.Magnitude > 0 then
                getgenv()._CDflyVel.Velocity = dir.Unit * speed
            else
                getgenv()._CDflyVel.Velocity = Vector3.zero
            end
            getgenv()._CDflyGyro.CFrame = camCF
        end))
    end
    local function disableFly()
        if getgenv()._CDflyConn then getgenv()._CDflyConn:Disconnect(); getgenv()._CDflyConn = nil end
        if getgenv()._CDflyVel then getgenv()._CDflyVel:Destroy(); getgenv()._CDflyVel = nil end
        if getgenv()._CDflyGyro then getgenv()._CDflyGyro:Destroy(); getgenv()._CDflyGyro = nil end
        if plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    -- Noclip
    getgenv()._CDnoclipConn = nil
    local function enableNoclip()
        if getgenv()._CDnoclipConn then return end
        getgenv()._CDnoclipConn = addConnection(RunService.Stepped:Connect(function()
            if not state.Noclip then return end
            local char = plr.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end))
    end
    local function disableNoclip()
        if getgenv()._CDnoclipConn then getgenv()._CDnoclipConn:Disconnect(); getgenv()._CDnoclipConn = nil end
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end

    -- AntiAim
    getgenv()._CDaaConn = nil
    local aaAngle = 0
    local function enableAntiAim()
        if getgenv()._CDaaConn then return end
        aaAngle = 0
        getgenv()._CDaaConn = addConnection(RunService.Heartbeat:Connect(function()
            if not state.AntiAim then return end
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            aaAngle = (aaAngle + 25) % 360
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.pi, math.rad(aaAngle), 0)
        end))
    end
    local function disableAntiAim()
        if getgenv()._CDaaConn then getgenv()._CDaaConn:Disconnect(); getgenv()._CDaaConn = nil end
    end

    -- AutoStrafe
    getgenv()._CDstrafeConn = nil
    local strafeDir, strafeTick = 1, 0
    local function enableAutoStrafe()
        if getgenv()._CDstrafeConn then return end
        strafeDir, strafeTick = 1, 0
        getgenv()._CDstrafeConn = addConnection(RunService.Heartbeat:Connect(function()
            if not state.AutoStrafe then return end
            local char = plr.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                local now = tick()
                local interval = 0.3 - ((settings.StrafeIntensity / 100) * 0.25)
                if now - strafeTick > interval then
                    strafeTick = now
                    strafeDir = -strafeDir
                end
                local right = hrp.CFrame.RightVector
                local vel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(vel.X + (right.X * strafeDir * (settings.StrafeIntensity / 10)), vel.Y, vel.Z + (right.Z * strafeDir * (settings.StrafeIntensity / 10)))
            end
        end))
    end
    local function disableAutoStrafe()
        if getgenv()._CDstrafeConn then getgenv()._CDstrafeConn:Disconnect(); getgenv()._CDstrafeConn = nil end
    end

    -- JumpBug
    getgenv()._CDjbConn = nil
    local function enableJumpBug()
        if getgenv()._CDjbConn then return end
        getgenv()._CDjbConn = addConnection(RunService.Heartbeat:Connect(function()
            if not state.JumpBug then return end
            local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
    end
    local function disableJumpBug()
        if getgenv()._CDjbConn then getgenv()._CDjbConn:Disconnect(); getgenv()._CDjbConn = nil end
    end

    -- ========== TORNADO ANIMATION ==========
    local _addConnection = getgenv()._cd_addConnection or addConnection
    local _state = getgenv()._cd_state or state
    local _plr = getgenv()._cd_plr or plr
    local _settings = getgenv()._cd_settings or settings

    local function anim2track(asset_id)
        local objs = game:GetObjects(asset_id)
        for i = 1, #objs do
            if objs[i]:IsA("Animation") then
                return objs[i].AnimationId
            end
        end
        return asset_id
    end

    local animid = "134029227396704"
    if not animid:find("rbxassetid://") then
        animid = "rbxassetid://" .. animid
    end
    animid = anim2track(animid)

    local tornadoAnimObj = Instance.new("Animation")
    tornadoAnimObj.AnimationId = animid
    getgenv()._CDtornadoTrack = nil

    local function _playTornadoAnim(character)
        local hum = character:FindFirstChildWhichIsA("Humanoid")
        if not hum then return end
        for _, track in next, hum:GetPlayingAnimationTracks() do track:Stop() end
        getgenv()._CDtornadoTrack = hum:LoadAnimation(tornadoAnimObj)
        getgenv()._CDtornadoTrack.Priority = Enum.AnimationPriority.Action4
        getgenv()._CDtornadoTrack:Play()
        getgenv()._CDtornadoTrack:AdjustSpeed(_settings.TornadoAnimSpeed)
        _addConnection(getgenv()._CDtornadoTrack.Stopped:Connect(function()
            if _state.TornadoAnim and _plr.Character then
                _playTornadoAnim(_plr.Character)
            end
        end))
    end

    local function _enableTornadoAnim()
        local char = _plr.Character
        if char then _playTornadoAnim(char) end
    end

    local function _disableTornadoAnim()
        if getgenv()._CDtornadoTrack then
            getgenv()._CDtornadoTrack:Stop()
            getgenv()._CDtornadoTrack = nil
        end
    end

    local function _updateTornadoSpeed()
        if getgenv()._CDtornadoTrack and _state.TornadoAnim then
            getgenv()._CDtornadoTrack:AdjustSpeed(_settings.TornadoAnimSpeed)
        end
    end


    -- ========== NO ANIMATION (VIEWMODEL) ==========
    local NoAnimState = { Enabled = false, WaitTime = 0.80, SavedGuns = {} }
    getgenv()._CDnoAnimConn = nil

    local function _fixGunPosition(gun)
        local hrp = gun:FindFirstChild("HumanoidRootPart") or gun:FindFirstChild("Handle")
        if hrp then
            hrp.CFrame = camera.CFrame * CFrame.new(0, -0.5, -1.5)
        end
        for _, part in pairs(gun:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.AnimationId = "" end)
            end
        end
    end

    local function _removeAnims(gun)
        for _, obj in pairs(gun:GetDescendants()) do
            if obj:IsA("Animator") or obj:IsA("Animation") or obj:IsA("AnimationTrack") then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    local function _processGunNoAnim(gun)
        if not NoAnimState.SavedGuns[gun] then
            NoAnimState.SavedGuns[gun] = false
            task.wait(NoAnimState.WaitTime)
            _removeAnims(gun)
            _fixGunPosition(gun)
            NoAnimState.SavedGuns[gun] = true
        else
            _removeAnims(gun)
            _fixGunPosition(gun)
        end
    end

    local function _checkWeaponsNoAnim()
        local firstPerson = workspace:FindFirstChild("ViewModels")
        if not firstPerson then return end
        local fpFolder = firstPerson:FindFirstChild("FirstPerson")
        if not fpFolder then return end
        for _, gun in pairs(fpFolder:GetChildren()) do
            if gun:IsA("Model") then
                _processGunNoAnim(gun)
            end
        end
    end

    local function _enableNoAnimation()
        if getgenv()._CDnoAnimConn then return end
        getgenv()._CDnoAnimConn = addConnection(RunService.RenderStepped:Connect(function()
            if NoAnimState.Enabled then
                _checkWeaponsNoAnim()
            end
        end))
    end

    local function _disableNoAnimation()
        if getgenv()._CDnoAnimConn then
            getgenv()._CDnoAnimConn:Disconnect()
            getgenv()._CDnoAnimConn = nil
        end
        NoAnimState.SavedGuns = {}
    end

    local function _updateNoAnimWaitTime(val)
        NoAnimState.WaitTime = val
    end

    -- Third Person
    getgenv()._CDtpConn = nil
    getgenv()._CDoriginalCamType = nil
    local function enableThirdPerson()
        if getgenv()._CDtpConn then return end
        local char = plr.Character
        if not char then return end
        if not getgenv()._CDoriginalCamType then getgenv()._CDoriginalCamType = camera.CameraType end
        camera.CameraType = Enum.CameraType.Scriptable
        getgenv()._CDtpConn = addConnection(RunService.RenderStepped:Connect(function()
            if not state.ThirdPerson then return end
            local c = plr.Character
            if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            camera.CFrame = CFrame.new(hrp.Position - hrp.CFrame.LookVector*12 + Vector3.new(0,4,0), hrp.Position + Vector3.new(0,2,0))
        end))
    end
    local function disableThirdPerson()
        if getgenv()._CDtpConn then getgenv()._CDtpConn:Disconnect(); getgenv()._CDtpConn = nil end
        if getgenv()._CDoriginalCamType then camera.CameraType = getgenv()._CDoriginalCamType; getgenv()._CDoriginalCamType = nil end
    end

    -- World Protections
    local function enableNoBounds()
        local folder = workspace:FindFirstChild("OutOfBounds") or workspace:FindFirstChild("DeathZones")
        if folder then for _, z in ipairs(folder:GetChildren()) do if z:IsA("BasePart") then z.CanTouch = false end end end
    end
    local function enableRemoveKillers()
        local obj = workspace:FindFirstChild("Killer") or workspace:FindFirstChild("Death")
        if obj then obj:Destroy() end
    end
    local function enableNoFireDamage()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("fire") then v.CanTouch = false end
        end
    end
    local function enableAntiFreeze()
        task.spawn(function()
            local lastSpeed = 16
            while state.AntiFreeze do
                local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
                if hum then
                    if hum.WalkSpeed == 0 then hum.WalkSpeed = lastSpeed end
                    lastSpeed = hum.WalkSpeed
                end
                task.wait(0.2)
            end
        end)
    end

    -- Auto Farm
    getgenv()._CDfarmConn = nil
    local function enableAutoFarm()
        if getgenv()._CDfarmConn then return end
        getgenv()._CDfarmConn = addConnection(RunService.Heartbeat:Connect(function()
            if not state.AutoFarm then return end
            local char = plr.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local closest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= plr and p.Character then
                    local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if tHrp and hum and hum.Health > 0 then
                        local d = (tHrp.Position - hrp.Position).Magnitude
                        if d < dist then closest = p; dist = d end
                    end
                end
            end
            if closest and closest.Character then
                local tHrp = closest.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local offset = farmPosition == "Above" and Vector3.new(0,6,0) or (farmPosition == "Under" and Vector3.new(0,-3,0)) or (-tHrp.CFrame.LookVector*3 + Vector3.new(0,0.5,0))
                    hrp.CFrame = CFrame.new(tHrp.Position + offset, tHrp.Position)
                end
            end
        end))
    end
    local function disableAutoFarm()
        if getgenv()._CDfarmConn then getgenv()._CDfarmConn:Disconnect(); getgenv()._CDfarmConn = nil end
    end

    -- Auto Drop Collector
    local drops = {}
    addConnection(workspace.ChildAdded:Connect(function(c) if c.Name == "_drop" then drops[c] = true end end))
    addConnection(workspace.ChildRemoved:Connect(function(c) drops[c] = nil end))
    for _, c in pairs(workspace:GetChildren()) do if c.Name == "_drop" then drops[c] = true end end
    addConnection(RunService.Heartbeat:Connect(function()
        if not state.AutoDrop then return end
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for obj in pairs(drops) do
            if obj.Parent then
                pcall(function() firetouchinterest(hrp, obj, 0) end)
                pcall(function() firetouchinterest(hrp, obj, 1) end)
            end
        end
    end))

    -- ========== ESP (OPTIMIZED & FREEZE-FIXED) ==========
    getgenv()._CDespObjects = {}
    local espSettings = {
        BoxType = "Corner",
        ShowTracers = true,
        ShowSkeleton = false,
        ShowChams = false,
        ShowWeapon = true,
        ShowRank = false,
        MaxDistance = 1000,
        FadeDistance = 500,
        TeamCheck = false,
        BoxColor = Color3.fromRGB(128, 213, 247),
        VisibleColor = Color3.fromRGB(0, 255, 128),
        HiddenColor = Color3.fromRGB(255, 50, 50),
        TextColor = Color3.new(1, 1, 1),
        TracerColor = Color3.fromRGB(128, 213, 247),
        TracerOrigin = "Bottom",
        ChamColor = Color3.fromRGB(128, 213, 247),
        ChamTransparency = 0.5,
        MaxPlayers = 8
    }

    local drawingSupported = pcall(function() return Drawing.new("Square") end)
    getgenv()._CDchamObjects = {}
    getgenv()._CDespUpdateConnection = nil
    local visibilityCache = {}

    if drawingSupported then
        local function newDrawing(t, props)
            local d = Drawing.new(t)
            for k,v in pairs(props) do d[k] = v end
            return d
        end

        local function createESP(p)
            if getgenv()._CDespObjects[p] then return end

            local baseColor = espSettings.BoxColor
            local esp = {
                box = newDrawing("Square", {Visible = false, Color = baseColor, Thickness = 1.5, Filled = false, Transparency = 1}),
                boxOutline = newDrawing("Square", {Visible = false, Color = Color3.new(0,0,0), Thickness = 3, Filled = false, Transparency = 0.5}),
                name = newDrawing("Text", {Visible = false, Color = espSettings.TextColor, Size = 13, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2}),
                dist = newDrawing("Text", {Visible = false, Color = Color3.fromRGB(200,200,200), Size = 11, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2}),
                weapon = newDrawing("Text", {Visible = false, Color = Color3.fromRGB(255,200,100), Size = 10, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2}),
                hpBg = newDrawing("Square", {Visible = false, Color = Color3.new(0.1,0.1,0.1), Filled = true, Transparency = 0.8}),
                hp = newDrawing("Square", {Visible = false, Color = baseColor, Filled = true, Transparency = 1}),
                hpText = newDrawing("Text", {Visible = false, Color = Color3.new(1,1,1), Size = 10, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2}),
                tracer = newDrawing("Line", {Visible = false, Color = espSettings.TracerColor, Thickness = 1.5, Transparency = 1}),
                tracerOutline = newDrawing("Line", {Visible = false, Color = Color3.new(0,0,0), Thickness = 3.5, Transparency = 0.5}),
                cornerTL_H = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerTL_V = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerTR_H = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerTR_V = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerBL_H = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerBL_V = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerBR_H = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerBR_V = newDrawing("Line", {Visible = false, Color = baseColor, Thickness = 1.5}),
                cornerSize = 6,
            }

            getgenv()._CDespObjects[p] = esp
        end

        local function removeESP(p)
            if getgenv()._CDespObjects[p] then
                for k,v in pairs(getgenv()._CDespObjects[p]) do
                    if k ~= "cornerSize" and v and v.Remove then
                        pcall(function() v:Remove() end)
                    end
                end
                getgenv()._CDespObjects[p] = nil
            end

            if getgenv()._CDchamObjects[p] then
                for _, cham in pairs(getgenv()._CDchamObjects[p]) do
                    if cham then pcall(function() cham:Destroy() end) end
                end
                getgenv()._CDchamObjects[p] = nil
            end

            visibilityCache[p] = nil
        end

        local function hideESP(p)
            if not getgenv()._CDespObjects[p] then return end
            local esp = getgenv()._CDespObjects[p]
            for k, v in pairs(esp) do
                if k ~= "cornerSize" and v and type(v) == "table" and v.Visible ~= nil then
                    pcall(function() v.Visible = false end)
                end
            end
        end

        local function getBounds(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local cnt = 0
            for _, off in ipairs({Vector3.new(2,3,2),Vector3.new(-2,3,-2),Vector3.new(2,3,-2),Vector3.new(-2,3,2),Vector3.new(2,-3,2),Vector3.new(-2,-3,-2),Vector3.new(2,-3,-2),Vector3.new(-2,-3,2)}) do
                local sp, on = camera:WorldToViewportPoint(hrp.Position + off)
                if on then
                    cnt = cnt + 1
                    minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                end
            end
            if cnt == 0 then return nil end
            return minX, minY, maxX, maxY, (minX+maxX)/2
        end

        local function checkVisibility(p, char, dist)
            local now = tick()
            local cache = visibilityCache[p]
            if cache and (now - cache.time) < 0.2 then
                return cache.visible
            end

            local head = char:FindFirstChild("Head")
            if not head then return false end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {plr.Character, char, camera}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = workspace:Raycast(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * dist, rayParams)
            local visible = not rayResult or rayResult.Instance:IsDescendantOf(char)

            visibilityCache[p] = {time = now, visible = visible}
            return visible
        end

        local function getWeaponName(char)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then return tool.Name end
            local player = Players:GetPlayerFromCharacter(char)
            if player and player:FindFirstChild("Backpack") then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then return item.Name end
                end
            end
            return nil
        end

        local function updateCham(p, char, visible)
            if not espSettings.ShowChams then
                if getgenv()._CDchamObjects[p] then
                    for _, cham in pairs(getgenv()._CDchamObjects[p]) do
                        if cham then pcall(function() cham:Destroy() end) end
                    end
                    getgenv()._CDchamObjects[p] = nil
                end
                return
            end

            if not getgenv()._CDchamObjects[p] then getgenv()._CDchamObjects[p] = {} end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.Name:find("Camera") then
                    if not getgenv()._CDchamObjects[p][part] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "CyberDragon_Cham"
                        highlight.FillColor = espSettings.ChamColor
                        highlight.OutlineColor = espSettings.ChamColor
                        highlight.FillTransparency = espSettings.ChamTransparency
                        highlight.OutlineTransparency = 0
                        highlight.Adornee = part
                        highlight.Parent = part
                        getgenv()._CDchamObjects[p][part] = highlight
                    end
                    local cham = getgenv()._CDchamObjects[p][part]
                    if cham then
                        cham.Enabled = visible
                        cham.FillColor = espSettings.ChamColor
                    end
                end
            end
        end

        local function updateESP(p)
            local esp = getgenv()._CDespObjects[p]
            if not esp then 
                if p.Character then
                    createESP(p)
                    esp = getgenv()._CDespObjects[p]
                end
                if not esp then return end
            end

            local char = p.Character
            if not char then hideESP(p); return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            if not hrp or not hum or not head then hideESP(p); return end

            local myHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then hideESP(p); return end

            local dist = (hrp.Position - myHrp.Position).Magnitude
            if dist > espSettings.MaxDistance then hideESP(p); return end

            local fadeAlpha = 1
            if dist > espSettings.FadeDistance then
                fadeAlpha = math.clamp(1 - ((dist - espSettings.FadeDistance) / (espSettings.MaxDistance - espSettings.FadeDistance)), 0.2, 1)
            end

            if espSettings.TeamCheck and p.Team == plr.Team then
                hideESP(p)
                return
            end

            local isVisible = checkVisibility(p, char, dist)
            local boxColor = isVisible and espSettings.VisibleColor or espSettings.HiddenColor

            updateCham(p, char, state.ESP)

            local x1, y1, x2, y2, cx = getBounds(char)
            if not x1 then hideESP(p); return end

            local boxW, boxH = x2 - x1, y2 - y1
            local cornerSize = math.min(esp.cornerSize or 6, boxW / 3, boxH / 3)
            local hpFrac = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

            if espSettings.BoxType == "Full" then
                esp.boxOutline.Position = Vector2.new(x1, y1)
                esp.boxOutline.Size = Vector2.new(boxW, boxH)
                esp.boxOutline.Visible = state.ESP
                esp.boxOutline.Transparency = fadeAlpha * 0.5

                esp.box.Position = Vector2.new(x1, y1)
                esp.box.Size = Vector2.new(boxW, boxH)
                esp.box.Color = boxColor
                esp.box.Visible = state.ESP
                esp.box.Transparency = fadeAlpha

                for _, corner in pairs({"cornerTL_H", "cornerTL_V", "cornerTR_H", "cornerTR_V", 
                                          "cornerBL_H", "cornerBL_V", "cornerBR_H", "cornerBR_V"}) do
                    if esp[corner] then esp[corner].Visible = false end
                end

            elseif espSettings.BoxType == "Corner" then
                esp.box.Visible = false
                esp.boxOutline.Visible = false

                local corners = {
                    {h1 = {x1, y1, x1 + cornerSize, y1}, v1 = {x1, y1, x1, y1 + cornerSize}},
                    {h1 = {x2 - cornerSize, y1, x2, y1}, v1 = {x2, y1, x2, y1 + cornerSize}},
                    {h1 = {x1, y2, x1 + cornerSize, y2}, v1 = {x1, y2 - cornerSize, x1, y2}},
                    {h1 = {x2 - cornerSize, y2, x2, y2}, v1 = {x2, y2 - cornerSize, x2, y2}},
                }

                local cornerNames = {"cornerTL", "cornerTR", "cornerBL", "cornerBR"}
                for i, cornerName in ipairs(cornerNames) do
                    local corner = corners[i]
                    local horizLine = esp[cornerName .. "_H"]
                    local vertLine = esp[cornerName .. "_V"]
                    if horizLine then
                        horizLine.From = Vector2.new(corner.h1[1], corner.h1[2])
                        horizLine.To = Vector2.new(corner.h1[3], corner.h1[4])
                        horizLine.Color = boxColor
                        horizLine.Visible = state.ESP
                        horizLine.Transparency = fadeAlpha
                    end
                    if vertLine then
                        vertLine.From = Vector2.new(corner.v1[1], corner.v1[2])
                        vertLine.To = Vector2.new(corner.v1[3], corner.v1[4])
                        vertLine.Color = boxColor
                        vertLine.Visible = state.ESP
                        vertLine.Transparency = fadeAlpha
                    end
                end
            end

            esp.name.Text = p.DisplayName
            esp.name.Position = Vector2.new(cx, y1 - 20)
            esp.name.Color = isVisible and espSettings.TextColor or Color3.fromRGB(150, 150, 150)
            esp.name.Visible = state.ESP
            esp.name.Transparency = fadeAlpha

            esp.dist.Text = math.floor(dist) .. "m"
            esp.dist.Position = Vector2.new(cx, y2 + 4)
            esp.dist.Visible = state.ESP
            esp.dist.Transparency = fadeAlpha

            local weaponName = getWeaponName(char)
            if weaponName and espSettings.ShowWeapon then
                esp.weapon.Text = "[" .. weaponName .. "]"
                esp.weapon.Position = Vector2.new(cx, y2 + 16)
                esp.weapon.Visible = state.ESP
                esp.weapon.Transparency = fadeAlpha
            else
                esp.weapon.Visible = false
            end

            local barW = 4
            local barOffset = 8
            local hpColor = Color3.new(2*(1-hpFrac), 2*hpFrac, 0)
            local barH = boxH * hpFrac

            esp.hpBg.Position = Vector2.new(x1 - barOffset, y1)
            esp.hpBg.Size = Vector2.new(barW, boxH)
            esp.hpBg.Visible = state.ESP
            esp.hpBg.Transparency = fadeAlpha * 0.8

            esp.hp.Position = Vector2.new(x1 - barOffset, y1 + boxH - barH)
            esp.hp.Size = Vector2.new(barW, barH)
            esp.hp.Color = hpColor
            esp.hp.Visible = state.ESP
            esp.hp.Transparency = fadeAlpha

            esp.hpText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
            esp.hpText.Position = Vector2.new(x1 - barOffset - 2, y1 + boxH / 2)
            esp.hpText.Visible = state.ESP
            esp.hpText.Transparency = fadeAlpha

            if espSettings.ShowTracers then
                local origin
                if espSettings.TracerOrigin == "Bottom" then
                    origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                elseif espSettings.TracerOrigin == "Center" then
                    origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                elseif espSettings.TracerOrigin == "Mouse" then
                    local mousePos = UserInputService:GetMouseLocation()
                    origin = Vector2.new(mousePos.X, mousePos.Y)
                end

                local targetPos = Vector2.new(cx, y2)

                esp.tracerOutline.From = origin
                esp.tracerOutline.To = targetPos
                esp.tracerOutline.Visible = state.ESP
                esp.tracerOutline.Transparency = fadeAlpha * 0.5

                esp.tracer.From = origin
                esp.tracer.To = targetPos
                esp.tracer.Color = boxColor
                esp.tracer.Visible = state.ESP
                esp.tracer.Transparency = fadeAlpha
            else
                esp.tracer.Visible = false
                esp.tracerOutline.Visible = false
            end
        end

        local function espUpdateLoop()
            if not state.ESP then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= plr then hideESP(p) end
                end
                return
            end

            local myHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end

            local targets = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= plr and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - myHrp.Position).Magnitude
                        if dist <= espSettings.MaxDistance then
                            table.insert(targets, {player = p, distance = dist})
                        end
                    end
                end
            end

            table.sort(targets, function(a, b) return a.distance < b.distance end)
            local renderCount = 0

            for _, target in ipairs(targets) do
                if renderCount >= espSettings.MaxPlayers then
                    hideESP(target.player)
                else
                    if not getgenv()._CDespObjects[target.player] then
                        createESP(target.player)
                    end
                    updateESP(target.player)
                    renderCount = renderCount + 1
                end
            end
        end

        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= plr and p.Character then
                createESP(p)
            end
        end

        addConnection(Players.PlayerAdded:Connect(function(p) 
            if p ~= plr then 
                if p.Character then
                    createESP(p)
                else
                    addConnection(p.CharacterAdded:Once(function()
                        task.wait(0.5)
                        createESP(p)
                    end))
                end
            end 
        end))

        addConnection(Players.PlayerRemoving:Connect(removeESP))

        getgenv()._CDespUpdateConnection = addConnection(RunService.RenderStepped:Connect(espUpdateLoop))
    end

    -- ========== EARLY ATTACK TRACKING ==========
    local lastAttackTime = 0
    addConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            lastAttackTime = tick()
        end
    end))
    addConnection(UserInputService.TouchTap:Connect(function()
        lastAttackTime = tick()
    end))

    local function _isAttacking()
        return (tick() - lastAttackTime) <= 0.4
    end

    -- ========== LINORIA UI LIBRARY SETUP ==========
local repo = "https://raw.githubusercontent.com/makarmatvij7-svg/LunoriaaLib/main/"

    local libOk, libResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "Library.lua"))()
    end)
    if not libOk or not libResult then
        warn("[Cyber Dragon] Failed to load UI library: " .. tostring(libResult))
        getgenv()._CyberDragon_Running = false
        getgenv()._CyberDragon_Reloading = false
        return
    end
    local Library = libResult

    local tmOk, ThemeManager = pcall(function()
        return loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    end)
    local smOk, SaveManager = pcall(function()
        return loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    end)
    if not tmOk then ThemeManager = nil end
    if not smOk then SaveManager = nil end

    getgenv()._CyberDragon_Library = Library

    local Options = getgenv().Options
    local _Toggles = getgenv().Toggles

    Library.NotifySide = "Middle"

    local Window = Library:CreateWindow({
        Title = "Cyber Dragon",
        Center = true,
        AutoShow = true,
        Resizable = true,
        ShowCustomCursor = false,
        UnlockMouseWhileOpen = true,
        NotifySide = "Middle",
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Combat = Window:AddTab("combat"),
        Movement = Window:AddTab("movement"),
        Visuals = Window:AddTab("visuals"),
        World = Window:AddTab("world"),
        Unlock = Window:AddTab("unlock"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    -- ========== COMBAT TAB ==========
    local CombatLeft = Tabs.Combat:AddLeftGroupbox("Weapon Mods")
    local CombatRight = Tabs.Combat:AddRightGroupbox("Combat Features")

CombatLeft:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false,
    Callback = function(Value)
        state.NoRecoil = Value
        if state.NoRecoil or state.NoSpread or state.RapidFire or state.InstantScope then
            startWeaponMods()
        else
            stopWeaponMods()
        end
    end
})

CombatLeft:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false,
    Callback = function(Value)
        state.NoSpread = Value
        if state.NoRecoil or state.NoSpread or state.RapidFire or state.InstantScope then
            startWeaponMods()
        else
            stopWeaponMods()
        end
    end
})

CombatLeft:AddToggle("RapidFire", {
    Text = "Rapid Fire",
    Default = false,
    Callback = function(Value)
        state.RapidFire = Value
        if state.NoRecoil or state.NoSpread or state.RapidFire or state.InstantScope then
            startWeaponMods()
        else
            stopWeaponMods()
        end
    end
})

CombatLeft:AddToggle("InstantScope", {
    Text = "Instant Scope",
    Default = false,
    Callback = function(Value)
        state.InstantScope = Value
        if state.NoRecoil or state.NoSpread or state.RapidFire or state.InstantScope then
            startWeaponMods()
        else
            stopWeaponMods()
        end
    end
})

    CombatLeft:AddToggle("AutoWeapon", {
        Text = "Auto Weapon",
        Default = false,
        Callback = function(Value)
            state.AutoWeapon = Value
            if Value then enableAutoWeapon() else disableAutoWeapon() end
        end
    })

    CombatLeft:AddToggle("AlwaysBackstab", {
        Text = "Always Backstab",
        Default = false,
        Callback = function(Value)
            state.AlwaysBackstab = Value
            if Value then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character then applyAlwaysBackstab(p.Character) end
                end
            end
        end
    })

    CombatLeft:AddToggle("AntiKatana", {
        Text = "Anti Katana",
        Default = false,
        Callback = function(Value)
            state.AntiKatana = Value
            if Value then enableAntiKatana() else disableAntiKatana() end
        end
    })

    CombatRight:AddButton({
        Text = "Load Silent Aim",
        Func = function()
            local ok = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/makarmatvij7-svg/SilentAim/refs/heads/main/Silentaim.lua"))()
            end)
            if ok then
                Library:Notify("Silent Aim loaded successfully!", 3)
            else
                Library:Notify("Failed to load Silent Aim!", 3)
            end
        end,
        DoubleClick = false,
        Tooltip = "Loads silent aim script"
    })

    CombatRight:AddToggle("AutoDrop", {
        Text = "Auto Drop Collector (in ffa)",
        Default = false,
        Callback = function(Value)
            state.AutoDrop = Value
        end
    })

    CombatRight:AddToggle("AutoFarm", {
        Text = "Auto Farm",
        Default = false,
        Callback = function(Value)
            state.AutoFarm = Value
            if Value then enableAutoFarm() else disableAutoFarm() end
        end
    })

    CombatRight:AddDropdown("FarmPosition", {
        Values = { "Behind", "Above", "Under" },
        Default = 1,
        Multi = false,
        Text = "Farm Position",
        Callback = function(Value)
            farmPosition = Value
        end
    })

    -- ========== MOVEMENT TAB ==========
    local MoveLeft = Tabs.Movement:AddLeftGroupbox("movement")
    local MoveRight = Tabs.Movement:AddRightGroupbox("Settings")

    MoveLeft:AddToggle("Fly", {
        Text = "Fly",
        Default = false,
        Callback = function(Value)
            state.Fly = Value
            if Value then enableFly() else disableFly() end
        end
    })

    MoveLeft:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false,
        Callback = function(Value)
            state.Noclip = Value
            if Value then enableNoclip() else disableNoclip() end
        end
    })

    MoveLeft:AddToggle("JumpBug", {
        Text = "Jump Bug",
        Default = false,
        Callback = function(Value)
            state.JumpBug = Value
            if Value then enableJumpBug() else disableJumpBug() end
        end
    })

    MoveLeft:AddToggle("AutoStrafe", {
        Text = "Auto Strafe",
        Default = false,
        Callback = function(Value)
            state.AutoStrafe = Value
            if Value then enableAutoStrafe() else disableAutoStrafe() end
        end
    })

    MoveLeft:AddToggle("AntiAim", {
        Text = "Anti Aim",
        Default = false,
        Callback = function(Value)
            state.AntiAim = Value
            if Value then enableAntiAim() else disableAntiAim() end
        end
    })

    MoveLeft:AddToggle("TornadoAnim", {
        Text = "Tornado Animation",
        Default = false,
        Callback = function(Value)
            _state.TornadoAnim = Value
            if Value then _enableTornadoAnim() else _disableTornadoAnim() end
        end
    })

    MoveLeft:AddSlider("TornadoSpeed", {
        Text = "Tornado Speed",
        Default = 1,
        Min = 0.5,
        Max = 5,
        Rounding = 1,
        Callback = function(Value)
            _settings.TornadoAnimSpeed = Value
            _updateTornadoSpeed()
        end
    })

    MoveLeft:AddToggle("NoAnimation", {
        Text = "No Animation",
        Default = false,
        Callback = function(Value)
            NoAnimState.Enabled = Value
            if Value then _enableNoAnimation() else _disableNoAnimation() end
        end
    })

    MoveLeft:AddSlider("NoAnimWaitTime", {
        Text = "No Anim Wait Time",
        Default = 0.80,
        Min = 0.1,
        Max = 2.0,
        Rounding = 2,
        Callback = function(Value)
            _updateNoAnimWaitTime(Value)
        end
    })


    MoveRight:AddSlider("WalkSpeed", {
        Text = "Walk Speed",
        Default = 16,
        Min = 1,
        Max = 150,
        Rounding = 0,
        Callback = function(Value)
            settings.WalkSpeed = Value
            local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = Value end
        end
    })

    MoveRight:AddSlider("JumpPower", {
        Text = "Jump Power",
        Default = 50,
        Min = 1,
        Max = 200,
        Rounding = 0,
        Callback = function(Value)
            settings.JumpPower = Value
            local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = Value end
        end
    })

    MoveRight:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 50,
        Min = 0,
        Max = 1000,
        Rounding = 0,
        Callback = function(Value)
            settings.FlySpeed = Value
        end
    })

    MoveRight:AddSlider("StrafeIntensity", {
        Text = "Strafe Intensity",
        Default = 50,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            settings.StrafeIntensity = Value
        end
    })

    -- ========== VISUALS TAB ==========
    local VisualLeft = Tabs.Visuals:AddLeftGroupbox("Player Visuals")

    VisualLeft:AddToggle("ESP", {
        Text = "ESP",
        Default = false,
        Callback = function(Value)
            state.ESP = Value
        end
    })

    VisualLeft:AddToggle("ThirdPerson", {
        Text = "Third Person",
        Default = false,
        Callback = function(Value)
            state.ThirdPerson = Value
            if Value then enableThirdPerson() else disableThirdPerson() end
        end
    })

    VisualLeft:AddToggle("HitNotif", {
        Text = "Hit Notifications",
        Default = false,
        Callback = function(Value)
            state.HitNotif = Value
        end
    })

    VisualLeft:AddDropdown("ESPBoxType", {
        Values = { "Corner", "Full" },
        Default = 1,
        Multi = false,
        Text = "Box Type",
        Callback = function(Value)
            espSettings.BoxType = Value
        end
    })

    VisualLeft:AddToggle("ESPTracers", {
        Text = "Show Tracers",
        Default = false,
        Callback = function(Value)
            espSettings.ShowTracers = Value
        end
    })

    VisualLeft:AddDropdown("ESPTracerOrigin", {
        Values = { "Bottom", "Center", "Mouse" },
        Default = 1,
        Multi = false,
        Text = "Tracer Origin",
        Callback = function(Value)
            espSettings.TracerOrigin = Value
        end
    })

    VisualLeft:AddToggle("ESPSkeleton", {
        Text = "Show Skeleton",
        Default = false,
        Callback = function(Value)
            espSettings.ShowSkeleton = Value
        end
    })

    VisualLeft:AddToggle("ESPChams", {
        Text = "Show Chams",
        Default = false,
        Callback = function(Value)
            espSettings.ShowChams = Value
        end
    })

    VisualLeft:AddToggle("ESPWeapon", {
        Text = "Show Weapon",
        Default = false,
        Callback = function(Value)
            espSettings.ShowWeapon = Value
        end
    })

    VisualLeft:AddToggle("ESPTeamCheck", {
        Text = "Team Check",
        Default = false,
        Callback = function(Value)
            espSettings.TeamCheck = Value
        end
    })

    VisualLeft:AddSlider("ESPMaxDistance", {
        Text = "Max Distance",
        Default = 1000,
        Min = 100,
        Max = 5000,
        Rounding = 0,
        Callback = function(Value)
            espSettings.MaxDistance = Value
        end
    })

    -- ========== WORLD TAB ==========
    local WorldLeft = Tabs.World:AddLeftGroupbox("Protection")

    WorldLeft:AddToggle("NoBounds", {
        Text = "Prevent OOB",
        Default = false,
        Callback = function(Value)
            state.NoBounds = Value
            if Value then enableNoBounds() end
        end
    })

    WorldLeft:AddToggle("RemoveKillers", {
        Text = "Remove Killers",
        Default = false,
        Callback = function(Value)
            state.RemoveKillers = Value
            if Value then enableRemoveKillers() end
        end
    })

    WorldLeft:AddToggle("NoFireDamage", {
        Text = "No Fire Damage",
        Default = false,
        Callback = function(Value)
            state.NoFireDamage = Value
            if Value then enableNoFireDamage() end
        end
    })

    WorldLeft:AddToggle("AntiFreeze", {
        Text = "Anti Freeze",
        Default = false,
        Callback = function(Value)
            state.AntiFreeze = Value
            if Value then enableAntiFreeze() end
        end
    })

    -- ========== UNLOCK TAB ==========
    local UnlockLeft = Tabs.Unlock:AddLeftGroupbox("Skins")

    UnlockLeft:AddToggle("UnlockAllSkins", {
        Text = "Unlock All Skins",
        Default = false,
        Callback = function(Value)
            state.UnlockCosmetics = Value
            if Value then
                task.spawn(function()
                    pcall(UnlockAll)
                    if getgenv()._CyberDragon_unlockRan then
                        Library:Notify("All Skins unlocked!", 3)
                    else
                        Library:Notify("All Skins unlock failed or already running!", 3)
                    end
                end)
            else
                task.spawn(function()
                    pcall(DisableCosmeticsUnlock)
                    Library:Notify("All Skins restored to normal.", 3)
                end)
            end
        end
    })

    UnlockLeft:AddLabel("Anti-kick is always active.")
    UnlockLeft:AddLabel("Press the button above to unlock cosmetics.")

    -- ========== UI SETTINGS ==========
    local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

    MenuGroup:AddToggle("KeybindMenuOpen", {
        Default = Library.KeybindFrame.Visible,
        Text = "Open Keybind Menu",
        Callback = function(value)
            Library.KeybindFrame.Visible = value
        end
    })

    MenuGroup:AddToggle("ShowCustomCursor", {
        Text = "Custom Cursor",
        Default = true,
        Callback = function(Value)
            Library.ShowCustomCursor = Value
        end
    })

    MenuGroup:AddDivider()

    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind"
    })

    MenuGroup:AddButton("Unload", function()
        Library:Unload()
    end)

    Library.ToggleKeybind = Options.MenuKeybind

    -- Key Management Section with Timer Display
    local KeyGroup = Tabs["UI Settings"]:AddRightGroupbox("Key System")

    local timerLabel = KeyGroup:AddLabel("Time Remaining: Checking...", true)

    task.spawn(function()
        while getgenv()._CyberDragon_Running do
            if getgenv()._CyberDragon_KeyExpiry then
                local now = KeySystem:GetCurrentTimestamp()
                local remaining = getgenv()._CyberDragon_KeyExpiry - now
                if remaining > 0 then
                    timerLabel:SetText("Time Remaining: " .. KeySystem:FormatTimeRemaining(remaining))
                    if remaining < 300 then
                        timerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    elseif remaining < 1800 then
                        timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    else
                        timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                else
                    timerLabel:SetText("Time Remaining: EXPIRED")
                    timerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            else
                timerLabel:SetText("Time Remaining: PERMANENT")
                timerLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
            task.wait(1)
        end
    end)

    KeyGroup:AddLabel("Current Key: " .. (getgenv()._CyberDragon_CurrentKey or "None"), true)

    KeyGroup:AddButton({
        Text = "Copy HWID",
        Func = function()
            local hwid = KeySystem:GetHWID()
            pcall(function() setclipboard(hwid) end)
            Library:Notify("HWID copied to clipboard!", 3)
        end,
        DoubleClick = false,
        Tooltip = "Copies your HWID for key generation"
    })

    KeyGroup:AddButton({
        Text = "Clear Saved Key",
        Func = function()
            KeySystem:ClearSavedKey()
            KeySystem:ClearKeyExpiry()
            Library:Notify("Saved key cleared! Restart script to re-enter key.", 5)
        end,
        DoubleClick = true,
        Tooltip = "Clears the saved key (requires double-click)"
    })

    KeyGroup:AddButton({
        Text = "Get New Key",
        Func = function()
            local hwid = KeySystem:GetHWID()
            local key, isExisting = KeyGenerator:GetOrCreateKeyForHWID(hwid)

            if not key then
                Library:Notify("Failed to generate unique key! Try again.", 5)
                return
            end

            if isExisting then
                Library:Notify("Your existing key: " .. key .. " (copied)", 5)
            else
                Library:Notify("New unique key generated: " .. key .. " (copied)", 5)
            end

            pcall(function() setclipboard(key) end)
        end,
        DoubleClick = false,
        Tooltip = "Generates a unique key for your HWID"
    })

    KeyGroup:AddDivider()

    KeyGroup:AddLabel("Key Status: " .. (getgenv()._CyberDragon_KeyValid and "VALIDATED" or "NOT VALIDATED"), true)

    -- ========== THEME & SAVE MANAGERS ==========
    if ThemeManager then
        pcall(function()
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("CyberDragon")
            ThemeManager:ApplyToTab(Tabs["UI Settings"])
        end)
    end
    if SaveManager then
        pcall(function()
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
            SaveManager:SetFolder("CyberDragon/settings")
            SaveManager:BuildConfigSection(Tabs["UI Settings"])
        end)
    end

    -- ========== WATERMARK ==========
    local FrameTimer = tick()
    local FrameCounter = 0
    local FPS = 60
    local GetPing = (function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local CanDoPing = pcall(function() return GetPing() end)

    getgenv()._CDWatermarkConnection = addConnection(game:GetService("RunService").RenderStepped:Connect(function()
        FrameCounter = FrameCounter + 1
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer = tick()
            FrameCounter = 0
        end
        if CanDoPing then
            Library:SetWatermark(("Cyber Dragon | %d fps | %d ms"):format(math.floor(FPS), GetPing()))
        else
            Library:SetWatermark(("Cyber Dragon | %d fps"):format(math.floor(FPS)))
        end
    end))

    Library:OnUnload(function()
        if getgenv()._CDWatermarkConnection then
            pcall(function() getgenv()._CDWatermarkConnection:Disconnect() end)
        end
        print("Cyber Dragon unloaded!")
        Library.Unloaded = true
    end)

    Library:SetWatermarkVisibility(true)
    if SaveManager then
        pcall(function() SaveManager:LoadAutoloadConfig() end)
    end

    -- ========== HIT NOTIFICATION SYSTEM ==========
    local HitNotify = {}
    HitNotify.LastHitTime = 0
    HitNotify.HitCombo = 0
    HitNotify.LastTarget = nil
    HitNotify.NotifCooldown = 0
    HitNotify.BATCH_WINDOW = 0.2

    getgenv()._CDaimSnapshots = {}
    local SNAPSHOT_LIFETIME = 3.0
    local MAX_SNAPSHOTS = 30

    local function getAimedPlayer()
        local myChar = plr.Character
        if not myChar then return nil end

        local camPos = camera.CFrame.Position
        local camDir = camera.CFrame.LookVector
        local bestPlayer = nil
        local bestAngle = -1
        local maxDist = 1000

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local head = p.Character:FindFirstChild("Head")
                local humanoid = p.Character:FindFirstChildWhichIsA("Humanoid")
                if hrp and head and humanoid and humanoid.Health > 0 then
                    local targetPos = head and head.Position or hrp.Position
                    local toTarget = targetPos - camPos
                    local dist = toTarget.Magnitude
                    if dist <= maxDist then
                        local angle = camDir:Dot(toTarget.Unit)
                        local angleThreshold = math.cos(math.rad(40))
                        if angle > angleThreshold and angle > bestAngle then
                            bestAngle = angle
                            bestPlayer = p
                        end
                    end
                end
            end
        end
        return bestPlayer
    end

    local function getAimLocation(char, camPos, camDir)
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if not head or not torso then return "Body" end

        local headDir = (head.Position - camPos).Unit
        local torsoDir = (torso.Position - camPos).Unit

        if camDir:Dot(headDir) > camDir:Dot(torsoDir) then
            return "Head"
        end
        return "Body"
    end

    addConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = getAimedPlayer()
            if target and target.Character then
                table.insert(getgenv()._CDaimSnapshots, {
                    target = target,
                    time = tick(),
                    location = getAimLocation(target.Character, camera.CFrame.Position, camera.CFrame.LookVector)
                })
                local now = tick()
                while #getgenv()._CDaimSnapshots > MAX_SNAPSHOTS or (now - getgenv()._CDaimSnapshots[1].time) > SNAPSHOT_LIFETIME do
                    table.remove(getgenv()._CDaimSnapshots, 1)
                end
            end
        end
    end))

    function HitNotify:Send(playerName, damage, hitLocation, isKill)
        local now = tick()

        if self.LastTarget == playerName and (now - self.LastHitTime) < self.BATCH_WINDOW then
            self.HitCombo = self.HitCombo + 1
            self.LastHitTime = now
            return
        end

        if self.HitCombo > 0 and self.LastTarget then
            self:_Flush()
        end

        self.HitCombo = 1
        self.LastHitTime = now
        self.LastTarget = playerName
        self.PendingDamage = damage
        self.PendingLocation = hitLocation
        self.PendingKill = isKill

        task.delay(self.BATCH_WINDOW, function()
            if self.LastTarget == playerName and (tick() - self.LastHitTime) >= self.BATCH_WINDOW - 0.05 then
                self:_Flush()
            end
        end)
    end

    function HitNotify:_Flush()
        if self.HitCombo == 0 then return end

        local combo = self.HitCombo
        local target = self.LastTarget
        local dmg = self.PendingDamage
        local loc = self.PendingLocation
        local kill = self.PendingKill

        self.HitCombo = 0
        self.LastTarget = nil

        local notifText
        if combo > 1 then
            notifText = string.format("Hit %s x%d for %d [%s]", target, combo, math.floor(dmg * combo), loc)
        else
            local actionText = kill and "Killed" or "Hit"
            notifText = string.format("%s %s for %d [%s]", actionText, target, math.floor(dmg), loc)
        end

        pcall(function()
            Library:Notify(notifText, 1.5)
        end)
    end

    -- ========== SERVER DAMAGE DETECTION ==========
    local lastHealth = {}
    local playerDebounce = {}

    local function findAimSnapshot(target)
        local now = tick()
        local best = nil
        local bestTime = math.huge

        for _, snap in ipairs(getgenv()._CDaimSnapshots) do
            if snap.target == target and (now - snap.time) < SNAPSHOT_LIFETIME then
                if snap.time < bestTime then
                    bestTime = snap.time
                    best = snap
                end
            end
        end
        return best
    end

    local function monitorPlayer(p)
        if p == plr then return end

        local function onChar(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then return end
            lastHealth[p] = hum.Health
            playerDebounce[p] = 0

            addConnection(hum.HealthChanged:Connect(function(new)
                if not state.HitNotif then return end

                local prev = lastHealth[p]
                if not prev or new >= prev then 
                    lastHealth[p] = new
                    return 
                end

                local dmg = prev - new
                if dmg < 1 then 
                    lastHealth[p] = new
                    return 
                end

                local snap = findAimSnapshot(p)
                if not snap then
                    lastHealth[p] = new
                    return
                end

                local now = tick()
                if now - (playerDebounce[p] or 0) < 0.12 then
                    lastHealth[p] = new
                    return
                end
                playerDebounce[p] = now

                local isKill = new <= 0
                HitNotify:Send(p.DisplayName or p.Name, math.floor(dmg), snap.location, isKill)

                lastHealth[p] = new
            end))
        end

        addConnection(p.CharacterAdded:Connect(onChar))
        if p.Character then task.spawn(function() onChar(p.Character) end) end
    end

    for _, p in pairs(Players:GetPlayers()) do monitorPlayer(p) end
    addConnection(Players.PlayerAdded:Connect(monitorPlayer))
    addConnection(Players.PlayerRemoving:Connect(function(p) 
        lastHealth[p] = nil 
        playerDebounce[p] = nil
    end))

    -- ========== REMOTE EVENT HOOKS ==========
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if not remotes then return end

        local damageRemote = remotes:FindFirstChild("Damage", true) 
            or remotes:FindFirstChild("HitConfirm", true)
            or remotes:FindFirstChild("BulletHit", true)
            or remotes:FindFirstChild("HitMarker", true)

        if damageRemote and damageRemote:IsA("RemoteEvent") then
            addConnection(damageRemote.OnClientEvent:Connect(function(...)
                local args = {...}
                local target = args[1]
                local damage = args[2] or 0

                local targetPlayer = nil
                if type(target) == "userdata" and target.IsA then
                    if target:IsA("Player") then
                        targetPlayer = target
                    else
                        targetPlayer = Players:GetPlayerFromCharacter(target:IsA("Model") and target or target.Parent)
                    end
                end

                if targetPlayer and targetPlayer ~= plr and damage > 0 then
                    local snap = findAimSnapshot(targetPlayer)
                    local loc = snap and snap.location or "Body"
                    local hum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local isKill = hum and hum.Health <= 0 or false

                    local now = tick()
                    if now - (playerDebounce[targetPlayer] or 0) < 0.12 then
                        return
                    end
                    playerDebounce[targetPlayer] = now

                    HitNotify:Send(targetPlayer.DisplayName or targetPlayer.Name, math.floor(damage), loc, isKill)
                end
            end))
        end
    end)

    pcall(function()
        local ClientEntity = require(plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
        if ClientEntity and ClientEntity.ReplicateFromServer and not getgenv()._CyberDragon_Originals.ClientEntityReplicate2 then
            getgenv()._CyberDragon_Originals.ClientEntityReplicate2 = ClientEntity.ReplicateFromServer
            local originalReplicate = ClientEntity.ReplicateFromServer
            ClientEntity.ReplicateFromServer = function(self, action, ...)
                if action == "TakeDamage" or action == "Damage" or action == "Hit" or action == "HitMarker" then
                    local args = {...}
                    local target = args[1]
                    local damage = args[2] or 0

                    local targetPlayer = nil
                    if type(target) == "userdata" and target.IsA then
                        if target:IsA("Player") then
                            targetPlayer = target
                        elseif target:IsA("Humanoid") then
                            targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
                        elseif target:IsA("Model") then
                            targetPlayer = Players:GetPlayerFromCharacter(target)
                        end
                    end

                    if targetPlayer and targetPlayer ~= plr and damage > 0 then
                        local snap = findAimSnapshot(targetPlayer)
                        local loc = snap and snap.location or "Body"
                        local hum = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                        local isKill = hum and hum.Health <= 0 or false

                        local now = tick()
                        if now - (playerDebounce[targetPlayer] or 0) < 0.12 then
                            return originalReplicate(self, action, ...)
                        end
                        playerDebounce[targetPlayer] = now

                        HitNotify:Send(targetPlayer.DisplayName or targetPlayer.Name, math.floor(damage), loc, isKill)
                    end
                end
                return originalReplicate(self, action, ...)
            end
        end
    end)

    -- ========== DESYNC + WALLBANG FEATURE (FIXED FOR LUA 5.1) ==========
    local DesyncWallbang = {}
    DesyncWallbang.Active = false
    DesyncWallbang.Instance = nil

    local getServiceDS = setmetatable({}, {
        __index = function(_, serviceName)
            local success, service = pcall(function()
                return game:GetService(serviceName)
            end)
            if success then
                return cloneref(service)
            end
            return nil
        end
    })

    local PlayersDS = getServiceDS.Players
    local RunServiceDS = getServiceDS.RunService
    local ReplicatedStorageDS = getServiceDS.ReplicatedStorage

    local LocalPlayerDS = PlayersDS.LocalPlayer
    local PlayerScriptsDS = LocalPlayerDS.PlayerScripts

    local GunModuleDS = nil
    local UtilityModuleDS = nil

    local DESYNC_CONFIG = {
        TARGET_UPDATE_RATE = 0.08,
        DESYNC_DEPTH = -10,
        SHOOT_DESYNC_DELAY = 0.1,
        HEAD_OFFSET_Y = 0.2,
        JITTER_XZ = 0.8,
        JITTER_Y = 0.6,
        PACKET_DELAY = 0.15,
        DESYNC_RESTORE_PRIORITY = 101
    }

    function DesyncWallbang:Init()
        if self.Instance then return end

        local instance = {}
        instance.active = true
        instance.currentTarget = nil
        instance.desyncActive = false
        instance.currentDesyncTarget = nil
        instance.targetUpdateConnection = nil
        instance.desyncConnection = nil
        instance.delayTask = nil
        instance.originalShootFunction = nil
        instance.lastTargetFindTime = 0
        instance.shouldStopDesync = false

        local ok1, gm = pcall(function() return require(PlayerScriptsDS.Modules.ItemTypes.Gun) end)
        local ok2, um = pcall(function() return require(ReplicatedStorageDS.Modules.Utility) end)
        if not ok1 or not ok2 then
            Library:Notify("DesyncWallbang: Failed to load required modules!", 5)
            return
        end
        GunModuleDS = gm
        UtilityModuleDS = um

        function instance:FindClosestEnemy()
            local myChar = LocalPlayerDS.Character
            if not myChar then return nil end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end

            local closestPlayer = nil
            local closestDistance = math.huge

            for _, player in pairs(PlayersDS:GetPlayers()) do
                if player ~= LocalPlayerDS then
                    local character = player.Character
                    if character then
                        local root = character:FindFirstChild("HumanoidRootPart")
                        local head = character:FindFirstChild("Head")
                        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                        if root and head and humanoid and humanoid.Health > 0 then
                            local distance = (myRoot.Position - root.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            return closestPlayer
        end

        function instance:StartDesync(target)
            if self.desyncConnection then
                self.desyncConnection:Disconnect()
            end
            self.desyncActive = true
            self.currentDesyncTarget = target
            self.shouldStopDesync = false

            self.desyncConnection = addConnection(RunServiceDS.Heartbeat:Connect(function()
                if not self.desyncActive then return end
                if self.shouldStopDesync then return end
                local myChar = LocalPlayerDS.Character
                if not myChar then return end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot then
                    self:StopDesync()
                    return
                end
                local originalCF = myRoot.CFrame
                local originalVel = myRoot.Velocity
                local originalRotVel = myRoot.RotVelocity
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, DESYNC_CONFIG.DESYNC_DEPTH, 0)
                local restoreName = "DesyncRestore_" .. tostring(math.random(100000))
                RunServiceDS:BindToRenderStep(restoreName, DESYNC_CONFIG.DESYNC_RESTORE_PRIORITY, function()
                    myRoot.CFrame = originalCF
                    myRoot.Velocity = originalVel
                    myRoot.RotVelocity = originalRotVel
                    RunServiceDS:UnbindFromRenderStep(restoreName)
                end)
            end))
        end

        function instance:StopDesync()
            self.desyncActive = false
            self.currentDesyncTarget = nil
            if self.desyncConnection then
                self.desyncConnection:Disconnect()
                self.desyncConnection = nil
            end
        end

        function instance:Setup()
            self.targetUpdateConnection = addConnection(RunServiceDS.Heartbeat:Connect(function()
                if not self.active then return end
                local now = tick()
                if now - self.lastTargetFindTime < DESYNC_CONFIG.TARGET_UPDATE_RATE then return end
                self.lastTargetFindTime = now
                self.currentTarget = self:FindClosestEnemy()
            end))

            if not getgenv()._CyberDragon_Originals.GunStartShooting then
                getgenv()._CyberDragon_Originals.GunStartShooting = GunModuleDS.StartShooting
            end

            local originalShoot = getgenv()._CyberDragon_Originals.GunStartShooting
            self.originalShootFunction = originalShoot

            GunModuleDS.StartShooting = function(gunObject, ...)
                local results = { originalShoot(gunObject, ...) }

                if not instance.active then return unpack(results) end
                if not gunObject.ClientFighter or not gunObject.ClientFighter.IsLocalPlayer then
                    return unpack(results)
                end

                local packetData = results[3]
                if not packetData or type(packetData) ~= "table" then
                    return unpack(results)
                end

                results[4] = true

                local target = instance.currentTarget
                if not target or not target.Character then
                    return unpack(results)
                end

                if not instance.desyncActive or instance.currentDesyncTarget ~= target then
                    instance:StartDesync(target)
                    task.wait(DESYNC_CONFIG.SHOOT_DESYNC_DELAY)
                end

                instance.shouldStopDesync = false

                local targetHead = target.Character:FindFirstChild("Head")
                if not targetHead then
                    return unpack(results)
                end

                local headPos = targetHead.Position
                local aimPoint = headPos - Vector3.new(0, DESYNC_CONFIG.HEAD_OFFSET_Y, 0)
                local aimDir = CFrame.lookAt(aimPoint, headPos)

                local jitterOffset = Vector3.new(
                    math.random(-DESYNC_CONFIG.JITTER_XZ * 100, DESYNC_CONFIG.JITTER_XZ * 100) / 100,
                    math.random(-DESYNC_CONFIG.JITTER_Y * 100, DESYNC_CONFIG.JITTER_Y * 100) / 100,
                    math.random(-DESYNC_CONFIG.JITTER_XZ * 100, DESYNC_CONFIG.JITTER_XZ * 100) / 100
                )
                local randomCF = targetHead.CFrame:ToObjectSpace(CFrame.new(headPos + jitterOffset))

                -- FIXED: Use string.char instead of utf8.char for Lua 5.1 compatibility
                packetData[string.char(0)] = UtilityModuleDS:EncodeCFrame(CFrame.new(aimPoint, headPos) * CFrame.Angles(aimDir:ToOrientation()))
                packetData[string.char(1)] = UtilityModuleDS:EncodeCFrame(CFrame.new(headPos) * CFrame.Angles(aimDir:ToOrientation()))
                packetData[string.char(2)] = targetHead
                packetData[string.char(3)] = UtilityModuleDS:EncodeCFrame(randomCF)

                -- FIXED: Use flag-based cancellation instead of task.cancel (not in Lua 5.1)
                instance.shouldStopDesync = false
                task.delay(DESYNC_CONFIG.PACKET_DELAY, function()
                    if not instance.shouldStopDesync then
                        instance:StopDesync()
                    end
                end)

                return unpack(results)
            end
        end

        function instance:Shutdown()
            self.active = false
            self.shouldStopDesync = true
            if self.targetUpdateConnection then
                self.targetUpdateConnection:Disconnect()
            end
            if self.desyncConnection then
                self.desyncConnection:Disconnect()
            end
            if getgenv()._CyberDragon_Originals.GunStartShooting then
                GunModuleDS.StartShooting = getgenv()._CyberDragon_Originals.GunStartShooting
            end
        end

        instance:Setup()
        self.Instance = instance
        Library:Notify("Desync + Wallbang loaded!", 3)
    end

    function DesyncWallbang:Shutdown()
        if self.Instance then
            self.Instance:Shutdown()
            self.Instance = nil
        end
        self.Active = false
    end

    CombatRight:AddToggle("DesyncWallbang", {
        Text = "Desync + Wallbang",
        Default = false,
        Callback = function(Value)
            DesyncWallbang.Active = Value
            if Value then
                task.spawn(function()
                    pcall(function() DesyncWallbang:Init() end)
                end)
            else
                pcall(function() DesyncWallbang:Shutdown() end)
            end
        end
    })

    CombatRight:AddSlider("DesyncDepth", {
        Text = "Desync Depth",
        Default = 10,
        Min = 1,
        Max = 50,
        Rounding = 0,
        Callback = function(Value)
            DESYNC_CONFIG.DESYNC_DEPTH = -Value
        end
    })

    CombatRight:AddSlider("ShootDelay", {
        Text = "Shoot Delay",
        Default = 0.1,
        Min = 0,
        Max = 0.5,
        Rounding = 2,
        Callback = function(Value)
            DESYNC_CONFIG.SHOOT_DESYNC_DELAY = Value
        end
    })

    CombatRight:AddSlider("PacketDelay", {
        Text = "Packet Delay",
        Default = 0.15,
        Min = 0.05,
        Max = 0.5,
        Rounding = 2,
        Callback = function(Value)
            DESYNC_CONFIG.PACKET_DELAY = Value
        end
    })

    CombatRight:AddSlider("HeadOffset", {
        Text = "Head Offset Y",
        Default = 0.2,
        Min = 0,
        Max = 2,
        Rounding = 2,
        Callback = function(Value)
            DESYNC_CONFIG.HEAD_OFFSET_Y = Value
        end
    })

    print("Cyber Dragon -- Linoria Edition loaded. Press RightShift to toggle.")

end -- End RunCyberDragon

-- ========== CLEANUP FUNCTION ==========
getgenv()._CyberDragon_Cleanup = function()
    -- Cleanup No Animation
    if getgenv()._CDnoAnimConn then
        pcall(function() getgenv()._CDnoAnimConn:Disconnect() end)
        getgenv()._CDnoAnimConn = nil
    end
    if getgenv()._CDnoAnimSavedGuns then
        getgenv()._CDnoAnimSavedGuns = {}
    end

    -- Disconnect all tracked connections
    if getgenv()._CyberDragon_Connections then
        for _, conn in ipairs(getgenv()._CyberDragon_Connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
            end
        end
        getgenv()._CyberDragon_Connections = nil
    end

    -- Disconnect legacy connections
    local conns = {
        "_CDflyConn", "_CDnoclipConn", "_CDaaConn", "_CDstrafeConn",
        "_CDjbConn", "_CDtpConn", "_CDfarmConn", "_CDautoWeapConn",
        "_CDantiKatConn", "_CDespUpdateConnection", "_CDWatermarkConnection",
        "_CyberDragon_WeaponModConnection", "_CDnoAnimConn"
    }
    for _, name in ipairs(conns) do
        local conn = getgenv()[name]
        if conn then
            pcall(function() conn:Disconnect() end)
            getgenv()[name] = nil
        end
    end

    -- Destroy physics objects
    if getgenv()._CDflyVel then pcall(function() getgenv()._CDflyVel:Destroy() end); getgenv()._CDflyVel = nil end
    if getgenv()._CDflyGyro then pcall(function() getgenv()._CDflyGyro:Destroy() end); getgenv()._CDflyGyro = nil end

    -- Stop animations
    if getgenv()._CDtornadoTrack then pcall(function() getgenv()._CDtornadoTrack:Stop() end); getgenv()._CDtornadoTrack = nil end

    -- Reset camera
    if getgenv()._CDoriginalCamType then
        pcall(function() game:GetService("Workspace").CurrentCamera.CameraType = getgenv()._CDoriginalCamType end)
        getgenv()._CDoriginalCamType = nil
    end

    -- Clear ESP
    local espObjs = getgenv()._CDespObjects
    if espObjs then
        for p, esp in pairs(espObjs) do
            for k, v in pairs(esp) do
                if k ~= "cornerSize" and v and v.Remove then
                    pcall(function() v:Remove() end)
                end
            end
        end
        getgenv()._CDespObjects = nil
    end

    -- Clear chams
    local chamObjs = getgenv()._CDchamObjects
    if chamObjs then
        for p, chams in pairs(chamObjs) do
            for _, cham in pairs(chams) do
                if cham then pcall(function() cham:Destroy() end) end
            end
        end
        getgenv()._CDchamObjects = nil
    end

    -- Restore original functions
    local originals = getgenv()._CyberDragon_Originals
    if originals then
        local CosmeticLibrary
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 5))
        end)
        if CosmeticLibrary then
            if originals.OwnsCosmeticNormally then CosmeticLibrary.OwnsCosmeticNormally = originals.OwnsCosmeticNormally end
            if originals.OwnsCosmeticUniversally then CosmeticLibrary.OwnsCosmeticUniversally = originals.OwnsCosmeticUniversally end
            if originals.OwnsCosmeticForWeapon then CosmeticLibrary.OwnsCosmeticForWeapon = originals.OwnsCosmeticForWeapon end
            if originals.OwnsCosmetic then CosmeticLibrary.OwnsCosmetic = originals.OwnsCosmetic end
        end

        local DataController
        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            DataController = require(plr.PlayerScripts.Controllers:WaitForChild("PlayerDataController", 5))
        end)
        if DataController then
            if originals.DataControllerGet then DataController.Get = originals.DataControllerGet end
            if originals.DataControllerGetWeaponData then DataController.GetWeaponData = originals.DataControllerGetWeaponData end
        end

        local ClientItem
        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            ClientItem = require(plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
        end)
        if ClientItem then
            if originals.CreateViewModel then ClientItem._CreateViewModel = originals.CreateViewModel end
        end

        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            local viewModelModule = plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
            if viewModelModule then
                local ClientViewModel = require(viewModelModule)
                if originals.GetWrap then ClientViewModel.GetWrap = originals.GetWrap end
                if originals.ViewModelNew then ClientViewModel.new = originals.ViewModelNew end
            end
        end)

        local ItemLibrary
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 5))
        end)
        if ItemLibrary and originals.GetViewModelImage then
            ItemLibrary.GetViewModelImageFromWeaponData = originals.GetViewModelImage
        end

        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            local ViewProfile = require(plr.PlayerScripts.Modules.Pages.ViewProfile)
            if ViewProfile and originals.ViewProfileFetch then
                ViewProfile.Fetch = originals.ViewProfileFetch
            end
        end)

        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            local ClientEntity = require(plr.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity)
            if ClientEntity then
                if originals.ClientEntityReplicate then ClientEntity.ReplicateFromServer = originals.ClientEntityReplicate end
                if originals.ClientEntityReplicate2 then ClientEntity.ReplicateFromServer = originals.ClientEntityReplicate2 end
            end
        end)

        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            local GunModule = require(plr.PlayerScripts.Modules.ItemTypes.Gun)
            if GunModule and originals.GunStartShooting then
                GunModule.StartShooting = originals.GunStartShooting
            end
        end)

        getgenv()._CyberDragon_Originals = nil
    end

    -- Unload Library
    if getgenv()._CyberDragon_Library then
        pcall(function() getgenv()._CyberDragon_Library:Unload() end)
        getgenv()._CyberDragon_Library = nil
    end

    -- Reset state
    getgenv()._CyberDragon_Running = false
    getgenv()._CyberDragon_Reloading = false
    getgenv().Library = nil
    getgenv().Options = nil
    getgenv().Toggles = nil

    -- Clear aim snapshots
    getgenv()._CDaimSnapshots = {}

    print("[Cyber Dragon] Cleanup completed")
end

-- ========== KEY UI (ONLY SHOWN IF KEY INVALID) ==========
if not getgenv()._CyberDragon_KeyValid then
    local repo = "https://raw.githubusercontent.com/makarmatvij7-svg/LunoriaaLib/main/"
    local KeyLib
    local keyLibOk, keyLibResult = pcall(function()
        return loadstring(game:HttpGet(repo .. "Library.lua"))()
    end)
    if not keyLibOk or not keyLibResult then
        warn("[Cyber Dragon] CRITICAL: Failed to load Key UI library: " .. tostring(keyLibResult))
        warn("[Cyber Dragon] Try using a different executor or check your internet connection.")
        return
    end
    KeyLib = keyLibResult

    local KeyWindow = KeyLib:CreateWindow({
        Title = "Cyber Dragon - Key System",
        Center = true,
        AutoShow = true,
        Resizable = false,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        NotifySide = "Left",
        TabPadding = 8,
        MenuFadeTime = 0.2,
        Size = Vector2.new(500, 350)
    })

    local KeyTab = KeyWindow:AddTab("Authentication")
    local LeftGroup = KeyTab:AddLeftGroupbox("Key Validation")
    local RightGroup = KeyTab:AddRightGroupbox("Information")

    local statusLabel = LeftGroup:AddLabel("Status: Enter your key below", true)
    local attemptsLabel = LeftGroup:AddLabel("Attempts: 0 / " .. KEY_CONFIG.MaxAttempts, true)

    -- FIX: Use getgenv to persist keyInput across callbacks
    getgenv()._CyberDragon_KeyInput = ""

    LeftGroup:AddInput("KeyInput", {
        Text = "Access Key",
        Default = "",
        Numeric = false,
        Finished = false,  -- FIX: Changed to false so it updates on every keystroke
        Placeholder = "Enter your key...",
        Callback = function(Value)
            getgenv()._CyberDragon_KeyInput = Value
        end
    })

    local savedKeyUI = KeySystem:LoadSavedKey()
    if savedKeyUI then
        getgenv()._CyberDragon_KeyInput = savedKeyUI
        statusLabel:SetText("Status: Saved key loaded - click VALIDATE")
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end

LeftGroup:AddButton({
    Text = "VALIDATE KEY",
    Func = function()
        local key = (getgenv()._CyberDragon_KeyInput or ""):gsub("%s+", "")
        if key == "" then
            statusLabel:SetText("Status: Please enter a key!")
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            KeyLib:Notify("Please enter a key!", 3)
            return
        end

        KEY_CONFIG.Attempts = KEY_CONFIG.Attempts + 1
        attemptsLabel:SetText("Attempts: " .. KEY_CONFIG.Attempts .. " / " .. KEY_CONFIG.MaxAttempts)

        if KEY_CONFIG.Attempts >= KEY_CONFIG.MaxAttempts then
            statusLabel:SetText("Status: TOO MANY ATTEMPTS - LOCKED")
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            KeyLib:Notify("Too many failed attempts! Script locked.", 5)
            return
        end

        local valid, msg, timeRemaining = KeySystem:ValidateKey(key)
        if valid then
            getgenv()._CyberDragon_KeyValid = true
            getgenv()._CyberDragon_CurrentKey = key:upper()

            local keyData = KEY_CONFIG.ValidKeys[key:upper()]
            local expiryInfo = nil

            -- FIXED: Always use the now-computed ExpiresAt from keyData
            if keyData and keyData.ExpiresAt then
                getgenv()._CyberDragon_KeyExpiry = keyData.ExpiresAt
                expiryInfo = {key = key:upper(), expiresAt = keyData.ExpiresAt}
            else
                getgenv()._CyberDragon_KeyExpiry = nil
            end

            if KEY_CONFIG.AutoSave then 
                KeySystem:SaveKey(key:upper(), expiryInfo) 
            end

            statusLabel:SetText("Status: KEY VALIDATED!")
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

            if timeRemaining then
                KeyLib:Notify("Key validated! Expires in: " .. KeySystem:FormatTimeRemaining(timeRemaining), 5)
            else
                KeyLib:Notify("Key validated! Permanent access granted.", 3)
            end

            task.wait(1.5)
            KeyLib:Unload()

            RunCyberDragon()
        else
            statusLabel:SetText("Status: INVALID KEY (" .. KEY_CONFIG.Attempts .. "/" .. KEY_CONFIG.MaxAttempts .. ") - " .. msg)
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            KeyLib:Notify("Invalid key! " .. KEY_CONFIG.Attempts .. "/" .. KEY_CONFIG.MaxAttempts .. " - " .. msg, 3)
            getgenv()._CyberDragon_KeyInput = ""
        end
    end,
    DoubleClick = false,
    Tooltip = "Validate your access key"
})

    LeftGroup:AddButton({
        Text = "GET KEY",
        Func = function()
            local hwid = KeySystem:GetHWID()
            local key, isExisting = KeyGenerator:GetOrCreateKeyForHWID(hwid)

            if not key then
                statusLabel:SetText("Status: FAILED TO GENERATE KEY")
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                KeyLib:Notify("Failed to generate unique key! Try again.", 5)
                return
            end

            if isExisting then
                statusLabel:SetText("Status: Your existing key: " .. key)
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                KeyLib:Notify("Your existing key copied: " .. key, 5)
            else
                statusLabel:SetText("Status: NEW KEY GENERATED: " .. key)
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                KeyLib:Notify("New unique key generated: " .. key, 5)
            end

            pcall(function() setclipboard(key) end)

            -- Auto-fill the input
            getgenv()._CyberDragon_KeyInput = key
        end,
        DoubleClick = false,
        Tooltip = "Generates a unique key for your HWID"
    })

    LeftGroup:AddButton({
        Text = "CLEAR SAVED KEY",
        Func = function()
            KeySystem:ClearSavedKey()
            KeySystem:ClearKeyExpiry()
            getgenv()._CyberDragon_KeyInput = ""
            statusLabel:SetText("Status: Saved key cleared")
            KeyLib:Notify("Saved key cleared!", 3)
        end,
        DoubleClick = true,
        Tooltip = "Clear saved key (double-click)"
    })

    RightGroup:AddLabel("Key System Info:", true)
    RightGroup:AddLabel("• Each HWID gets a unique key", true)
    RightGroup:AddLabel("• Keys are case-insensitive", true)
    RightGroup:AddLabel("• Keys cannot be shared", true)
    RightGroup:AddLabel("• Max attempts: " .. KEY_CONFIG.MaxAttempts, true)
    RightGroup:AddLabel("", true)
    RightGroup:AddLabel("Current HWID:", true)
    RightGroup:AddLabel(KeySystem:GetHWID():sub(1, 30) .. "...", true)

    RightGroup:AddButton({
        Text = "COPY HWID",
        Func = function()
            local hwid = KeySystem:GetHWID()
            pcall(function() setclipboard(hwid) end)
            KeyLib:Notify("HWID copied!", 3)
        end,
        DoubleClick = false,
        Tooltip = "Copy HWID for key generation"
    })

    RightGroup:AddDivider()
    RightGroup:AddLabel("Cyber Dragon v2.0", true)
else
    print("[Cyber Dragon] Auto-login with saved key: " .. getgenv()._CyberDragon_CurrentKey)

    RunCyberDragon()
end
