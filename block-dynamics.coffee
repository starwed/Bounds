
console.log("Block dyn\n")
GLOBAL_PUSHED  = null
GRAVITY =  0.2
FRICTION = 0.3
RESTITUTION = 1/8





Crafty.c("DynamicCollision", {
    init: ()-> 
        this.requires("Solid, Ballistic, BounceMethods")
        this.bind("Collide", @chooseCollision)


    chooseCollision: (collisionInfo)->
        firstHit = collisionInfo.objs[0].obj
        if firstHit.has("DynamicCollision")
            @doCollision(this, firstHit)
        else 
            A = @getGlueTop()
            if A._bounce?
                A._bounce(collisionInfo.move)
            
        return

    # A and B are the objects colliding
    doCollision: (A, B) ->
        
        # Find a vector for collision axis, from A towards B
        r = 
            x: B.x + B._w/2- A.x - A._w/2
            y: B.y + B._h/2 - A.y - A._h/2

        r_sq = r.x*r.x + r.y* r.y
        r_mag = Math.sqrt(r_sq)

        rhat = 
            x: r.x/r_mag
            y: r.y/r_mag

        #Move up the chain to controlling objects if necessary
        A = A.getGlueTop()
        B = B.getGlueTop()

        # If the collision is on the ground, force it to be along the x or y axis.
        # If the collision is in the air, we allow more dynamic collisions (FALSE, but wast true)

        # All objects currently considered are square blocks
        #if (A.grounded and B.grounded)
        if Math.abs(rhat.x) > Math.abs(rhat.y)
            if rhat.x >0
                rhat = {x: 1, y:0}
            else
                rhat = {x:-1, y:0}
        else
            if rhat.y>0
                rhat = {x:0, y:1}
            else
                rhat = {x:0, y:-1}

        #Find component of V projected onto collision axis
        Va = A._vx * rhat.x + A._vy * rhat.y
        Vb = B._vx * rhat.x + B._vy * rhat.y

        #Calculate change in velocity along axis of collision
        [dVa, dVb] = @collisionOnAxis(Va, Vb, @restitution)

        #Assign new values to velocity
        A._vx +=  dVa * rhat.x
        A._vy +=  dVa * rhat.y

        B._vx += dVb * rhat.x
        B._vy += dVb * rhat.y


        return



    # for now, assume M_a = M_b
    # C is coefficient that tells us what speed of separation looks like
    collisionOnAxis: (Va, Vb, C)->
        nVa = (1/2) * ( (1+C)*Vb + (1-C)*Va )
        nVb = (1/2) * ( (1+C)*Va + (1-C)*Vb )
        # Return delta V for each 
        return [nVa - Va, nVb - Vb]

})

Crafty.c("Platform", {
    init: ()-> this.requires("Solid")
})

Crafty.c("Pushable", {
    
    init: ()->
        this.requires("2D, Ballistic, Slider, Supportable, Collision, Solid")
            .accelerate(0, GRAVITY)
        this.setSlop(5)
        this.active=false

})

Crafty.c("Pusher", {



})



Crafty.c("Feet", {
    init: ()-> 
        this.requires("2D, Collision, Movable")
        #this.requires("Canvas, Tint, Color")
        #this.tint("#FF00FF", .4)
})

Crafty.c("Hands", {
    pushed: null
    pushMarker: null
    
    init: ()-> 
        console.log("Initing hands")
        this.requires("2D, Collision")
        @pushMarker = null
        @attrObj = {}
        return
        #this.requires("Canvas, Tint, Color")
        #this.tint("#FF0000", .4)
        
    _attachment: (body)->
        @_body=body
        
        @_body.hands = this
        this.bind("EnterFrame", @_handFrame)
        this.attr({
            y:  @_body._y + 3
            x:  @_body._x - 1
            w:  @_body._w + 2 
            h:  @_body._h - 6
        })
        this.collision()    #reset polygon size
        #this.trigger("Change")
        return @


        

    
    _endPush: ()->
        return if not @_body
        return if not @_body.pushed
        #console.log('ending push')
        #console.log(@__c)
        if @pushMarker
            @_body.pushed.unglue(@pushMarker)
            @pushMarker.destroy()

        @_body.pushed.controlled = false
        @_body.unglue(@_body.pushed) 


        #@_body.pushed._vx = @_body._vx
        #@_body.pushed._vy = @_body._vy
        @_body.pushed = null
        return

        

    _startPush: (target)->  

        #console.log('starting push')
        #console.log(@__c)
        @_body.pushed = target 

        #Mark that object is being pushed temporarily
        if @pushmarkerName?
            @pushMarker = Crafty.e("#{@pushmarkerName}")
            

            @pushMarker.w = target.w
            @pushMarker.h = target.h
            @pushMarker.x = target.x
            @pushMarker.y = target.y
            target.glue(@pushMarker)
        else @pushMarker = null
        
        @_body.pushed.controlled = true 
        #@_body.pushed.active = true 
        @_body.glue(@_body.pushed)
        @_body.pushed.bind("Remove", @_endPush)
        return
        #console.log(@pushMarker.__c)
        
    _rightway: (pusher, target)->
        (target.x < pusher.x  and pusher._ax <=0) or 
            (target.x > pusher.x and pusher._ax>=0)

    _handFrame: ()->
        #Create a hitbox that is 3px to the right and left, and 1px within the vertical
        this.x = @_body._x- 1
        this.y = @_body._y + 3
        this.h = @_body._h - 6
        this.w = @_body._w + 2 
        

        ###
            Three conditions to end push:
                * Moving oppoisite direction
                * Not grounded
                * 
        ###
        if @_body.pushed isnt null
            #console.log(@_rightway(@_body, @_body.pushed))
            if @_body.grounded and @_body.pushed.grounded and @_rightway(@_body, @_body.pushed)
                
                @_body.pushed._vx = @_body._vx
                @_body.pushed._vy = @_body._vy
            else
                @_endPush()

        else if this._body.grounded and this.hit('Pushable') 
            pushed_obj = this.hit('Pushable')
            for obj in pushed_obj
                maybe_pushed = obj.obj  # maybe_pushed is one eligible obj

                
                if @_rightway(@_body, maybe_pushed ) and (maybe_pushed.grounded is true)
                    #console.log("might be: " + @_rightway(@_body, maybe_pushed))
                    #console.log(@_body._vx)
                    @_startPush(maybe_pushed)
                    return
})




Crafty.c("Solid", {
    init: ()->
        this.requires("2D, Collision")
        this.bind("CheckMove", @_checkMove)
        @collideInfo = {}
    _checkMove: (move)->
        
        if hitObjs = this.hit("Solid")
            #console.log("Cancelling move for #{this[0]}")
            this.trigger("CancelMove", move)

            @collideInfo.objs = hitObjs
            @collideInfo.move = move
            this.trigger("Collide", @collideInfo)
})


Crafty.c("Bounce", {
    sound: 'bounce'
    init: ()->
        this.requires("BounceMethods")
        this.bind("Collide", @_bounce)
})

# To be included by anything that needs _bounce
Crafty.c("BounceMethods", {
    restitution: RESTITUTION
    threshold: .1

    init: ()-> 
    
    _bounce: (move)->
        # Should probably never be called if object is controlled
        if move.x isnt 0
            if Math.abs(this._vx) < @threshold 
                @_vx = 0
            else 
                this.trigger("Bounce", @_vx)
                Crafty.audio.play(@sound, 1, Math.min(Math.abs(.1*@_vx), .8) ) if @sound
                @_vx = - Math.round(@_vx) * @restitution
                    
        if move.y isnt 0
            if Math.abs(@_vy) < @threshold
                @_vy = 0
            else 
                this.trigger("Bounce", @_vy)
                Crafty.audio.play(@sound, 1, Math.min(Math.abs(.1*@_vy), .8)) if @sound
                @_vy = - Math.round(@_vy) * @restitution

        return

})


MYFLAG = 0

Crafty.c("Movable", {
    glued: []
    old: null
    hit_holder: null
    init: ()->
        
        this.bind("Remove", @onRemoval)
        #this.bind("Teleport", @translate)
        this.bind("Translate", @doMove)
        this.bind("CancelMove", @cancelMove)
        @glued = []
        @carried = []
        @moveOK = true #Should start as true?


    #Also remove children?
    onRemoval: ()->
        if @glue_parent?
            @glue_parent.unglue(this)




    translate: (move, ok)->
        @moveOK = ok
        this.x += move.x
        this.y += move.y 
        for e in @glued
            e.translate(move, ok)
        for e in @carried
            e.translate(move, ok)

    


    cancelMove: (move)->
        @moveOK = false
        if this.glue_parent
            this.glue_parent.cancelMove(move)
        else
            @translate({x:-move.x, y:-move.y}, false)


    doMove: (move)->
        move.x = Math.round(move.x)
        move.y = Math.round(move.y)

        @translate(move, true)

        @checkMoves(move)
        if @moveOK
            @triggerMove() 
        

    checkMoves: (move)->
        

        return if not @moveOK
        for e in @carried
            e.checkMoves(move)
        for e in @glued
            e.checkMoves(move)
        #console.log("CheckingMoves")
        this.trigger("CheckMove", move)




    doMove2: (move)->
        #Enforce pixel displacements
        move.x = Math.round(move.x)
        move.y = Math.round(move.y)

        @translate(move)
        this.trigger("CheckMove")
        @hit_holder = @findHitObj(move)
        if @hit_holder isnt false
            @translate({x:-move.x, y:-move.y})
            if @hit_holder.has("DynamicCollision")
                @doCollision(this, @hit_holder)
            else
                #console.log("` collision")
                @_bounce(move)
        else
            @triggerMove()


    triggerMove: ()->
        this.trigger("Moved")
        for e in @glued
            e.triggerMove()
        return
        
    checkHit: (move)->
        return true if this.has("Solid") and this.hit("Solid")
        for e in @glued
            return true if e.checkHit(move) is true
        return false

    findHitObj: (move)->
        if this.has("Solid") 
            @hit_holder = this.hit("Solid")
            return  @hit_holder[0].obj if  @hit_holder isnt false
                
        for e in @glued
            obj = e.findHitObj(move)
            return obj if obj isnt false
        return false
            


    # Objects glued to this move along with it.
    # If they collide with something, the whole system does whatever it's supposed to  
    # The attach() method native to Crafty won't deal with collision very gracefully            
    # You could glue anything which has appropriate translate and checkHit methods.
    glue: (e, x=null, y=null)->
        #Giving x&y is a shorthand for also moving the object to a particular offset relative to the parent
        if e.has("Movable") is false then return false
        e.glue_parent = this
        if x? and y?
            e.x = this.x+x
            e.y = this.y+y
        if @glued.indexOf(e) < 0
            @glued.push(e)

    unglue: (e)->
        return if not e
        e.glue_parent = null
        i = @glued.indexOf(e)
        if i >=0
            @glued.splice(i, 1)

    getGlueTop: ()->
        if this.glue_parent?
            return this.glue_parent.getGlueTop()
        else
            return this


})


T = 20

Crafty.c("Ballistic", {
    _vx: 0
    _vy: 0
    _ax: 0
    _ay: 0
    _fx: 0
    _fy: 0
    _tx: false
    _ty: false

    

    controlled: false
    init: ()-> 
        this.requires("2D, Movable")
        this.requires("Mouse")
        this.bind("Click", @debug )
        @_tx = @_ty = false
        
        @_moveVec = {x:0, y:10}
        
        this.bind("EnterFrame", @_enterBallisticFrame)
        
       
    debug: ()->
        statusText.text("""
            r:#{@_x},#{@_y};
            dim:#{@_w},#{@_h};
            v:#{@_vx},#{@_vy};
            a:#{@_ax},#{@_vy};
            f:#{@_fx},#{@_fy};""")

    launch: (vx=0, vy=0)-> 
        this._vx = vx
        this._vy = vy
        
        return this

    accelerate: (ax=0, ay=0)->
        this._ax = ax
        this._ay = ay
        return this

    terminal: (x=false, y=false)->
        @_tx = x 
        @_ty = y 
        return this



    _enterBallisticFrame: (f)->
        #console.log("Insert")
        #Allow other code to take control of the ballistic object
        #f.dt = 20
        if not f?.dt?
            f.dt = 20

        if f?.dt?>60
            f.dt = 60
        #console.log(f.dt) if Math.random()<.05
        #f.dt = 20
        #console.log(f.dt);
        if @controlled is off
            @moveOK = true
            this._move(f.dt)
            
            #@moveOk is a property of Moveable; it's set to false if the move was cancelled
            return if not @moveOK 

            this._accelerate(f.dt)
            this._friction(f.dt)
            if @_tx and Math.abs(@_vx) > @_tx
                   if @_vx > 0 then @_vx = @_tx else @_vx = - @_tx 
        
        return
        

    _accelerate: (t)->
        this._vx = @_round(this._ax * t/T + this._vx)
        this._vy = @_round(this._ay * t/T + this._vy)

    _round: (x)-> Math.round(1000*(x))/1000 

    #Forces like friction can't change the direction of motion
    _friction: (t)->
        ###if MYFLAG <15
            console.log("_moveBegin")
            console.log(@_moveVec)###
        if @_fx isnt 0
            if @_vx > 0
                @_vx = Math.max(0, @_round( @_vx - @_fx* t/T) )
            if @_vx < 0
                @_vx = Math.min(0, @_round( @_vx + @_fx* t/T) )

        if @_fy isnt 0
            if @_vy > 0
                @_vy = Math.max(0, @_round( @_vy - @_fy* t/T) )
            if @_vy < 0
                @_vy = Math.min(0, @_round( @_vy + @_fy* t/T) )
        return

    #In this world, will break if v is large enough, allowing passage through objects
    _move: (t)->
        ###if MYFLAG++ <15
            console.log("_moveBegin")
            console.log(@_moveVec)###
        # Reuse moveVec, to avoid creating objects every frame
        
        if @_vx isnt 0
            @_moveVec.x = this._vx * t/T + .5 * this._ax * (t/T)*(t/T)
            @_moveVec.y = 0
            this.trigger('Translate', @_moveVec) 

        if @_vy isnt 0
            @_moveVec.x = 0 
            @_moveVec.y = this._vy * t/T+ .5 * this._ay * (t/T)*(t/T)
            ###if MYFLAG++ < 15
                console.log("checking movevec #{MYFLAG}")
                tester = this._vy * t/T+ .5 * this._ay * (t/t)*(t/T) 
                #console.log("test is " + tester)
                @_moveVec.y = tester
                
                console.log(@_moveVec)
                console.log(@_moveVec.y)###
            this.trigger('Translate', @_moveVec)

    

})

Crafty.c("Supportable", {
    leftfoot: null
    rightfoot: null
    slop: false
    init: ()->
        this.requires("Movable")
        @leftfoot = @rightfoot = null
        @slop = false
        @feet = Crafty.e("2D, Collision, Feet")
        @feet._body=this
        @widthFraction = 1
        @widthOffset = 0
        @slopOffset = 0
 
        #poly = new Crafty.polygon(
        #     [0, 0, this.w, 0, this.w, this.h, 0, this.h])
        # @feet.collision(poly)
        #@feet.addComponent("SolidHitBox")
        @bind("EnterFrame", @_checkSupport) #Check every frame, since support can be removed
        @bind("Moved", @_teeter)
        @_sizeFeet()

    _sizeFeet: ()->
        #console.log("Resizing feet! #{@widthFraction}, #{this.w}")
        #console.log("#{this.x}, #{this.y}")
        @feet.w = this.w * @widthFraction
        @feet.h = 1
        #@feet.x = this.x + this.w * (1-@widthFraction)/2
        #@feet.y = @_y + @_h
        #console.log("dim: #{@feet.w}")
        return this


    feetWidth: (fraction=1, offset=0)->
        @widthFraction = fraction
        @widthOffset = offset
        @_sizeFeet()

    setSlop: (offset=0)->
        return @ if offset is 0 
        @slopOffset = offset
        @leftfoot = Crafty.e("2ision, Feet")
            .attr({x: @_x-offset, y: @_y+@_h, w: this.w, h: 1})
        @rightfoot = Crafty.e("2D, Collision, Feet")
            .attr({x: @_x+offset, y: @_y+@_h, w: this.w, h: 1})
        @slop = true
        @checkTeeter = true
        return this

    standingOn: (component)->
        fh = @feet.hit(component)
        if fh
            return fh
        else
            return false

    _checkSupport: ()->
        @checkTeeter = true
        #@feet.y = @_y + @_h
        #@feet.x = @_x
        @feet.x = this.x + this.w * (1-@widthFraction)/2
        @feet.y = @_y + @_h


        if @feet.hit('Platform') 
            @_ay=0
            if not @grounded            
                @grounded = true
                @_teeter()
        else
            @grounded = false
            @_ay= GRAVITY
        
    # Supportable objects should fall into holes that are an exact fit
    # This seems like the best approach:
    #  - If slop has been set, slide towards the edge if it'll make the object fall
    #  - This is only called on a move, rather than every frame, but that seems reasonable 
    _teeterChecker: {x:0, y:0}
    _teeter: ()->
        return if (not @slop) or (not @grounded) or (not @checkTeeter) or (@controlled)
        @checkTeeter = false
        #console.log("Checking teetering")
        @_teeterChecker.y = @_y+@_h
        for dx in [1..@slopOffset]
            @_teeterChecker.x = @_x - dx
            @leftfoot.attr( @_teeterChecker)
            if @leftfoot.hit('Platform') is false
                #console.log("teetering left #{dx}")
                this.trigger("Translate", {x:-1, y:0})
                return
            @_teeterChecker.x = @_x + dx
            @rightfoot.attr(@_teeterChecker)
            if @rightfoot.hit('Platform') is false
                #console.log("teetering right #{dx}")
                this.trigger("Translate", {x:+1, y:0})
                return


    })


Crafty.c("Slider",{
    init: ()->
        this.requires("Ballistic, Supportable")
        this.bind("EnterFrame", @_slideEnterFrame)
        #@_f = .2
        @_f = FRICTION

    setFriction: (friction)->
        @_f = friction

    _slideEnterFrame: ()->
        if @grounded is true
            @_ay = 0
            if Math.abs(@_vy) < 1
                @_vy = 0
        else
            @_ay = GRAVITY
        
        if @active is false 
            if @grounded is true and @_vx isnt 0
                @_fx = @_f
            else
                @_fx = 0
        else
            @_fx = 0


})

    