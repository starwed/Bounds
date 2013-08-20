console.log("map tile incoming")
Crafty.c "MapTile",
    init: ()-> @
    setMapInfo: (@map_c, @map_r, @tiledLevel, @mapTileType)-> @
    findRelativeTile: (a, b)->
        if typeof a is "string"
            [dr, dc] = switch a
                when "above" then [-1, 0]
                when "below" then [1, 0] 
                when "right" then [0, 1] 
                when "left" then  [0, -1] 
        else
            [dr, dc] = [a, b]
        @tiledLevel.getTile(@map_r+dr, @map_c+dc)


Crafty.c "TiledLevel",
    makeTiles : (ts, drawType) ->
        {image: tsImage, firstgid: tNum, imagewidth: tsWidth} =ts
        {imageheight: tsHeight, tilewidth: tWidth, tileheight: tHeight} = ts
        {tileproperties: tsProperties} = ts
        #console.log ts
        xCount = tsWidth/tWidth | 0
        yCount = tsHeight/tHeight | 0
        sMap = {}
        #Crafty.load [tsImage], ->
        for i in [0...yCount * xCount] by 1
            #console.log _ref
            posx = i % xCount
            posy = i / xCount | 0 
            sName = "tileSprite#{tNum}"
            tName = "tile#{tNum}"
            sMap[sName] = [posx, posy]
            components = "2D, #{drawType}, #{sName}, MapTile"
            if tsProperties
                if tsProperties[tNum - 1]
                    if tsProperties[tNum - 1]["components"]
                        components += ", #{tsProperties[tNum - 1]["components"]}"
            #console.log components
            Crafty.c tName,
                comp: components
                init: ->
                    @addComponent(@comp)
                    @
            tNum++ 
        #console.log sMap
        Crafty.sprite(tWidth, tHeight, tsImage, sMap)
        return null

    makeLayer : (layer) ->
        #console.log layer
        
        {data: lData, width: lWidth, height: lHeight} = layer
        layerDetails = {tiles:[], width:lWidth, height:lHeight}
        for tDatum, i in lData
            if tDatum
                tile = Crafty.e "tile#{tDatum}"
                tile.x = (i % lWidth) * tile.w
                tile.y = (i / lWidth | 0) * tile.h

                
                tile.addComponent("MapTile")
                tile.setMapInfo(i % lWidth, (i / lWidth | 0), this,  tDatum)
                layerDetails.tiles[i] = tile
        @_layerArray.push(layerDetails)
        #console.log("Layer!!!! \n \n " + layerDetails.tiles)
        return null

    tiledLevel : (levelURL, drawType) ->
        console.log("Starting things off!")
        console.log(levelURL)
        $.ajax
            type: 'GET'
            url: levelURL
            dataType: 'json'
            data: {}
            async: false
            success: (level) =>
                console.log "loaded #{levelURL}"
                {layers: lLayers, tilesets: tss} = level
                drawType = drawType ? "Canvas"
                tsImages = for ts in tss
                    ts.image
                #console.log(tsImages)
                Crafty.load tsImages, =>
                    @makeTiles(ts, drawType) for ts in tss
                    @makeLayer(layer) for layer in lLayers
                    @trigger("TiledLevelLoaded")
                    return null
                return null
        return @

    getTile: (r,c,l=0)->
        layer = @_layerArray[l]
        return null if not layer? or r<0 or r>=layer.height or c<0 or c>=layer.width
        tile = layer.tiles[c + r*layer.width]
        
        if tile
            return tile



    init: -> 
        @_layerArray = []
        
        