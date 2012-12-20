Crafty = window.Crafty
Clamp = (x, a, b)->
    return Math.min(Math.max(x,a),b)


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

spriteInfo = [
    { img:"question.png", x:32, y:32, map: 
        {questionmark: [0, 0]} }
    { img:"tractor2.png", x:32, y:32, map: 
        {tract1: [0,0]
        tract2: [1,0]
        tract3: [2,0]
        tract4: [3,0]
        tract5: [4,0]
        tract6: [5,0]}}
    { img:"question.png", x:32, y:32, 
    map: {questionmark: [0, 0]} }

]




map = {}
Bounds.levels = levels = [
    {url:"bounds-intro.json", name:"Going Up", par:{m:4, t:20}}
    {url:"bounds-intro-floorspikes.json", name:"Mind the Gap", par:{m:3, t:5}}
    {url:"bounds-slightly-tricky-jumps.json", name:"Plateau", par:{m:5, t:15}}
    {url:"bounds-stairsdown.json", name:"The Descent", par:{m:3, t:9}}
    {url:"bounds-false-dichotomy.json", name:"The Choice", par:{m:2, t:7}}
    {url:"bounds-gentle-slope.json", name:"No Hesitation", par:{m:3, t:8}}
    {url:"bounds-intro-ceiling-spikes.json", name:"Head Room", par:{m:2, t:60}} 
    {url:"bounds-powerup-intro.json", name:"Watch the Red", par:{m:1, t:5}}
    {url:"bounds-half-power.json", name:"Half Power", par:{m:1, t:8}}
    {url:"bounds-power-down-intro.json", name:"Emerald Steps", par:{m:5, t:8}}

    {url:"skip.json", name:"There And Back Again", par:{m:7, t:60}}
    {url:"bounds-up-then-down.json", name:"Up and Down", par:{m:5, t:17}}
    {url:"bounds-mix-up.json", name:"Parity Violation", par:{m:6, t:20}}

    {url:"bounds-block-intro.json", name:"Just Push It", par:{m:2, t:13}}
    {url:"golfing-up.json", name:"Hit Jump While Pushing", par:{m:6, t:60}}
    {url:"target-practice.json", name:"Target Practice", par:{m:0, t:60}}
    {url:"window.json", name:"Jaws", par:{m:2, t:30}}
    {url:"breakin.json", name:"Break On Through", par:{m:3, t:15}}
    {url:"bounds-tricky-block-drop.json", name:"Forcefield", par:{m:1, t:60}}
    

    
    
    {url:"bounds-red-diamond-diamond.json", name:"Full Power", par:{m:1, t:8}}


    {url:"intro-negativity.json", name:"Introduction to Negativity", par:{m:2, t:60}}
    {url:"multiple-choice.json", name:"Multiple Choice", par:{m:5, t:30}}  
    {url:"two-short-walls.json", name:"Two Short Walls", par:{m:3, t:60}} 

    {url:"pyramid.json", name:"Pyramid", par:{m:5, t:120}}
    {url:"thedig.json", name:"The Dig", par:{m:4, t:120}}

    {url:"men-in-hats.json", name:"The Hat of Death", par:{m:2, t:7}}
    {url:"crumble-brick-intro.json", name:"Seven Steps Up", par:{m:4, t:12}}
    {url:"tenuous-bridge.json", name:"Central Limit", par:{m:6, t:90}} 
    {url:"FourCorners.json", name:"Quartet", par:{m:6, t:20}} 
    {url:"glass-pyramid.json", name:"Glass Ziggaraut", par:{m:6, t:20}}
    {url:"escalator.json", name:"Good Intentions", par:{m:6, t:30}}

    {url:"sway.json", name:"Drawbridge", par:{m:5, t:60}}       #Needs time?
    

    
    
    {url:"test.json", name:"Test", par:{m:5, t:1000}}
]

for ll in Bounds.levels
    ll.url = "levels/" + ll.url



##---------------------------------------------------##---------------------------------------------------##


#######
#    Game loop
########

##---------------------------------------------------##---------------------------------------------------##

spriteList =  [ "sprites/tractor.png", "sprites/negative-transition",  "sprites/crumble-brick.png", "sprites/metal-tiles-bluesteel.png"
                 "sprites/metal-tiles3.png", "sprites/nebula.jpg", "sprites/gradient1.png", "sprites/antiblock"
                "sprites/block-test.png", "sprites/grid.png", "sprites/question.png", "sprites/glass-brick2.png"
                "sprites/alien.png", "sprites/side-flames.png", "sprites/bottom-flames2.png"]


loadScene = ()->
        console.log("Running loadscene")

        
        Bounds.loadCompletion()
        #Crafty.audio.add('bounce', 'bump2.wav')
        Crafty.audio.add('bounce', 'audio/hit.wav')
        Crafty.audio.add('death', 'audio/death.wav')
        Crafty.audio.add('music-track-1', 'audio/alien-puzzle.wav')
        #Crafty.audio.add('bounce', 'wall.wav')
        Crafty.audio.add('shatter', 'audio/breaking-glass-block.wav')
        Crafty.audio.add('jump', 'audio/jump3.wav')
        #Crafty.audio.add('gem', 'gem-pickup.wav')
        Crafty.audio.add('gem', 'audio/gem.wav')
        Crafty.load( spriteList, ()->Crafty.scene("select") )
        

        sliceSprites()
        Crafty.background("#000")

waitForMap = (level, glyph)->
    console.log("Waiting for map #{glyph}")
    map?.destroy?()
    map = Crafty.e("TiledLevel").tiledLevel(level.url)
        .bind("TiledLevelLoaded", ()-> Bounds.playMap(level, glyph) )
    counter = 0


# ----  Scene for player to choose a level to play

audioPlaying = false
levelSelect = ()->
    if not audioPlaying
        Crafty.audio.play("music-track-1", -1, .5)
        audioPlaying = true

    console.log("Running level select scene")
    Bounds.sceneChangeQueued = false
    levelMenu = []
    xpos = 0
    clickFactory = (name, lIndex)->
        ()->
            console.log("Loading #{name}")
            Bounds.CURRENT_LEVEL = lIndex
            Crafty.scene("load #{lIndex}") 

    levelText = Crafty.e("UIText")
    passedText = Crafty.e("UIText").css({"font-size":"12px"}).textColor('#DDDDDD', 1)
    parText = Crafty.e("UIText").css({"font-size":"12px"}).textColor('#DDDDDD', 1)

    #hover factory
    hoverFactory = (level, l)->
        level_description = level.name
        levH = Bounds.completion.levels[level.url]
        
        if levH?.passed is true
            passed_description = "&nbsp;Best: &nbsp;#{levH.m} mv, #{levH.t} s"
             #Only show par score if player has beaten level
            if level.par?
                par_description ="&nbsp;Par:  #{level.par.m} mv,  #{level.par.t} s"
        else
            passed_description = ""
            par_description = ""

           
        return ()-> 
            levelText.text(level_description )
            passedText.text(passed_description)
            parText.text(par_description)
    #end factory

    completionPoints=0
    for level, lIndex in levels
        console.log("Creating text")
        try
            row = 50 * (xpos % 8) + 50
            col = 50 + 50 * Math.floor(xpos/8)
            selectorText = Crafty.e("UIText").attr({ x: row + 5, y: col + 3 })
                    .text("#{(lIndex+1)}")
                    .textColor('#0000FF', 1)

            selectorBG = Crafty.e("2D, Color, Canvas, Mouse")
                .attr({ x: row, y: col, w: 30, h: 30 })
                .color("#ffffff")
                .bind("Click", clickFactory(level.name, lIndex) )
                .bind("MouseOver", hoverFactory(level, lIndex) )

            lev =  Bounds.completion.levels[level.url]
            if lev?.passed is true
                completionPoints++
                passMarker = Crafty.e("2D, Color, Canvas, Mouse")
                    .attr({ x: row+25, y: col+25, w: 5, h: 5 })
                    .color("#666699")
                if lev.t <= level.par?.t and lev.m <= level.par?.m
                    #selectorBG.color("#3333FF")
                    passMarker.color("blue")
                        .attr({w:5, h:5})
                    #selectorText.textColor("#FFFFFF")
                    completionPoints++
                    #passMarker.color("#000000")
                    #Crafty.e("2D, Color, Canvas, Mouse")
                    #    .attr({ x: row, y: col+25, w: 25, h: 5 })
                    #    .color("cyan")
                    
        catch e
            console.log(e)
        xpos++
    completionRate = Math.floor(completionPoints / 64*100)/100 
    #console.log("length is #{Bounds.levels.length}")
    rateText = Crafty.e("UIText").attr({x:550, y: 50}).text("#{completionRate*100}%")
        .css({"font-size":"200px"})
        .attr(alpha: completionRate*completionRate+.001)


    levelText.attr({x:50, y:col+50 }).text("")
    passedText.attr({x:50, y:col+95 }).text("
        ")
    parText.attr({x:50, y:col+75 }).text("")


    
    instructions2 = Crafty.e("2D, DOM, HTML, Keyboard")
        .attr({x:50, y:col+150, w:(350+32)})
        .replace("""<h1>Bounds</h1>
            #{INSTRUCTIONS2} 
             <br/><br/><small> <a href="attribution.html">Attributions</a></small>""")
        .css({'font-family':'Helvetica, Arial', 'text-align':'right'
        'font-size':'14pt', 'color':'white', 'width':'400'})
        .bind("KeyDown", 
            (e)-> instructions2.replace("""<h1>Bounds</h1>#{INSTRUCTIONS} """)  if e.key is  191 )

sliceSprites = ()->
    ###Crafty.sprite(48, "guard.png", {
        guard1: [0,0],
        guard2: [1,0]
        guardx: [2,0]} )###
    Crafty.sprite(32, 32, "sprites/question.png", {
        questionmark: [0,0]
    })

    Crafty.sprite(960, 640, "sprites/gradient1.png", {
        backdrop: [0, 0]

    })

    Crafty.sprite(960, 640, "sprites/grid.png", {
        gridPattern: [0,0]
    })

    ###Crafty.sprite(32, "shockwave.png", {
        shockwaveLeft: [0,0]
    })###

    Crafty.sprite(32, "sprites/block-test.png", {
        midBlock1: [0,0]
        topBlock1: [1,0]
    })

    Crafty.sprite(32, "sprites/metal-tiles-bluesteel.png", {
        edgeMetal: [0,0]
        innerMetal: [1,0]
    })

    Crafty.sprite(32, "sprites/antiblock.png", {
        anti1: [0,0]
        anti2: [1,0]
    })

    Crafty.sprite(32, "sprites/metal-tiles3.png", {
        outerEdge: [0,0]
        outerAlt: [1,0]
    })

    ###Crafty.sprite(32, "arrow-up.png", {
        arrowSprite: [0,0]
    })###

    Crafty.sprite(32, "sprites/tractor2.png", {
        tract1: [0,0],
        tract2: [1,0]
        tract3: [2,0]
        tract4: [3,0]
        tract5: [4,0]
        tract6: [5,0]} )

    ###Crafty.sprite(16, "test.png", {
        t1: [0,0],
        t2: [1,0]
        t3: [2,0]} )
    ###

    Crafty.sprite(28, 24, "sprites/alien-sprites.png", {
        alienNorm: [0,0]
        alienDie: [1, 0]
        alienR: [2, 0]
        alienL: [3, 0]
        alienLeanL: [4, 0]


    })

    Crafty.sprite(32, 32, "sprites/negative-transition.png", {
        negt1: [0,0]
        negt2: [1, 0]
        negt3: [2, 0]
    })

    Crafty.sprite(32, 32, "sprites/crumble-brick.png", {
        crBrick1: [0,0]
        crBrick2: [1, 0]
        crBrick3: [2, 0]
    })

    Crafty.sprite(32, 32, "sprites/glass-brick2.png", {
        gbL: [0,0]
        gbM: [1, 0]
        gbR: [2, 0]
    })






    Crafty.sprite(10, 8, "sprites/side-flames.png", {
        rightFlame: [0,0]
        leftFlame: [1, 0]
    })
    Crafty.sprite(18, 17, "sprites/bottom-flames2.png", {
        leftJet: [0,0]
        rightJet: [1, 0]
    })


window.onload = ()->
    WIDTH = 1200
    HEIGHT = 640
    # Initialize Crafty
    Crafty.init(WIDTH, HEIGHT)

    loadFactory = (map,glyph)-> ()-> waitForMap(map,glyph)

    console.log("Creating scenes")
    for level, lIndex in levels
        Crafty.scene("load #{lIndex}",loadFactory(level, lIndex) )    
    console.log("scenes done")

    Crafty.scene("loading", loadScene)
    Crafty.scene("select", levelSelect)



    
    

    

    
   

                    

    Crafty.scene("loading")
    #Crafty.scene("loading")
    #Crafty.modules( { TiledLevel: 'DEV' }, 
    #    ()-> Crafty.scene("loading")
    #)

