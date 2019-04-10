local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local mapImage, scrollImage, mosterOrange, monsterPurple, avatar, portal, xCrystal, xCrystal2
local redTiles = {}
local greenTiles = {}
local blueTiles = {}
local gemTiles = {}
local draggedObj
local monstOState, monstPState
local mapNum, scrollNum, redNum, blueNum, greenNum, gemNum, xCrystalNum
local dacW, dacH = display.actualContentWidth, display.actualContentHeight
local levelNumField, scrollNumField, redNumField, blueNumField, greenNumField
local worldGroup = display.newGroup()
local fontSize = dacW/50
local textFieldWidth = dacW/8
local inputFieldWidth = dacW/30

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- ----------------------------------------------------------------------------------- 
local function custButton(event)
    -- body
    local target = event.target
    local targetX = target.x
    local targetY = target.y
    local targetIndx = target.index
    print(targetX..":"..targetY..":"..targetIndx)
    if (target.lit == true) then
        display.remove(target)
        if (targetIndx == 1) then
            monstOState = display.newImageRect("images/off.png",inputFieldWidth, inputFieldWidth*.4)
            monstOState.x, monstOState.y = targetX, targetY
            monstOState.lit = false
            monstOState.index = 1
            monstOState:addEventListener("tap", custButton)
            worldGroup:insert(monstOState)
        else
            monstPState = display.newImageRect("images/off.png",inputFieldWidth, inputFieldWidth*.4)
            monstPState.x, monstPState.y = targetX, targetY
            monstPState.lit = false
            monstPState.index = 2
            monstPState:addEventListener("tap", custButton)
            worldGroup:insert(monstPState)
        end
    else
        display.remove(target)
        if (targetIndx == 1) then
            monstOState = display.newImageRect("images/on.png",inputFieldWidth, inputFieldWidth*.4)
            monstOState.x, monstOState.y = targetX, targetY
            monstOState.lit = true
            monstOState.index = 1
            monstOState:addEventListener("tap", custButton)
            worldGroup:insert(monstOState)
        else
            monstPState = display.newImageRect("images/on.png",inputFieldWidth, inputFieldWidth*.4)
            monstPState.x, monstPState.y = targetX, targetY
            monstPState.lit = true
            monstPState.index = 2
            monstPState:addEventListener("tap", custButton)
            worldGroup:insert(monstPState)
        end
    end
end
local function dragObj( event )
    -- body
    local target = event.target
    target:toFront()
    if (event.phase == "began")then
        draggedObj = target
    elseif(event.phase == "moved") then
        if draggedObj == nil then
            draggedObj = target
        end
        draggedObj.x = event.x
        draggedObj.y = event.y
    elseif (event.phase == "ended") then
        draggedObj.x = event.x
        draggedObj.y = event.y
        draggedObj = nil
    else
        draggedObj = nil
    end
    return true
end

local function dragBg( event )
    -- body
    if (draggedObj ~= nil) then
        local target = draggedObj
        target:toFront()
        if (event.phase == "began")then
            target = target
        elseif(event.phase == "moved") then
            target.x = event.x
            target.y = event.y
        elseif (event.phase == "ended") then
            target.x = event.x
            target.y = event.y
        else
            draggedObj = nil
        end
    end
    return true
end

local function clearScene( )
    -- body
    display.remove(mapImage)
    display.remove(scrollImage)
    display.remove(monsterOrange)
    display.remove(monsterPurple)
    display.remove(avatar)
    display.remove(portal)
    display.remove(xCrystal)
    display.remove(xCrystal2)
    for i=1, #redTiles do
        display.remove(redTiles[i])
        redTiles[i] = nil
        -- table.remove(redTiles)
    end
    for i=1, #greenTiles do
        display.remove(greenTiles[i])
        greenTiles[i] = nil
        -- table.remove(greenTiles)
    end
    for i=1, #blueTiles do
        display.remove(blueTiles[i])
        blueTiles[i] = nil
        -- table.remove(blueTiles)
    end
    for i=1, #gemTiles do
        display.remove(gemTiles[i])
        gemTiles[i] = nil
        -- table.remove(gemTiles)
    end
end
local function setUpScene( map, scroll, red, blue, green, gems, xCryst, xCryst2, monstO, monstP)
    -- body
    -- print(map..":"..scroll..":"..red..":"..blue..":"..green..":"..gems..":"..xCryst)
    local mapX, mapY, scrollX, scrollY
    if (((dacH/3)*2) < ((dacW/3)*2)*0.65) then
        mapX, mapY = ((dacH/3)*2)*1.5, ((dacH/3)*2)
        scrollX, scrollY = ((dacH/3)*1.5), ((dacH/3)*1.5) * 0.8
    else
        mapX, mapY = (dacW/3)*2, ((dacW/3)*2)*.65
        scrollX, scrollY = dacW/3, (dacW/3)*.8 
    end

    if(map ~= "")then
        mapImage = display.newImageRect("images/map"..(map%10)..".png", mapX, mapY )
        mapImage.x, mapImage.y = mapImage.contentWidth/2, dacH - mapImage.contentHeight/2
        worldGroup:insert(mapImage)
    else
        mapImage = display.newImageRect("images/map"..(1%10)..".png", mapX, mapY )
        mapImage.x, mapImage.y = mapImage.contentWidth/2, dacH - mapImage.contentHeight/2
        worldGroup:insert(mapImage)
    end
    if (scroll ~= "") then
        scrollImage = display.newImageRect("images/scroll"..scroll..".png", scrollX, scrollY )
        scrollImage.x, scrollImage.y = mapImage.x + mapImage.contentWidth/2 + scrollImage.contentWidth/2, dacH - scrollImage.contentHeight/2
        worldGroup:insert(scrollImage)
    else
        scrollImage = display.newImageRect("images/scroll"..(1)..".png", scrollX, scrollY )
        scrollImage.x, scrollImage.y = mapImage.x + mapImage.contentWidth/2 + scrollImage.contentWidth/2, dacH - scrollImage.contentHeight/2
        worldGroup:insert(scrollImage)
    end
    if (red ~= "" and red ~= "0") then
        for i=1,red do
            redTiles[i] = display.newImageRect("images/tileRed.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*redTiles[i].contentWidth)
            redTiles[i].x, redTiles[i].y = xPos, scrollImage.y - scrollImage.contentHeight/2 - redTiles[i].contentHeight/2
            redTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(redTiles[i])
        end
    else
        for i=1,4 do
            redTiles[i] = display.newImageRect("images/tileRed.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*redTiles[i].contentWidth)
            redTiles[i].x, redTiles[i].y = xPos, scrollImage.y - scrollImage.contentHeight/2 - redTiles[i].contentHeight/2
            redTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(redTiles[i])
            redTiles[i].alpha = 0
        end
    end
    if (blue ~= "" and blue ~= "0") then
        for i=1,blue do
            blueTiles[i] = display.newImageRect("images/tileBlue.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*blueTiles[i].contentHeight)
            blueTiles[i].x, blueTiles[i].y = xPos, redTiles[#redTiles].y - blueTiles[i].contentHeight
            blueTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(blueTiles[i])
        end
    else
        for i=1,4 do
            blueTiles[i] = display.newImageRect("images/tileBlue.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*blueTiles[i].contentHeight)
            blueTiles[i].x, blueTiles[i].y = xPos, redTiles[#redTiles].y - blueTiles[i].contentHeight
            blueTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(blueTiles[i])
            blueTiles[i].alpha = 0
        end
    end

    if (green ~= "" and green ~= "0") then
        for i=1,green do
            greenTiles[i] = display.newImageRect("images/tileGreen.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*greenTiles[i].contentHeight)
            greenTiles[i].x, greenTiles[i].y = xPos, blueTiles[#blueTiles].y - greenTiles[i].contentHeight
            greenTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(greenTiles[i])
        end
    else
        for i=1,4 do
            greenTiles[i] = display.newImageRect("images/tileGreen.png", dacW/25, dacW/25)
            local xPos = scrollImage.x - scrollImage.contentWidth/2 + (i*greenTiles[i].contentHeight)
            greenTiles[i].x, greenTiles[i].y = xPos, blueTiles[#blueTiles].y - greenTiles[i].contentHeight
            greenTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(greenTiles[i])
            greenTiles[i].alpha = 0
        end
    end
    if (gems ~="") then
        local case = false
        if (gems == "0") then
            gems = 1
            case = true
        end
        for i=1, gems do
            gemTiles[i] = display.newImageRect("images/crystal.png", dacW/20, (dacW/20)*.65)
            gemTiles[i].x, gemTiles[i].y = mapImage.x + ((mapImage.contentWidth/2)-gemTiles[i].contentWidth/2)-((i-1)*gemTiles[i].contentWidth), mapImage.y - (mapImage.contentHeight/2)-(gemTiles[i].contentHeight/2)
            gemTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(gemTiles[i])
        end
        if (case) then
            gemTiles[#gemTiles].alpha = 0
        end
    else
        for i=1, 1 do
            gemTiles[i] = display.newImageRect("images/crystal.png", dacW/20, (dacW/20)*.65)
            gemTiles[i].x, gemTiles[i].y = mapImage.x + ((mapImage.contentWidth/2)-gemTiles[i].contentWidth/2)-((i-1)*gemTiles[i].contentWidth), mapImage.y - (mapImage.contentHeight/2)-(gemTiles[i].contentHeight/2)
            gemTiles[i]:addEventListener("touch", dragObj)
            worldGroup:insert(gemTiles[i])
            gemTiles[i].alpha = 0
        end
    end
    if (xCryst ~= "") then
        xCrystal = display.newImageRect("images/"..xCryst.."x.png", dacW/25, (dacW/25)*1.2)
        xCrystal.x, xCrystal.y = scrollImage.x + scrollImage.contentWidth/2 - xCrystal.contentWidth/2, scrollImage.y - ((scrollImage.contentHeight/2)+(xCrystal.contentHeight/1.75))
        xCrystal:addEventListener("touch", dragObj)
        worldGroup:insert(xCrystal)
        if (xCryst == "0" ) then
            xCrystal.alpha = 0
        end
    else
        xCrystal = display.newImageRect("images/"..(6).."x.png", dacW/25, (dacW/25)*1.2)
        xCrystal.x, xCrystal.y = scrollImage.x + scrollImage.contentWidth/2 - xCrystal.contentWidth/2, scrollImage.y - ((scrollImage.contentHeight/2)+(xCrystal.contentHeight/1.75))
        xCrystal.alpha = 0
        xCrystal:addEventListener("touch", dragObj)
        worldGroup:insert(xCrystal)
    end

    if (xCryst2 ~= "" ) then
        xCrystal2 = display.newImageRect("images/"..xCryst2.."x.png", dacW/25, (dacW/25)*1.2)
        xCrystal2.x, xCrystal2.y = xCrystal.x, xCrystal.y - (xCrystal.contentHeight)
        xCrystal2:addEventListener("touch", dragObj)
        worldGroup:insert(xCrystal2)
        if (xCryst2 == "0" ) then
            xCrystal2.alpha = 0
        end
    else
        xCrystal2 = display.newImageRect("images/"..(6).."x.png", dacW/25, (dacW/25)*1.2)
        xCrystal2.x, xCrystal2.y = xCrystal.x, xCrystal.y - (xCrystal.contentHeight)
        xCrystal2.alpha = 0
        xCrystal2:addEventListener("touch", dragObj)
        worldGroup:insert(xCrystal2)
    end

    monsterOrange = display.newImageRect("images/monsterOrange.png", dacW/25, (dacW/25)*1.2)
    monsterOrange.x, monsterOrange.y = xCrystal2.x, xCrystal2.y - (xCrystal2.contentHeight)
    monsterOrange:addEventListener("touch", dragObj)
    worldGroup:insert(monsterOrange)
    if (monstO == false) then
        monsterOrange.alpha = 0
    end

    monsterPurple = display.newImageRect("images/monsterPurple.png", dacW/25, (dacW/25)*1.2)
    monsterPurple.x, monsterPurple.y = monsterOrange.x, monsterOrange.y - (monsterOrange.contentHeight)
    monsterPurple:addEventListener("touch", dragObj)
    worldGroup:insert(monsterPurple)
    if (monstP == false) then
        monsterPurple.alpha = 0
    end

    avatar = display.newImageRect("images/avatar.png", dacW/20, (dacW/20)*1.47)
    avatar.x, avatar.y = avatar.contentWidth/2, mapImage.y - (mapImage.contentHeight/2)-(avatar.contentHeight/2)
    avatar:addEventListener("touch", dragObj)
    worldGroup:insert(avatar)

    portal = display.newImageRect("images/portal.png", dacW/20, (dacW/20)*1.25)
    portal.x, portal.y = avatar.x+avatar.contentWidth, mapImage.y - (mapImage.contentHeight/2)-(portal.contentHeight/2)
    portal:addEventListener("touch", dragObj)
    worldGroup:insert(portal)

    
end

local function textListener( event )
    local target = event.target
    local maxLen = target.maxLen
    local sizeLimit = target.max
    local sizeMin = target.min
    local text = event.text

    if ( event.phase == "began" ) then
        -- User begins editing "numericField"
    elseif ( event.phase == "editing" ) then
        if( string.len( text ) > maxLen ) then
            target.text = string.sub( text, 1, maxLen ) 
        end
        if (text ~= nil and text ~= "") then
            if( tonumber(text) > sizeLimit ) then
                target.text = "" 
            end
            if( tonumber(text) < sizeMin ) then
                target.text = "" 
            end
        end
    else
        --do nothing
    end
end

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        if (event.target.id ~= "EXIT") then
            local monstOT, monstPT = false,false
            if monstOState.lit then
                monstOT = true
            end
            if monstPState.lit then
                monstPT = true
            end
            clearScene()
            draggedObj = nil
            setUpScene(levelNumField.text, scrollNumField.text, redNumField.text, blueNumField.text, greenNumField.text, gemNumField.text, xCryNumField.text, xCry2NumField.text, monstOT, monstPT)
        else
            pcall(function(e)native.requestExit()end)
        end

    end
end
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    sceneGroup:insert(worldGroup)
    local bg = display.newRect(dacW/2, dacH/2, dacW, dacH)
    bg:setFillColor(.25)
    worldGroup:insert(bg)
    bg:addEventListener("touch", dragBg)

    mapNum = 1
    scrollNum = 1
    redNum = 4
    blueNum = 4
    greenNum = 4
    gemNum = 6
    xCrystal = 6
    xCrystal2 = 6
    setUpScene(mapNum, scrollNum, redNum, blueNum, greenNum, gemNum, xCrystal, xCrystal2, true, true)
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local LNToptions = 
    {
        text = "Level #",     
        x = textFieldWidth/1.5,
        y = fontSize/1.5,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local levelNumTxt = display.newText( LNToptions )
    levelNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(levelNumTxt)

    -- Create text field
    levelNumField = native.newTextField( levelNumTxt.x+ levelNumTxt.contentWidth/1.8, levelNumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    levelNumField.inputType = "number"
    levelNumField.maxLen = 2
    levelNumField.max = 60
    levelNumField.min = 1
    levelNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(levelNumField)

    local SNToptions = 
    {
        text = "Scroll #",     
        x = textFieldWidth/1.5,
        y = levelNumTxt.y + dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local scrollNumTxt = display.newText( SNToptions )
    scrollNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(scrollNumTxt)

    scrollNumField = native.newTextField( scrollNumTxt.x+ scrollNumTxt.contentWidth/1.8, scrollNumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    scrollNumField.inputType = "number"
    scrollNumField.maxLen = 2
    scrollNumField.max = 12
    scrollNumField.min = 1
    scrollNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(scrollNumField)

    local RNToptions = 
    {
        text = "# of Red",     
        x = levelNumTxt.x + textFieldWidth*1.25,
        y = levelNumTxt.y,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local redNumTxt = display.newText( RNToptions )
    redNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(redNumTxt)

    redNumField = native.newTextField( redNumTxt.x + redNumTxt.contentWidth/1.8, levelNumField.y , inputFieldWidth, inputFieldWidth*.65 )
    redNumField.inputType = "number"
    redNumField.maxLen = 1
    redNumField.max = 4
    redNumField.min = 0
    redNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(redNumField)

    local BNToptions = 
    {
        text = "# of Blue",     
        x = redNumTxt.x,
        y = redNumTxt.y+ dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local blueNumTxt = display.newText( BNToptions )
    blueNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(blueNumTxt)

    blueNumField = native.newTextField( blueNumTxt.x + blueNumTxt.contentWidth/1.8, blueNumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    blueNumField.inputType = "number"
    blueNumField.maxLen = 1
    blueNumField.max = 4
    blueNumField.min = 0
    blueNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(blueNumField)

    local GNToptions = 
    {
        text = "# of Green",     
        x = blueNumTxt.x,
        y = blueNumTxt.y+dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local greenNumTxt = display.newText( GNToptions )
    greenNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(greenNumTxt)

    greenNumField = native.newTextField( greenNumTxt.x + greenNumTxt.contentWidth/1.8, greenNumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    greenNumField.inputType = "number"
    greenNumField.maxLen = 1
    greenNumField.max = 4
    greenNumField.min = 0
    greenNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(greenNumField)

    local GeNToptions = 
    {
        text = "# of Gems",     
        x = redNumTxt.x + textFieldWidth*1.25,
        y = redNumTxt.y,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local gemNumTxt = display.newText( GeNToptions )
    gemNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(gemNumTxt)

    gemNumField = native.newTextField( gemNumTxt.x + gemNumTxt.contentWidth/1.8, redNumField.y , inputFieldWidth, inputFieldWidth*.65 )
    gemNumField.inputType = "number"
    gemNumField.maxLen = 1
    gemNumField.max = 6
    gemNumField.min = 0
    gemNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(gemNumField)

    local xCNToptions = 
    {
        text = "(1) GemX #",     
        x = gemNumTxt.x,
        y = gemNumTxt.y+ dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local xCryNumTxt = display.newText( xCNToptions )
    xCryNumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(xCryNumTxt)

    xCryNumField = native.newTextField( xCryNumTxt.x + xCryNumTxt.contentWidth/1.8, xCryNumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    xCryNumField.inputType = "number"
    xCryNumField.maxLen = 1
    xCryNumField.max = 6
    xCryNumField.min = 0
    xCryNumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(xCryNumField)

    local xC2NToptions = 
    {
        text = "(2) GemX #",     
        x = xCryNumTxt.x,
        y = xCryNumTxt.y+ dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local xCry2NumTxt = display.newText( xC2NToptions )
    xCry2NumTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(xCry2NumTxt)

    xCry2NumField = native.newTextField( xCry2NumTxt.x + xCry2NumTxt.contentWidth/1.8, xCry2NumTxt.y, inputFieldWidth, inputFieldWidth*.65 )
    xCry2NumField.inputType = "number"
    xCry2NumField.maxLen = 1
    xCry2NumField.max = 6
    xCry2NumField.min = 0
    xCry2NumField:addEventListener( "userInput", textListener )
    sceneGroup:insert(xCry2NumField)

    local mONToptions = 
    {
        text = "Orange Guy",     
        x = gemNumTxt.x + textFieldWidth*1.25,
        y = gemNumTxt.y,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local monstOTgglTxt = display.newText( mONToptions )
    monstOTgglTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(monstOTgglTxt)

    monstOState = display.newImageRect("images/on.png",inputFieldWidth, inputFieldWidth*.4)
    monstOState.x, monstOState.y = monstOTgglTxt.x + monstOTgglTxt.contentWidth/1.8, monstOTgglTxt.y
    monstOState.lit = true
    monstOState.index = 1
    monstOState:addEventListener("tap", custButton)
    sceneGroup:insert(monstOState)
    
    local mPNToptions = 
    {
        text = "Purple Guy",     
        x = monstOTgglTxt.x,
        y = monstOTgglTxt.y+dacH/20,
        width = textFieldWidth,
        font = native.systemFont,   
        fontSize = fontSize,
        align = "left"  -- Alignment parameter
    }
     
    local monstPTgglTxt = display.newText( mPNToptions )
    monstPTgglTxt:setFillColor( 1, 0, 0 )
    sceneGroup:insert(monstPTgglTxt)

    monstPState = display.newImageRect("images/on.png",inputFieldWidth, inputFieldWidth*.4)
    monstPState.x, monstPState.y = monstOState.x, monstOState.y + dacH/20
    monstPState.lit = true
    monstPState.index = 2
    monstPState:addEventListener("tap", custButton)
    sceneGroup:insert(monstPState)
     
    local sqaures = {}

    for i=1,4 do
        local sX
        if (i == 1) then
            sX = (levelNumTxt.x - levelNumTxt.contentWidth/2) + ((levelNumField.x + levelNumField.contentWidth/2)-(levelNumTxt.x - levelNumTxt.contentWidth/2))/2
        elseif (i == 2) then
            sX = (redNumTxt.x - redNumTxt.contentWidth/2) + ((redNumField.x + redNumField.contentWidth/2)-(redNumTxt.x - redNumTxt.contentWidth/2))/2
        elseif (i == 3) then
            sX = (gemNumTxt.x - gemNumTxt.contentWidth/2) + ((gemNumField.x + gemNumField.contentWidth/2)-(gemNumTxt.x - gemNumTxt.contentWidth/2))/2
        else
            sX = (monstOTgglTxt.x - monstOTgglTxt.contentWidth/2) + ((monstOState.x + monstOState.contentWidth/2)-(monstOTgglTxt.x - monstOTgglTxt.contentWidth/2))/2
        end
        sqaures[#sqaures+1] = display.newRect(sX, ((dacH/20)*3)/2, textFieldWidth+inputFieldWidth, (dacH/18)*3)
        sqaures[#sqaures].strokeWidth = 1
        sqaures[#sqaures]:setFillColor( 0.5 )
        sqaures[#sqaures]:setStrokeColor( 0, 0, 0 )
        worldGroup:insert(sqaures[#sqaures])
    end

    -- Create the widget
    local submitButton = widget.newButton(
    {
        width = textFieldWidth/1.5,
        height = textFieldWidth/5.5,
        id = "submitButton",
        label = "SUBMIT",
        labelColor = { default={ 0, 0, 1 }, over={ .25, .25, 1 } },
        onEvent = handleButtonEvent,
        align = "center" 
    })
    submitButton._view._label.size = textFieldWidth/6
    submitButton.x, submitButton.y = monstPTgglTxt.x, monstPTgglTxt.y + dacH/22.5

    -- Create the widget
    local closeButton = widget.newButton(
    {
        width = textFieldWidth/1.5,
        height = textFieldWidth/5.5,
        id = "EXIT",
        label = "EXIT",
        labelColor = { default={ 0, 0, 1 }, over={ .25, .25, 1 } },
        onEvent = handleButtonEvent,
        align = "center" 
    })
    closeButton._view._label.size = textFieldWidth/5.5
    closeButton.x, closeButton.y = dacW - closeButton.contentWidth/2,closeButton.contentHeight/2

    -- local rect = display.newRect(dacW - submitButton.contentWidth/2, submitButton.contentHeight/2, textFieldWidth/1.5,textFieldWidth/5.5 )
    -- submitButton:toFront()

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene