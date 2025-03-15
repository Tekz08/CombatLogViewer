-- Create the main frame
local frame = CreateFrame("Frame", "CombatLogFrame", UIParent, "BackdropTemplate")
frame:SetSize(400, 300)  -- Initial size: 400 width, 300 height
frame:SetPoint("CENTER")  -- Position it at the center of the screen
frame:SetMovable(true)  -- Allow dragging to move
frame:SetResizable(true)  -- Allow resizing
frame:EnableMouse(true)  -- Enable mouse interaction
frame:RegisterForDrag("LeftButton")  -- Drag with left mouse button
frame:SetScript("OnDragStart", frame.StartMoving)  -- Start moving when dragged
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)  -- Stop moving when drag ends

-- Add a background and border
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)  -- Dark background
frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)  -- Gray border

-- Create header
local headerFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
headerFrame:SetHeight(24)
headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
headerFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
headerFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
headerFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
headerFrame:EnableMouse(true)
headerFrame:RegisterForDrag("LeftButton")
headerFrame:SetScript("OnDragStart", function() frame:StartMoving() end)
headerFrame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

-- Add title text
local titleText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", headerFrame, "LEFT", 8, 0)
titleText:SetText("Combat Log Viewer")

-- Create filter panel
local filterFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
filterFrame:SetSize(200, 300)  -- Width: 200, Height: same as main frame
filterFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)  -- Attach to right side of main frame
filterFrame:Hide()  -- Hide the filter frame initially
filterFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
filterFrame:SetBackdropColor(0, 0, 0, 0.8)
filterFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

-- Add close button (moved after filter frame creation)
local closeButton = CreateFrame("Button", nil, headerFrame)
closeButton:SetSize(16, 16)
closeButton:SetPoint("RIGHT", headerFrame, "RIGHT", -4, 0)
closeButton:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
closeButton:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
closeButton:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
closeButton:SetScript("OnClick", function() 
    frame:Hide()
    if filterFrame then
        filterFrame:Hide()
    end
end)

-- Create footer
local footerFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
footerFrame:SetHeight(35)  -- Reduced height to fit just the clear button
footerFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
footerFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
footerFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
footerFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)

-- Add resize grip (moved to be on top of footer)
local resizeButton = CreateFrame("Button", nil, footerFrame)
resizeButton:SetSize(16, 16)
resizeButton:SetPoint("BOTTOMRIGHT", footerFrame, "BOTTOMRIGHT", 0, 0)
resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
resizeButton:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
resizeButton:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

-- Create the ScrollingMessageFrame for displaying combat log messages
local logScrollFrame = CreateFrame("ScrollFrame", "CombatLogViewerScrollFrame", frame, "UIPanelScrollFrameTemplate")
logScrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -24)  -- Offset from below header
logScrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 35)  -- Adjusted for scrollbar and footer

local logFrame = CreateFrame("ScrollingMessageFrame", "CombatLogViewerMessageFrame", logScrollFrame)
logFrame:SetPoint("TOPLEFT", logScrollFrame, "TOPLEFT", 0, 0)
logFrame:SetPoint("BOTTOMRIGHT", logScrollFrame, "BOTTOMRIGHT", 0, 0)
logFrame:SetFontObject(GameFontNormal)
logFrame:SetJustifyH("LEFT")
logFrame:SetMaxLines(1000)
logFrame:EnableMouse(true)
logFrame:SetFading(false)
logFrame:EnableMouseWheel(true)
logFrame:SetHyperlinksEnabled(true)
logFrame:SetTextCopyable(true)  -- Enable text copying
logFrame:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM)

-- Handle mouse wheel scrolling
logFrame:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        self:ScrollUp()    -- When scrolling up, show older messages
    else
        self:ScrollDown()  -- When scrolling down, show newer messages
    end
end)

-- Set up the scroll bar functionality
local scrollBar = _G["CombatLogViewerScrollFrameScrollBar"]
if scrollBar then
    scrollBar:SetScript("OnValueChanged", function(self, value)
        logFrame:SetScrollOffset(value)
    end)
    
    -- Hook the scroll bar update to the message frame
    local function UpdateScrollBar()
        local numMessages = logFrame:GetNumMessages()
        if numMessages > 0 then
            scrollBar:SetMinMaxValues(0, numMessages)
            -- Keep at bottom to show newest messages
            scrollBar:SetValue(numMessages)
        end
    end
    
    -- Update scroll bar when new messages are added
    local oldAddMessage = logFrame.AddMessage
    logFrame.AddMessage = function(self, text, ...)
        oldAddMessage(self, text, ...)
        UpdateScrollBar()
        -- Always scroll to bottom to show newest messages
        self:ScrollToBottom()
    end
end

-- Create clear button in footer (moved after logFrame creation)
local clearButton = CreateFrame("Button", nil, footerFrame, "UIPanelButtonTemplate")
clearButton:SetSize(80, 22)
clearButton:SetPoint("BOTTOMRIGHT", footerFrame, "BOTTOMRIGHT", -30, 7)
clearButton:SetText("Clear log")
clearButton:SetScript("OnClick", function() logFrame:Clear() end)

-- Create copy all button in footer
local copyButton = CreateFrame("Button", nil, footerFrame, "UIPanelButtonTemplate")
copyButton:SetSize(80, 22)
copyButton:SetPoint("RIGHT", clearButton, "LEFT", -10, 0)
copyButton:SetText("Copy All")
copyButton:SetScript("OnClick", function()
    if logFrame:GetNumMessages() > 0 then
        -- Create a temporary chat frame for copying
        local chatFrame = SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
        local messages = {}
        
        -- Collect all messages
        for i = 1, logFrame:GetNumMessages() do
            local message = logFrame:GetMessageInfo(i)
            if message then
                table.insert(messages, message)
            end
        end
        
        -- Join messages and add to chat frame for copying
        local allText = table.concat(messages, "\n")
        if allText ~= "" then
            chatFrame:AddMessage(allText)
            ChatEdit_ActivateChat(chatFrame.editBox)
            chatFrame.editBox:SetText(allText)
            chatFrame.editBox:HighlightText()
        end
    end
end)

-- Character name filter
local nameFilterLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nameFilterLabel:SetPoint("TOPLEFT", filterFrame, "TOPLEFT", 10, -30)
nameFilterLabel:SetText("Filter by character:")

local nameFilterEditBox = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
nameFilterEditBox:SetSize(180, 20)
nameFilterEditBox:SetPoint("TOPLEFT", nameFilterLabel, "BOTTOMLEFT", 0, -5)
nameFilterEditBox:SetAutoFocus(false)
nameFilterEditBox:SetText("")
nameFilterEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

-- Keyword list
local keywordLabel = filterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
keywordLabel:SetPoint("TOPLEFT", nameFilterEditBox, "BOTTOMLEFT", 0, -15)
keywordLabel:SetText("Keywords:")

-- Create ScrollFrame for keyword list
local keywordScrollFrame = CreateFrame("ScrollFrame", nil, filterFrame, "UIPanelScrollFrameTemplate")
keywordScrollFrame:SetSize(160, 150)
keywordScrollFrame:SetPoint("TOPLEFT", keywordLabel, "BOTTOMLEFT", 0, -5)

-- Create content frame for keyword list
local keywordContent = CreateFrame("Frame", nil, keywordScrollFrame)
keywordContent:SetSize(160, 150)
keywordScrollFrame:SetScrollChild(keywordContent)

-- Keyword add controls
local keywordEditBox = CreateFrame("EditBox", nil, filterFrame, "InputBoxTemplate")
keywordEditBox:SetSize(120, 20)
keywordEditBox:SetPoint("TOPLEFT", keywordScrollFrame, "BOTTOMLEFT", 0, -10)
keywordEditBox:SetAutoFocus(false)
keywordEditBox:SetText("")

local addKeywordButton = CreateFrame("Button", nil, filterFrame, "UIPanelButtonTemplate")
addKeywordButton:SetSize(60, 22)
addKeywordButton:SetPoint("LEFT", keywordEditBox, "RIGHT", 5, 0)
addKeywordButton:SetText("Add")

-- Table to store keywords
local keywords = {}

-- Function to update keyword list display
local function UpdateKeywordList()
    -- Clear existing keyword frames
    for _, child in pairs({keywordContent:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    
    -- Add keyword entries
    local previousButton
    for i, keyword in ipairs(keywords) do
        local keywordFrame = CreateFrame("Frame", nil, keywordContent)
        keywordFrame:SetSize(160, 20)
        if previousButton then
            keywordFrame:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -2)
        else
            keywordFrame:SetPoint("TOPLEFT", keywordContent, "TOPLEFT", 0, 0)
        end
        
        local keywordText = keywordFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        keywordText:SetPoint("LEFT", keywordFrame, "LEFT", 5, 0)
        keywordText:SetText(keyword)
        
        local removeButton = CreateFrame("Button", nil, keywordFrame, "UIPanelCloseButton")
        removeButton:SetSize(16, 16)
        removeButton:SetPoint("RIGHT", keywordFrame, "RIGHT", -2, 0)
        removeButton:SetScript("OnClick", function()
            table.remove(keywords, i)
            CombatLogViewerDB.keywords = keywords  -- Save keywords when removing
            UpdateKeywordList()
        end)
        
        previousButton = keywordFrame
    end
    
    -- Update content frame height
    keywordContent:SetHeight(math.max(150, #keywords * 22))
end

-- Add keyword button click handler with save
addKeywordButton:SetScript("OnClick", function()
    local keyword = keywordEditBox:GetText():trim()
    if keyword ~= "" then
        table.insert(keywords, keyword)
        CombatLogViewerDB.keywords = keywords  -- Save keywords when adding
        keywordEditBox:SetText("")
        UpdateKeywordList()
    end
end)

keywordEditBox:SetScript("OnEnterPressed", function(self)
    addKeywordButton:Click()
    self:ClearFocus()
end)

-- Make filter frame move with main frame
frame:HookScript("OnDragStart", function()
    filterFrame:StartMoving()
end)

frame:HookScript("OnDragStop", function()
    filterFrame:StopMovingOrSizing()
end)

-- Update the filter frame position when main frame moves
local function UpdateFilterFramePosition()
    filterFrame:ClearAllPoints()
    filterFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)
end

frame:HookScript("OnDragStop", UpdateFilterFramePosition)
frame:HookScript("OnSizeChanged", UpdateFilterFramePosition)

-- Modify the combat log event handler to use the keyword list
local function CheckKeywordMatch(message)
    if #keywords == 0 then
        return true
    end
    
    -- Convert message to lowercase once
    message = message:lower()
    
    -- Check if ANY keyword matches (OR logic)
    for _, keyword in ipairs(keywords) do
        if message:find(keyword:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Initialize saved variables
local function InitializeFrame(frame)
    -- Initialize saved variables if they don't exist
    CombatLogViewerDB = CombatLogViewerDB or {
        point = "CENTER",
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 0,
        width = 400,
        height = 300,
        isShown = false,
        nameFilter = "",
        keywords = {}
    }
    
    -- Apply saved position and size
    frame:ClearAllPoints()
    frame:SetPoint(CombatLogViewerDB.point, UIParent, CombatLogViewerDB.relativePoint, 
                  CombatLogViewerDB.xOfs, CombatLogViewerDB.yOfs)
    frame:SetSize(CombatLogViewerDB.width, CombatLogViewerDB.height)
    
    -- Apply saved visibility
    if CombatLogViewerDB.isShown then
        frame:Show()
        filterFrame:Show()
        -- Register combat log events if frame is shown
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        frame:Hide()
        filterFrame:Hide()
    end

    -- Restore saved name filter
    if CombatLogViewerDB.nameFilter then
        nameFilterEditBox:SetText(CombatLogViewerDB.nameFilter)
    end
    
    -- Restore saved keywords
    if CombatLogViewerDB.keywords then
        keywords = CombatLogViewerDB.keywords
        UpdateKeywordList()
    end
end

-- Save frame state
local function SaveFrameState(frame)
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    CombatLogViewerDB.point = point
    CombatLogViewerDB.relativePoint = relativePoint
    CombatLogViewerDB.xOfs = xOfs
    CombatLogViewerDB.yOfs = yOfs
    CombatLogViewerDB.width = frame:GetWidth()
    CombatLogViewerDB.height = frame:GetHeight()
    CombatLogViewerDB.isShown = frame:IsShown()
    CombatLogViewerDB.nameFilter = nameFilterEditBox:GetText()
    CombatLogViewerDB.keywords = keywords
end

-- Helper function to format combat log values
local function formatValue(value, valueType)
    if valueType == "number" then
        return tostring(value)
    elseif valueType == "string" then
        return value
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    else
        return tostring(value or "nil")
    end
end

-- Register events for initialization and saving
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

-- Handle initialization and saving
local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "CombatLogViewer" then
        InitializeFrame(frame)
    elseif event == "PLAYER_LOGOUT" then
        SaveFrameState(frame)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and frame:IsShown() then
        -- Get all combat log info
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, 
              sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, 
              param1, param2, param3, param4, param5, param6, param7, param8, 
              param9, param10, param11, param12 = CombatLogGetCurrentEventInfo()

        -- Format timestamp
        local timeString = date("%H:%M:%S", timestamp)
        
        -- Initialize message parts
        local parts = {
            string.format("|cFFFFFF00[%s]|r", timeString),  -- Timestamp in yellow
            string.format("|cFF00FF00%s|r", subevent or ""),  -- Event type in green
        }

        -- Add source info if available
        if sourceName then
            local sourceInfo = sourceName
            if sourceGUID then
                local sourceType = select(1, strsplit("-", sourceGUID))
                if sourceType then
                    sourceInfo = string.format("%s (%s)", sourceName, sourceType)
                end
            end
            table.insert(parts, string.format("|cFF69CCF0%s|r", sourceInfo))  -- Source in blue
        end

        -- Add destination info if available
        if destName then
            local destInfo = destName
            if destGUID then
                local destType = select(1, strsplit("-", destGUID))
                if destType then
                    destInfo = string.format("%s (%s)", destName, destType)
                end
            end
            table.insert(parts, string.format("|cFFFF6060%s|r", destInfo))  -- Destination in red
        end

        -- Process additional parameters based on event type
        local extraInfo = {}
        
        -- Handle different event types
        if subevent then
            if subevent:match("DAMAGE") then
                -- Damage events
                if param1 and param4 then  -- spellId/amount
                    table.insert(extraInfo, string.format("Damage: |cFFFFFF00%s|r", formatValue(param4, "number")))
                    if param7 then  -- overkill
                        table.insert(extraInfo, string.format("Overkill: |cFFFFFF00%s|r", formatValue(param7, "number")))
                    end
                    if param10 then  -- critical
                        table.insert(extraInfo, "|cFFFF0000Critical|r")
                    end
                end
            elseif subevent:match("HEAL") then
                -- Healing events
                if param4 then  -- amount
                    table.insert(extraInfo, string.format("Heal: |cFF00FF00%s|r", formatValue(param4, "number")))
                    if param5 then  -- overheal
                        table.insert(extraInfo, string.format("Overheal: |cFFFFFF00%s|r", formatValue(param5, "number")))
                    end
                    if param6 then  -- absorbed
                        table.insert(extraInfo, string.format("Absorbed: |cFFFFFF00%s|r", formatValue(param6, "number")))
                    end
                    if param10 then  -- critical
                        table.insert(extraInfo, "|cFFFF0000Critical|r")
                    end
                end
            elseif subevent:match("MISSED") then
                -- Miss events
                if param1 and param2 then
                    -- Convert param2 to string explicitly to handle both string and boolean cases
                    local missType = type(param2) == "boolean" and (param2 and "true" or "false") or tostring(param2)
                    table.insert(extraInfo, string.format("|cFFFF0000%s|r", missType))
                    if param3 then  -- amount
                        table.insert(extraInfo, string.format("Amount: |cFFFFFF00%s|r", formatValue(param3, "number")))
                    end
                end
            end
        end

        -- Add spell or ability info if available
        if param1 and param2 and type(param1) == "number" then
            table.insert(parts, string.format("|cFFFFCC00[%d] %s|r", param1, param2))  -- Spell ID and name in gold
        end

        -- Add extra info if available
        if #extraInfo > 0 then
            table.insert(parts, string.format("(%s)", table.concat(extraInfo, ", ")))
        end

        -- Format the complete message
        local message = table.concat(parts, " ")
        
        -- Apply filters
        local nameFilter = nameFilterEditBox:GetText():lower()
        
        -- Check character name filter
        if nameFilter ~= "" then
            local sourceMatch = sourceName and sourceName:lower():find(nameFilter, 1, true)
            local destMatch = destName and destName:lower():find(nameFilter, 1, true)
            if not (sourceMatch or destMatch) then
                return
            end
        end
        
        -- Check keyword filters
        if not CheckKeywordMatch(message) then
            return
        end
        
        -- Display the message in the log
        logFrame:AddMessage(message)
    end
end

frame:SetScript("OnEvent", OnEvent)

-- Register/unregister combat log events based on frame visibility
frame:SetScript("OnShow", function()
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)

frame:SetScript("OnHide", function()
    frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    SaveFrameState(frame)
end)

-- Update frame state when hidden
frame:SetScript("OnHide", function()
    SaveFrameState(frame)
end)

-- Update frame state when moved or resized
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveFrameState(frame)
end)

resizeButton:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    SaveFrameState(frame)
end)

-- Add slash command
SLASH_CLV1 = "/clv"
SlashCmdList["CLV"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
        filterFrame:Hide()
    else
        frame:Show()
        filterFrame:Show()
    end
end

-- Update name filter save on change
nameFilterEditBox:SetScript("OnTextChanged", function(self)
    CombatLogViewerDB.nameFilter = self:GetText()
end)