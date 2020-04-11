selectImage("binary_nuclei.tif");
getDimensions(width, height, channels, slices, frames);
newImage("cell_count_mask", "8-bit Black", width, height, slices);
selectImage("binary_nuclei.tif");
run("Analyze Particles...", "show=[Count Masks] display clear");
rename("nuclei_count_mask");
n=nResults;
run("Clear Results");
for (i=1; i<=n; i++) {
	selectImage("nuclei_count_mask");
	setThreshold(i, i);
	run("Create Mask");
	rename("nucleus-"+i);
	run("BinaryReconstruct ", "mask=binary_cell.tif seed=nucleus-"+i+" create white");
	rename("cell-"+i);
	run("Analyze Particles...", "add");
	close("nucleus-"+i);
	close("cell-"+i);
	selectImage("cell_count_mask");
	roiManager("Select", i-1);
	setForegroundColor(i, i, i);
	roiManager("fill");
}
selectImage("nuclei_count_mask");
run("glasbey_inverted");
selectImage("cell_count_mask");
run("glasbey_inverted");
run("Tile");
