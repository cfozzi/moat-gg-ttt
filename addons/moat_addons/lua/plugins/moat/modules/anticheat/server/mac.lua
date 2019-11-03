util.AddNetworkString "moat.verify"

local hate_list = {
    "nigger",
    "faggot"
}

util.AddNetworkString("moat._.initloading")

local replace_list = {}

function contains_hateful(s)
    for k,v in ipairs(hate_list) do
        if s:lower():match(v:lower()) then
            return true, k
        end
    end
    return false
end

local cached_toxic = {}
local cached_err = {}
local api_key = "AIzaSyCs45XuL0kh2rSto-vkQsbRUj70RmXA98w"
local requestedAttributes = {
    ["IDENTITY_ATTACK"] = {},
    ["INSULT"] =  {},
    ["SEVERE_TOXICITY"] = {}
}
local custom_min = {
    SEVERE_TOXICITY = 0.9,
    INSULT = 0.9
}
function perspective_post(nick,sid,message,ply)
    if #message < 3 then return end
    if cached_toxic[message] then return end -- avoid short term spam
    cached_toxic[message] = true
    if message:match("^[!/]") then return end -- command
    local msg = util.TableToJSON({
            comment = {text = message},
            languages = {"en"},
            requestedAttributes = requestedAttributes
        },true):gsub("%[%]","{}")
    HTTP({
        method = "POST",
        url = "https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=" .. api_key,
        body = msg,
        type = "application/json",
        success = function (code,body)
            message = message:gsub("*","\\*")
            if code == 200 then
                local t = util.JSONToTable(body)
                local s = "{" .. (Server and Server.Name or GetHostName()) .. "} (" .. sid .. ") " .. nick .. ": " .. message .. "\n```"
                local show = false
                for k,v in pairs(requestedAttributes) do
                    local value = t.attributeScores[k].summaryScore.value
                    if value > (custom_min[k] or 0.8) then
                        show = true
                        s = s .. k .. ": >" .. math.Round(value * 100,2) .. "%<" 
                    else
                        s = s .. k .. ": " .. math.Round(value * 100,2) .. "%"
                    end
                    s = s .. "\t"
                end
                if show then
                    s = s .. "```"
                    discord.Send("Toxic",s)
                end
            else
                discord.Send("Developer","[Error] (" .. sid .. ") (" .. message .. ") `" .. GetHostName() .. "`: Got other code: `" .. code .. "," .. body .. ",(" .. message ..")`")
            end
        end,
        failed = function(s)
            if cached_err[s] then return end
            cached_err[s] = true
            discord.Send("Developer","[Error] (" .. sid .. ") (" .. message .. ") `" .. GetHostName() .. "`: Got error: `" .. s .. "`")
        end
    })
end

hook.Add("PlayerInitialSpawn","Automatic Hate kicking",function(ply)
    local h, i = contains_hateful(ply:Nick())
    if h then
        RunConsoleCommand("mga","kick",ply:SteamID(),"Change your name to be more friendly [" .. i .. "]")
    end
end)

hook.Add("PlayerSay","Automatic Hateful Conduct Ban",function(ply,txt)
    perspective_post(ply:Nick(),ply:SteamID(),txt,ply)
end)


local detection_reasons = {
    [-1] = "DHTML RUNLUA",
    [1] = "Aimware",
    [2] = "Scripthook",
    [3] = "Lua Detours",
    [4] = "sv_allowcslua",
    [5] = "sv_cheats",
    [6] = "Scripthook",
    [7] = "Lenny Scripts",
    [8] = "host_timescale",
    [9] = "mat_wireframe",
    [10] = "mat_fullbright",
    [11] = "pHack",
    [12] = "mApex",
    [13] = "Sasha Hack",
    [14] = "snixzz",
    [15] = "gmcl_external",
    [16] = "Aspire Menu",
    [17] = "cdriza scripts",
    [18] = "xHack",
    [19] = "Invalid Commands",
    [20] = "Invalid Hooks",
    [21] = "gDaap",
    [22] = "SmegHack"
}

local detections_ac = {}

local function discordLog(sid, mouse)
	local msg = "[Anti Cheat] Detected: `" .. mouse[1] .. " (" .. sid .. ") [" .. mouse[2] .. "] lvl(" .. mouse[3] .. ")` { http://steamcommunity.com/profiles/" .. mouse[4] .. " } Server: " .. game.GetIP() .. " Detections: `" .. mouse[5] .. "`"
	discord.Send("Skid", msg)
end

local banned = {}
hook.Add("TTTEndRound","anti.cheat.end.round",function()
    local i = 0
    for k, v in pairs(detections_ac) do
        i = i + 1
        timer.Simple(i, function() discordLog(k, v) end)
		if (not banned[k]) then
        	RunConsoleCommand("mga","perma",k,"Cheating")
			banned[k] = true
		end
    end
    detections_ac = {}
end)

local function detect(pl, reason)
    if (pl.Detected) then return end
    pl.Detected = true

    if (not detections_ac[pl:SteamID()]) then
        detections_ac[pl:SteamID()] = {
            pl:Nick(),
            pl:IPAddress(),
            pl:GetNW2Int("MOAT_STATS_LVL", -1),
            pl:SteamID64(),
            reason
        }
    end
end

local dev_server = GetHostName():lower():find("dev")
net.Receive("moat.verify", function(_, pl)
    if (dev_server or pl:IsUserGroup("communitylead")) then return end

    local dets = net.ReadTable()
    local reason = "Cheating: "
    local steamid = pl:SteamID()

    for k, v in pairs(dets) do
        if (not detection_reasons[v]) then
            RunConsoleCommand("mga", "perma", steamid, "Cheating")

            return
        else
            reason = reason .. detection_reasons[v] .. (k == #dets and " " or ", ")
        end
    end

    detect(pl, reason)
end)

hook.Add("OnEntityCreated","Anti skid",function(ent)
    if ent:GetClass():lower() == "lua_run" then
        function ent:AcceptInput() return true end
        function ent:RunCode() return true end
        timer.Simple(0,function()
            ent:Remove()
        end)
    elseif ent:GetClass():lower() == "point_servercommand" then
        timer.Simple(0,function()
            ent:Remove()
        end)
    end
end)

local skids = {}
net.Receive("moat._.initloading",function(l,p)
    local s = net.ReadString()
    if not skids[p] then 
        skids[p] = util.CRC(s)
        detect(p,-1)
    elseif skids[p] == util.CRC(s) then 
        return 
    end
    HTTP({
        url = "https://pastebin.com/api/api_post.php",
        method = "post",
        success = function(_,b,_,_)
            discord.Send("Skid",p:Nick() .. " (" .. p:SteamID() .. ") attempted to RUNLUA with DHTML: (Banning them)\nFull lua: " .. b .. "\n```" .. string.sub(s, 1, 100) .. "```")
        end,
        failed = function(a) 
            discord.Send("Skid",p:Nick() .. " (" .. p:SteamID() .. ") attempted to RUNLUA with DHTML: (Banning them)```" .. a .. "```")
        end,
        parameters = {
            ["api_dev_key"] = "243a56b209869a644bdb9627d4e50aa6",
            ["api_option"] = "paste",
            ["api_paste_code"] = s,
            ["api_paste_name"] = os.time(),
            ["api_paste_private"] = "0"
        },
    })
end)