import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.ugens.*;

Minim       minim;
AudioOutput out;
Oscil       wave;
Oscil       wave2;
Oscil       wave3;
Oscil       wave4;
Oscil       wave5;
Oscil       wave6;
ChebFilter cbf;
Gain       gain;
Frequency  currentFreq;



float[] steps;
float[] normalizedSteps;
String[] day;
int totalDays;
float scale;
float max;
float amplitudeOutput;
float interpolateOut;
int indeX;
float velocity;

int passTime;
int saveTime = 0;
int limitTime = 1000;

float speed = 10;

Boolean trigger = false;

PGraphics pg;





void setup() {
  fullScreen(P2D);
  //size(1024, 360, P2D);
  println(trigger);

  // Chart 
  {
    // scaling steps count for window  
    scale = height;

    // Load data
    Table table = loadTable("days.csv", "header");
    totalDays = table.getRowCount();
    println("total days: " + totalDays);

    // Get step value 
    steps = new float[totalDays];
    day = new String[totalDays];
    for (int i = 0; i<table.getRowCount(); i++) {
      TableRow row = table.getRow(i);
      day[i] = row.getString("Finish");
      steps[i]= row.getFloat("Steps");
    }

    max = max(steps);
    println("the max steps count in total: " + max(steps));

    normalizedSteps = new float[steps.length];
    for (int i = 0; i<steps.length; i++) {
      normalizedSteps[i] = norm(steps[i], 0, max);
    }
  }

  // Audio 
  {
    minim = new Minim(this);

    // output to soundCard
    out = minim.getLineOut(Minim.STEREO, 2048 );
    gain = new Gain(0.f);
    Summer sum = new Summer();
    currentFreq = Frequency.ofPitch( "A4" );


    //wave6 = new Oscil( 1560, 0.1, Waves.SAW);
    wave = new Oscil( 397, 0.9, Waves.SAW);
    wave.patch( sum );
    wave = new Oscil( 794, 0.9, Waves.SAW);
    wave.patch( sum );
    wave = new Oscil( 1211, 0.5, Waves.SAW);
    wave.patch( sum );
    wave = new Oscil( 1650, 0.2, Waves.SAW);
    wave.patch( sum );
    //wave = new Oscil( 2370, 0.2, Waves.SAW);
    //wave.patch( sum );
    //wave = new Oscil( 2777, 0.2, Waves.SAW);
    //wave.patch( sum );
    //wave = new Oscil( 3170, 0.1, Waves.SAW);
    //wave.patch( sum );
    //wave = new Oscil( 198, 0.1, Waves.SAW);
    //wave.patch( sum );
    //wave = new Oscil( 160, 0.1, Waves.SAW);
    //wave.patch( sum );



    float cutoffFreq = 7000;
    float ripplePercent = 2;
    cbf = new ChebFilter(cutoffFreq, ChebFilter.HP, ripplePercent, 2, wave.sampleRate());

    sum.patch(cbf).patch(gain).patch(out);// filter
    //wave2.patch(cbf).patch(out);
    //wave3.patch(cbf).patch(out);
    //wave4.patch(cbf).patch(out);
    //wave5.patch(cbf).patch(out);
    //wave6.patch(cbf).patch(out);
    //wave.patch(out);
  }


  pg = createGraphics(200, 30);
}


float x;
void draw() {
  //background(255);

  noStroke();
  fill(255, 1);
  rectMode(CORNER);
  rect(0, 0, width, height);


  //------------------------------------------------------------------------------------- 

  for (int i = 0; i< totalDays-1; i++) {

    if (indeX == i) {
      stroke(255, 0, 0);
      strokeWeight(5);
      fill(0); 
      pg.beginDraw();
      pg.background(102);
      pg.text(day[i]+ ": "+int(steps[i]), 10, 20);
      pg.endDraw();
      image(pg, 40, 20);
      float interpolatelize = lerp(steps[i], steps[i+1], 0.5); 
      amplitudeOutput = norm(interpolatelize, 0, max); // 0.0 ~ 1.0

      //out.shiftPan(steps[i], steps[i+1], 1000);

      float x1 = map(i, 0, totalDays, 0, width);
      float x2 = map(i+1, 0, totalDays, 0, width);
      float pointHeight1 = height-norm(steps[i], 0, max)*scale;
      float pointHeight2 = height-norm(steps[i+1], 0, max)*scale;

      float weight = map(indeX, 0, width, 0, 255);
      float strokeweight = map(indeX, 0, width, 0, 2);
      stroke(weight, 0, 0, weight);
      strokeWeight(strokeweight);

      line(x1, pointHeight1, x2, pointHeight2);

      rectMode(CENTER);
      fill(0);
      rect(x1, pointHeight1, 5, 5);
    } else {
      stroke(255);
      strokeWeight(1);
    }

    float x1 = map(i, 0, totalDays, 0, width);
    float x2 = map(i+1, 0, totalDays, 0, width);
    float pointHeight1 = height-norm(steps[i], 0, max)*scale;
    float pointHeight2 = height-norm(steps[i+1], 0, max)*scale;




    //draw static bar
    {

      line(int(x1), height, int(x1), pointHeight1);
      line(int(x1), pointHeight1, int(x2), pointHeight2);

      stroke(200, 0, 0);
      strokeWeight(3);
      point(int(x1), pointHeight1);
    }
  }

  //------------------------------------------------------------------------------------- 
  // ADSR
  adsr();

  //------------------------------------------------------------------------------------- 
  // for bug
  //if (indeX == 0 ) {
  //  wave.setAmplitude(0);
  //  out.shiftVolume(0, 0, 16);
  //}
  // sound processing 
  //wave.setAmplitude( amplitudeOutput );
  currentFreq = Frequency.ofHertz( map(amplitudeOutput, 0, 1, 397, 300) );
  wave.setFrequency( currentFreq);
  cbf.setFreq(map(amplitudeOutput, 0, 1, 0, 13000));
  cbf.setRipple(map(noise(amplitudeOutput), 0, 1, 0, 1));
  float dB = map(amplitudeOutput, 0, 1, -6, 6);
  gain.setValue(dB);
  //out.shiftVolume(0, amplitudeOutput, 16);
}

void keyPressed() {
  println("trigger event");
  trigger = true;
  newTrigger = true;
}

void keyReleased() {
  startDecay = true;
}



int attackTime = 1000;
int decayTime = 1000;
int sustainLevel = 100;

float envValue; // output value
float valueStartDecay;
long startTime;
long attackEndTime;
long decayEndTime;

boolean newTrigger = false;
boolean startDecay = false;


void adsr() {

  if (newTrigger) {
    startTime = millis();
    attackEndTime = startTime + attackTime;
    newTrigger = false;
  }

  if (millis() < attackEndTime) {
    envValue = map(millis(), startTime, attackEndTime, 0, sustainLevel); 
    float panModular = map(envValue, 0, sustainLevel, -1, 1);
    float v = map(envValue, 0, sustainLevel, 0, 1);

    out.setPan(panModular);
    out.shiftVolume(0, v, 16);

    indeX = int(map(envValue, 0, sustainLevel, 0, width));
    indeX = int(map(indeX, 0, width, 0, totalDays)); // if static bar, run this command 
    //println(value);
  }

  if (startDecay) {
    startDecay = false;
    valueStartDecay = envValue; // find out current value, as might release before end of attack phase
    startTime = millis(); // reuse this for start of decay phase
    attackEndTime = startTime; // set to now to finish attack phase
    decayEndTime = startTime + decayTime;
  }

  if (millis() < decayEndTime) {
    envValue = map(millis(), startTime, decayEndTime, valueStartDecay, 0); 
    float panModular = map(envValue, 0, valueStartDecay, -1, 1);
    float v = map(envValue, 0, sustainLevel, 0, 1);
    out.setPan(panModular);
    out.shiftVolume(0, v, 16);

    indeX = int(map(envValue, 0, valueStartDecay, 0, width));
    indeX = int(map(indeX, 0, width, 0, totalDays)); // if static bar, run this command. if dynamic bar, commented 

    if (indeX<=100) {
      indeX = 0;
    }

    println(indeX);
  }
}
