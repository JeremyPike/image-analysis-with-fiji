
/* Macro for calculating Manders coefficents for a single file
   This macro was developed for the Image Analysis for Fiji course run by the 
   Centre of Membrane Proteins and Receptors (COMPARE).
   
   Author: Jeremy Pike
   Course Website: https://jeremypike.github.io/image-analysis-with-fiji/
*/

 
// create user interface asking for a input directory and file suffix
#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix


// close any open images so we start with a clean slate
run("Close All");
// create table to hold coloc stats
measurments = Table.create("measurements");
// call process folder function
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {

	print("Processing: " + input + File.separator + file);
	// open the current image
	open(input + File.separator + file);
	// rename image window to make it easier to keep track
	rename("raw_data");
	// split into 2 windows (one for each channel) 
	run("Split Channels");
	
	//// Segmentation workflow for first channel ////
	
	// You should insert your segmentation workflow here
	// select raw data for C1
	selectWindow("C1-raw_data");
	// duplicate as a new window called C1-segmentation
	run("Duplicate...", "title=C1-segmentation duplicate");
	// blur with a Gaussian to reduce noise
	run("Gaussian Blur...", "sigma=1 stack");
	// apply Otsu threshold
	setAutoThreshold("Otsu dark stack");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Otsu background=Dark black");
	
	//// Segmentation workflow for second channel ////
	
	// This is the same as for C1 but can be different if needed
	selectWindow("C2-raw_data");
	run("Duplicate...", "title=C2-segmentation duplicate");
	run("Gaussian Blur...", "sigma=1 stack");
	setAutoThreshold("Otsu dark stack");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Otsu background=Dark black");
	
	//// Use the channel segmentations to calculate the Manders coefficients ////
	
	// zero all signal outside of the C1 segmentation, this creates a new window
	// to do this we use the imageCalculator plugin and the "AND" operation
	imageCalculator("AND create stack", "C1-raw_data","C1-segmentation");
	// rename new window
	rename("C1-signal");
	// get the sum of all signal in this 3D volume useing our user defined function
	C1_sum = getSum3D();
	// get the sum C1 signal colocalizing with C2
	imageCalculator("AND create stack", "C1-signal","C2-segmentation");
	rename("C1-coloc_signal");
	C1_coloc_sum = getSum3D();
	// get the sum C2 signal
	imageCalculator("AND create stack", "C2-raw_data","C2-segmentation");
	rename("C2-signal");
	C2_sum = getSum3D();
	// get the sum C2 signal colocalizing with C1
	imageCalculator("AND create stack", "C2-signal","C1-segmentation");
	rename("C2-coloc_signal");
	C2_coloc_sum = getSum3D();
	
	// calculate the Manders coefficients
	M1 = C1_coloc_sum / C1_sum;
	M2 = C2_coloc_sum / C2_sum;
	
	// print to log window
	print("File: " + file);
	print("M1: " + M1);
	print("M2: " + M2);
	
	// add as new row inmeasurments table
	selectWindow("measurements");
	row = Table.size;
	Table.set("file", row, file);
	Table.set("M1", row, M1);
	Table.set("M2", row, M2);
	Table.update;
	// save table in same directory as images
	Table.save(input + File.separator + "coloc_stats.csv")	
	// clean up
	run("Close All");
}


// This is an example of a user defined function which we use within the script
// It loops through all slices in the active window and calculates the sum intensity across them
function getSum3D() {
	// start sum at zero
	sum = 0;
	// loop through slices
	for (z = 1; z <= nSlices; z++) {
		// set slice
		setSlice(z);
		//get area and mean of slice
		getStatistics(area, mean);
		// multiply area and mean together to get sum for slice and add this to the rolling total
		sum += area * mean;
	}
	return sum ;
}

