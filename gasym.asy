import fontsize; 

struct Goban {
	int size;
	int lines;
	picture pic;
	
	void operator init(int size, int lines) {
		this.size = size;
		this.lines = lines;
	}
}

void renderblackstone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.47),black);
}

void renderwhitestone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.46),white);
}

void whitestonenum(Goban gb, pair intersection, int movenum) {
	renderwhitestone(gb.pic,intersection);
	label(gb.pic,format(movenum),intersection,fontsize((gb.size/(gb.lines+2)*1)));
}

void blackstonenum(Goban gb, pair intersection, int movenum) {
	renderblackstone(gb.pic,intersection);
	label(gb.pic,format(movenum),intersection,fontsize((gb.size/(gb.lines+2)*1))+white);
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
		dotfactor = 6; // hard coded, should restore to default, fix later
	} 
	
	//eventually needs to live where it can be modular!
//	renderwhitestone(pic,(2,2));
//	label(pic,format(9),(2,2),fontsize((gobansize/(gobancounter+2)*1.15)));
}

void drawgoban(Goban gb) {
	rendergoban(gb.pic,gb.size,gb.lines);
}



Goban mygoban = Goban(250,9);
drawgoban(mygoban);
renderblackstone(mygoban.pic,(3,5));
whitestonenum(mygoban,(4,4),6);
blackstonenum(mygoban,(2,3),7);

shipout(mygoban.pic);
