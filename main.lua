-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {}
local superGunBullets = 0
 
local ship
local gameLoopTimer
local livesText
local scoreText

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    }
}

local objectSheet = graphics.newImageSheet( "images/gameObjects.png", sheetOptions )

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect( backGroup, "images/background.png", 800, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
ship.myName = "ship"

physics.addBody( ship, { radius=30, isSensor=true } )

livesText = display.newText( uiGroup, "Lives: " .. lives, 200, -120, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 550, -120, native.systemFont, 36 )

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function createAsteroid(scale)
 
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
	newAsteroid.myName = "asteroid"
	
	local whereFrom = math.random( 3 )
	
	if ( whereFrom == 1 ) then
		-- From the left
		newAsteroid.x = -60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
 
	elseif ( whereFrom == 2 ) then
		-- From the top
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
 
	elseif ( whereFrom == 3 ) then
		-- From the right
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
		
	end
	
	newAsteroid:applyTorque( math.random( -6,6 ) )
 
end

local function createSuperGunBonus()
	local newSuperGunBonus = display.newImageRect( backGroup, "images/supergun.png", 90, 90 )
	table.insert( asteroidsTable, newSuperGunBonus )
	physics.addBody( newSuperGunBonus, "dynamic", { radius=40, bounce=0.8 } )
	newSuperGunBonus.myName = "supergunbonus"
	
	local whereFrom = math.random( 3 )
	
	if ( whereFrom == 1 ) then
		-- From the left
		newSuperGunBonus.x = -60
		newSuperGunBonus.y = math.random( 500 )
		newSuperGunBonus:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
 
	elseif ( whereFrom == 2 ) then
		-- From the top
		newSuperGunBonus.x = math.random( display.contentWidth )
		newSuperGunBonus.y = -60
		newSuperGunBonus:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
 
	elseif ( whereFrom == 3 ) then
		-- From the right
		newSuperGunBonus.x = display.contentWidth + 60
		newSuperGunBonus.y = math.random( 500 )
		newSuperGunBonus:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
		
	end
	
	newSuperGunBonus:applyTorque( math.random( -6,6 ) )
end

local function fireLaser()

if(superGunBullets > 0) then

	local newLaser1 = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser1, "dynamic", { isSensor=true } )
    newLaser1.isBullet = true
	newLaser1.myName = "laser"
	newLaser1.x = ship.x
	newLaser1.y = ship.y
	newLaser1:toBack()
	newLaser1:rotate(-30)
	
	local newLaser2 = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser2, "dynamic", { isSensor=true } )
    newLaser2.isBullet = true
	newLaser2.myName = "laser"
	newLaser2.x = ship.x
	newLaser2.y = ship.y
	newLaser2:toBack()
	
	local newLaser3 = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser3, "dynamic", { isSensor=true } )
    newLaser3.isBullet = true
	newLaser3.myName = "laser"
	newLaser3.x = ship.x
	newLaser3.y = ship.y
	newLaser3:toBack()
	
	newLaser1:setLinearVelocity( -320, -480 )
	newLaser2:setLinearVelocity( 0, -480 )
	newLaser3:setLinearVelocity( 320, -480 )
	newLaser3:rotate(30)
	
	superGunBullets = superGunBullets - 1
else
    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor=true } )
    newLaser.isBullet = true
	newLaser.myName = "laser"
	
	newLaser.x = ship.x
	newLaser.y = ship.y
	
	newLaser:toBack()
	
	transition.to( newLaser, { y=-40, time=500, onComplete = function() display.remove( newLaser ) end } )
end
 
end

ship:addEventListener( "tap", fireLaser )

local function dragShip( event )
 
    local ship = event.target
    local phase = event.phase
 
    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x
 
    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
 
    elseif ( "ended" == phase or "cancelled" == phase ) then
        -- Release touch focus on the ship
        display.currentStage:setFocus( nil )
    end
 
    return true  -- Prevents touch propagation to underlying objects
end

ship:addEventListener( "touch", dragShip )

local function restoreShip()
 
    ship.isBodyActive = false
    ship:setLinearVelocity( 0, 0 )
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end

local function onCollision( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
		
		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )
 
			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end
 
			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score
		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ))
		then
			if ( died == false ) then
				died = true
 
				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives
 
				if ( lives == 0 ) then
					display.remove( ship )
				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		elseif ( ( obj1.myName == "ship" and obj2.myName == "supergunbonus" ) or
				 ( obj1.myName == "supergunbonus" and obj2.myName == "ship" ) or
				 ( obj1.myName == "supergunbonus" and obj2.myName == "laser" )or
				 ( obj1.myName == "laser" and obj2.myName == "supergunbonus"  ) )
		then
			superGunBullets = 5
			if(obj1.myName == "supergunbonus") then
				display.remove( obj1 )
			end
			if(obj2.myName == "supergunbonus") then
				display.remove( obj2 )
			end
			
			if(obj1.myName == "laser") then
				display.remove( obj1 )
			end
			if(obj2.myName == "laser") then
				display.remove( obj2 )
			end
			
			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end
		end
    end
end

Runtime:addEventListener( "collision", onCollision )

local function gameLoop()
 
    -- Create new asteroid
    createAsteroid()
	
	local superGunBonusChance = math.random( 1000 )
	if(superGunBonusChance < 50) then
		createSuperGunBonus()
	end
 
    -- Remove asteroids which have drifted off screen
    for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]
 
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth + 100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight + 200 )
        then
            display.remove( thisAsteroid )
            table.remove( asteroidsTable, i )
        end
    end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )