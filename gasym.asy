import fontsize; 
usepackage("fontspec");
usepackage("xunicode");
usepackage("xltxtra");
texpreamble("\setmainfont{Linux Libertine}");

struct Move {
	pair at;
	int num; //positive for moves, negative for other symbols
	bool iswhite; 
	bool special; //both false is black 
	string glyph; //special symbol for stone or at
	string comment;
	pen specialpen; //sends a color or font ; might be needed.
	
	void operator init(pair at, int num, bool iswhite) {
		this.at = at;
		this.num = num;
		this.iswhite = iswhite;
	}
}

struct Goban {
	int size;
	int lines;
	int movenum;
	bool whitemove;
	real fontsize;
	picture pic;
	Move[] move;

	void operator init(int size, int lines=19) {
		this.size = size;
		this.lines = lines;
		this.fontsize = this.size/(this.lines+2);
		unitsize(this.pic,this.fontsize);
		this.movenum = 1;
		this.whitemove = false; // black plays first
	}
}

Move mumumumove[] = new Move[]; //can this possibly work?
  // though it makes the Baby Jesus cry, this variable seems to be needed for cloneGoban to function
  // which is in turn needed because I can't figure out how to pass structures by value. hmm.

Goban cloneGoban(Goban b) {
	Goban a = new Goban;
	a.size = b.size;
	a.lines = b.lines;
	a.movenum = b.movenum;
	a.whitemove = b.whitemove;
	a.fontsize = b.fontsize;
	erase(a.pic);
	add(a.pic,b.pic); //believe it or not, this adds b to a! (or should, asy manual pg 49)
	a.move = copy(b.move);
	return a;
}


// Global variables -- kind of afraid of these b/c I don't understand their interaction w/ XeTeX
//  -- it should be as simple as the variables initializing when the module loads,
// after which, later code in the XeLaTeX document can change it. This needs testing.

real stonefontscalar = 1; // default 1
real stonetenscalar = 0.7; // default 0.7
real stonehundredscalar = 0.7; // default 0.7
real stonepenscalar = 0.06;   // default TBD
real charfontscalar = 0.8; // default 0.4


restricted int rhombusnumber = -5; //test that these can't be changed outside module! trust no one :-D
restricted int charnumber = -6;
restricted real rhombusize = 0.35;

bool isplayed (Goban gb, Move move, int moveindex) {

// detects already played ats.
// considers the absolute order of play to be the array order 
// of the moves; this should be respected. 

	bool status = false;
	for (int i=0; i< gb.move.length; ++i) {
		Move xy = gb.move[i];
		if (xy.at == move.at) {
			if (i < moveindex) { 
				status = true;
			} 
		}
	}
	return status;
}

void renderblanksquare(Goban gb, pair at) {
	real w = 0.5;
	path blankify = ((at.x-w,at.y-w)--(at.x-w,at.y+w)--(at.x+w,at.y+w)--(at.x+w,at.y-w)--cycle);
	filldraw(gb.pic,blankify,white,white);
}

void renderchar(Goban gb, pair at, string glyph) {
	// Currently requires that the goban be drawn so that the units are correct
	label(gb.pic,scale(charfontscalar)*glyph,at,fontsize(gb.fontsize*stonefontscalar));
}

void renderblackstone(picture pic=currentpicture, pair at) {
	filldraw(pic,circle(at,0.47),black);
}

void renderblackstone(Goban gb, pair at) {
	filldraw(gb.pic,circle(at,0.47),black);
}

void renderwhitestone(picture pic=currentpicture, pair at) {
	filldraw(pic,circle(at,0.46),white);
}

void renderwhitestone(Goban gb, pair at) {
	filldraw(gb.pic,circle(at,0.46),white);
}

void renderpenrhombus(Goban gb, pair at, pen pencil) {
	path diamante = ((at.x-rhombusize,at.y)--(at.x,at.y+rhombusize)--(at.x+rhombusize,at.y)--(at.x,at.y-rhombusize)--cycle);
	filldraw(gb.pic,diamante,pencil);
}

void renderwhiterhombus(Goban gb, pair at) {
	renderpenrhombus(gb,at,white);
}

void renderblackrhombus(Goban gb, pair at) {
	renderpenrhombus(gb,at,black);
}

void rendersquareglyph(Goban gb, pair at, pen modpen) {
	real w = 0.20;
	path squarify = ((at.x-w,at.y-w)--(at.x-w,at.y+w)--(at.x+w,at.y+w)--(at.x+w,at.y-w)--cycle);
	draw(gb.pic,squarify,modpen);
}

void rendersquarestone(Goban gb, pair at, bool iswhite, pen modpen=currentpen) {
	real w = 0.20;
	path squarify = ((at.x-w,at.y-w)--(at.x-w,at.y+w)--(at.x+w,at.y+w)--(at.x+w,at.y-w)--cycle);
	if (iswhite) {
		renderwhitestone(gb,at);
		rendersquareglyph(gb,at,modpen);
	} else {
		renderblackstone(gb,at);
		rendersquareglyph(gb,at,modpen);
	}
} 

void rendercharrhomb(Goban gb, pair at, string glyph, bool iswhite = true) {
	if (iswhite) {
		renderwhiterhombus(gb, at);
		label(gb.pic,scale(charfontscalar)*glyph,at,fontsize(gb.fontsize*stonefontscalar));
		}
}

void whitestonenum(Goban gb, pair at, int movenum) {
	renderwhitestone(gb.pic,at);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,at,fontsize(gb.fontsize*stonefontscalar)) ;
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,at,fontsize(gb.fontsize*stonetenscalar*stonefontscalar));
	} else if (movenum > 99){
		label(gb.pic,xscale(stonehundredscalar)*movenumtext,at,fontsize(gb.fontsize*stonetenscalar*stonefontscalar));
	}	
}

void blackstonenum(Goban gb, pair at, int movenum) {
	renderblackstone(gb.pic,at);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,at,fontsize(gb.fontsize*stonefontscalar)+white);
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,at,fontsize(gb.fontsize*stonetenscalar*stonefontscalar)+white);
	} else if (movenum > 99){
			label(gb.pic,xscale(stonehundredscalar)*movenumtext,at,fontsize(gb.fontsize*stonetenscalar*stonefontscalar)+white);
	}
}

void rendergoban(picture pic=currentpicture, int gobansize, int gobanlines) {

	int gobancounter=gobanlines + 1;
	unitsize(pic,gobansize/(gobancounter+1));

	//Bounding Box and background

	filldraw(pic,box((0.25,0.25),(gobancounter-0.25,gobancounter-0.25)),white,white);

	//Draw grid

	for(int i=1; i < gobancounter; ++i) {
 		draw(pic,(i,1)--(i,gobanlines));
	} 

	for(int i=1; i < gobancounter; ++i) {
 		draw(pic,(1,i)--(gobanlines,i));
	}

	//Hoshi!

	if(gobanlines > 5) {
	
		if (gobansize<70) {  // muck about with this until the hoshi look right
			dotfactor = 4;
		}
		dot(pic,(4,4));
		dot(pic,(gobancounter-4,4));
		dot(pic,(gobancounter-4,gobancounter-4));
		dot(pic,(4,gobancounter-4));
		if ((gobanlines > 14) & (gobanlines % 2==1)) {
		dot(pic,(4,gobanlines/2+0.5));
		dot(pic,(gobanlines/2+0.5,4));
		dot(pic,(gobancounter-4,gobanlines/2+0.5));
		dot(pic,(gobanlines/2+0.5,gobancounter-4));
		dot(pic,(gobanlines/2+0.5,gobanlines/2+0.5));
		}
		dotfactor = 6; // hard coded, should restore to default, fix later
	} 	
}

void rendergoban(Goban gb) {
	rendergoban(gb.pic,gb.size,gb.lines);
}

void rendermoves(Goban gb) {
	for (int i=0; i< gb.move.length; ++i) {
		Move move = gb.move[i]; //by referenece; should work the same as before
	   	if (isplayed(gb,move,i) == false) {
			if ((move.at.x <= gb.lines) & (move.at.y <= gb.lines)
			  & (move.at.x > 0) & (move.at.y > 0)) {
				if (move.num > 0) {	
					if (move.iswhite) {
						whitestonenum(gb,move.at,move.num);
					} else {
						blackstonenum(gb,move.at,move.num);
					}
				} else if (move.num == 0) {
					if (move.iswhite) {
						renderwhitestone(gb,move.at);
					} else {
						renderblackstone(gb,move.at);
					}
				} else if (move.num == rhombusnumber) {
					if (move.iswhite) {
						renderwhiterhombus(gb,move.at);
					} else {
						renderblackrhombus(gb,move.at);
					}
				} else if (move.num == charnumber) {
					renderblanksquare(gb,move.at);
					renderchar(gb,move.at,move.glyph);
				}			
			}	
	   	}
	}
}	

void addstonenum(Goban gb, pair at, int movenum, bool iswhite = false) {
	Move addmove = new Move;
	addmove.at = at;
	addmove.num = movenum;
	addmove.iswhite = iswhite;
	gb.move.push(addmove);
	
}
				
void addmove(Goban gb, pair at) {
	addstonenum(gb,at,gb.movenum,gb.whitemove);
	gb.movenum = ++gb.movenum;
	gb.whitemove = ! gb.whitemove;
}
	
void addchar(Goban gb, pair at, string glyph) {
	Move addmove = new Move;
	addmove.at = at;
	addmove.num = charnumber;
	addmove.glyph = glyph;
	gb.move.push(addmove);
}			
	
void addsequence(Goban gb, pair[] newmoves, int startnum, bool startwhite = false) {
	int i = startnum;
	bool whiteness = startwhite; // black is the default first move
	for (pair xy : newmoves) {
		Move addmove = new Move;
		addmove.at = xy;
		addmove.num = i;
		addmove.iswhite = whiteness;
		gb.move.push(addmove);
		whiteness = !whiteness;
		i = i + 1;		
	}
	gb.movenum = i;
	gb.whitemove = whiteness;
}

void addsequence(Goban gb, pair[] newmoves) {
	addsequence(gb,newmoves,gb.movenum,gb.whitemove);
}

void addstones(Goban gb, pair[] newmoves, bool startwhite = false) {
	bool whiteness = startwhite;
	for (pair xy : newmoves) {
		Move addmove = Move(xy,0,whiteness);
		gb.move.push(addmove);
		whiteness = !whiteness;
	}
}

void addblackstones(Goban gb, pair[] newmoves) {
	for (pair xy : newmoves) {
		Move addmove = Move(xy,0,false);
		gb.move.push(addmove);
	}
}

void addwhitestones(Goban gb, pair[] newmoves) {
	for (pair xy : newmoves) {
		Move addmove = Move(xy,0,true);
		gb.move.push(addmove);
	}
}

void addwhiterhombus(Goban gb,pair at) {
		Move addmove = Move(at,rhombusnumber,true);
		gb.move.push(addmove);
}

void addblackrhombus(Goban gb,pair at) {
		Move addmove = Move(at,rhombusnumber,false);
		gb.move.push(addmove);
}

void addwhiterhombi(Goban gb, pair[] newrhombi) {
	for (pair xy: newrhombi) {
		addwhiterhombus(gb,xy);
	}	
}

void addblackrhombi(Goban gb, pair[] newrhombi) {
	for (pair xy: newrhombi) {
		addblackrhombus(gb,xy);
	}	
}

void reflectgoban(Goban gb) {
	pair flipxy(pair a) {
		pair b;
		b = (a.y,a.x);
		return b;
	}
	for (int i=0; i< gb.move.length; ++i) {
			gb.move[i].at = (gb.move[i].at.y, gb.move[i].at.x);
	}
}

void drawgoban(Goban gb) {
	rendergoban(gb);
	rendermoves(gb);
}

void testsuite(Goban gb) {
	pair[] firstrow  = {(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,13),(1,19)};
	pair[] secondrow = {(2,1),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,13),(2,19)};
	pair[] thirdrow  = {(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,13),(3,19)};
	pair[] fourthrow = {(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),(4,9),(4,13),(4,19)};
	addsequence(gb,firstrow);
	addsequence(gb,secondrow);
	addstones(gb,thirdrow);
	addsequence(gb,fourthrow);
	addmove(gb,(5,1));
	addmove(gb,(5,2));
	addchar(gb,(5,3),"@");
	addmove(gb,(5,4));
	reflectgoban(gb);
	drawgoban(gb);
}

// main sequence. starting to look like high level behavior!

Goban mygoban = Goban(400,9);
Goban yourgoban = Goban(300,15);
addmove(mygoban,(5,5));
testsuite(mygoban);
mygoban = cloneGoban(yourgoban);
testsuite(mygoban);
drawgoban(yourgoban);
shipout(mygoban.pic);



















//pair[] sequence = {(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(5,5),(7,7),(8,8),(9,9),(20,20),(-3,-5),(150,150),(13,13)};
//pair[] abusetest = {(-2,5),(-24,-24),(150,150),(5,-14),(12,12)};
//pair[] newstones = {(2,3),(3,4),(4,5),(5,6),(6,7)};
//pair[] newwhites = {(3,2),(4,3),(5,4),(5,5),(6,5)};
//pair[] newblacks = {(3,5),(4,6),(5,7)};
//addsequence(mygoban,sequence,1);
//addsequence(mygoban,abusetest,13, true);
//addwhiterhombi(mygoban,newstones);
//addblackrhombi(mygoban,newblacks);
//addwhitestones(mygoban,newwhites);
//addblackstones(mygoban,newblacks);
//rendercharrhomb(mygoban,(6,10),"@");
//renderblankat(mygoban,(10,6));
//rendersquarestone(mygoban,(6,11),true,linewidth(mygoban.size/mygoban.lines*stonepenscalar)+red);
//rendersquarestone(mygoban,(7,10),false,linewidth(mygoban.size/mygoban.lines*stonepenscalar)+red);

