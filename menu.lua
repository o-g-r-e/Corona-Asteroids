
local composer = require( "composer" )

local scene = composer.newScene()

local menuMusic

local function gotoGame()
    composer.removeScene( "game" )
    composer.gotoScene( "game", { time=800, effect="crossFade" } )
end
 
local function gotoHighScores()
    composer.removeScene( "highscores" )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "images/background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	local title = display.newImageRect( sceneGroup, "images/title.png", 500, 80 )
	title.x = display.contentCenterX
	title.y = 200
	
	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
	playButton:setFillColor( 0.82, 0.86, 1 )
	playButton:addEventListener( "tap", gotoGame )
	
	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.75, 0.78, 1 )
	highScoresButton:addEventListener( "tap", gotoHighScores )
	
	menuMusic = audio.loadStream( "sounds/Midnight-Crawlers_Looping.wav")
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		audio.play( menuMusic, { channel=1, loops=-1 } )
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end

function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(menuMusics)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene