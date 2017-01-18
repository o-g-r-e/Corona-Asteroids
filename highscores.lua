local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
 
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local highscoresMusic

local function loadScores()
 
    local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function gotoMenu()
    composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

function scene:create( event )
 
    local sceneGroup = self.view
	
    loadScores()
	
    table.insert( scoresTable, composer.getVariable( "finalScore" ) )
    composer.setVariable( "finalScore", 0 )
	
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )
	
    saveScores()
 
    local background = display.newImageRect( sceneGroup, "images/background.png", 800, 1400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
 
    local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44 )
 
    for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 150 + ( i * 56 )
 
            --local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 36 )
            --rankNum:setFillColor( 0.8 )
            --rankNum.anchorX = 1
 
            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX, yPos, native.systemFont, 36 )
            thisScore.anchorX = 0.5
        end
    end
 
    local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44 )
    menuButton:setFillColor( 0.75, 0.78, 1 )
    menuButton:addEventListener( "tap", gotoMenu )
	
	highscoresMusic = audio.loadStream( "sounds/Escape_Looping.wav")
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if ( phase == "did" ) then
		audio.play( highscoresMusic, { channel=1, loops=-1 } )
	end
end

function scene:hide( event )
    local phase = event.phase
	
    if ( phase == "did" ) then
		audio.stop( 1 )
    end
end

function scene:destroy( event )
	audio.dispose(highscoresMusic)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene