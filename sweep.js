	//RectangleSweep.js
/**
 * Given a set of rectangles, find a minimal covering set of concave polygons
 * The rectangles are axis oriented
 * They are given by the coordinate of their upper left corner, along with h and w
 */


/*window.onload= function(){

	drawRects(base_set);
}*/

var sets = []
var currentSet = false;

prepCount=0;

//helper function THAT ASSUMES el is actually present in array
function removeFromArray(key, A){
  var imin = 0, imax = A.length-1;
  // continue searching while [imin,imax] is not empty
  while (imax >= imin)
  {
      /* calculate the midpoint for roughly equal partition */
      var imid = ~~((imin + imax)/2);
 
      // determine which subarray to search
      if (A[imid].x < key.x)
        // change min index to search upper subarray
        imin = imid +1;
      else if (A[imid].x > key.x)
        // change max index to search lower subarray
        imax = imid-1;
      else {
      	A.splice(imid, 1);
        // key found at index imid
        return imid;
       }
  }
  // key not found
  return null;


}



var test_set;
var NN = 20;
function init_test(){
	test_set = [];
	for(var n=0; n<NN; n++){
		test_set.push({_x: ~~(Math.random()*100+1), _y: ~~(Math.random()*100+1), _w: 20, _h: 20});
	}
	return test_set;

}

function restart_test(){
	//test_set = [];
	for(var n=0; n<NN; n++){
		test_set[n]._x = ~~(Math.random()*100) + 1 ;
		test_set[n]._y = ~~(Math.random()*100) + 1;
	}
	return test_set;

	test_set = [
		{_x: 10, _y:10, _w: 10, _h:10},
		{_x: 20, _y:10, _w:13, _h:10},
		{_x: 20, _y:20, _w:10, _h:11},
		{_x: 10, _y:20, _w:10, _h:10},
		{_x: 105, _y:15, _w:10, _h:10},
		{_x: 50, _y:50, _w:10, _h:20},
		{_x: 70, _y:50, _w:10, _h:20},
		{_x: 40, _y:55, _w:70, _h:10}, 
		{_x: 10, _y:100, _w:10, _h:10},
		{_x: 20, _y:110, _w:10, _h:10},
		{_x: 50, _y:45, _w:100, _h:100},

		/*{_x: 10, _y:10, _w: 10, _h:10},
		{_x: 20, _y:10, _w:13, _h:10},
		{_x: 20, _y:20, _w:10, _h:11},
		{_x: 10, _y:20, _w:10, _h:10},
		{_x: 105, _y:15, _w:10, _h:10},
		{_x: 50, _y:50, _w:10, _h:20},
		{_x: 70, _y:50, _w:10, _h:20},
		{_x: 40, _y:55, _w:70, _h:10}, 
		{_x: 10, _y:100, _w:10, _h:10},
		{_x: 20, _y:110, _w:10, _h:10},
		{_x: 50, _y:45, _w:100, _h:100},
		{_x: 10, _y:10, _w: 10, _h:10},
		{_x: 20, _y:10, _w:13, _h:10},
		{_x: 20, _y:20, _w:10, _h:11},
		{_x: 10, _y:20, _w:10, _h:10},
		{_x: 105, _y:15, _w:10, _h:10},
		{_x: 50, _y:50, _w:10, _h:20},
		{_x: 70, _y:50, _w:10, _h:20},
		{_x: 40, _y:55, _w:70, _h:10}, 
		{_x: 10, _y:100, _w:10, _h:10},
		{_x: 20, _y:110, _w:10, _h:10},
		{_x: 50, _y:45, _w:100, _h:100}*/

	];
	return test_set;


}

test_set = init_test();



function newEvent(r,  type){
	if (type === 0)
		return {type:type, r:r, y:r._y, top:null}
	else
		return {type:type, r:r, y:r._y + r._h, top:null}

} 

function sortEvents(a, b){
	/*if (a.y == b.y )
		return (a.r._x - b.r._x)
	else*/
	return (a.y - b.y)
}


/*
 *	rectSet
 * 	 An object for tracking collections of intersecting rectangles and the path around them
 */

function rectSet(){
	this.covers = [];
	this.paths = [];
	this.primed = null;
};




rectSet.prototype.merge = function (a){
	if (!a.set){
		a.set= this;
		this.covers.push(a);;
		if (a._x<this.x1)
			this.x1 = a._x;
		if (a._y < this.y1)
			this.y1 = a._y;
		if (a._y + a._h > this.y2)
			this.y2 = a._y + a._h;
		if (a._x + a._w > this.x2)
			this.x2 = a._x + a._w;
	} else {
		
		// Push the lists from set a into this current set
		var mset = a.set, l = mset.covers.length;

		for (var i=0; i<l; ++i ){
			mset.covers[i].set = this;
			this.covers.push(mset.covers[i]);
		}
		
		// Use faster method on paths, since we don't need to set anything else
		this.paths.push.apply(this.paths, mset.paths)
		sets.splice( sets.indexOf(mset), 1)
		//removeFromArray(mset, sets);
		if (mset.x1 < this.x1)
			this.x1 = mset.x1
		if (mset.y1 < this.y1)
			this.y1 = mset.y1;
		if (mset.y2 > this.y2)
			this.y2 = mset.y2;
		if (mset.x2 > this.x2)
			this.x2 = mset.x2;
		
	}
};

rectSet.prototype.includes = function(e){
	for (var i=0, l=this.covers.length; i<l; i++){
		r = this.covers[i];
		if (r._x < e._x + e._w && r._y < e._y + e._h 
					&& r._x + r._w > e._x && r._y + r._h > e._y)
			return true
	}
	return false;
}

// This is the hard part
rectSet.prototype.addPoint =  function(x, y){
	//console.log("\n <><><> Adding point " + x + ", " + y)
	//var p = this.newPoint(x, y);
	var p = xEventStack.newPoint(x, y);
	//Every other time, store the point to deal with later.  (Points always come in connected pairs.)
	if (this.primed === null){
		this.primed = p;
		return;
	}

	// If we make it here, we now have two points.
	var q = this.primed;
	this.primed = null;

	//console.log("\n <><><> Adding segment  " + q.x + ", " +q.y+ " | " +p.x + ", " + p.y + "")
	// Attempt to attach the points.  
	// Returns either a push or an unshift function; null if the point doesn't attach anywhere.  
	// This can either be called or applied to an array to add points to the correct end.
	// This is a little bit of voodoo, but by returning the required *functions* we avoid a lot of conditionals.
	pAttach = this.findAttachment(p);
	qAttach = this.findAttachment(q);


	// If neither connnects, we have a new path
	// If only one connects, add the other to its path
	// If both connect, we need to merge the paths if there's more than 1 left
	if(!pAttach && !qAttach){ 
		this.paths.push([p, q]);
	} else if (!qAttach){
		pAttach.call(p.path, p);
		pAttach.call(p.path, q);
	} else if (!pAttach){
		qAttach.call(q.path, q);
		qAttach.call(q.path, p);
	} else {
		
		pAttach.call(p.path, p);
		qAttach.call(q.path, q);
		// Merge paths if they're different
		// If they're matched up right, just attach one array to the other
		// Otherwise, reverse one array so it *does* match up.
		if (p.path !== q.path){
			if(pAttach !== qAttach)
				pAttach.apply(p.path, q.path)
			else 
				pAttach.apply(p.path, q.path.reverse())
			// Then remove the path we just joined to p.path
			this.paths.splice( this.paths.indexOf(q.path), 1)
			//removeFromArray(q.path, this.paths);
		}
	}
	//delete p.path;
	//delete q.path;

};

rectSet.prototype.findAttachment = function(p){
	var i=0, path, paths=this.paths, px = p.x;
	// Cycle through paths, checking first and last point to see if p is below any of them
	while(path = paths[i++]){
		
		// if p is the new beginning of the path, points need to be unshifted 
		if (px === path[0].x){
			p.path=path;
			return Array.prototype.unshift;
		}	
		// p is the new end of the path, points need to be pushed
		else if (px === path[path.length-1].x){
			p.path=path;
			return Array.prototype.push;
		}
	}
	// If nothing is found, return null!
	return null;

}

// Will be used to recycle objects
rectSet.prototype.newPoint = function(x, y){
	return {x:x, y:y};
}


// Will be used to recycle objects
function makeSet(r){
	


	var s= new rectSet();
	r.set = s;
	s.covers.push(r);
	s.x1 = r._x;
	s.x2 = r._x + r._w;
	s.y1 = r._y;
	s.y2 = r._y + r._h;

	sets.push(s);
	return s;
}




xEventStack = {
	bin: [],
	pointer: 0,
	newEvent: function(x, r, type){
		if (this.pointer < this.bin.length){
			var p = this.bin[this.pointer++];
			p.x = x;
			p.r= r;
			p.type = type;
			return p;
		} else{
			var p = {x:x, r:r, type:type};
			this.bin.push(p);
			this.pointer++;
			return p;
		}

	},

/*
function newEvent(r,  type){
	if (type === 0)
		return {type:type, r:r, y:r._y, top:null}
	else
		return {type:type, r:r, y:r._y + r._h, top:null}

} 
*/

	newPoint: function(x, y){
		if (this.pointer < this.bin.length){
			var p = this.bin[this.pointer++];
			p.x = x;
			p.y = y;
			return p;
		} else
			var p = {x:x, y:y};
			this.bin.push(p);
			this.pointer++;
			return p;
	},

	reset: function(){
		this.pointer = 0;
	}


}





/*  Object for handling events as we scan a line along the x axis */

var xEvents = {
	events: [],
	i:0,
	next: function(){
		if (this.i>=this.events.length)
			return null
		else
			return this.events[this.i++];
	},

	nextMatch: function(e){
		if (this.i < this.events.length  && this.events[this.i].r === e.r ){
			//console.log("match point at" + e.x + ", " + this.events[this.i].x)
			return true
		}else
			return false

	},

	//TODO if this is the bottom of a rect, needs to remove the top corners
	add: function(e){
		//console.log("\nvvvv\n\nAdding " + e.r._x + ", " + (e.r._x + e.r._w));
		//console.log("Current array: " + this.events.toSource());
		var el = xEventStack.newEvent(e.r._x, e.r, 1) //this.newEvent(e.r._x, e.r, 1);
		var er = xEventStack.newEvent(e.r._x + e.r._w, e.r, -1);
		//var el = this.newEvent(e.r._x, e.r, 1) //this.newEvent(e.r._x, e.r, 1);
		//var er = this.newEvent(e.r._x + e.r._w, e.r, -1);
		var j=0, l = this.events.length, ev = this.events, ex = el.x;
		while(j<l){
			if (ex <= ev[j].x ){				
				ev.splice(j, 0, el);
				break;
			}
			j++;
		}
		if (j>=l){
			ev.push(el, er);
			//console.log("New array: " + this.events.toSource() + "\n\n");
			return;
		}
		ex = er.x;
		while(j<l+1){
			if (ex <= ev[j].x){
				if (ex != ev[j].x  ||  ev[j].type != 1 ){  // Make sure closing events are *after* opening events
					ev.splice(j, 0, er);

					return;
				}
			}
			j++;
		}
		if (j>=l){
			ev.push(er);
			
		}
		//console.log("New array: " + this.events.toSource() + "\n\n");

		// Push open and close events
		//this.events.push(, );
	}, 

	newEvent: function(x, r, type){
		return {x:x, r:r, type:type}
	},

	remove: function(xe){
		// Remove element
		var j = this.events.indexOf(xe);
		this.events.splice(j, 1);
		//var j = removeFromArray(xe, this.events);
		// If necessary, decrement counter, so that next() works properly.
		if (j<= this.i)
			this.i--;

	},

	prepare: function(){
		//prepCount++;

		this.i=0;
		//this.events.sort(this.xsort)
	},

	reset: function(){
		this.events.length = 0;
		i=0;
	},


};



// The algo works by sweeping downwards along the y axis.  
// The beginning and end of a rectangle are added to a queue of events, which are sorted by y
// All the points added will have y coordinates along an event

function SweepMerge(rects){
	var r, i, e, l;
	var e0, e1;
	var events = [];
	sets=[];

	for (var i=0, l=rects.length; i<l; ++i){
		r = rects[i];
		if (r.w <=0 || r._h <=0){
			console.log("Impossible")
			continue;
		}
		r.set = 0
		e0 = newEvent(r, 0);
		e1 = newEvent(r,  1);
		e1.top = true;
		events.push( e0, e1);	

	}	
	events.sort(sortEvents);
	//console.log(events.length + " y events");

	var i=0, j, k;
	e = events[0]

	//console.log("Starting y sweep")
	xEvents.reset();
	while (e){
		//console.log("\n------------------\n")
		//console.log("\n\nContinuing y sweep")

		// start this set of events
		if (!e.top)
			xEvents.add(e);
		currentY = e.y;
		e = events[++i];
	
		// as long as the next event shares the same y, add it as well.
		while(e && e.y == currentY){
			//console.log(e.toSource())
			if (!e.top)
				xEvents.add(e);
			e = events[++i];
		}
		//Sort the events added
		xEvents.prepare();

		currentSet = false;
		// Now proceed through the events in xEvents 
		// R is the number of open rectangles, L the number of open lines
		//console.log("Starting x sweep along y=" + currentY)
		//console.log(xEvents.events.toSource())
		sweepX(currentY);

	}

	xEventStack.reset();

	for (i=0, l=sets.length; i<l; i++){
		s = sets[i];
		s._x = s.x1;
		s._y = s.y1;
		s._w = s.x2 - s.x1;
		s._h = s.y2 - s.y1;
	}
	//console.log("Returning sets #" + sets.length);
	//console.log(sets.toSource())
	return sets;


}


// Sweep along the x axis, merging overlapping rectangles and adding points

// Caveats: might be problems with rectangles of 0 height; 
// Rectangles touching only at the corners might act a little weird
function sweepX(currentY){
	
	var xe, r;
	var currentX = false;
	var U=0, B=0//, UL=false, BL=false;  // Keep track of the number of rectangles above and below
	var oldCorners = 0;
	var newCorners;
	xe = xEvents.next();
	currentX = xe.x;
	currentSet = false;
	while(xe!==null){

		//console.log("-> sweep tick " + xe.x)
		// If necessary, find the currentSet, assigning a new one if empty
		r = xe.r;

		if (!currentSet){
			if (!r.set)  // could also check type of event?
				makeSet(r);
			currentSet = r.set
		} else if (r.set !== currentSet){
			//console.log("merging at x = " + currentX)
			currentSet.merge(r);	
		}

		// special case if rectangle has no events inside of it
		// Process two events at once, no need to change U or B
	

		if (  xEvents.nextMatch(xe)  ){

			if (U==0 || B==0){
				if  (U>0 || B>0){
					currentSet.addPoint(xe.x, currentY);
					xe=xEvents.next();
					currentSet.addPoint(xe.x, currentY);
				}
				else if (currentY == r._y ){
					currentSet.addPoint(xe.x, currentY);
					xe=xEvents.next();
					currentSet.addPoint(xe.x, currentY);
				}else if ( U==0 && currentY == r._y + r._h ) {
					currentSet.addPoint(xe.x, currentY);
					xEvents.remove(xe);
					xe=xEvents.next();
					currentSet.addPoint(xe.x, currentY);
					xEvents.remove(xe);
				} else{
					xEvents.next();
				}

				if (U + B == 0)
					currentSet = false;
			} else{
				xEvents.next();

			}
			xe = xEvents.next();
			if(xe)
				currentX = xe.x;
			continue;
			
		}
		

		//based on type, change the rect counters above and below currentY
		if (r._y < currentY)
			U += xe.type;
		if (r._y + r._h > currentY)
			B += xe.type;
		else 
			xEvents.remove(xe);
		
		



		// Increment
		xe = xEvents.next();
		
		// If we've moved along the x axis, stop to process the transition
		// With some mild type coercion, we count the number of open quadrants around this point
		// The current state (to the right) is tracked by U and B; the left state is maintained from the last time
		// We add the point if there's on occupided quadrant (convex corner) or three (concave corner)
		if (xe===null || (xe.x != currentX) ){
			//console.log("pause to process at x = " + currentX + " and  y = " + currentY)
			//console.log(UL +  " | " + U  )
			//console.log(BL +  " | " + B  )
			//corners = UL + BL; 
			newCorners = (U>0) + (B>0);
			//UL = U>0;
			//BL = B>0;
			
			if ( (oldCorners + newCorners) % 2 == 1)
				currentSet.addPoint(currentX, currentY);
			oldCorners = newCorners;
			if (xe)
				currentX = xe.x;
			// close set if no rectangles are currently open
			if (U + B == 0)
				currentSet = false;
		}

	}

}


var lenna;

function Pre(){
	drawRects(test_set);

}

function Run(){
	TestSweep();
	//Profile(SweepMerge);
	console.log("Xeventstack bin size " + xEventStack.bin.length)
	//console.log("Statico")
	//Profile(staticoMerge);
	
}

function TestSweep(){
	
	
	
	try{
		//test_set = base_test;
		
		SweepMerge(test_set);
		//console.log("#sets " + sets.length);
		drawBounds();
		//var rs = staticoMerge(test_set);
		//drawStatico(rs)
	} catch(e){
		console.log("Problem: " + e)
	}

}

function Profile(merge_function){
	
	/*lenna = new Image();   // Create new img element
	lenna.onload=Run2;
	lenna.src = 'Lenna.png'; // Set source path*/

	//gem = new Image();
	//gem.src = 'diamond.png'
	console.log('hi')
	t1 = +new Date();
	for(var c=0; c<1000; ++c){
		test_set = restart_test();
		merge_function(test_set);	
		//oldMerge(test_set);
		//staticoMerge(test_set);

	}
	
	t1 = +new Date() - t1;
	console.log("Sets " + sets.length)
	console.log("Time is "  + t1)
	console.log("Prep count is " + prepCount)


}












var path1 = [
	{x:10, y:10},
	{x:10, y:110},
	{x:110, y:110},
	{x:110, y:10}
]

var cut=50;
var path2 = [
	{x:10, y:10},
	{x:10, y:110},
	{x:110-cut, y:110},
	{x:110-cut, y:110-cut},
	{x:110, y:110-cut}, 
	{x:110, y:10}
]

var path3 = [
	{x:10, y:10},
	{x:10, y:110-cut},
	{x:110-cut, y:110-cut},
	{x:110-cut, y:10}
]




base_test = [
		{_x: 10, _y:10, _w: 10, _h:10},
		{_x: 20, _y:10, _w:13, _h:10},
		{_x: 20, _y:20, _w:10, _h:11},
		{_x: 10, _y:20, _w:10, _h:10},
		{_x: 105, _y:15, _w:10, _h:10},
		{_x: 50, _y:50, _w:10, _h:20},
		{_x: 70, _y:50, _w:10, _h:20},
		{_x: 40, _y:55, _w:70, _h:10}, 
		{_x: 10, _y:100, _w:10, _h:10},
		{_x: 20, _y:110, _w:10, _h:10},];
		//{_x: 50, _y:45, _w:100, _h:100} ];



function testDraw(path, ctx, cc){
		ctx.save();


		ctx.beginPath();
		//ctx.clearRect(10, 10, 100, 100);
		var p = path[path.length-1];

		ctx.moveTo(p.x, p.y)
		for (var j=0; j<path.length; j++){
			p = path[j];
			ctx.lineTo(p.x, p.y)
		}
		//ctx.closePath()
		ctx.clip();
		ctx.globalAlpha=.05;
		for (var k = 0 ; k<500; k++)
			ctx.drawImage(lenna, -250+k%10, -250)
		//ctx.stroke();

		ctx.restore();

}


function drawRects(set){
	var canvas = document.getElementById('canvas1');
	var ctx = canvas.getContext('2d');
	ctx.strokeStyle = "black";
	
	for (var i=0, l=set.length; i<l; ++i){
		console.log('draw')
		r = set[i];
		ctx.strokeRect(r._x, r._y, r._w, r._h)

	}
	//ctx.strokeRect(50,50,50,50);
}


function drawStatico(set){
	var canvas = document.getElementById('canvas1');
	var ctx = canvas.getContext('2d');
	ctx.strokeStyle = "red";
	ctx.lineWidth = 2;
	
	for (var i=0, l=set.length; i<l; ++i){
		console.log('draw')	
		r = set[i];
		ctx.strokeRect(r._x, r._y, r._w, r._h)

	}
	//ctx.strokeRect(50,50,50,50);
}

function drawBounds(){
	console.log("stroking")
	var canvas = document.getElementById('canvas1');
	var ctx = canvas.getContext('2d');
	ctx.strokeStyle = "red";
	ctx.lineWidth = "2"
	ctx.globalAlpha = 1
	for (var i=0, l=sets.length; i<l; ++i){
		ctx.save();

		console.log('draw')
		var o = sets[i].paths[0];
		console.log(o.toSource());
		ctx.beginPath();
		var p = o[o.length-1];

		ctx.moveTo(p.x, p.y)
		for (var j=0; j<o.length; j++){

			 p = o[j];
			 delete p.path;
			console.log("move " + p.toSource())
			ctx.lineTo(p.x, p.y)
		}
		ctx.stroke();
		ctx.closePath()
		ctx.strokeStyle = "orange";
		ctx.lineWidth = "4";
		
		o = sets[i];
		console.log("right sicde " + o.x1)
		ctx.strokeRect(o.x1, o.y1, o.x2-o.x1, o.y2-o.y1);
		ctx.strokeStyle = "red";
		ctx.lineWidth = "2"
		//ctx.clip();

		//ctx.drawImage(lenna, -250, -250)
		

		ctx.restore();
		

	}


}

