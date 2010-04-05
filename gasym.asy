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
	string tag; //special symbol for stone or intersection
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
	real fontsize;
	picture pic;
	Move[] move;

	void operator init(int size, int lines=19) {
		this.size = size;
		this.lines = lines;
		fontsize = this.size/(this.lines+2);
	}
}

// Global variables -- kind of afraid of these b/c I don't understand their interaction w/ XeTeX
//  -- it should be as simple as the variables initializing when the module loads,
// after which, later code in the XeLaTeX document can change it. This needs testing.

real stonefontscalar = 1; // default 1
real stonetenscalar = 0.7; // default 0.7
real stonehundredscalar = 0.7; // default 0.7
real charfontscalar = 0.4; // default 0.4


restricted int rhombusnumber = -5; //test that these can't be changed outside module! trust no one :-D
restricted real rhombusize = 0.35;

bool isplayed (Goban gb, Move move, int moveindex) {

// detects already played intersections.
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

void renderblankintersection(Goban gb, pair at) {
	real w = 0.5;
	path blankify = ((at.x-w,at.y-w)--(at.x-w,at.y+w)--(at.x+w,at.y+w)--(at.x+w,at.y-w)--cycle);
	filldraw(gb.pic,blankify,white,white);
}

void renderblackstone(picture pic=currentpicture, pair intersection) {
	filldraw(pic,circle(intersection,0.47),black);
}

void renderblackstone(Goban gb, pair intersection) {
	filldraw(gb.pic,circle(intersection,0.47),black);
}

void renderwhitestone(picture pic=currentpicture, pair intersection) {
	filldraw(pic,circle(intersection,0.46),white);
}

void renderwhitestone(Goban gb, pair intersection) {
	filldraw(gb.pic,circle(intersection,0.46),white);
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

void rendersquarestone(Goban gb, pair at, bool iswhite, pen modpen=currentpen) {
	real w = 0.25;
	path squarify = ((at.x-w,at.y-w)--(at.x-w,at.y+w)--(at.x+w,at.y+w)--(at.x+w,at.y-w)--cycle);
	if (iswhite) {
		renderwhitestone(gb,at);
		draw(gb.pic,squarify,modpen+black);
	} else {
		renderblackstone(gb,at);
		draw(gb.pic,squarify,modpen+white);
		
	}
}

void rendercharrhomb(Goban gb, pair at, string glyph, bool iswhite = true) {
	if (iswhite) {
		renderwhiterhombus(gb, at);
		label(gb.pic,scale(charfontscalar)*glyph,at,fontsize(gb.fontsize*stonefontscalar));
		}
}

void whitestonenum(Goban gb, pair intersection, int movenum) {
	renderwhitestone(gb.pic,intersection);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,intersection,fontsize(gb.fontsize*stonefontscalar)) ;
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,intersection,fontsize(gb.fontsize*stonetenscalar*stonefontscalar));
	} else if (movenum > 99){
		label(gb.pic,xscale(stonehundredscalar)*movenumtext,intersection,fontsize(gb.fontsize*stonetenscalar*stonefontscalar));
	}	
}

void blackstonenum(Goban gb, pair intersection, int movenum) {
	renderblackstone(gb.pic,intersection);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,intersection,fontsize(gb.fontsize*stonefontscalar)+white);
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,intersection,fontsize(gb.fontsize*stonetenscalar*stonefontscalar)+white);
	} else if (movenum > 99){
			label(gb.pic,xscale(stonehundredscalar)*movenumtext,intersection,fontsize(gb.fontsize*stonetenscalar*stonefontscalar)+white);
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
				if (move.num > 1) {	
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
				}			
			}	
	   	}
	}
}	
				
void addsequence(Goban gb, pair[] newmoves, int startnum, bool startwhite = false) {
	int i = startnum;
	bool whiteness = startwhite; // black is the default first move
	for (pair xy : newmoves) {
		Move addmove = new Move;
		addmove.at = xy;
		addmove.num = i;
		addmove.iswhite = whiteness;
		whiteness = !whiteness;
		i = i + 1; 
		gb.move.push(addmove);
	}
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

void addwhiterhombus(Goban gb,pair xy) {
		Move addmove = Move(xy,rhombusnumber,true);
		gb.move.push(addmove);
}

void addblackrhombus(Goban gb,pair xy) {
		Move addmove = Move(xy,rhombusnumber,false);
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

void drawgoban(Goban gb) {
	rendergoban(gb);
	rendermoves(gb);
}

// main sequence. starting to look like high level behavior!
Goban mygoban = Goban(400);
pair[] sequence = {(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(5,5),(7,7),(8,8),(9,9),(20,20),(-3,-5),(150,150),(13,13)};
pair[] abusetest = {(-2,5),(-24,-24),(150,150),(5,-14),(12,12)};
pair[] newstones = {(2,3),(3,4),(4,5),(5,6),(6,7)};
pair[] newwhites = {(3,2),(4,3),(5,4),(5,5),(6,5)};
pair[] newblacks = {(3,5),(4,6),(5,7)};
addsequence(mygoban,sequence,1);
addsequence(mygoban,abusetest,13, true);
addwhiterhombi(mygoban,newstones);
addblackrhombi(mygoban,newblacks);
//addwhitestones(mygoban,newwhites);
//addblackstones(mygoban,newblacks);
drawgoban(mygoban);
rendercharrhomb(mygoban,(6,10),"@");
renderblankintersection(mygoban,(10,6));
rendersquarestone(mygoban,(6,11),true);
rendersquarestone(mygoban,(7,10),false,linewidth(2));
shipout(mygoban.pic);
