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
	picture pic;
	// pair[] moves; // stores the numbered stones of the main sequence. 1 goban per variant!
	Move[] move;

	void operator init(int size, int lines) {
		this.size = size;
		this.lines = lines;
	//	this.move = new Move[];
	}
}

// Global variables -- kind of afraid of these b/c I don't understand their interaction w/ XeTeX
//  -- it should be as simple as the variables initializing when the module loads,
// after which, later code in the XeLaTeX document can change it. This needs testing.

real stonefontscalar = 1; // default 1
real stonetenscalar = 0.7; // default 0.7
real stonehundredscalar = 0.7; // default 0.7


void renderblackstone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.47),black);
}

void renderwhitestone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.46),white);
}

void whitestonenum(Goban gb, pair intersection, int movenum) {
	renderwhitestone(gb.pic,intersection);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonefontscalar)) );
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonetenscalar*stonefontscalar)) );
	} else if (movenum > 99){
		label(gb.pic,xscale(stonehundredscalar)*movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonetenscalar*stonefontscalar)) );
	}	
}

void blackstonenum(Goban gb, pair intersection, int movenum) {
	renderblackstone(gb.pic,intersection);
	string movenumtext = string(movenum);
	if (movenum > 1 & movenum < 10 ) {
		label(gb.pic,movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonefontscalar))+white);
	} 
	else if (movenum <100) {
		label(gb.pic,movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonetenscalar*stonefontscalar))+white);
	} else if (movenum > 99){
			label(gb.pic,xscale(stonehundredscalar)*movenumtext,intersection,fontsize((gb.size/(gb.lines+2)*stonetenscalar*stonefontscalar))+white);
	}
}

void rendergoban(picture pic=currentpicture, int gobansize, int gobanlines=19) {

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
		if ((gobanlines > 10) & (gobanlines % 2==1)) {
		dot(pic,(4,gobanlines/2+0.5));
		dot(pic,(gobanlines/2+0.5,4));
		dot(pic,(gobancounter-4,gobanlines/2+0.5));
		dot(pic,(gobanlines/2+0.5,gobancounter-4));
		dot(pic,(gobanlines/2+0.5,gobanlines/2+0.5));
		}
		dotfactor = 6; // hard coded, should restore to default, fix later
	} 	
}

bool isplayed (Goban gb, Move move) {

// detects already played intersections.
// if both stones have the same num (e.g. 0 for unnumbered stones) it will
// return false; this keeps the move from detecting itself, and probably
// constitutes correct behavior for un-numbered moves. 
//
// since all unexpected behavior is < 1, this could be caught and handled
// however one likes.

	bool status = false;
	for (Move xy : gb.move ) {
		if (xy.at == move.at) {
			if (xy.num < move.num) { 
				status = true;
			}
		}
	}
	return status;
}

void rendermoves(Goban gb) {
	for(Move move : gb.move) { 
	   if (isplayed(gb,move) == false) {	
			if (move.iswhite) {
				whitestonenum(gb,move.at,move.num);
			} else {
				blackstonenum(gb,move.at,move.num);
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
		i = i + 1; // no postfix rly? lolz
		gb.move.push(addmove);
	}
}

void drawgoban(Goban gb) {
	rendergoban(gb.pic,gb.size,gb.lines);
	rendermoves(gb);
}

// main sequence. starting to look like high level behavior!
Goban mygoban = Goban(350,13);
pair[] sequence = {(1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(5,5),(7,7),(8,8),(9,9)};
addsequence(mygoban,sequence,7,true);
drawgoban(mygoban);
shipout(mygoban.pic);
