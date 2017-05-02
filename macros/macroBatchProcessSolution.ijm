
/* Macro for batch processing of image files whithin a given directory.
   This macro was developed for the Image Analysis for Fiji course run by the 
   Centre of Membrane Proteins and Receptors (COMPARE).
*/
// Author: Jeremy Pike
// Course Website: https://jeremypike.github.io/image-analysis-with-fiji/

// Turn on batch processing
setBatchMode(true);

// Store the directory as a variable. This will be a different location on your machine.
directory = "C:\\Users\\pikeja\\Reports\\image-analysis-with-fiji\\SampleData\\ND2H-SIM\\";

// Store the file extension as a variable
extension = ".tif";

// Get the names of all files in given directory
fileNames = getFileList(directory);

// Loop through the number of files in the directory, regardless of how many there are
for  (i = 0; i < fileNames.length; i = i + 1)  {
 	
	// Only open if it’s a .tif file open and process it
	if (endsWith(fileNames[i], extension) == true) {
		
		// Open the Image
		open(directory + fileNames[i]);

		/////////////// Recorded commands go here !! ////////////////////
		
		// Perform a Gaussian Blur, with radius 4 pixels to de-noise the image
		run("Gaussian Blur...", "sigma=4");
		
		// Subtract the background with rolling ball radius of 60 pixels
		run("Subtract Background...", "rolling=60");
		
		// Perform an automated Otsu thresholding and convert to binary image
		setAutoThreshold("Default dark");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");
		
		// Fill any "holes" in the binary image
		run("Fill Holes");
		
		// Seperate touching objects with a watershed transformation
		run("Watershed");
		
		// Count the number of particles with the Analyse Particles plugin.
		// Minimum object size set to 9 micro-meters squared
		// Only the "exclude on edges", "summarize" boxes were ticked
		run("Analyze Particles...", "size=9-Infinity exclude summarize");

		/////////////// End of recorded commands ///////////////////
				
		// Close all windows
		run("Close All");
	}
}