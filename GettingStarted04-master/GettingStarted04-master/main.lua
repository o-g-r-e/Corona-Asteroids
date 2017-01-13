--
-- Copyright (c) 2016 Corona Labs Inc.
-- Code is MIT licensed and can be reused, see https://www.coronalabs.com/links/code/license
-- Other assets are licensed by their creators:
--    Art assets by Kenney: http://kenney.nl/assets
--    Music and sound effect assets by Eric Matyas: http://www.soundimage.org
-- 

local composer = require( "composer" )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator
math.randomseed( os.time() )

-- this will eventually go to the menu scene.
composer.gotoScene( "menu" )
