// Generated by CoffeeScript 1.4.0
(function() {
  var FRICTION, GLOBAL_PUSHED, GRAVITY, MYFLAG, RESTITUTION, T;

  console.log("Block dyn\n");

  GLOBAL_PUSHED = null;

  GRAVITY = 0.2;

  FRICTION = 0.3;

  RESTITUTION = 1 / 8;

  Crafty.c("DynamicCollision", {
    init: function() {
      this.requires("Solid, Ballistic, BounceMethods");
      return this.bind("Collide", this.chooseCollision);
    },
    chooseCollision: function(collisionInfo) {
      var A, firstHit;
      firstHit = collisionInfo.objs[0].obj;
      if (firstHit.has("DynamicCollision")) {
        this.doCollision(this, firstHit);
      } else {
        A = this.getGlueTop();
        if (A._bounce != null) {
          A._bounce(collisionInfo.move);
        }
      }
    },
    doCollision: function(A, B) {
      var Va, Vb, dVa, dVb, r, r_mag, r_sq, rhat, _ref;
      r = {
        x: B.x + B._w / 2 - A.x - A._w / 2,
        y: B.y + B._h / 2 - A.y - A._h / 2
      };
      r_sq = r.x * r.x + r.y * r.y;
      r_mag = Math.sqrt(r_sq);
      rhat = {
        x: r.x / r_mag,
        y: r.y / r_mag
      };
      A = A.getGlueTop();
      B = B.getGlueTop();
      if (Math.abs(rhat.x) > Math.abs(rhat.y)) {
        if (rhat.x > 0) {
          rhat = {
            x: 1,
            y: 0
          };
        } else {
          rhat = {
            x: -1,
            y: 0
          };
        }
      } else {
        if (rhat.y > 0) {
          rhat = {
            x: 0,
            y: 1
          };
        } else {
          rhat = {
            x: 0,
            y: -1
          };
        }
      }
      Va = A._vx * rhat.x + A._vy * rhat.y;
      Vb = B._vx * rhat.x + B._vy * rhat.y;
      _ref = this.collisionOnAxis(Va, Vb, this.restitution), dVa = _ref[0], dVb = _ref[1];
      A._vx += dVa * rhat.x;
      A._vy += dVa * rhat.y;
      B._vx += dVb * rhat.x;
      B._vy += dVb * rhat.y;
    },
    collisionOnAxis: function(Va, Vb, C) {
      var nVa, nVb;
      nVa = (1 / 2) * ((1 + C) * Vb + (1 - C) * Va);
      nVb = (1 / 2) * ((1 + C) * Va + (1 - C) * Vb);
      return [nVa - Va, nVb - Vb];
    }
  });

  Crafty.c("Platform", {
    init: function() {
      return this.requires("Solid");
    }
  });

  Crafty.c("Pushable", {
    init: function() {
      this.requires("2D, Ballistic, Slider, Supportable, Collision, Solid").accelerate(0, GRAVITY);
      this.setSlop(5);
      return this.active = false;
    }
  });

  Crafty.c("Pusher", {});

  Crafty.c("Feet", {
    init: function() {
      return this.requires("2D, Collision, Movable");
    }
  });

  Crafty.c("Hands", {
    pushed: null,
    pushMarker: null,
    init: function() {
      console.log("Initing hands");
      this.requires("2D, Collision");
      this.pushMarker = null;
      this.attrObj = {};
    },
    _attachment: function(body) {
      this._body = body;
      this._body.hands = this;
      this.bind("EnterFrame", this._handFrame);
      this.attr({
        y: this._body._y + 3,
        x: this._body._x - 1,
        w: this._body._w + 2,
        h: this._body._h - 6
      });
      this.collision();
      return this;
    },
    _endPush: function() {
      if (!this._body) {
        return;
      }
      if (!this._body.pushed) {
        return;
      }
      if (this.pushMarker) {
        this._body.pushed.unglue(this.pushMarker);
        this.pushMarker.destroy();
      }
      this._body.pushed.controlled = false;
      this._body.unglue(this._body.pushed);
      this._body.pushed = null;
    },
    _startPush: function(target) {
      this._body.pushed = target;
      if (this.pushmarkerName != null) {
        this.pushMarker = Crafty.e("" + this.pushmarkerName);
        this.pushMarker.w = target.w;
        this.pushMarker.h = target.h;
        this.pushMarker.x = target.x;
        this.pushMarker.y = target.y;
        target.glue(this.pushMarker);
      } else {
        this.pushMarker = null;
      }
      this._body.pushed.controlled = true;
      this._body.glue(this._body.pushed);
      this._body.pushed.bind("Remove", this._endPush);
    },
    _rightway: function(pusher, target) {
      return (target.x < pusher.x && pusher._ax <= 0) || (target.x > pusher.x && pusher._ax >= 0);
    },
    _handFrame: function() {
      var maybe_pushed, obj, pushed_obj, _i, _len;
      this.x = this._body._x - 1;
      this.y = this._body._y + 3;
      this.h = this._body._h - 6;
      this.w = this._body._w + 2;
      /*
                  Three conditions to end push:
                      * Moving oppoisite direction
                      * Not grounded
                      *
      */

      if (this._body.pushed !== null) {
        if (this._body.grounded && this._body.pushed.grounded && this._rightway(this._body, this._body.pushed)) {
          this._body.pushed._vx = this._body._vx;
          return this._body.pushed._vy = this._body._vy;
        } else {
          return this._endPush();
        }
      } else if (this._body.grounded && this.hit('Pushable')) {
        pushed_obj = this.hit('Pushable');
        for (_i = 0, _len = pushed_obj.length; _i < _len; _i++) {
          obj = pushed_obj[_i];
          maybe_pushed = obj.obj;
          if (this._rightway(this._body, maybe_pushed) && (maybe_pushed.grounded === true)) {
            this._startPush(maybe_pushed);
            return;
          }
        }
      }
    }
  });

  Crafty.c("Solid", {
    init: function() {
      this.requires("2D, Collision");
      this.bind("CheckMove", this._checkMove);
      return this.collideInfo = {};
    },
    _checkMove: function(move) {
      var hitObjs;
      if (hitObjs = this.hit("Solid")) {
        this.trigger("CancelMove", move);
        this.collideInfo.objs = hitObjs;
        this.collideInfo.move = move;
        return this.trigger("Collide", this.collideInfo);
      }
    }
  });

  Crafty.c("Bounce", {
    sound: 'bounce',
    init: function() {
      this.requires("BounceMethods");
      return this.bind("Collide", this._bounce);
    }
  });

  Crafty.c("BounceMethods", {
    restitution: RESTITUTION,
    threshold: .1,
    init: function() {},
    _bounce: function(move) {
      if (move.x !== 0) {
        if (Math.abs(this._vx) < this.threshold) {
          this._vx = 0;
        } else {
          this.trigger("Bounce", this._vx);
          if (this.sound) {
            Crafty.audio.play(this.sound, 1, Math.min(Math.abs(.1 * this._vx), .8));
          }
          this._vx = -Math.round(this._vx) * this.restitution;
        }
      }
      if (move.y !== 0) {
        if (Math.abs(this._vy) < this.threshold) {
          this._vy = 0;
        } else {
          this.trigger("Bounce", this._vy);
          if (this.sound) {
            Crafty.audio.play(this.sound, 1, Math.min(Math.abs(.1 * this._vy), .8));
          }
          this._vy = -Math.round(this._vy) * this.restitution;
        }
      }
    }
  });

  MYFLAG = 0;

  Crafty.c("Movable", {
    glued: [],
    old: null,
    hit_holder: null,
    init: function() {
      this.bind("Remove", this.onRemoval);
      this.bind("Translate", this.doMove);
      this.bind("CancelMove", this.cancelMove);
      this.glued = [];
      this.carried = [];
      return this.moveOK = true;
    },
    onRemoval: function() {
      if (this.glue_parent != null) {
        return this.glue_parent.unglue(this);
      }
    },
    translate: function(move, ok) {
      var e, _i, _j, _len, _len1, _ref, _ref1, _results;
      this.moveOK = ok;
      this.x += move.x;
      this.y += move.y;
      _ref = this.glued;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        e.translate(move, ok);
      }
      _ref1 = this.carried;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        e = _ref1[_j];
        _results.push(e.translate(move, ok));
      }
      return _results;
    },
    cancelMove: function(move) {
      this.moveOK = false;
      if (this.glue_parent) {
        return this.glue_parent.cancelMove(move);
      } else {
        return this.translate({
          x: -move.x,
          y: -move.y
        }, false);
      }
    },
    doMove: function(move) {
      move.x = Math.round(move.x);
      move.y = Math.round(move.y);
      this.translate(move, true);
      this.checkMoves(move);
      if (this.moveOK) {
        return this.triggerMove();
      }
    },
    checkMoves: function(move) {
      var e, _i, _j, _len, _len1, _ref, _ref1;
      if (!this.moveOK) {
        return;
      }
      _ref = this.carried;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        e.checkMoves(move);
      }
      _ref1 = this.glued;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        e = _ref1[_j];
        e.checkMoves(move);
      }
      return this.trigger("CheckMove", move);
    },
    doMove2: function(move) {
      move.x = Math.round(move.x);
      move.y = Math.round(move.y);
      this.translate(move);
      this.trigger("CheckMove");
      this.hit_holder = this.findHitObj(move);
      if (this.hit_holder !== false) {
        this.translate({
          x: -move.x,
          y: -move.y
        });
        if (this.hit_holder.has("DynamicCollision")) {
          return this.doCollision(this, this.hit_holder);
        } else {
          return this._bounce(move);
        }
      } else {
        return this.triggerMove();
      }
    },
    triggerMove: function() {
      var e, _i, _len, _ref;
      this.trigger("Moved");
      _ref = this.glued;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        e.triggerMove();
      }
    },
    checkHit: function(move) {
      var e, _i, _len, _ref;
      if (this.has("Solid") && this.hit("Solid")) {
        return true;
      }
      _ref = this.glued;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (e.checkHit(move) === true) {
          return true;
        }
      }
      return false;
    },
    findHitObj: function(move) {
      var e, obj, _i, _len, _ref;
      if (this.has("Solid")) {
        this.hit_holder = this.hit("Solid");
        if (this.hit_holder !== false) {
          return this.hit_holder[0].obj;
        }
      }
      _ref = this.glued;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        obj = e.findHitObj(move);
        if (obj !== false) {
          return obj;
        }
      }
      return false;
    },
    glue: function(e, x, y) {
      if (x == null) {
        x = null;
      }
      if (y == null) {
        y = null;
      }
      if (e.has("Movable") === false) {
        return false;
      }
      e.glue_parent = this;
      if ((x != null) && (y != null)) {
        e.x = this.x + x;
        e.y = this.y + y;
      }
      if (this.glued.indexOf(e) < 0) {
        return this.glued.push(e);
      }
    },
    unglue: function(e) {
      var i;
      if (!e) {
        return;
      }
      e.glue_parent = null;
      i = this.glued.indexOf(e);
      if (i >= 0) {
        return this.glued.splice(i, 1);
      }
    },
    getGlueTop: function() {
      if (this.glue_parent != null) {
        return this.glue_parent.getGlueTop();
      } else {
        return this;
      }
    }
  });

  T = 20;

  Crafty.c("Ballistic", {
    _vx: 0,
    _vy: 0,
    _ax: 0,
    _ay: 0,
    _fx: 0,
    _fy: 0,
    _tx: false,
    _ty: false,
    controlled: false,
    init: function() {
      this.requires("2D, Movable");
      this.requires("Mouse");
      this.bind("Click", this.debug);
      this._tx = this._ty = false;
      this._moveVec = {
        x: 0,
        y: 10
      };
      return this.bind("EnterFrame", this._enterBallisticFrame);
    },
    debug: function() {
      return statusText.text("r:" + this._x + "," + this._y + ";\ndim:" + this._w + "," + this._h + ";\nv:" + this._vx + "," + this._vy + ";\na:" + this._ax + "," + this._vy + ";\nf:" + this._fx + "," + this._fy + ";");
    },
    launch: function(vx, vy) {
      if (vx == null) {
        vx = 0;
      }
      if (vy == null) {
        vy = 0;
      }
      this._vx = vx;
      this._vy = vy;
      return this;
    },
    accelerate: function(ax, ay) {
      if (ax == null) {
        ax = 0;
      }
      if (ay == null) {
        ay = 0;
      }
      this._ax = ax;
      this._ay = ay;
      return this;
    },
    terminal: function(x, y) {
      if (x == null) {
        x = false;
      }
      if (y == null) {
        y = false;
      }
      this._tx = x;
      this._ty = y;
      return this;
    },
    _enterBallisticFrame: function(f) {
      if (!((f != null ? f.dt : void 0) != null)) {
        f.dt = 20;
      }
      if (((f != null ? f.dt : void 0) != null) > 60) {
        f.dt = 60;
      }
      if (this.controlled === false) {
        this.moveOK = true;
        this._move(f.dt);
        if (!this.moveOK) {
          return;
        }
        this._accelerate(f.dt);
        this._friction(f.dt);
        if (this._tx && Math.abs(this._vx) > this._tx) {
          if (this._vx > 0) {
            this._vx = this._tx;
          } else {
            this._vx = -this._tx;
          }
        }
      }
    },
    _accelerate: function(t) {
      this._vx = this._round(this._ax * t / T + this._vx);
      return this._vy = this._round(this._ay * t / T + this._vy);
    },
    _round: function(x) {
      return Math.round(1000 * x) / 1000;
    },
    _friction: function(t) {
      /*if MYFLAG <15
          console.log("_moveBegin")
          console.log(@_moveVec)
      */
      if (this._fx !== 0) {
        if (this._vx > 0) {
          this._vx = Math.max(0, this._round(this._vx - this._fx * t / T));
        }
        if (this._vx < 0) {
          this._vx = Math.min(0, this._round(this._vx + this._fx * t / T));
        }
      }
      if (this._fy !== 0) {
        if (this._vy > 0) {
          this._vy = Math.max(0, this._round(this._vy - this._fy * t / T));
        }
        if (this._vy < 0) {
          this._vy = Math.min(0, this._round(this._vy + this._fy * t / T));
        }
      }
    },
    _move: function(t) {
      /*if MYFLAG++ <15
          console.log("_moveBegin")
          console.log(@_moveVec)
      */
      if (this._vx !== 0) {
        this._moveVec.x = this._vx * t / T + .5 * this._ax * (t / T) * (t / T);
        this._moveVec.y = 0;
        this.trigger('Translate', this._moveVec);
      }
      if (this._vy !== 0) {
        this._moveVec.x = 0;
        this._moveVec.y = this._vy * t / T + .5 * this._ay * (t / T) * (t / T);
        /*if MYFLAG++ < 15
            console.log("checking movevec #{MYFLAG}")
            tester = this._vy * t/T+ .5 * this._ay * (t/t)*(t/T) 
            #console.log("test is " + tester)
            @_moveVec.y = tester
            
            console.log(@_moveVec)
            console.log(@_moveVec.y)
        */

        return this.trigger('Translate', this._moveVec);
      }
    }
  });

  Crafty.c("Supportable", {
    leftfoot: null,
    rightfoot: null,
    slop: false,
    init: function() {
      var poly;
      this.requires("Movable");
      this.leftfoot = this.rightfoot = null;
      this.slop = false;
      this.feet = Crafty.e("2D, Collision, Feet");
      this.feet._body = this;
      this.widthFraction = 1;
      this.widthOffset = 0;
      this.slopOffset = 0;
      poly = new Crafty.polygon([0, 0], [this.w, 0], [this.w, this.h], [0, this.h]);
      this.feet.collision(poly);
      this.bind("EnterFrame", this._checkSupport);
      this.bind("Moved", this._teeter);
      return this._sizeFeet();
    },
    _sizeFeet: function() {
      this.feet.w = this.w * this.widthFraction;
      this.feet.h = 1;
      return this;
    },
    feetWidth: function(fraction, offset) {
      if (fraction == null) {
        fraction = 1;
      }
      if (offset == null) {
        offset = 0;
      }
      this.widthFraction = fraction;
      this.widthOffset = offset;
      return this._sizeFeet();
    },
    setSlop: function(offset) {
      if (offset == null) {
        offset = 0;
      }
      if (offset === 0) {
        return this;
      }
      this.slopOffset = offset;
      this.leftfoot = Crafty.e("2D, Collision, Feet").attr({
        x: this._x - offset,
        y: this._y + this._h,
        w: this.w,
        h: 1
      });
      this.rightfoot = Crafty.e("2D, Collision, Feet").attr({
        x: this._x + offset,
        y: this._y + this._h,
        w: this.w,
        h: 1
      });
      this.slop = true;
      this.checkTeeter = true;
      return this;
    },
    standingOn: function(component) {
      var fh;
      fh = this.feet.hit(component);
      if (fh) {
        return fh;
      } else {
        return false;
      }
    },
    _checkSupport: function() {
      this.checkTeeter = true;
      this.feet.x = this.x + this.w * (1 - this.widthFraction) / 2;
      this.feet.y = this._y + this._h;
      if (this.feet.hit('Platform')) {
        this._ay = 0;
        if (!this.grounded) {
          this.grounded = true;
          return this._teeter();
        }
      } else {
        this.grounded = false;
        return this._ay = GRAVITY;
      }
    },
    _teeterChecker: {
      x: 0,
      y: 0
    },
    _teeter: function() {
      var dx, _i, _ref;
      if ((!this.slop) || (!this.grounded) || (!this.checkTeeter) || this.controlled) {
        return;
      }
      this.checkTeeter = false;
      this._teeterChecker.y = this._y + this._h;
      for (dx = _i = 1, _ref = this.slopOffset; 1 <= _ref ? _i <= _ref : _i >= _ref; dx = 1 <= _ref ? ++_i : --_i) {
        this._teeterChecker.x = this._x - dx;
        this.leftfoot.attr(this._teeterChecker);
        if (this.leftfoot.hit('Platform') === false) {
          this.trigger("Translate", {
            x: -1,
            y: 0
          });
          return;
        }
        this._teeterChecker.x = this._x + dx;
        this.rightfoot.attr(this._teeterChecker);
        if (this.rightfoot.hit('Platform') === false) {
          this.trigger("Translate", {
            x: +1,
            y: 0
          });
          return;
        }
      }
    }
  });

  Crafty.c("Slider", {
    init: function() {
      this.requires("Ballistic, Supportable");
      this.bind("EnterFrame", this._slideEnterFrame);
      return this._f = FRICTION;
    },
    setFriction: function(friction) {
      return this._f = friction;
    },
    _slideEnterFrame: function() {
      if (this.grounded === true) {
        this._ay = 0;
        if (Math.abs(this._vy) < 1) {
          this._vy = 0;
        }
      } else {
        this._ay = GRAVITY;
      }
      if (this.active === false) {
        if (this.grounded === true && this._vx !== 0) {
          return this._fx = this._f;
        } else {
          return this._fx = 0;
        }
      } else {
        return this._fx = 0;
      }
    }
  });

}).call(this);
