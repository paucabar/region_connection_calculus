// get the starting coordinates of the objects (nuclei)
selectImage("binary_nuclei.tif");
run("Particles8 ", "white show=Particles minimum=0 maximum=9999999 overwrite redirect=None");
nucX=newArray(nResults);
nucY=newArray(nResults);
for (i=0; i<nucX.length; i++) {
	nucX[i]=getResult("XStart", i);
	nucY[i]=getResult("YStart", i);
}

// get the starting coordinates of the objects (cells)
selectImage("binary_cell.tif");
run("Particles8 ", "white show=Particles minimum=0 maximum=9999999 overwrite redirect=None");
cellX=newArray(nResults);
cellY=newArray(nResults);
for (i=0; i<cellX.length; i++) {
	cellX[i]=getResult("XStart", i);
	cellY[i]=getResult("YStart", i);
}

// get the RCC image
run("RCC8D UF Multi", "x=binary_nuclei.tif y=binary_cell.tif show=RCC5D details");
selectImage("RCC");

getDimensions(widthRCC, heightRCC, channelsRCC, slicesRCC, framesRCC);

// duplicate binary masks as 16-bit images
selectImage("binary_nuclei.tif");
run("Duplicate...", "title=nuc_count_mask");
run("16-bit");
run("glasbey_inverted");
selectWindow("binary_cell.tif");
run("Duplicate...", "title=cell_count_mask");
run("16-bit");
run("glasbey_inverted");

// remove non-connected objects (nuclei)
for (x=0; x<widthRCC; x++) {
	grayValue=0;
	for (y=0; y<heightRCC; y++) {
		selectImage("RCC");
		grayValue+=getPixel(x, y);
	}
	if (grayValue == 0) {
		setColor(0);
		selectImage("nuc_count_mask");
		floodFill(nucX[x], nucY[x],"8");
	}
}

// remove non-connected objects (cells)
for (y=0; y<heightRCC; y++) {
	grayValue=0;
	for (x=0; x<widthRCC; x++) {
		selectImage("RCC");
		grayValue+=getPixel(x, y);
	}
	if (grayValue == 0) {
		setColor(0);
		selectImage("cell_count_mask");
		floodFill(cellX[y], cellY[y],"8");
	}
}

// index connected objects
count=1;
for (x=0; x<widthRCC; x++) {
	for (y=0; y<heightRCC; y++) {
		selectImage("RCC");
		grayValue=getPixel(x, y);
		if (grayValue>0 && grayValue <4 ) {
			setColor(count);
			if (grayValue ==1)  print("Potential non-unique PO between nucleus "+x+" and cell "+y);	
			selectImage("nuc_count_mask");
			floodFill(nucX[x], nucY[x],"8");
			selectImage("cell_count_mask");
			floodFill(cellX[y], cellY[y],"8");			
			count++;
		}
	}
}

// generate indexed cytoplasms
imageCalculator("Subtract create", "cell_count_mask","nuc_count_mask");

// sort
close("RCC");
run("Tile");