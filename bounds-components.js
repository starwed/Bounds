// Generated by CoffeeScript 1.9.0
console.log("Bounds comp");

Crafty.c("AnimatedEffect", {
  init: function() {
    return this.requires("2D, Canvas, Sprite, SpriteAnimation, Tween");
  },
  setAnimation: function(reelId, frames) {
    this.reelName = reelId;
    this.animate(reelId, frames);
    return this;
  },
  setTween: function(properties) {
    this.tweenProp = properties;
    return this;
  },
  runAnimation: function(duration) {
    var onAnimationEnd;
    onAnimationEnd = (function(_this) {
      return function() {
        return _this.destroy();
      };
    })(this);
    if (this.reelName) {
      this.bind("AnimationEnd", onAnimationEnd);
      this.playAnimation(this.reelName, duration);
    }
    if (this.tweenProp) {
      this.bind("TweenEnd", onAnimationEnd);
      this.tween(this.tweenProp, duration);
    }
    return this;
  }
});

Crafty.c("UIText", {
  init: function() {
    return this.requires("2D, Text, DOM, Mouse").attr({
      w: 400
    }).css({
      'font-family': 'Helvetica, Arial'
    }).textColor('#FFFFFF', 1).textFont({
      size: "12pt"
    });
  }
});

Crafty.c("Dialogue", {
  init: function() {},
  dialogue: function(message, options) {
    var o, oIndex, _i, _len;
    this.requires("2D, Canvas, Color, Draggable").color("#333333").attr({
      w: 400,
      h: 400,
      x: 100,
      y: 100
    });
    this._msg = Crafty.e("2D, DOM, Text").text(message).attr({
      x: this._x + 10,
      y: this.y + 10
    }).css({
      "color": "white"
    });
    oIndex = 1;
    this.options = [];
    for (_i = 0, _len = options.length; _i < _len; _i++) {
      o = options[_i];
      this.options[oIndex] = Crafty.e("2D, DOM, Text").text(o.text).attr({
        x: this._x + 10,
        y: this._y + oIndex * 32,
        w: 200
      });
      oIndex++;
    }
    return this.attach(this._msg);
  },
  close: function() {
    this._msg.destroy();
    return this.destroy();
  }
});

Crafty.c("TractorBeam", {
  init: function() {
    return this.requires("2D, Canvas, tract1, SpriteAnimation, Movable").attr({
      alpha: 0.8
    }).animate("ripple", [[5, 0], [4, 0], [3, 0], [2, 0], [1, 0], [0, 0]]).playAnimation("ripple", 20, -1);
  }
});

Crafty.c("Brick", {
  init: function() {
    return this.requires("Platform, Solid");
  }
});

Crafty.c("CrumbleBrick", {
  init: function() {
    return this.requires("Platform, Solid");
  },
  crumble: function(firstcrumble) {
    var crumbleQueue, e, eff, _i, _len;
    if (firstcrumble == null) {
      firstcrumble = true;
    }
    crumbleQueue = [];
    if (firstcrumble) {
      Crafty.audio.play('shatter', 1, .7);
    }
    this.probe = this;
    this.x -= 1;
    if (this.probe.hit("CrumbleBrick")) {
      crumbleQueue.push(this.probe.hit('CrumbleBrick')[0].obj);
    }
    this.x += 2;
    if (this.probe.hit("CrumbleBrick")) {
      crumbleQueue.push(this.probe.hit('CrumbleBrick')[0].obj);
    }
    eff = Crafty.e("AnimatedEffect, crBrick1").attr({
      x: this.x,
      y: this.y,
      alpha: .8
    }).setAnimation("shatter", [[0, 0], [1, 0], [2, 0], [2, 0]]).setTween({
      alpha: .3,
      y: this.y + 20
    }).runAnimation(20);
    this.destroy();
    for (_i = 0, _len = crumbleQueue.length; _i < _len; _i++) {
      e = crumbleQueue[_i];
      e.crumble(false);
    }
  }
});

Crafty.c("Stone", {
  init: function() {
    this.requires("Slider, DynamicCollision, Pushable");
    this.sound = 'bounce';
    return this.setFriction(.2);
  }
});

Crafty.c("AntiStone", {
  init: function() {
    this.sound = 'bounce';
    this.requires("Slider, DynamicCollision, Pushable, Platform, SpriteAnimation");
    this.setFriction(.2);
    this.bind("Moved", this.checkGemHit);
    this.activeNegation = true;
    console.log("Adding particles");
    this.addComponent("anti1");
  },
  pulse: function() {},
  addFountain: function() {
    var options, redness;
    if (this.has("2D") && this.has("Movable")) {
      this.unbind("EnterFrame", this.addFountain);
    } else {
      return;
    }
    redness = .5;
    options = {
      startColour: [150 + 100 * redness, 200 * (1 - redness), 155 + 150 * (1 - redness), 1],
      startColourRandom: [0, 0, 0, 0],
      endColourRandom: [0, 0, 0, 0],
      endColour: [redness, 0, 255 * (1 - redness), .5],
      lifespan: 3,
      gravity: {
        x: 0,
        y: 0
      },
      fastMode: false,
      maxParticles: 5,
      angle: 0,
      angleRandom: 180,
      size: 4,
      sizeRandom: 1,
      spread: 4,
      speed: 0,
      speedRandom: 0
    };
    this.fountain = Crafty.e("2D,Canvas,Particles, Movable").particles(options);
    this.glue(this.fountain, 16, 16);
    this.bind("Remove", function() {
      this.unglue(this.fountain);
      return this.fountain.destroy();
    });
    return console.log("particles added");
  },
  setActivity: function(flag) {
    return this.activeNegation = flag;
  },
  checkGemHit: function() {
    var e, eff, gem;
    if (!this.activeNegation) {
      return;
    }
    try {
      if (this.hit('Gem')) {
        Crafty.audio.play('gem', 1, 1);
        gem = this.hit('Gem')[0].obj;
        eff = Crafty.e("AnimatedEffect, negt1").attr({
          x: gem.x,
          y: gem.y
        }).setAnimation("fade", [[0, 0], [1, 0], [2, 0]]).setTween({
          alpha: 0
        }).runAnimation(20);
        gem.destroy();
        return this.destroy();
      }
    } catch (_error) {
      e = _error;
      return console.log(e);
    }
  }
});

Crafty.c("Gem", {
  init: function() {}
});

Crafty.c("PlayerStart", {
  init: function() {
    this.requires("2D");
    return this.visible = false;
  }
});

Crafty.c("spikes", {
  init: function() {}
});

Crafty.c("OverlayGrid", {
  init: function() {
    return this.requires("2D, Canvas, gridPattern");
  }
});

Crafty.c("BackdropPicture", {
  init: function() {
    return this.requires("2D, Canvas, backdrop");
  }
});

Crafty.c("Heart", {
  init: function() {
    return this.requires("2D, Collision");
  },
  _attachment: function(body) {
    var poly;
    this.bind("EnterFrame", this._enterHeartFrame);
    this._body = body;
    body.heart = this;
    this.y = this._body._y + 6;
    this.x = this._body._x + 6;
    this.w = this._body._w - 12;
    this.h = this._body._h - 12;
    poly = new Crafty.polygon([0, 0, this.w, 0, this.w, this.h, 0, this.h]);
    return this.collision(poly);
  },
  _enterHeartFrame: function() {
    this.y = this._body._y + 6;
    this.x = this._body._x + 6;
    this.w = this._body._w - 12;
    return this.h = this._body._h - 12;
  }
});


/*
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



})
 */

Crafty.c("Arrow", {
  init: function() {
    return this.requires("2D, Canvas, arrowSprite").origin("bottom middle");
  },
  setAngle: function(angle) {
    angle = angle * 180 / Math.PI;
    return this.rotation = 90 - angle;
  }
});

Crafty.c("PathMarker", {
  init: function() {
    return this.requires("2D, DOM, Color").attr({
      w: 3,
      h: 3
    }).color("blue").css({
      "border": "2px solid cyan",
      "border-radius": "2px"
    });
  }
});

Crafty.c("Hoister", {
  init: function() {
    return this.requires("Jumpman");
  },
  hoistObject: function(target) {
    var ox, oy, plParent;
    ox = target.x;
    oy = target.y;
    target.y = this.y - target.h;
    target.x = this.x + this.w / 2 - target.w / 2;
    if (target.hit("Solid")) {
      target.x = ox;
      return target.y = oy;
    } else {
      this.showParabola = true;
      this.showParabolaPoints();
      this.hoisted = target;
      this.hoisted.controlled = true;
      this.hoisted.grounded = false;
      this.glue(this.hoisted);
      if (this.hoisted.has("AntiStone")) {
        this.hoisted.setActivity(false);
      }
      this.hoistMarker = Crafty.e("TractorBeam");
      this.hoistMarker.w = target.w;
      this.hoistMarker.h = target.h;
      this.hoistMarker.x = target.x;
      this.hoistMarker.y = target.y;
      target.glue(this.hoistMarker);
      return plParent = this;

      /*@pointer = Crafty.e("Arrow, Movable")
          .bind("EnterFrame", ()-> @setAngle(plParent.calcAngle(plParent.lastmovesign)) )
      @glue(@pointer, -4, -48)
       */
    }
  },
  unhoist: function() {
    var old;
    if (this.hoistMarker != null) {
      this.hoisted.unglue(this.hoistMarker);
      this.hoistMarker.destroy();
    }
    this.showParabola = false;
    this.killParabola();
    this.hoisted.controlled = false;
    this.hoisted._vx = this._vx;
    this.hoisted._vy = this._vy;
    this.unglue(this.hoisted);
    if (this.hoisted.has("AntiStone")) {
      this.hoisted.setActivity(true);
    }
    old = this.hoisted;
    this.hoisted = null;
    return old;
  }
});

Crafty.c("Bounder", {
  init: function() {
    var n, _i;
    this.requires("Jumpman");
    this.ppoints = null;
    this.points = [];
    for (n = _i = 0; _i <= 5; n = ++_i) {
      this.points.push({
        x: 0,
        y: 0
      });
    }
  },
  calcAngle: function(xsign) {
    var angle, vx, vy;
    vy = this.getVy() + this._vy;
    vx = xsign * this.getVx() + this._vx;
    angle = Math.atan2(-vy, vx);
    return angle;
  },
  calcParabolaPoints: function(xsign, N) {
    var dx, n, vx, vy, x0, y0, _i;
    vy = this.getVy() + this._vy;
    vx = xsign * this.getVx() + this._vx;
    y0 = this.y - 16 - 2;
    x0 = this.x + this.w / 2 - 2;
    for (n = _i = 0; 0 <= N ? _i <= N : _i >= N; n = 0 <= N ? ++_i : --_i) {
      dx = xsign * 16 * Math.sqrt(this._boundFactor) * n;
      this.points[n].x = x0 + dx;
      this.points[n].y = y0 + (dx / vx) * (vy + .1 * (dx / vx));
    }
    return this.points;
  },
  showParabolaPoints: function() {
    var n, _i, _j;
    this.ppoints = this.calcParabolaPoints(this.lastmovesign, 5);
    if (this.markers == null) {
      console.log("making markers");
      this.markers = [];
      for (n = _i = 0; _i <= 5; n = ++_i) {
        this.markers.push(Crafty.e("PathMarker").attr({
          alpha: .7 - .08 * n
        }));
      }
    }
    for (n = _j = 0; _j <= 5; n = ++_j) {
      this.markers[n].attr(this.ppoints[n]);
    }
  },
  killParabola: function() {
    var m, _i, _len, _ref;
    _ref = this.markers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      m = _ref[_i];
      m.destroy();
    }
    this.ppoints = null;
    return this.markers = null;
  },
  getVy: function() {
    var dvy;
    dvy = -Math.sqrt(2 * (this._boundFactor * 32 + 2) * Bounds.GRAVITY);
    return dvy;
  },
  getVx: function() {
    var dvx;
    return dvx = 1 * Math.sqrt(this._boundFactor);
  },
  flingSomething: function(xsign, projectile) {
    var dvx, dvy, heightWatcher, hh, maxh, pred;
    if (projectile === false) {
      return;
    }
    dvx = this.getVx();
    dvy = this.getVy();
    projectile._vy += dvy;
    projectile._vx += dvx * xsign;

    /*pToBlock = (p)->
        phN = Math.floor(p/32)
        phP = p-phN*32
        return "#{phN} blocks, #{phP} px"
     */
    pred = (this._vy + dvy) * (this._vy + dvy) / .4;
    this.targetHeight = 32 * this._boundFactor + 7;
    hh = 0;
    maxh = 0;
    heightWatcher = function() {
      hh = this.start_y - this.y;
      if (hh > this.targetHeight && this._vy < 0) {
        this._vy = 0;
      }
      if (hh > maxh) {
        return maxh = hh;
      } else {
        return this.unbind("EnterFrame", heightWatcher);
      }
    };
    this.start_y = this.y;
    this.predict = pred;
    return this.bind("EnterFrame", heightWatcher);
  },
  jump: function(xsign, bounder) {
    var cb, jet;
    if (bounder == null) {
      bounder = this;
    }
    console.log("Trying to jump");
    if (bounder === false) {
      return;
    }
    Crafty.audio.play('jump', 1, .3 * Math.min(Math.sqrt(this._boundFactor), 1));
    this.flingSomething(xsign, this);
    if (this.standingOn("CrumbleBrick")) {
      cb = Crafty(this.standingOn('CrumbleBrick')[0].obj[0]);
      cb.crumble();
    }
    this.grounded = false;
    this._boundFactor += 1;
    this.jumps++;
    if (xsign < 0) {
      jet = Crafty.e("AnimatedEffect, rightJet, Movable").attr({
        x: this._x + this._w - 7,
        y: this._y + 16,
        w: 18,
        h: 17,
        alpha: 0.7
      });
    } else {
      jet = Crafty.e("AnimatedEffect, leftJet, Movable").attr({
        x: this._x - 11,
        y: this._y + 16,
        w: 18,
        h: 17,
        alpha: 0.7
      });
    }
    this.glue(jet);
    jet.setTween({
      alpha: .4
    }).runAnimation(20);
    return this.trigger("Bounded");
  },
  "throw": function(xsign, projectile) {
    if (projectile == null) {
      projectile = false;
    }
    if (projectile === false) {
      return;
    }
    Crafty.audio.play('jump', 1, .3 * Math.min(Math.sqrt(this._boundFactor), 1));
    this.flingSomething(xsign, projectile);
    this._boundFactor += 1;
    this.jumps++;
    return this.trigger("Bounded");
  }
});

Crafty.c("JumpMan", {
  _boundFactor: 1,
  jumps: 0,
  dead: false,
  g: .1,
  init: function() {
    this.requires("Ballistic, DynamicCollision, Bounder, Hoister");
    this.requires("Keyboard");
    console.log("initing debug canvas");

    /*testPoly = new Crafty.polygon([0, 0], [30, 0], [30, 30], [0, 30]); 
    this.attach(testPoly);
    this.requires("DebugPolygon")
        .debugPolygon( testPoly, "white" );
     */
    this.heart = Crafty.e("2D, Collision, Heart")._attachment(this);
    this.gemhitbox = this;
    this.hands = Crafty.e("2D, Collision, Hands")._attachment(this);
    this.hands.pushmarkerName = "TractorBeam";
    this.active = false;
    this.dead = false;
    this.hoisted = null;
    this.pushed = null;
    this.sideflame = null;
    this.pointer = null;
    this.lastmovesign = 0;
    this.bind('Moved', this.onMove);
    this.showParabola = false;
    this.checker = null;
    return this.sound = 'bounce';
  },
  flicker: function() {
    if (this.alpha < 0.8) {
      return this.alpha += .02;
    } else {
      return this.alpha -= .1;
    }
  },
  setSprite: function(mode) {
    if (this.animationMode === mode) {
      return;
    }
    if (this.sideflame != null) {
      this.unglue(this.sideflame);
      this.sideflame.destroy();
      this.sideflame = null;
    }
    switch (mode) {
      case "dead":
        this.sprite(1, 0, 1, 1);
        break;
      case "norm":
        if (!this.dead) {
          this.sprite(0, 0, 1, 1);
        }
        break;
      case "right":
        if (!this.dead) {
          this.sprite(2, 0, 1, 1);
        }
        this.sideflame = Crafty.e("2D, Canvas, leftFlame, Movable");
        this.sideflame.attr({
          x: this._x - 10,
          y: this._y + 9,
          w: 10,
          h: 8,
          alpha: 0.3
        });
        this.sideflame.bind("EnterFrame", this.flicker);
        this.glue(this.sideflame);
        break;
      case "left":
        if (!this.dead) {
          this.sprite(3, 0, 1, 1);
        }
        this.sideflame = Crafty.e("2D, Canvas, rightFlame, Movable");
        this.sideflame.attr({
          x: this._x + this._w,
          y: this._y + 9,
          w: 10,
          h: 8,
          alpha: 0.3
        });
        this.sideflame.bind("EnterFrame", this.flicker);
        this.glue(this.sideflame);
    }
    return this.animationMode = mode;
  },
  die: function() {
    Bounds.resetMap();
    this.dead = false;
    return Bounds.setStatus("You came back!");
  },
  stepper: function(step) {
    if (!this.checker.hit("Platform")) {
      this.trigger("Translate", {
        x: step,
        y: 0
      });
      return true;
    } else {
      return false;
    }
  },
  stepDown: function() {
    var stepped;
    if (this.hoisted || !this.grounded) {
      return;
    }
    if (!this.checker) {
      this.checker = Crafty.e("2D, Collision");
      this.checker.h = 2;
      this.checker.w = 4;
    }
    this.checker.y = this.y + 28;
    stepped = false;
    if (this.pushed != null) {
      if (this.pushed.x > this.x) {
        this.checker.x = this.pushed.x + this.pushed.w - this.checker.w + 1;
        if (!this.checker.hit("Platform")) {
          stepped = this.stepper(1);
        }
      } else {
        this.checker.attr({
          x: this.pushed.x - 1
        });
        if (!this.checker.hit("Platform")) {
          stepped = this.stepper(-1);
        }
      }
    } else {
      this.checker.x = this.x - 1;
      if (!this.checker.hit("Platform")) {
        stepped = this.stepper(-1);
      } else {
        this.checker.x = this.x + this.w - this.checker.w + 1;
        if (!this.checker.hit("Platform")) {
          stepped = this.stepper(1);
        }
      }
    }
    return stepped;
  },
  thrust_x: 0.1,
  trigger_action: function(xsign) {
    var brick, projectile;
    if (this.hoisted !== null) {
      projectile = this.unhoist();
      this["throw"](xsign, projectile);
    } else if (this.pushed !== null) {
      brick = this.pushed;
      this.hands._endPush();
      this.hoistObject(brick);
    } else if (this.grounded) {
      this.jump(xsign, this);
    }
    return Crafty.trigger("UpdateBoundmeter");
  },
  onMove: function() {
    var e, gem;
    if (this.showParabola) {
      this.showParabolaPoints();
    }
    if (this._vx < 0) {
      this.lastmovesign = -1;
    } else if (this._vx > 0) {
      this.lastmovesign = 1;
    }
    if (this.heart.hit('Deadly') && this.dead === false && Bounds.level_complete === false) {
      Bounds.setStatus("You died!");
      this.dead = true;
      this.setSprite("dead");
      Crafty.audio.play('death', .6, 1);
      Bounds.queueSceneChange((function() {
        return Bounds.player.die();
      }), 1000);
    }
    if (this.gemhitbox.hit('Gem')) {
      console.log('gem!');
      try {
        Crafty.audio.play('gem', 1, .8);
        gem = this.gemhitbox.hit('Gem')[0].obj;
        if (gem.has("PowerUp")) {
          this.trigger("Bounded");
          this._boundFactor++;
          Crafty.trigger('UpdateBoundmeter');
        }
        if (gem.has("PowerDown") && this._boundFactor > 1) {
          this._boundFactor--;
          this.trigger("Bounded");
          Crafty.trigger('UpdateBoundmeter');
        }
        return gem.destroy();
      } catch (_error) {
        e = _error;
        return console.log(e);
      }
    }
  }
});

Crafty.c("KeyboardMan", {
  init: function() {
    this.requires("JumpMan, Keyboard");
    this.bind("EnterFrame", this._checkKeys);
    this.bind("KeyDown", this._keydown);
    return this.bind("KeyUp", this._keyup);
  },
  _checkKeys: function() {

    /*if this.isDown('SHIFT')
        #@terminal(1, false)
        @terminal(false, false)
    else
        @terminal(false, false)
     */
    if (this.isDown('a') || this.isDown('A') || this.isDown('LEFT_ARROW')) {
      if (!this.dead) {
        this.setSprite("left");
      }
      this.active = true;
      if (this._vx <= 0) {
        this._ax = -this.thrust_x;
      } else {
        this._ax = -.3;
      }
    } else if (this.isDown('d') || this.isDown('D') || this.isDown('RIGHT_ARROW')) {
      if (!this.dead) {
        this.setSprite("right");
      }
      this.active = true;
      if (this._vx >= 0) {
        this._ax = this.thrust_x;
      } else {
        this._ax = .3;
      }
    } else {
      this.active = false;
      this._ax = 0;
    }
    if (this.isDown('DOWN_ARROW')) {
      if (!this.stepDown() && this.grounded) {
        if (this._vx < 0) {
          this._ax = +.3;
        } else if (this._vx > 0) {
          this._ax = -.3;
        }
      }
    }
    if (this.pushed) {
      return this._ax = this._ax / 1.5;
    }
  },
  _keydown: function(e) {
    if (this.isDown('k') || this.isDown('K')) {
      this.die();
    }
    if (this.isDown('m') || this.isDown('M') || this.isDown('ESC')) {
      Crafty.scene("loading");
    }
    switch (e.key) {
      case 37:
      case 'a':
      case 'A':
        this.active = true;
        this._ax = -this.thrust_x;
        this.trigger("Translate", {
          x: -1,
          y: 0
        });
        break;
      case 81:
        console.log("Wheee");
        this.trigger_action(-1);
        break;
      case 69:
        console.log("wheee");
        this.trigger_action(+1);
        break;
      case 39:
      case 'd':
      case 'D':
        this.active = true;
        this._ax = this.thrust_x;
        this.trigger("Translate", {
          x: 1,
          y: 0
        });
        break;
      case 71:
        console.log("toggling?");
        Bounds.toggleGrid();
    }
    if (this.pushed) {
      return this._ax = this._ax / 1.5;
    }
  },
  _keyup: function(e) {
    switch (e.key) {
      case 37:
      case 39:
        this._ax = 0;
        this.active = false;
        if (!this.dead) {
          return this.setSprite("norm");
        }
    }
  }
});

Crafty.c("DownIndicator", {
  init: function() {
    return this.requires("2D, Canvas, down_arrow").attr({
      h: 32,
      w: 32
    });
  }
});
