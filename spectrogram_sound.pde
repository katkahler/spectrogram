//Throughout this sketch, code is based from Dan Ellis' Live Spectrogram from Processing Forum
//(https://forum.processing.org/beta/num_1213161810.html)
//credit of math and variables in order to create the sgram[][] array goes to him. The arraySetup() function
//at line (LINE) is a function including his math and setup for filling the sgram[][] array

//importing the minim library and its audio analysis feature
//to import the minim library and code used to load and play audio (lines 11-16, 29-31, 49, 111-116)
//code is taken from "Audio in Processing - Minim Library"
//(http://artandtech.aalto.fi/wp-content/uploads/2012/06/minim.pdf)

import ddf.minim.analysis.*; 
import ddf.minim.*;

Minim minim; //loads minim
AudioPlayer song; //playback of an audio file
FFT fft; // (FFT = fast fourier transforms) generates a frequency spectrum based on the audio file signal put into the sketch's data folder

int colmax = 500; //maximum number of columns allowed before restarting
int rowmax = 256; //maximum number of rows allowed before restarting
int[][] sgram = new int[rowmax][colmax]; //an array that takes in every FFT frequency value from the audio input
int col; //a counter for the number of columns that have been drawn
int leftedge; //restarts the spectrogram after maximum number of columns allowed has been hit

void setup()
{
  size(512, 256, P3D);
  colorMode(HSB); //using hue, saturation, and brightness color mode

  minim = new Minim(this); //using the minim library and loading it
  song = minim.loadFile("hanako.mp3"); //loads sound file
  song.play(); //plays the song


//use of bufferSize and sampleRate and Hamming window is copied from Dan Ellis
  fft = new FFT(song.bufferSize(), song.sampleRate()); 
  fft.window(FFT.HAMMING); //a Hamming window is applied to hone sound 
  //explanation of Hamming window from National Instruments "Understanding FFTs and Windowing" (https://download.ni.com/evaluation/pxi/Understanding%20FFTs%20and%20Windowing.pdf)
}


void draw()
{
  background(0);
  lights();
  stroke(255);
  rotateX(-PI/4);//make it easy to see the 3D component

  // begin recieving audio
  fft.forward(song.mix);

  //building the sgram array and filling it will FFT input values
  arraySetup();

  //moving the column over for the next array fill
  col = col + 1;
  //when reset, the array starts over at the first column
  if (col == colmax) {
    col = 0;
  }

  //Start drawing based on array inputs
  triangles();

  //second count and check for reset
  leftedge = leftedge + 1;

  if (leftedge == colmax) {
    leftedge = 0;
  }
}

void arraySetup() {
  for (int i = 0; i < rowmax /* fft.specSize() */; i++)
  {
    if (fft.getBand(i)>0.2) { //check range
      sgram[i][col] = (int)Math.round(Math.max(0, 2*20*Math.log10(100*fft.getBand(i)))); 
      //for every space in the sgram array (in rows)there is the FFT value from the audio 
      //which has been maximized to a greater number
      //else statement is my own to prevent values of 0 from being drawn
    } else {
      sgram[i][col]=-100;  
      //if not then set the array space value to a number that does not fit the range of possible FFT values
    }
  }
}

void triangles() {
  for (int i = 0; i < leftedge; i++) {  // draw each column, up until the max column (leftedge)
    beginShape(TRIANGLES);
    for (int j = 0; j < rowmax; j++) {  // draw each row in the column, up until max row (rowmax)
      if (sgram[j][i]!=-100) { //if fft.getBand(i) is non existent //this extra if statement is my own for the sake of preventing values of 0 from being drawn
        if (i>2) {
          //creation of triangles vs. points in Dan Ellis' code is my own
          stroke(sgram[j][i], 255, 255); //hue changes based on FFT in sgram array, saturation and brightness remain same 
          vertex(i+colmax-leftedge, height-j, sgram[j][i]); //makes the first vertex of the triangle
          //

          stroke(sgram[j][i-1], 255, 255);
          vertex(i+colmax-leftedge-1, height-j, sgram[j][i-1]);

          stroke(sgram[j][i-2], 255, 255);
          vertex(i+colmax-leftedge-2, height-j, sgram[j][i-2]);
        }
      }
    }
    endShape();
  }
}
//credit for void stop() can go to both Dan Ellis and the "Audio in Processing" article, since both use this function 
//for closing audio
void stop()
{
  song.close(); //closing minim song audio classes
  minim.stop(); // stopping minim before closing

  super.stop(); //confirms that all has closed before exiting
}
