function displayMessage(msg,time)
    local messageFrame = vgui.Create("DNotify")
    -- Grey background panel
    local background = vgui.Create("DPanel", messageFrame)
    background:Dock(FILL)
    background:SetBackgroundColor(Color(64,64,64,150))
    -- Text, parented to background panel
    local label = vgui.Create("DLabel", background)
    label:SetText(msg)
    
    label:SetTextColor(Color(255,255,255))
    label:SetFont("GModNotify")
    label:Dock(FILL)
    label:SetContentAlignment(5)
    surface.SetFont("GModNotify")
    width,height = surface.GetTextSize(msg)
    print(width .. "," .. height)

    messageFrame:SetWidth(width + 50)
    messageFrame:SetHeight(height + 25)
    
    -- Absolute center, then shift up to top 24th of screen
    messageFrame:Center()
    positionW, positionH = messageFrame:GetPos()
    positionH = ScrH() / 24
    messageFrame:SetPos(positionW, positionH)

    -- Display message
    messageFrame:SetLife(time)
    messageFrame:AddItem(background)
end

function stopCountdownTimer()
    timer.Remove("TimerCountDownHUDTimer")
    hook.Remove("HUDPaint","HUDTimerCountDown")
end

function startCountdownTimer(time)
    timer.Create("TimerCountDownHUDTimer", 1, 0, function()
        hook.Add("HUDPaint", "HUDTimerCountDown", function() 
            draw.SimpleTextOutlined("Voting ends in " .. time .. " seconds.", "DermaDefault", ScrW() / 2, 50, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
        end)
        time = time - 1
        if (time < 1) then
            stopCountdownTimer()
        end
    end)
end

function voteWindow()
    local voteNum = 1
    -- votableMaps = {"ttt_tr_debug_34", "ttt_rooftops_2016_v2","ttt_examplemap"}
    INTERNAL_DARK = Color(56,56,56)

    local frame = vgui.Create("DFrame")
    frame:SetSize(175, 250)
    frame:Center()
    local frameW,frameH = frame:GetPos()
    frame:SetPos(-175, ScrH() / 2)
    frame:MakePopup()
    frame:SetTitle("Map Vote")
    frame:IsActive(false)
    frame:ShowCloseButton(false)
    frame:MoveTo(0,frameH,.5,0,.1)
    
    local label = vgui.Create("DLabel", frame)
    label:Dock(TOP)
    label:SetText("Which map should be next?")
    
    local BackButton = vgui.Create("DButton", frame)
    BackButton:SetText("Undo Last Choice")
    BackButton:SetSize(24,20)
    BackButton:SetImage("icon16/arrow_rotate_clockwise.png")
    BackButton:Dock(TOP)
    BackButton.DoClick = function()
        if voteNum > 1 then
            local tmpMap = votes[#votes]
            for _,map in ipairs(buttons) do 
                if (map:GetText() == #votes .. ": " .. tmpMap) then 
                    print("Found it -- entry " .. _)
                    map:SetEnabled(true)
                    map:SetText(tmpMap)
                    table.remove(votes)
                    voteNum = voteNum - 1
                    if(voteNum-1 != #votableMaps) then
                        label:SetText("Which map should be next?")
                    end
                end
            end
        end
    end

    -- Container for the map buttons
    local container = vgui.Create("DPanel", frame)
    container:SetBackgroundColor(INTERNAL_DARK)
    container:Dock(TOP)
    container:DockPadding(5,5,5,10)

    -- Buttons
    buttons = {}
    for _,map in ipairs(votableMaps) do 
        local DermaButton = vgui.Create("DButton", container)
        DermaButton:SetText(map)
        DermaButton:SetSize(250,30)
        DermaButton:Dock(TOP)
        DermaButton:DockMargin(5,5,5,5)
        DermaButton.DoClick = function() 
            votes[voteNum] = map
            DermaButton:SetEnabled(false)
            DermaButton:SetText(voteNum .. ": " .. map)
            voteNum = voteNum + 1
            if(voteNum-1 == #votableMaps) then
                label:SetText("Submit!")
            end
        end
        table.insert(buttons, DermaButton)
    end
    
    -- Done voting button
    local done = vgui.Create("DButton", frame)
    done:Dock(TOP)
    done:SetText("Done Voting")
    done:SetSize(125,30)
    done:SetIcon("icon16/tick.png")
    done.DoClick = function()
        frame:SetKeyboardInputEnabled(false)
        frame:SetMouseInputEnabled(false)
        local curX,curY = frame:GetPos()
        frame:MoveTo(-177,curY,.5,0,.1, function()
                sendVotes()
            frame:Close()
        end)
    end
    
    -- Allow the GUI to scale to itself
    container:InvalidateLayout(true)
    container:SizeToChildren(false,true)
    frame:InvalidateLayout(true)
    frame:SizeToChildren(false,true)
end

-- voteWindow()