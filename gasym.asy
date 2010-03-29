void drawgoban(picture pic=currentpicture, int gobansize, int gobanlines=19) {

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

}

void placeblackstone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.47),black);
}

void placewhitestone(picture pic=currentpicture,pair intersection) {
	filldraw(pic,circle(intersection,0.46),white);
}

//	label("23",(6,6));


picture mygoban; //if you will
drawgoban(mygoban,500,19);
placeblackstone(mygoban,(5,6));
placewhitestone(mygoban,(5,5));
placewhitestone(mygoban,(6,6));
placeblackstone(mygoban,(6,7));
placewhitestone(mygoban,(5,7));
placeblackstone(mygoban,(7,6));
placeblackstone(mygoban,(19,19));
//placewhitestone(mygoban,(12,4));
shipout(mygoban);
