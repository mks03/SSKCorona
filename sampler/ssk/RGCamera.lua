-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2015
-- =============================================================
--  ** RGCamera
-- =============================================================
-- 								License
-- =============================================================
--[[
	> SSK is free to use.
	> SSK is free to edit.
	> SSK is free to use in a free or commercial game.
	> SSK is free to use in a free or commercial non-game app.
	> SSK is free to use without crediting the author (credits are still appreciated).
	> SSK is free to use without crediting the project (credits are still appreciated).
	> SSK is NOT free to sell for anything.
	> SSK is NOT free to credit yourself with.
]]
-- =============================================================
local camera = {}
_G.ssk.camera = camera

local mDeg  	= math.deg
local mRad  	= math.rad
local mCos  	= math.cos
local mSin  	= math.sin
local mAcos 	= math.acos
local mAsin 	= math.asin
local mSqrt 	= math.sqrt
local mCeil 	= math.ceil
local mFloor 	= math.floor
local mAtan2 	= math.atan2
local mPi 		= math.pi
local isValid 	= display.isValid

local getTimer  = system.getTimer
local mAbs 		= math.abs


local function add( x1, y1, x2, y2 )
	return x2+x1, y2+y1
end

local function sub( x1, y1, x2, y2 )
	return x2-x1, y2-y1
end

local function len( x, y )
	return mSqrt( x * x + y * y )
end

local function norm( x, y, doNorm )
	if( not doNorm ) then
		return x, y
	end
	local vLen = len( x, y )
	return x/vLen, y/vLen
end

local function a2v( angle )
	return a2vCache[angle][1], a2vCache[angle][2] 
end

local function v2a( x, y )
	return mCeil(mAtan2( y, x ) * 180 / mPi) + 90	
end

local function scale( x, y, mag )
	return x*mag,y*mag
end


----------------------------------------------------------------------
--	3. Definitions
----------------------------------------------------------------------

-- ==
--		tracking() - Follows target exactly.
-- ==
function camera.tracking( trackObj, layers, params )	
	if( not isValid( layers ) ) then return end
	
	params = params or {}	
	local lockX = params.lockX 
	local lockY = params.lockY
	local centered = fnn( params.centered, false)
	--local trackRot = fnn(params.trackRot, false)

	local lx = 0
	local ly = 0

	if( centered ) then
		if( lockX ) then
			lx = trackObj.x
		else
			lx = centerX
		end

		if( lockY ) then
			ly = trackObj.y
		else
			ly = centerY
		end
	else
		lx = trackObj.x
		ly = trackObj.y
	end

	--local lr = trackObj.rotation

	layers.world.enterFrame = function( event )
		if( not isValid( layers ) ) then return end
		if( not isValid( trackObj ) ) then return end
		local dx = 0
		local dy = 0
		if(not lockX) then dx = trackObj.x - lx end		
		if(not lockY) then dy = trackObj.y - ly end
		if(dx or dy) then	
			layers.world:translate(-dx,-dy)
			lx = trackObj.x
			ly = trackObj.y
		end
		return true
	end
	Runtime:addEventListener( "enterFrame", layers.world )
end

-- ==
--		trackingLooseSquare() - Follows target, but has a deadzone followed by an acceleration zone to gradually move the camera.
-- ==
function camera.trackingLooseSquare( trackObj, boundarySize, layers, params )	
	if( not isValid( layers ) ) then return end

	local minDelta = 0.2

	local boundarySize = boundarySize or 240
	local halfBoundary = boundarySize/2 

	local top = boundarySize
	local bot = h - boundarySize
	local left = boundarySize
	local right = w - boundarySize

	layers.lx = trackObj.x
	layers.ly = trackObj.y

	layers.world.enterFrame = function( event )
		if( not isValid( layers ) ) then return end
		local dx = trackObj.x - layers.lx
		local dy = trackObj.y - layers.ly

		local lx, ly = trackObj:localToContent( 0, 0 ) 

		
		if( lx > left and lx < right and ly > top and ly < bot ) then 
			layers.lx = trackObj.x
			layers.ly = trackObj.y
			return true 
		end

		local ddy = 0
		local ddx = 0

		if(ly >= bot) then
			ddy = (mAbs( ly - bot )/ boundarySize) + minDelta
		
		elseif(ly <= top) then
			ddy = (mAbs( ly - top )/ boundarySize) + minDelta			
		end
		if( ddy > 1) then ddy = 1 end

		if(lx >= right) then
			ddx = (mAbs( lx - right )/ boundarySize) + minDelta
		
		elseif(lx <= left) then
			ddx = (mAbs( lx - left )/ boundarySize) + minDelta			

		end
		if( ddx > 1) then ddx = 1 end

		if(dx or dy) then	
			--print( trackObj:contentToLocal( 0, 0 ) )
			--print( trackObj:localToContent( 0, 0 ) )
			layers.world:translate(-dx * ddx,-dy * ddy)
			layers.lx = trackObj.x
			layers.ly = trackObj.y
		end

		return true
	end
	Runtime:addEventListener( "enterFrame", layers.world )
end


-- ==
--		trackingLooseCircle() - Same as loose, but using bounding circle
-- ==
function camera.trackingLooseCircle( trackObj, deadRadius, bufferSize, layers, params )	
	if( not isValid( layers ) ) then return end

	local params     = params or {}
	local debugEn 	 = params.debugEn or false
	local deadRadius = deadRadius or 100
	local bufferSize = bufferSize or 50
	local maxRadius  = deadRadius + bufferSize

	local innerCircle 
	local outerCircle

	if( debugEn ) then
		innerCircle = display.newCircle( layers.overlay, centerX, centerY, deadRadius )
		innerCircle:setFillColor(0,0,0,0)
		innerCircle:setStrokeColor(0,1,1,1)
		innerCircle.strokeWidth = 2

		if( bufferSize > 0 ) then
			outerCircle = display.newCircle( layers.overlay, centerX, centerY, maxRadius )
			outerCircle:setFillColor(0,0,0,0)
			outerCircle:setStrokeColor(1,0,0,1)
			outerCircle.strokeWidth = 2
		end
	end

	layers.lx = trackObj.x
	layers.ly = trackObj.y

	layers.world.enterFrame = function( event )
		if( not isValid( layers ) ) then return end
		local dx = trackObj.x - layers.lx
		local dy = trackObj.y - layers.ly
		local lx, ly = trackObj:localToContent( 0, 0 )  -- EFM will allow for offset camera centering?
		local olx, oly = lx - centerX, ly - centerY

		local vLen = len( olx, oly )

		if( innerCircle ) then innerCircle:toFront() end
		if( outerCircle ) then outerCircle:toFront() end

		--print( vLen, olx, oly, deadRadius, bufferSize, maxRadius)
		
		if( vLen <= deadRadius) then 
			layers.lx = trackObj.x
			layers.ly = trackObj.y
			return true 
		end

		local dLen 
		local moveDelta

		if( bufferSize == 0 ) then
			moveDelta = 1
		else
			dLen = vLen - deadRadius
			if(dLen > bufferSize) then dLen = bufferSize end
			moveDelta = dLen/bufferSize
		end


		if(dx or dy) then	
			layers.world:translate(-dx * moveDelta,-dy * moveDelta)
			layers.lx = trackObj.x
			layers.ly = trackObj.y
		end

		return true
	end
	Runtime:addEventListener( "enterFrame", layers.world )
end

function camera.trackingLooseSquare_orig( trackObj, boundarySize )	
	local settings	= settingsMgr.get()
	local layers	= layersMgr.get()
	if( not isValid( layers ) ) then return end
	

	local boundarySize = boundarySize or 240
	local halfBoundary = boundarySize/2 

	local top = boundarySize
	local bot = h - boundarySize
	local left = boundarySize
	local right = w - boundarySize

	layers.lx = trackObj.x
	layers.ly = trackObj.y

	layers.world.enterFrame = function( event )
		if( not isValid( layers ) ) then return end
		local dx = trackObj.x - layers.lx
		local dy = trackObj.y - layers.ly

		local lx, ly = trackObj:localToContent( 0, 0 ) 

		
		if( lx > left and lx < right and ly > top and ly < bot ) then 
			layers.lx = trackObj.x
			layers.ly = trackObj.y
			return true 
		end
		if(dx or dy) then	
			--print( trackObj:contentToLocal( 0, 0 ) )
			--print( trackObj:localToContent( 0, 0 ) )
			layers.world:translate(-dx,-dy)
			layers.lx = trackObj.x
			layers.ly = trackObj.y
		end

		return true
	end
	Runtime:addEventListener( "enterFrame", layers.world )
end

----------------------------------------------------------------------
--	4. The Module
----------------------------------------------------------------------
return camera