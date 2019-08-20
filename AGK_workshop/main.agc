
// Project: AGK_workshop 
// Created: 2019-08-20

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Infinite Planes" )
SetWindowSize( 480, 640, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 480, 640 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

// Background Sprite
CreateImageColor(999, 128, 255, 255, 255)
CreateSprite(999, 999)
SetSpriteSize(999, GetVirtualWidth(),GetVirtualHeight())

// Start Screen Text
CreateText(1, "Welcome to Air Strike")
SetTextColor(1, 0, 0, 0, 255)
SetTextSize(1, 60)
SetTextPosition(1, GetVirtualWidth()/2 - GetTextTotalWidth(1)/2, GetVirtualHeight()/3 - 10)

CreateText(2, "Press Enter to Begin")
SetTextColor(2, 0, 0, 0, 255)
SetTextSize(2, 40)
SetTextPosition(2, GetVirtualWidth()/2 - GetTextTotalWidth(2)/2, GetTextY(1) + GetTextTotalHeight(1) + 4)

CreateText(3, "Press Q at any time to Quit")
SetTextColor(3, 0, 0, 0, 255)
SetTextSize(3, 40)
SetTextPosition(3, GetVirtualWidth()/2 - GetTextTotalWidth(3)/2, GetTextY(2) + GetTextTotalHeight(2) + 5)

// Score
CreateText(4, "Score: ")
SetTextColor(4, 0, 0, 0, 255)
SetTextSize(4, 40)
SetTextPosition(4, 5, 5)


CreateText(5, "0")
SetTextColor(5, 0, 0, 0, 255)
SetTextSize(5, 40)
SetTextPosition(5, GetTextX(4) + GetTextTotalWidth(4), 5)

// Laser
CreateImageColor(6, 255, 0, 0, 255)
CreateSprite(3,6)
SetSpriteSize(3, 4, 10)
laserx = 0 - GetSpriteWidth(3)
lasery = 0 - GetSpriteHeight(3)
SetSpritePosition(3, laserx, lasery)

// Player Sprite
LoadImage(1, "planes blue.png")
CreateSprite(1, 1)
SetSpriteScale(1, 0.8, 0.8)
playerx = GetVirtualWidth()/2 - GetSpriteWidth(1)/2
playery = GetVirtualHeight() - GetSpriteHeight(1) - 10
SetSpritePosition(1, playerx, playery)

// Enemy Sprite
LoadImage(2, "planes black.png")
LoadImage(3, "planes brown.png")
LoadImage(4, "planes green.png")
LoadImage(5, "planes red.png")
CreateSprite(2, 2)
enemyx as integer
enemyy as integer
speed = 5
gosub updateEnemy
SetSpritePosition(2, enemyx, enemyy)

// Variables
running = 0
score = 0
shooting = 0

do
    gosub startScreen
    if running
		gosub movePlayer
		gosub checkEdges
		gosub moveEnemy
		gosub updateSpritePositions
		gosub checkCollisions
		gosub shootLaser
		gosub laserCollisions
		gosub scoreUp
		gosub updateSpritePositions
	endif
	gosub checkQuit
    Sync()
loop

movePlayer:
	if GetRawKeyState(68) // "d"
		playerx = playerx + 5
	endif
	if GetRawKeyState(65) // "a"
		playerx = playerx - 5
	endif
	if GetRawKeyState(87)
		playery = playery - 5
	endif
	if GetRawKeyState(83)
		playery = playery + 5
	endif
return

checkEdges:
	if playerx > GetVirtualWidth() - GetSpriteWidth(1)
		playerx = GetVirtualWidth() - GetSpriteWidth(1)
	elseif playerx < 0
		playerx = 0
	endif
	if playery > GetVirtualHeight() - GetSpriteHeight(1)
		playery = GetVirtualHeight() - GetSpriteHeight(1)
	elseif playery < 0
		playery = 0
	endif
return

updateEnemy:
	SetSpriteImage(2, Random(2, 5))
	SetSpriteScale(2, 0.8, 0.8)
	SetSpriteFlip(2, 0, 1)
	enemyx = Random(0, GetVirtualWidth() - GetSpriteWidth(2))
	enemyy = 0 - GetSpriteHeight(2) - 10
return

updateSpritePositions:
	SetSpritePosition(1, playerx, playery)
	SetSpritePosition(2, enemyx, enemyy)
return

moveEnemy:
	enemyy = enemyy + speed
	if enemyy > GetVirtualHeight()
		gosub updateEnemy
		if speed < 20
			speed = speed + 2
		endif
	endif
return

checkCollisions:
	if GetSpriteCollision(1, 2)
		playerx = GetVirtualWidth()
		playery = GetVirtualHeight()
		enemyx = GetVirtualWidth()
		enemyy = GetVirtualHeight()
		gosub updateSpritePositions
		running = 0
	endif
return

startScreen:
	
	while not running:
		for i = 1 to 3
			SetTextVisible(i, 1)
		next i
		gosub checkQuit
		if GetRawKeyPressed(13) // "ENTER"
			SetTextVisible(1,0)
			SetTextVisible(2,0)
			SetTextVisible(3,0)
			score = 0
			running =1
		endif
		Sync()
	endwhile
return

checkQuit:
	if GetRawKeyPressed(81) // "Q"
		end
	endif
return

scoreUp:
	score = score + 1
	SetTextString(5, Str(score))
return

shootLaser:
	if GetRawKeyPressed(32) and not shooting
		shooting = 1
		laserx = getSpriteX(1) + GetSpriteWidth(1)/2
		lasery = getSpriteY(1)
	endif
	if shooting
		lasery = lasery - 10
		SetSpritePosition(3, laserx, lasery)
		if lasery < 0 - GetSpriteHeight(3)
			shooting = 0
		endif
	endif
return

laserCollisions:
	if GetSpriteCollision(2, 3)
		score = score + 100
		gosub updateEnemy
		laserx = GetVirtualWidth()
		lasery = GetVirtualHeight()
		SetSpritePosition(3, laserx, lasery)
		shooting = 0
	endif
return
