hudlog = hudlog or {}

local objMaxMessages = CreateClientConVar("hudlog_max_messages", "5", true, false, "Maxmimum number of messages shown at the top of the screen at once")
local objMessageTimeout = CreateClientConVar("hudlog_msg_timeout", "3", true, false, "Number of seconds each message has to live")

local MESSAGES_MAX = math.Clamp(objMaxMessages:GetInt(), 0, 8)
local MESSAGES_TIMEOUT = math.Clamp(objMessageTimeout:GetInt(), 0, 15)

cvars.AddChangeCallback("hudlog_max_messages", function(strConVar, strOld, strNew)
    local iNew = math.Clamp(tonumber(strNew), 0, 8)
    objMaxMessages:SetInt(iNew)
    MESSAGES_MAX = iNew
end)

cvars.AddChangeCallback("hudlog_msg_timeout", function(strConVar, strOld, strNew)
    local iNew = math.Clamp(tonumber(strNew), 0, 15)
    objMessageTimeout:SetInt(iNew)
    MESSAGES_TIMEOUT = iNew
end)

local tblQueue = {}

local function removeFromQueue(iIndex)
    table.remove(tblQueue, iIndex)
end

local function addToQueue(tblDrawable)
    if(#tblQueue >= MESSAGES_MAX) then
        table.remove(tblQueue, 1)
    end

    tblQueue[#tblQueue+1] = {
        ["added_at"] = RealTime(),
        ["data"] = tblDrawable,
    }
end

function hudlog.add(...)
    local tblDrawable = {}

    for k,v in pairs({...}) do
        table.insert(tblDrawable, isstring(v) and string.Replace(v, "\n", " ") or v)
    end

    MsgC(unpack(tblDrawable))
    MsgC("\n")

    addToQueue(tblDrawable)
end

hook.Add("HUDPaint", "hudlog.paint", function()
    surface.SetFont("ChatFont")
    surface.SetTextColor(color_white)

    local iWidth, iHeight = surface.GetTextSize("W")

    local tblToTrash = {}

    for i=1,#tblQueue do
        local tblDrawable = tblQueue[i]
        local tblData = tblDrawable["data"]

        local iOffset = 0

        for k,v in pairs(tblData) do
            surface.SetTextPos(2+iOffset, 2+(i-1)*iHeight)

            if(IsColor(v)) then
                surface.SetTextColor(v)
            elseif(isstring(v)) then
                if(k > 1) then
                    iOffset = iOffset + (select(1, surface.GetTextSize(v)))
                end
                surface.DrawText(v)
            end
        end

        if(RealTime() > tblDrawable["added_at"] + MESSAGES_TIMEOUT) then
            table.insert(tblToTrash, i)
        end
    end

    for i=1,#tblToTrash do
        removeFromQueue(i)
    end
end)
