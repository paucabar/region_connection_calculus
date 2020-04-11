// get the starting coordinates of the objects (nuclei)
selectImage("binary_nuclei.tif");
run("Set Measurements...", "  redirect=None decimal=2");
run("Analyze Particles...", "display clear record");
nucX=newArray(nResults);
nucY=newArray(nResults);
for (i=0; i<nucX.length; i++) {
	nucX[i]=getResult("XStart", i);
	nucY[i]=getResult("YStart", i);
}

// get the starting coordinates of the objects (cells)
selectImage("binary_cell.tif");
run("Set Measurements...", "  redirect=None decimal=2");
run("Analyze Particles...", "display clear record");
cellX=newArray(nResults);
cellY=newArray(nResults);
for (i=0; i<cellX.length; i++) {
	cellX[i]=getResult("XStart", i);
	cellY[i]=getResult("YStart", i);
}

// get the RCC image
run("RCC8D UF Multi", "x=binary_nuclei.tif y=binary_cell.tif show=RCC5D details");
selectImage("RCC");
run("8-bit");
getDimensions(widthRCC, heightRCC, channelsRCC, slicesRCC, framesRCC);

// generate two 8-bit black images sizes as the binary images
selectImage("binary_nuclei.tif");
getDimensions(width, height, channels, slices, frames);
newImage("nuc_count_mask", "8-bit Black", width, height, slices);
newImage("cell_count_mask", "8-bit Black", width, height, slices);

// create the count masks of nuclei and cells, which will be linked by its object index
run("Wand Tool...", "tolerance=0 mode=Legacy");
count=1;
for (x=0; x<widthRCC; x++) {
	for (y=0; y<heightRCC; y++) {
		selectImage("RCC");
		grayValue=getPixel(x, y);
		if (grayValue != 255) {
			setForegroundColor(count, count, count);
			selectImage("binary_nuclei.tif");
			doWand(nucX[x], nucY[x]);
			roiManager("add");
			selectImage("nuc_count_mask");
			roiManager("fill");
			roiManager("reset");
			selectImage("binary_cell.tif");
			doWand(cellX[y], cellY[y]);
			roiManager("add");
			selectImage("cell_count_mask");
			roiManager("fill");
			roiManager("reset");
			count++;
		}
	}
}

//sort
selectImage("binary_nuclei.tif");
run("Select None");
selectImage("binary_cell.tif");
run("Select None");
selectImage("nuc_count_mask");
run("glasbey_inverted");
selectImage("cell_count_mask");
run("glasbey_inverted");
close("RCC");
run("Tile");