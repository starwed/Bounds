console.log("Bounds comp")

# An animated effect that runs once and is destroyed
Crafty.c("AnimatedEffect", {
    init: ()-> 
        this.requires("2D, Canvas, Sprite, SpriteAnimation, Tween")
       


    setAnimation: (reelId, frames)->
        @reelName = reelId
        @animate(reelId, frames)
        return this
        

    setTween: (properties)-> 
        @tweenProp = properties
        return this

    runAnimation: (duration)->
        onAnimationEnd = ()=> 
            @destroy()
        if @reelName
            @bind("AnimationEnd", onAnimationEnd)
            @playAnimation(@reelName, duration)
        if @tweenProp
            @bind("TweenEnd", onAnimationEnd)
            @tween(@tweenProp, duration)
        return this

})


Crafty.c("UIText", {
    init: ()-> 
        this.requires("2D, Text, DOM, Mouse")
            .attr({w:400})  #Default width
            .css({'font-family': 'Helvetica, Arial'})   #Default font
            .textColor('#FFFFFF', 1)    #Default text color
            .textFont({size:"12pt"})

})

Crafty.c("Dialogue", {
    init: ()->

    dialogue: (message, options)->
        this.requires("2D, Canvas, Color, Draggable")
            .color("#333333")
            .attr(w:400, h:400, x:100, y:100)

        @_msg = Crafty.e("2D, DOM, Text")
            .text(message)
            .attr({x: @_x+10, y: @y+10})
            .css({"color": "white"})
        oIndex = 1
        @options = []
        for o in options
            @options[oIndex] = Crafty.e("2D, DOM, Text")
                .text(o.text)
                .attr({x:@_x+10, y:@_y + oIndex*32, w:200})
            oIndex++


        @attach(@_msg)

    close: ()->
        @_msg.destroy()
        @destroy()


})


Crafty.c("TractorBeam", {
    init: ()->
        this.requires("2D, Canvas, tract1, SpriteAnimation, Movable")
            .attr(alpha:0.8)
            .animate("ripple", [[5,0], [4, 0], [3, 0], [2,0], [1, 0], [0, 0]])
            .playAnimation("ripple", 20, -1 )



})

####
#### Game tile elements
####

# Not actually used right now?
Crafty.c("Brick", {
    init: ()->
        this.requires("Platform, Solid")

})


Crafty.c("CrumbleBrick", {
    init:()->
        this.requires("Platform, Solid")


    crumble:(firstcrumble=true)->
        crumbleQueue = []
        if firstcrumble
            Crafty.audio.play('shatter',1, .7)

        @probe = this
        this.x -= 1
        if @probe.hit("CrumbleBrick")
            crumbleQueue.push @probe.hit('CrumbleBrick')[0].obj
        this.x += 2
        if @probe.hit("CrumbleBrick")
            crumbleQueue.push @probe.hit('CrumbleBrick')[0].obj


        eff = Crafty.e("AnimatedEffect, crBrick1")
            .attr({x: this.x, y:this.y, alpha:.8})
            .setAnimation("shatter", [[0,0], [1,0], [2,0], [2,0]])
            .setTween({alpha:.3, y:this.y+20})
            .runAnimation(20)
        this.destroy()
        for e in crumbleQueue
            e.crumble(false)

        return



})
Crafty.c("Stone", {
    init: ()->
        this.requires("Slider, DynamicCollision, Pushable")
        @sound = 'bounce'
        @setFriction(.2)

})

Crafty.c("AntiStone", {

    init: ()->
        @sound = 'bounce'
        this.requires("Slider, DynamicCollision, Pushable, Platform, SpriteAnimation")
        @setFriction(.2)
        this.bind("Moved", @checkGemHit)
        #this.bind("EnterFrame", @pulse)
        @activeNegation = true
        console.log("Adding particles")
        this.addComponent("anti1")
        #this.animate('jarloop', [[0,0], [0,0],  [0,0],  [0,0], [0,0], [0,0],  [0,0],  [1,0], [1,0], [0,0]] )

        return
        #@bind("EnterFrame", @addFountain)
        

    pulse: ()-> 
        #if @isPlaying('jarloop') is false and Math.random()<.05
        #    this.animate('jarloop', 50)

    addFountain: ()->
        if this.has("2D") and this.has("Movable") 
            @unbind("EnterFrame", @addFountain)
        else
            return
        redness = .5;

        options = 
            startColour:[150+100*redness, 200*(1-redness),155 + 150*(1-redness),1],
            startColourRandom:[0, 0, 0, 0]
            endColourRandom:[0, 0, 0, 0]
            endColour:[redness, 0, 255*(1-redness), .5]
            lifespan: 3
            gravity:{x:0,y:0}
            fastMode:false
            maxParticles: 5
            angle: 0
            angleRandom: 180
            size: 4
            sizeRandom: 1
            spread: 4
            speed: 0
            speedRandom: 0
            #jitter: 10
        @fountain = Crafty.e("2D,Canvas,Particles, Movable").particles(options);
        @glue(@fountain, 16, 16)
        @bind("Remove", ()-> 
            @unglue(@fountain)
            @fountain.destroy()
        )
        console.log("particles added")

    setActivity: (flag)-> @activeNegation = flag

    checkGemHit: ()->
        return if not @activeNegation
        
        try
            if this.hit('Gem') 
                Crafty.audio.play('gem',1, 1)
                gem = this.hit('Gem')[0].obj #Crafty(this.hit('Gem')[0].obj[0])
                #console.log("Gem source: " + gem.toSource())
                eff = Crafty.e("AnimatedEffect, negt1")
                    .attr({x: gem.x, y:gem.y})
                    .setAnimation("fade", [[0,0], [1,0], [2,0]])
                    .setTween({alpha:0})
                    .runAnimation(20)
                gem.destroy()
                this.destroy()

        catch e
            console.log(e)


})


Crafty.c("Gem", { 
    init:()-> #this.requires("VisibleMBR").debugAlpha(0.5)
})

Crafty.c("PlayerStart", {
    init: ()-> 
        this.requires("2D")
        this.visible=false

    })

Crafty.c("spikes", {
    init: ()->

})

Crafty.c("OverlayGrid", {
    init: ()->  this.requires("2D, Canvas, gridPattern")

})

Crafty.c("BackdropPicture", {
    init: ()-> this.requires("2D, Canvas, backdrop")

})



Crafty.c("Heart", {
    init: ()->
        this.requires("2D, Collision")


    _attachment: (body)->
        this.bind("EnterFrame", @_enterHeartFrame)
        @_body = body
        body.heart = this
        @y = @_body._y + 6
        @x = @_body._x + 6
        @w = @_body._w - 12
        @h = @_body._h - 12
        poly = new Crafty.polygon([
            0, 0, 
            this.w, 0,
            this.w, this.h,
            0, this.h])
        this.collision(poly)
    _enterHeartFrame: ()->
        #  margin around the heart
        @y = @_body._y + 6
        @x = @_body._x + 6
        @w = @_body._w - 12
        @h = @_body._h - 12
})

###
Crafty.c("Shockwave", {
    init: ()-> 

    run: (x, y)->
        leftwave = Crafty.e("2D, Canvas, Ballistic, shockwaveLeft, Collision, Tween")
        rightwave = Crafty.e("2D, Canvas, Ballistic, shockwaveLeft, Collision, Tween")
        rightwave.flip("X")

        leftwave.y = rightwave.y=y
        leftwave.x = x - 16
        rightwave.x = x + 16
        destructor = ()-> 
            if @hit("Solid")
                @destroy()
        rightwave.bind("EnterFrame", destructor).tween({alpha:0}, 20)
        leftwave.bind("EnterFrame", destructor).tween({alpha:0}, 20)
        leftwave.launch(-3, 0)
        rightwave.launch(3, 0)

        @destroy()



})###


Crafty.c("Arrow", {
    init: ()->
        this.requires("2D, Canvas, arrowSprite")
            .origin("bottom middle")


    setAngle: (angle)->
        angle = angle * 180 / (Math.PI)
        #console.log("Angle #{angle}")
        this.rotation = (90-angle )

})

Crafty.c("PathMarker", {
    init: ()->  
        this.requires("2D, DOM, Color")
            .attr({w:3, h:3}).color("blue")
            .css({"border":"2px solid cyan", "border-radius":"2px"})
        

})


Crafty.c("Hoister", {
    init: ()-> 
        this.requires("Jumpman")

    hoistObject: (target)->
        ox = target.x
        oy = target.y
        target.y = this.y - target.h
        target.x = this.x + this.w/2 - target.w/2
        if target.hit("Solid")
            target.x = ox
            target.y = oy
        else
            @showParabola = true 
            @showParabolaPoints() 
            @hoisted = target
            @hoisted.controlled = true
            @hoisted.grounded = false
            @glue(@hoisted)

            if @hoisted.has("AntiStone")
                @hoisted.setActivity(off)

            @hoistMarker = Crafty.e("TractorBeam")
            @hoistMarker.w = target.w
            @hoistMarker.h = target.h
            @hoistMarker.x = target.x
            @hoistMarker.y = target.y
            target.glue(@hoistMarker)
            plParent = @
            ###@pointer = Crafty.e("Arrow, Movable")
                .bind("EnterFrame", ()-> @setAngle(plParent.calcAngle(plParent.lastmovesign)) )
            @glue(@pointer, -4, -48)###


    unhoist: ()->

        if @hoistMarker?
            @hoisted.unglue(@hoistMarker)
            @hoistMarker.destroy()
        @showParabola = false
        @killParabola()

        @hoisted.controlled = false
        @hoisted._vx = this._vx
        @hoisted._vy = this._vy
        @unglue(@hoisted)
        if @hoisted.has("AntiStone")
                @hoisted.setActivity(on)
        old = @hoisted
        @hoisted = null


        return old

})


Crafty.c("Bounder", {

    init: ()-> 
        this.requires("Jumpman")
        @ppoints = null
        @points = []
        for n in [0..5]
            @points.push({x:0, y:0})
        return

    calcAngle: (xsign)->
        vy = @getVy() + this._vy
        vx = xsign * @getVx() +  this._vx
        #console.log("vx: #{vx}; vy: #{vy}")
        angle = Math.atan2(-vy, vx) 
        #console.log("calculate angle is #{angle}")
        return angle

    calcParabolaPoints: (xsign, N)->
        vy = @getVy() + this._vy
        vx = xsign * @getVx() +  this._vx
        #yofx = (x)-> vy * (x/vx) + 0.5 * (+.2) * (x/vx)*(x/vx)
        y0 = this.y - 16 -2
        x0 = this.x + this.w/2 -2
        for n in [0..N]
            dx = xsign * 16*Math.sqrt(@_boundFactor)* n
            @points[n].x = x0 +  dx 
            @points[n].y = y0 + (dx/vx)* ( vy  +  (.1) * (dx/vx) )
        return @points



    showParabolaPoints: ()->
        #console.log('showing points')
        @ppoints = @calcParabolaPoints(@lastmovesign, 5)
        if not @markers?
            console.log("making markers")
            @markers = []
            @markers.push( Crafty.e("PathMarker").attr({alpha:.7-.08*n}) )for n in [0..5]

        for n in [0..5]
            @markers[n].attr( @ppoints[n])
        return

    killParabola: ()->
        m.destroy() for m in @markers
        @ppoints = null
        @markers = null






    getVy: ()->
        # dvy = sqrt ( 2 * y_max * g)
        # y_max = N*32 + offset
        # BUT our digital reality is not exact, so add fudge factor for longer jumps
        
        # OLD VERSION: dvy =  -.1 - 3.58 * Math.sqrt(@_boundFactor)
        #if @_boundFactor < 6
        dvy = -Math.sqrt( 2 * (@_boundFactor * 32 + 2) * Bounds.GRAVITY)
        #else if @_boundFactor < 10
        #    dvy = -Math.sqrt( 2 * (@_boundFactor * 31 + 3) *GRAVITY)
        #else
        #    dvy = -Math.sqrt( 2 * (@_boundFactor * 31 + 4) *GRAVITY)
        return dvy
    getVx: ()->
        dvx = 1 * Math.sqrt(@_boundFactor)




    flingSomething: (xsign, projectile)->
        return if projectile is false
        dvx = @getVx()
        dvy = @getVy()
        
        #console.log("proj._vy #{projectile._vy}")
        projectile._vy += dvy
        projectile._vx += dvx * xsign
        ###pToBlock = (p)->
            phN = Math.floor(p/32)
            phP = p-phN*32
            return "#{phN} blocks, #{phP} px"###

        pred = (this._vy+dvy)*(this._vy+dvy)/.4
        
        #console.log("current y is #{this.y}")
        this.targetHeight = 32 * @_boundFactor + 7
        hh  = 0
        maxh = 0
        heightWatcher = ()->
            hh = this.start_y - this.y
            #console.log("hh is " + hh)
            #maxh = this.track_h[this.track_h.length-1]
            #Hard cap on how high we can fly.
            if hh> this.targetHeight and this._vy <0
                this._vy = 0
            # Tracking stuff
            if hh >maxh
                maxh = hh
            else
                this.unbind("EnterFrame", heightWatcher)

        this.start_y = this.y
        #this.track_h = [0]
        this.predict = pred
        this.bind("EnterFrame", heightWatcher)
       
    jump: (xsign, bounder=this)->
        console.log("Trying to jump")
        return if bounder is false 
        Crafty.audio.play('jump', 1, .3* Math.min(Math.sqrt(@_boundFactor), 1))
        @flingSomething(xsign, this)
        if @standingOn("CrumbleBrick")
            cb = Crafty(@standingOn('CrumbleBrick')[0].obj[0])
            
            #swy = cb.y
            cb.crumble()
            #Crafty.e("Shockwave").run(@x, cb.y)

        @grounded = false
        @_boundFactor+=1
        @jumps++
        if xsign <0
            jet = Crafty.e("AnimatedEffect, rightJet, Movable")
                .attr({x:@_x+@_w-7, y:@_y+16, w:18, h:17, alpha:0.7})
        else
            jet = Crafty.e("AnimatedEffect, leftJet, Movable")
                .attr({x:@_x-11, y:@_y+16, w:18, h:17, alpha:0.7})


        
        this.glue(jet)
        jet.setTween({alpha:.4})
            .runAnimation(20)
        @trigger("Bounded")


    throw: (xsign, projectile=false)->
        return if projectile is false 
        Crafty.audio.play('jump', 1, .3* Math.min(Math.sqrt(@_boundFactor), 1))
        @flingSomething(xsign, projectile)
        @_boundFactor+=1
        @jumps++
        @trigger("Bounded")


})



Crafty.c("JumpMan", {
    _boundFactor:1
    jumps:0
    dead: false
    g: .1 #Default g value
    init: ()-> 
        this.requires("Ballistic, DynamicCollision, Bounder, Hoister")
        this.requires("Keyboard")
        

        console.log("initing debug canvas")
        ###testPoly = new Crafty.polygon([0, 0], [30, 0], [30, 30], [0, 30]); 
        this.attach(testPoly);
        this.requires("DebugPolygon")
            .debugPolygon( testPoly, "white" );###
        #this.requires("VisibleMBR");#debugAlpha(.8).solidColor("green")

        @heart = Crafty.e("2D, Collision, Heart")._attachment(this)
        @gemhitbox = this #

        @hands = Crafty.e("2D, Collision, Hands")._attachment(this)
        @hands.pushmarkerName = "TractorBeam"

        @active = false
        @dead = false
        @hoisted = null
        @pushed = null

        @sideflame = null

        @pointer = null
        @lastmovesign = 0

        @bind('Moved', @onMove)

        @showParabola = false

        @checker=null

        @sound = 'bounce';


    flicker: ()->
            if this.alpha < 0.8
                this.alpha+= .02
            else
                this.alpha-= .1

    setSprite: (mode)->
        return if @animationMode is mode
        



        # delete sideflame if current animation mode involves it
        if @sideflame?
            @unglue(@sideflame)
            @sideflame.destroy()
            @sideflame = null
        switch mode
            when "dead"
                @sprite(1,0,1,1)
            when "norm"
                
                @sprite(0,0,1,1) if not @dead
            when "right"
                @sprite(2,0,1,1) if not @dead
                @sideflame = Crafty.e("2D, Canvas, leftFlame, Movable")
                @sideflame.attr({x:@_x - 10, y: @_y+9, w:10, h:8, alpha:0.3})
                @sideflame.bind("EnterFrame", @flicker)
                @glue(@sideflame)
                
            when "left"
                @sprite(3,0,1,1)  if not @dead
                   
                
                @sideflame = Crafty.e("2D, Canvas, rightFlame, Movable")
                @sideflame.attr({x:@_x+@_w, y:@_y+9, w:10, h:8, alpha:0.3})
                
                @sideflame.bind("EnterFrame", @flicker)
                @glue(@sideflame)
        @animationMode = mode


    die: ()->
        Bounds.resetMap()
        @dead = false
        Bounds.setStatus("You came back!")




    stepper: (step)->
            if not @checker.hit("Platform")
                    this.trigger("Translate", {x:step, y:0})
                    return true
            else
                return false


    stepDown: ()->
        return if @hoisted or not @grounded  

  
        if not @checker 
            @checker = Crafty.e("2D, Collision")
            @checker.h=2
            @checker.w=4
            #poly = new Crafty.polygon([0, 0], [@checker._w, 0], [@checker._w, @checker._h], [0, @checker._h])
            #@checker.collision(poly)

        @checker.y= this.y+28
        

        
        stepped = false
        

        if @pushed? 
            if @pushed.x > this.x
                @checker.x= @pushed.x + @pushed.w-@checker.w + 1
                if not @checker.hit("Platform")
                    stepped = @stepper(1)
            else
                @checker.attr({x:@pushed.x - 1})
                if not @checker.hit("Platform")
                    stepped = @stepper(-1)
        else
            @checker.x = this.x-1
            if not @checker.hit("Platform")
                stepped = @stepper(-1)
            else 
                @checker.x =this.x+this.w-@checker.w+1
                if not @checker.hit("Platform")
                    stepped = @stepper(1)

        #checker.destroy()
        return stepped

    




    thrust_x: 0.1
    


    


    trigger_action: (xsign)->
        if @hoisted isnt null
            projectile = @unhoist()
            @throw(xsign, projectile)
        else if this.pushed isnt null
            brick = this.pushed
            this.hands._endPush()
            @hoistObject( brick)
        else if this.grounded
            @jump(xsign, this)
        # trigger the boundmeter to update
        Crafty.trigger("UpdateBoundmeter")



    onMove: -> 
            if @showParabola
                @showParabolaPoints()
            
            if @_vx < 0 
                @lastmovesign = -1
            else if @_vx > 0 
                @lastmovesign = 1
            
             # Kill if you hit something deadly...
            # but not if you're already dead or have collected the last gem   
            if @heart.hit('Deadly') and @dead is false and Bounds.level_complete is false
                Bounds.setStatus("You died!")

                @dead = true
                @setSprite("dead")
                Crafty.audio.play('death', .6, 1)
                Bounds.queueSceneChange( (()-> Bounds.player.die()), 1000)


            if @gemhitbox.hit('Gem') 
                
                console.log('gem!')
                try
                    Crafty.audio.play('gem',1, .8)
                    #gem = Crafty(@gemhitbox.hit('Gem')[0].obj[0])
                    gem = @gemhitbox.hit('Gem')[0].obj #Crafty(this.hit('Gem')[0].obj[0])
                    #gem = Crafty(@gemhitbox.hit('Gem')[0].obj[0])
                    if gem.has("PowerUp")
                        @trigger("Bounded")
                        @_boundFactor++
                        Crafty.trigger('UpdateBoundmeter')
                    if gem.has("PowerDown") and @_boundFactor >1
                        @_boundFactor--
                        @trigger("Bounded")
                        Crafty.trigger('UpdateBoundmeter')

                    gem.destroy()
                catch e
                    console.log(e)
            #try
            #    checkWin()
            #catch e
            #    console.log(e)

    

})


#Controls for keyboard
Crafty.c("KeyboardMan", {
    init: ()->
        this.requires("JumpMan, Keyboard")
        this.bind("EnterFrame", @_checkKeys)
        this.bind("KeyDown", this._keydown)
        this.bind("KeyUp", this._keyup)

    _checkKeys: ()->
        
        
        ###if this.isDown('SHIFT')
            #@terminal(1, false)
            @terminal(false, false)
        else
            @terminal(false, false)###

        

        if this.isDown('a') or this.isDown('A') or this.isDown('LEFT_ARROW')
            @setSprite("left") if not @dead
            @active =true
            if @_vx <=0
                @_ax=- @thrust_x # Old value .05
            else
                @_ax=-.3 # Old value .05

        else if this.isDown('d') or this.isDown('D') or this.isDown('RIGHT_ARROW')
            @setSprite("right") if not @dead
            @active =true
            if @_vx >=0
                @_ax=@thrust_x # Old value .05, more recent .08
            else
                @_ax = .3

        else 
            @active = false
            @_ax = 0

        if this.isDown('DOWN_ARROW')
            if not @stepDown() and @grounded
                if @_vx < 0
                    @_ax= +.3
                else if @_vx > 0
                    @_ax= -.3 

        if this.pushed
            @_ax = @_ax/1.5


    _keydown: (e)->
        
        if this.isDown('k') or this.isDown('K')
            this.die()

        if this.isDown('m') or this.isDown('M') or this.isDown('ESC')
            Crafty.scene("loading")
        
       

        switch e.key
            when 37, 'a', 'A'
                @active = true
                @_ax= -@thrust_x 
                @trigger("Translate", {x:-1, y:0})
            when 81
                console.log("Wheee")
                @trigger_action(-1)
            when 69
                console.log("wheee")
                @trigger_action(+1)
            when 39, 'd', 'D'
                @active = true
                @_ax = @thrust_x
                @trigger("Translate", {x:1, y:0})
            when 71 # 'g'
                console.log("toggling?")
                Bounds.toggleGrid()


        if this.pushed
            @_ax = @_ax/1.5

    _keyup: (e)->
        switch e.key
            when 37, 39 
                @_ax=0
                @active = false
                @setSprite("norm") if not @dead


})





Crafty.c("DownIndicator", {
    init: ()->
        this.requires("2D, Canvas, down_arrow")
            .attr({h:32, w:32})

})