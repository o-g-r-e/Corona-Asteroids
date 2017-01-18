local composer = require( "composer" )

local scene = composer.newScene()

local lives = 3
local score = 0
local died = false
 
local asteroidsTable = {}
local superGunBullets = 0
 
local ship
local gameLoopTimer
local livesText
local scoreText

local explosionSound
local fireSound
local musicTrack

local physics = require( "physics" )

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

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function initAsteroidPosition(asteroid)

	local function setPosAndVel(asteroid, x, y, velX, velY)
		asteroid.x = x
		asteroid.y = y
		asteroid:setLinearVelocity( velX, velY )
	end
	
	local whereFrom = math.random( 3 )
	
	if ( whereFrom == 1 ) then
		setPosAndVel(asteroid, -60, math.random( 500 ), math.random( 40,120 ), math.random( 20,60 ))
 
	elseif ( whereFrom == 2 ) then
		setPosAndVel(asteroid, math.random( display.contentWidth ), -60, math.random( -40,40 ), math.random( 40,120 ))
 
	elseif ( whereFrom == 3 ) then
		setPosAndVel(asteroid, display.contentWidth + 60, math.random( 500 ), math.random( -120,-40 ), math.random( 20,60 ))
	end
	
	asteroid:applyTorque( math.random( -6,6 ) )
end

local function initAsteroid(asteroid, radius, name)
	table.insert( asteroidsTable, asteroid )
	physics.addBody( asteroid, "dynamic", { radius=radius, bounce=0.8 } )
	asteroid.myName = name
	initAsteroidPosition(asteroid)
end

local function createAsteroid()
    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
	initAsteroid(newAsteroid, 40, "asteroid")
end

local function createSuperGunBonus()
	local newSuperGunBonus = display.newImageRect( backGroup, "images/crate.png", 290, 290 )
	initAsteroid(newSuperGunBonus, 40, "supergunbonus")
end

local function fireLaser()

	local function initLaser(name, x, y, angle)
		local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
		physics.addBody( newLaser, "dynamic", { isSensor=true } )
		newLaser.isBullet = true
		newLaser.myName = name
		newLaser.x = x
		newLaser.y = y
		newLaser:toBack()
		newLaser:rotate(angle)
		return newLaser
	end
	
	if(superGunBullets > 0) then
		local newLaser1 = initLaser("laser", ship.x, ship.y, -30)
		local newLaser2 = initLaser("laser", ship.x, ship.y, 0)
		local newLaser3 = initLaser("laser", ship.x, ship.y, 30)
	
		newLaser1:setLinearVelocity( -320, -480 )
		newLaser2:setLinearVelocity( 0, -480 )
		newLaser3:setLinearVelocity( 320, -480 )
	
		superGunBullets = superGunBullets - 1
	else
		local newLaser = initLaser("laser", ship.x, ship.y, 0)
	
		transition.to( newLaser, { y=-40, time=500, onComplete = function() display.remove( newLaser ) end } )
	end
	
	audio.play( fireSound )
 
end

local function dragShip( event )
 
    local ship = event.target
    local phase = event.phase
 
    if ( "began" == phase ) then
        display.currentStage:setFocus( ship )
        ship.touchOffsetX = event.x - ship.x
 
    elseif ( "moved" == phase ) then
        ship.x = event.x - ship.touchOffsetX
 
    elseif ( "ended" == phase or "cancelled" == phase ) then
        display.currentStage:setFocus( nil )
    end
 
    return true
end

local function restoreShip()
 
    ship.isBodyActive = false
    ship:setLinearVelocity( 0, 0 )
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 100
	
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end

local function endGame()
    composer.setVariable( "finalScore", score )
    composer.removeScene( "highscores" )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function onCollision( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
		
		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			display.remove( obj1 )
			display.remove( obj2 )
 
			audio.play( explosionSound )
			
			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end
			
			score = score + 100
			scoreText.text = "Score: " .. score
		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ))
		then
			if ( died == false ) then
				died = true
				
				lives = lives - 1
				livesText.text = "Lives: " .. lives
 
				if ( lives == 0 ) then
					display.remove( ship )
					timer.performWithDelay( 2000, endGame )
				else
					ship.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
				
				audio.play( explosionSound )
			end
		elseif ( ( obj1.myName == "ship" and obj2.myName == "supergunbonus" ) or
				 ( obj1.myName == "supergunbonus" and obj2.myName == "ship" ) or
				 ( obj1.myName == "supergunbonus" and obj2.myName == "laser" )or
				 ( obj1.myName == "laser" and obj2.myName == "supergunbonus"  ) )
		then
			superGunBullets = 5
			if(obj1.myName ~= "ship" and obj2.myName ~= "ship") then
				display.remove( obj1 )
				display.remove( obj2 )
			else
				if(obj1.myName == "supergunbonus") then
					display.remove( obj1 )
				elseif(obj2.myName == "supergunbonus") then
					display.remove( obj2 )
				end
			end
			
			audio.play( explosionSound )
			
			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end
		end
    end
end

local function gameLoop()
    createAsteroid()
	
	local superGunBonusChance = math.random( 1000 )
	if(superGunBonusChance < 50) then
		createSuperGunBonus()
	end
	
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

function scene:create( event )
    local sceneGroup = self.view
	physics.start()
	physics.setGravity( 0, 0 )
    --physics.pause()
	
	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )
 
	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )
 
	uiGroup = display.newGroup()
	sceneGroup:insert( uiGroup )
	
	local background = display.newImageRect( backGroup, "images/background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
	ship.myName = "ship"
	ship:addEventListener( "tap", fireLaser )
	ship:addEventListener( "touch", dragShip )
	physics.addBody( ship, { radius=30, isSensor=true } )
	
	livesText = display.newText( uiGroup, "Lives: " .. lives, 200, -120, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 550, -120, native.systemFont, 36 )

	explosionSound = audio.loadSound( "sounds/explosion.wav" )
	fireSound = audio.loadSound( "sounds/fire.wav" )
	musicTrack = audio.loadStream( "sounds/80s-Space-Game_Looping.wav")
end

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
		
    elseif ( phase == "did" ) then
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		audio.setVolume( 0.2, { channel=1 } )
		audio.play( musicTrack, { channel=1, loops=-1 } )
    end
end

function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        timer.cancel( gameLoopTimer )
    elseif ( phase == "did" ) then
        Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
		audio.stop( 1 )
		audio.setVolume( 1.0, { channel=1 } )
    end
end

function scene:destroy( event )
 
    local sceneGroup = self.view
    audio.dispose( explosionSound )
    audio.dispose( fireSound )
    audio.dispose( musicTrack )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene