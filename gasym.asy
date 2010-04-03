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
	pen specialpen; //sends a color or font ; might be needed.
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
	
	//eventually needs to live where it can be modular!
//	renderwhitestone(pic,(2,2));
//	label(pic,format(9),(2,2),fontsize((gobansize/(gobancounter+2)*1.15)));
}

void drawgoban(Goban gb) {
	rendergoban(gb.pic,gb.size,gb.lines);
}

Goban mygoban = Goban(400,23);
drawgoban(mygoban);
renderblackstone(mygoban.pic,(3,5));
whitestonenum(mygoban,(4,4),5);
blackstonenum(mygoban,(2,3),7);
blackstonenum(mygoban,(7,7),8);
whitestonenum(mygoban,(2,2),69);
whitestonenum(mygoban,(9,4),137);
blackstonenum(mygoban,(7,8),77);
blackstonenum(mygoban,(9,3),122);
blackstonenum(mygoban,(15,15),144);
whitestonenum(mygoban,(14,15),145);
shipout(mygoban.pic);
