local composer = require( "composer" )
math.randomseed( os.time() )
audio.reserveChannels( 1 )
composer.gotoScene("menu", { time=800, effect="crossFade" })