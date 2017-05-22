

/* Macro which labels each slice.
   This macro was developed for the Image Analysis for Fiji course run by the 
   Centre of Membrane Proteins and Receptors (COMPARE).
*/
// Author: Jeremy Pike
// Course Website: https://jeremypike.github.io/image-analysis-with-fiji/

// Find the dimensions of the active window, we need the number of slices
getDimensions(width, height, channels, slices, frames)

// Loop through all slices in the stack
for (c = 1; c <= channels; c++) {
	Stack.setChannel(c);
	for (t = 1; t <=frames; t ++) {
		Stack.setFrame(t);
		for (i = 1; i <= slices; i = i + 1) {
		
			// Set the slice to the current index
			Stack.setSlice(i)
		
			// Draw the slice index at position (5,5)
			makeText("z = " + i, 5, 5);
			run("Draw", "slice");
			
		}
}
}