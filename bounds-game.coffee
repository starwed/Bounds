console.log("Bounds game")
Crafty = window.Crafty
Clamp = (x, a, b)->
    return Math.min(Math.max(x,a),b)
GLOBAL_PUSHED  = null
GRAVITY =  0.2
statusText = null
debugText = null
showDebugText = null
resetMap = null

# Flag to flush saves easily
FLUSH_SAVES = false

INSTRUCTIONS = """
    <div>
        <b>Arrows</b> move.<br/>
        <b>Q</b> & <b>E</b> jump left & right.<br/>
        <b>Down</b> slides off a ledge.<br/> 
        <br/>
        <b>G</b> toggles grid.<br/>
        <b>K</b> restarts.<br/>  
        <b>Esc</b> for level select.
    </div>  
"""


INSTRUCTIONS2 = """
    <div>
        <b>Arrows</b> move.<br/>
        <b>Q</b> & <b>E</b> jump left & right.<br/>
        <b>?</b> for more info.<br/> 
    </div>  
"""





window.Bounds = Bounds = {
    dataVersion: 0.211
    AUTO_ADVANCE: true
    CURRENT_LEVEL: 1
    storage: {}
    dbName: "Bounds0"
    player: {}
    gridVisibility: false



    GRAVITY: GRAVITY

    setStatus: (msg)->
        statusText.text(msg)
    toggleGrid: ()->
        console.log("hey toggled")
        @gridVisibility = not @gridVisibility

        @TheGrid.visible = @gridVisibility


    advance: (time, moves)->
        # Save completion data
        l = Bounds.CURRENT_LEVEL
        lID= window.Bounds.levels[l].url
        if Bounds.completion.levels[lID]?
            levA = Bounds.completion.levels[lID]
        else
            levA = Bounds.completion.levels[lID] = {}

        console.log("Completion to check #{moves} moves in #{time} s against (#{levA.m} mv | #{levA.t} s)")
        levA.passed = true
        # If player has new best moves, record that; if tied, check for best time.
        if levA.m?
            if moves < levA.m  
                console.log("updating move score")      
                levA.m = moves
                levA.t = time
            else if 1.0*moves == 1.0*levA.m and ( (1.0*time) <  (1.0*levA.t) )
                console.log("updating time score only")
                levA.t = 1.0*time
            else
                console.log("WTF?")
                console.log("t: #{time} vs. #{levA.t}")
                console.log("m: #{moves} vs. #{levA.m}")
        else
            console.log("no m?")
            levA.m = moves
            levA.t = time

        #console.log("New completion time: #{Bounds.completion.levels[l].t}")

        Bounds.saveCompletion()
        Bounds.CURRENT_LEVEL++
        if Bounds.levels[Bounds.CURRENT_LEVEL]
            #Clear scene changes
            Bounds.sceneChangeQueued = false
            console.log("About to load #{Bounds.CURRENT_LEVEL}")
            Crafty.scene("load #{Bounds.CURRENT_LEVEL}")

    queueSceneChange: (action, timeout)->
        return if Bounds.sceneChangeQueued is true 
        Bounds.sceneChangeQueued = true
        sceneChange = ()=>
            return if Bounds.sceneChangeQueued is false
            Bounds.sceneChangeQueued = false
            action()

        window.setTimeout(sceneChange, timeout)


}

window.Level = Level = {
    start_time: NaN
    level: null



}

window.Bounds=Bounds

Bounds.db = {
    getValue: (key)->
        return $.jStorage.get(key, null)


    setValue: (key, val)->
        $.jStorage.set(key, val)

    deleteKey: (key)->
        $.jStorage.deleteKey(key)
}

Bounds.loadCompletion = ()->

    version = Bounds.db.getValue("dataVersion")
    console.log("Data version in store is #{version}")
    if Bounds.dataVersion > version or version is null or FLUSH_SAVES is true
        Bounds.db.deleteKey("completion")
        Bounds.db.setValue("dataVersion", Bounds.dataVersion)

    completionJSON = Bounds.db.getValue("completion")
    if completionJSON isnt null
        #console.log(completionJSON)
        try
            Bounds.completion = JSON.parse(completionJSON)
        catch e
            console.log("blech, choking on json completion")
            Bounds.completion = {levels:{}}
            Bounds.saveCompletion()

    else
        Bounds.completion = {levels:{}}


Bounds.saveCompletion = ()->
    console.log("Saving completion values")
    console.log("Saving: " + JSON.stringify(Bounds.completion))
    Bounds.db.setValue("completion", JSON.stringify(Bounds.completion) )
    console.log("Done saving")





##---------------------------------------------------##---------------------------------------------------##




#######
#    Game loop
########



##---------------------------------------------------##---------------------------------------------------##


newPlayer = (start)->
    p =Crafty.e("2D, WebGL, alienNorm, Collision, Ballistic, JumpMan, KeyboardMan, Slider, Solid, Platform")
            .attr({x: start._x, y: start._y, w: 28, h: 24}) # for Component 2D 
            .launch(0, 0)
            .accelerate(0, GRAVITY)
            ._sizeFeet()

    return p

particleEffect = (level)->
    redness = Math.min(1, level/20)
    options = 
        startColour:[150+100*redness, 200*(1-redness),155 + 150*(1-redness),1],
        startColourRandom:[0, 0, 0, 0]
        endColourRandom:[0, 0, 0, 0]
        endColour:[redness, 0, 255*(1-redness), .5]
        lifespan: 5
        gravity:{x:0,y:0}
        fastMode:false
        maxParticles: 5
        angle: 0
        angleRandom: 180
        size: level
        spread: 1
        #jitter: 10
    return Crafty.e("2D,Canvas,Particles, Movable").particles(options).attr({x:100,y:100});


particleBackground = ()->
    options = 
        startColour:[50, 50, 200, 1],
        startColourRandom:[0, 0, 50, 0]
        endColour:[255, 255, 255, .8]
        endColourRandom:[0, 0, 0, .3]
        lifeSpan: 100
        speed: .8
        speedRandom: .2
        gravity:{x:0,y:0}
        fastMode: false
        maxParticles: 20
        angle: 0
        angleRandom: 180
        size: 15
        spread: 400
        backgroundLayer: true
    return Crafty.e("2D,Canvas,Particles, Movable").particles(options).attr({x:500,y:400, z:-100});    



Bounds.playMap = (level, glyph)->
    Level.level = level
    Level.gems = Crafty("Gem").length;
    console.log("Playing map #{glyph}")
    Bounds.level_complete = false
    Bounds.sceneChangeQueued = false
    Bounds.resetMap = ()-> 
        Crafty.scene("load #{glyph}") 
    

    
    #sliceSprites()
           
                


    

    debugText = Crafty.e("2D, DOM, Text").attr({ x: 1000, y: 100, w:200 })
    debugText.text(" ").css({"color": "white"})

    statusText = Crafty.e("2D, DOM, Text, Movable").attr({ x: 500, y: 100 })
    statusText.text("")
    statusText.css({"color": "white"})
    statusText.textFont({size: "10pt"})
    
    #console.log("\nMap\n" + map.toSource() )
    




    pl={}
    dead = false
    win_time = false
    r2d = 180/Math.PI 
    showDebugText = ()->
        return
        debugText.text("""#{@_x},#{@_y}; v:#{@_vx},#{@_vy}; a:#{@_ax},#{@_ay}; 
            active:#{@active}; g:#{@grounded}; Jumps:#{Bounds.player._boundFactor}   
            Gems:#{Crafty('Gem').length}; 
            Friction:#{Bounds.player._fx}  Pushing:#{Bounds.player.pushed?}""")


    
    start = Crafty( Crafty("PlayerStart")[0] )
    Bounds.player = newPlayer(start)
    pl = Bounds.player

    Bounds.TheGrid = Crafty.e("OverlayGrid").
        attr({x: 0, y: 0, alpha:.4} )

    Bounds.TheGrid.visible =  Bounds.gridVisibility

    Bounds.backdrop = Crafty.e("BackdropPicture").
        attr({x: 0, y: 0, alpha:1, z:-100} )

    #Crafty.e("2D, Canvas, Color").attr(h:10, w:10, x:100, y:300).color('red')
    
    #pl.parts = particleEffect(1)
    #particleBackground()
    #pl.glue(pl.parts, 14, 12)

    reactorUpdate = ()->
        return
        @unglue(@parts)
        @parts.destroy()
        @parts=particleEffect(@_boundFactor)
        @glue(@parts, 14-@_boundFactor/2, 12)

    #Bounds.player.bind("Bounded",  reactorUpdate)
        
    

    Level.start_time = (new Date).getTime()

    # Bind enter frame
    Bounds.player.bind("EnterFrame", checkWin)
    #    .bind('EnterFrame', showDebugText)

    ###thing = Crafty.e("2D, Canvas, Sprite, topBlock1")
    thing.x = 100
    thing.y = 300
    thing.w=32
    thing.h=32
    thing.addComponent("topBlock1")###
    #statusText.y = Bounds.player.y - 50
    #statusText.x = Bounds.player.x
    Bounds.player.glue(statusText, 0, -50)


    boundMeter = Crafty.e("2D, DOM, Color")
        .color("#BB0000")
        .attr({x: 1000, y:  600 -32, h: 32, w: 32})
        .css({ "box-shadow":"0px 0px 5px violet inset","border-top-left-radius":"15px","border-bottom-right-radius":"0px"})
        .bind("EnterFrame", ()->
            this.h = Bounds.player._boundFactor * 32
            this.y = 600 - this.h
        )

    boundMeterText = Crafty.e("UIText")
        .attr({x: 1000, y: 605})
        #.bind("EnterFrame", ()->this.text(pl._boundFactor ))
    jumpMeterText = Crafty.e("UIText")
        .attr({x: 1100, y: 605, w:100})
        #.bind("EnterFrame", ()->this.text("Moves: #{pl.jumps}" ) ) 

    #timeText2 = Crafty.e("UIText")
    #    .attr({x: 1100, y: 400, w:100})
    
    
    updateTimeText2 = ()->
        return if Bounds.level_complete 
        current_time = (new Date() ).getTime()
        time = new Date(current_time - Level.start_time)
        this.text("Time: #{time.getMinutes()}:#{ time.getSeconds()}.#{Math.floor(time.getMilliseconds()/100) }")
    
    timeText = Crafty.e("UIText")
        .attr({x: 1100, y: 585, w:100})
        #.bind("EnterFrame", updateTimeText) 

    updateUI = ()->
        boundMeterText.text( Bounds.player._boundFactor)  
        jumpMeterText.text("Moves: #{Bounds.player.jumps}")
        boundMeter.h = Bounds.player._boundFactor * 32
        boundMeter.y = 600-boundMeter.h
        
    boundMeter.bind("UpdateBoundmeter", updateUI)
    Bounds.level_time = 0
    min = 0
    sec = 0
    secD = 0
    updateTime = (data)->
        Bounds.level_time += data.dt
        if not Bounds.level_complete #and (time_ticks % 2 is 1)
            time = Bounds.level_time/1000
            min = (time/60)|0
            sec = (time - 60*min)|0
            secD = (time - 60*min - sec)*10 |0
            timeText.text("Time: #{min}:#{sec}.#{secD}")

    timeText.bind("EnterFrame", updateTime)
    #timeText2.bind("EnterFrame", updateTimeText2)


    titleText = Crafty.e("UIText")
        .attr({x: 100, y: 10, w:400})
        .css({"font-size":"30pt"})
        .textFont({size:"30pt"})
        .text((glyph + 1) + ". " + level.name)

    instructionText = Crafty.e("2D, DOM, HTML, Mouse")
        .attr({x:1000, y: 55, w:198, visible: false})
        .append("#{INSTRUCTIONS}")
        .css(
            {'font-family':'Helvetica, Arial', 'text-align':'right'
            'font-size':'12pt', 'color':'white', 'width':'400', 'visibility':'hidden'})





    instructionText._visible = false

 

    instructionToggle  = Crafty.e("2D, Canvas, Mouse, Keyboard, questionmark")
        .attr({ x: 1170, y: 10, w: 30, h: 30 })
        #.color("#ffffff")
        .bind("Click", -> 
            instructionText.visible = not instructionText.visible 

            )
        .bind("KeyDown", 
            (e)-> instructionText.visible = not instructionText.visible if e.key is  191 )

    instructionText.visible = false
    ###toggleText = Crafty.e("UIText").attr({ x: 1170 + 10, y: 10 + 10 })
        .text("?")
        .textColor('#000000', 1)###
    





    #resetCollisions()
    configureTileGraphics()


configureTileGraphics = ()->
        tiles = Crafty("MapTile")
        console.log("fixing tiles now")
        testBlock = (e, pos)->
            e2 = e.findRelativeTile(pos[0], pos[1])
            if e2 isnt null 
                if (e2?.mapTileType is e.mapTileType) then 0 else 1
            else
                -1000
        testBlock2 = (e, pos)->
            e2 = e.findRelativeTile(pos)
            if e2 isnt undefined then true else false

        for id in tiles
            ent = Crafty(id)
            
            if ent.mapTileType is 1
                adjEmptyTiles = 0
                adjEmptyTiles += testBlock(ent, pos) for pos in [ [-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1] ]

                if adjEmptyTiles>0
                    ent.addComponent("edgeMetal")
                else if adjEmptyTiles<0
                    ent.addComponent("edgeMetal")
                else
                    #console.log("Inner block found!")
                    ent.removeComponent("Solid").removeComponent("Platform").removeComponent("Collision")
                        .addComponent("innerMetal")

            if ent.has("CrumbleBrick")
                ent.addComponent("gbM")

                ###if ent.findRelativeTile("left") isnt undefined 
                    if ent.findRelativeTile("right") isnt undefined
                        ent.addComponent("gbM")
                    else
                        ent.addComponent("gbR")

                else
                    ent.addComponent("gbL")###
resetCollisions = ()->
        boxes = Crafty("Collision")
        for id in boxes
            ent = Crafty(id)
            poly = new Crafty.polygon([0, 0], [ent._w, 0], [ent._w, ent._h], [0, ent._h])
            ent.collision(poly)


checkWin = ()->
        if Bounds.player.grounded and Crafty('Gem').length is 0 and Bounds.player.dead is false and Bounds.level_complete is false
            level = Level.level
            statusText.text("All gems collected!")
            Bounds.level_complete = true
            win_time =  Math.floor( ( Bounds.level_time )/100 ) /10
            win_moves = Bounds.player.jumps
            try
                console.log("Checking time as #{win_moves} in #{win_time} against #{level.par.m}/#{level.par.t} ")
            catch e
                console.log(e)
            
            if level.par?
                if win_time<=level.par.t and win_moves <= level.par.m
                    statusText.text("Very efficient!")
                else if win_time >300 or win_moves > 20
                    statusText.text("Finally...")

            advanceLevel = ()-> Bounds.advance(win_time, win_moves)
            Bounds.queueSceneChange( advanceLevel, 1000)






    
    

    

    
   

                    

    #Crafty.scene("loading")
    #Crafty.scene("loading")
    #Crafty.modules( { TiledLevel: 'DEV' }, 
    #    ()-> Crafty.scene("loading")
    #)

