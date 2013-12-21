-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2013 
-- =============================================================
-- Labels Factory
-- =============================================================
-- Short and Sweet License: 
-- 1. You may use anything you find in the SSKCorona library and sampler to make apps and games for free or $$.
-- 2. You may not sell or distribute SSKCorona or the sampler as your own work.
-- 3. If you intend to use the art or external code assets, you must read and follow the licenses found in the
--    various associated readMe.txt files near those assets.
--
-- Credit?:  Mentioning SSKCorona and/or Roaming Gamer, LLC. in your credits is not required, but it would be nice.  Thanks!
--
-- =============================================================
-- Docs: https://github.com/roaminggamer/SSKCorona/wiki
-- =============================================================

-- External helper functions
local labels

if( not _G.ssk.labels ) then
	_G.ssk.labels = {}
	_G.ssk.labels.presetsCatalog = {}
end

labels = _G.ssk.labels

-- ==
--    ssk.labels:addPreset( presetName, params ) - Creates a label button preset (table containing visual options for label).
-- ==
function labels:addPreset( presetName, params )
	local entry = {}

	self.presetsCatalog[presetName] = entry

	entry.text           = fnn(params.text, "")
	entry.font           = fnn(params.font, native.systemFontBold)
	entry.fontSize       = fnn(params.fontSize, 20)
	entry.textColor          = fnn(params.textColor, {1,1,1,1})

	entry.emboss         = fnn(params.emboss, false)
	entry.embossTextColor     = fnn(params.embossTextColor, {1,1,1,1})
	entry.embossHighlightColor = fnn(params.embossHighlightColor, {1,1,1,1})
	entry.embossShadowColor    = fnn(params.embossShadowColor, {0,0,0,1})

--EFM G2	entry.referencePoint = fnn(params.referencePoint, display.CenterReferencePoint)
end

-- ==
--    ssk.labels:new( params, screenGroup ) - Core builder function for creating new labels.
-- ==
function labels:new( params, screenGroup )

	local screenGroup = screenGroup or display.currentStage

	local tmpParams = {}

	-- 1. Check for catalog entry option and apply FIRST 
	-- (allows us to override by passing params too)
	tmpParams.presetName     = params.presetName, nil 
	local presetCatalogEntry = self.presetsCatalog[tmpParams.presetName]
	if(presetCatalogEntry) then
		for k,v in pairs(presetCatalogEntry) do
			tmpParams[k] = v
		end
	end

	-- 2. Apply any passed params
	if(params) then
		for k,v in pairs(params) do
			tmpParams[k] = v
		end
	end

	-- 3. Ensure all 'required' values have something in them Snag Setting (assume all set)
	tmpParams.x              = fnn(tmpParams.x, display.contentWidth/2)
	tmpParams.y              = fnn(tmpParams.y, 0)
	tmpParams.embossTextColor     = fnn(tmpParams.embossTextColor, {1,1,1,1})
	tmpParams.embossHighlightColor = fnn(tmpParams.embossHighlightColor, {1,1,1,1})
	tmpParams.embossShadowColor    = fnn(tmpParams.embossShadowColor, {0,0,0,1})
--EFM G2	tmpParams.referencePoint = fnn(tmpParams.referencePoint, display.CenterReferencePoint)

	-- Create the label
	local labelInstance
	if(tmpParams.emboss) then
		labelInstance = display.newEmbossedText( tmpParams.text, 0, 0, tmpParams.font, tmpParams.fontSize, tmpParams.textColor )
	else
		labelInstance = display.newText( tmpParams.text, 0, 0, tmpParams.font, tmpParams.fontSize )
	end	

	-- 4. Store the params directly in the 
	for k,v in pairs(tmpParams) do
		labelInstance[k] = v
	end

	-- 5. Assign methods based on embossed or not
	if(labelInstance.emboss) then
		
		if(not labelInstance.setText) then
			function labelInstance:setText( text )
				self.label.text = text
				self.highlight.text = text
				self.shadow.text = text
				self.text = text
				return self.text
			end
		else
			labelInstance._old_setText = labelInstance.setText
			function labelInstance:setText( text )
				labelInstance:_old_setText( text )				
				self.text = text
				return self.text
			end
		end

		-- ==
		--    myLabel:setFillColors( embossTextColor, embossHighlightColor, embossShadowColor ) - Changes text, highlight, and shadow colors for a embossed label.
		-- ==
		function labelInstance:setFillColors( embossTextColor, embossHighlightColor, embossShadowColor )
			self:setTextColor( unpack( embossTextColor ) )

			local color = 
			{
			    highlight = 
			    {
			        r = embossHighlightColor[1]  or 1, 
			        g = embossHighlightColor[2]  or 1, 
			        b = embossHighlightColor[3]  or 1, 
			        a = embossHighlightColor[4]  or 1
			    },
			    shadow =
			    {
			        r = embossShadowColor[1]  or 1, 
			        g = embossShadowColor[2]  or 1, 
			        b = embossShadowColor[3]  or 1, 
			        a = embossShadowColor[4]  or 1
			    }
			}			

			self:setEmbossColor( color )

		end

		-- ==
		--    myLabel:getText( ) - Gets the label text.
		-- ==
		function labelInstance:getText()
			return self.text
		end

	else

		-- ==
		--    myLabel:setText( text ) - Changes the label text.
		-- ==
		function labelInstance:setText( text )
			self.text = text
			return self.text
		end

		function labelInstance:setFillColors( embossTextColor, embossHighlightColor, embossShadowColor )
			print("warning: not embossed text" )
		end

		-- ==
		--    funcname() - description
		-- ==
		function labelInstance:getText()
			return self.text
		end

	end	

	-- 6. Set textColor
	if(labelInstance.emboss) then
		if(labelInstance.textColor) then
			local r = fnn(labelInstance.textColor[1],  1)
			local g = fnn(labelInstance.textColor[2],  1)
			local b = fnn(labelInstance.textColor[3],  1)
			local a = fnn(labelInstance.textColor[4],  1)
			labelInstance:setFillColor(r,g,b,a)
		end

		if(labelInstance.embossTextColor) then
			labelInstance:setTextColor(unpack(labelInstance.embossTextColor))
		end

		if(labelInstance.embossHighlightColor and labelInstance.embossShadowColor) then
			local color = 
			{
			    highlight = 
			    {
			        r = labelInstance.embossHighlightColor[1]  or 1, 
			        g = labelInstance.embossHighlightColor[2]  or 1, 
			        b = labelInstance.embossHighlightColor[3]  or 1, 
			        a = labelInstance.embossHighlightColor[4]  or 1
			    },
			    shadow =
			    {
			        r = labelInstance.embossShadowColor[1]  or 1, 
			        g = labelInstance.embossShadowColor[2]  or 1, 
			        b = labelInstance.embossShadowColor[3]  or 1, 
			        a = labelInstance.embossShadowColor[4]  or 1
			    }
			}			
			labelInstance:setEmbossColor( color )
		end
	else
		if(labelInstance.textColor) then
			local r = fnn(labelInstance.textColor[1],  1)
			local g = fnn(labelInstance.textColor[2],  1)
			local b = fnn(labelInstance.textColor[3],  1)
			local a = fnn(labelInstance.textColor[4],  1)
			labelInstance:setFillColor(r,g,b,a)
		end
	end

	-- 6. Set reference point and do final positioning
--EFM G2	labelInstance:setReferencePoint( labelInstance.referencePoint )
	labelInstance.x = tmpParams.x
	labelInstance.y = tmpParams.y

	if(screenGroup) then
		screenGroup:insert(labelInstance)
	end

	return labelInstance
end


-- ==
--    ssk.labels:presetLabel( group, presetName, text, x, y [, params ] ) - A label builder utilizing a preset to set the label's visual options.
-- ==
function labels:presetLabel( group, presetName, text, x, y, params  )
	local group = group or display.currentStage
	local presetName = presetName or "default"
		
	local tmpParams = params or {}
	tmpParams.presetName = presetName
	tmpParams.text = text
	tmpParams.x = x
	tmpParams.y = y
	
	local tmpLabel = self:new(tmpParams, group)
	return tmpLabel
end


-- ==
--    ssk.labels:quickLabel( group, text, x, y [, font [, fontSize [, textColor ] ] ] ) - An alternative label builder.  Only supports basic text options.
-- ==
function labels:quickLabel( group, text, x, y, font, fontSize, textColor )
	local group = group or display.currentStage
	local tmpParams = 
	{ 
		text = text,
		x = x,
		y = y,
		font = font or native.systemFont,
		fontSize = fontSize or 16,
		textColor  = textColor or _WHITE_
	}

	local tmpLabel = self:new(tmpParams, group)
	return tmpLabel
end

-- ==
--    ssk.labels:quickEmbossedLabel( group, text, x, y [, font [, fontSize [, embossTextColor [, embossHighlightColor [, embossShadowColor ] ] ] ] ] ) An alternative embossed label builder.  Only supports basic embossed options.
-- ==
function labels:quickEmbossedLabel( group, text, x, y, font, fontSize, embossTextColor, embossHighlightColor, embossShadowColor )
	local group = group or display.currentStage
	local tmpParams = 
	{ 
		text = text,
		x = x,
		y = y,
		font = font or native.systemFont,
		fontSize = fontSize or 16,
		embossTextColor  = embossTextColor or _BLACK_,
		embossHighlightColor  = embossHighlightColor or _LIGHTGREY_,
		embossShadowColor  = embossShadowColor or _TRANSPARENT_,
		emboss = true
	}

	local tmpLabel = self:new(tmpParams)
	group:insert(tmpLabel)
	return tmpLabel
end

