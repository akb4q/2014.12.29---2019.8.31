class ToneInstrument implements Instrument
{
  // create all variables that must be used througout the class
  Oscil wave;
  ADSR  adsr;
  ChebFilter cbf;
  Wavetable   table;

  // constructor for this instrument
  ToneInstrument( float frequency, float amplitude)
  {    
    // create new instances of any UGen objects as necessary

    table = new Wavetable(normalizedSteps);
    //OSC
    wave = new Oscil( frequency, amplitude, table); // Waves.SAW

    // Evelope ADSR(float maxAmp, float attTime, float decTime, float susLvl, float relTime)
    adsr = new ADSR( 1, 0.1, 0.05, 0, 0.5 );
    //Filter
    float cutoffFreq = 4000;
    float ripplePercent = 1;
    cbf = new ChebFilter(cutoffFreq, ChebFilter.HP, ripplePercent, 2, wave.sampleRate());

    // patch everything together up to the final output
    //wave.patch(cbf);
    wave.patch( adsr );
  }

  // every instrument must have a noteOn( float ) method
  void noteOn( float dur )
  {
    // turn on the ADSR
    adsr.noteOn();
    // patch to the output
    adsr.patch( out );
  }

  // every instrument must have a noteOff() method
  void noteOff()
  {
    // tell the ADSR to unpatch after the release is finished
    adsr.unpatchAfterRelease( out );
    // call the noteOff 
    adsr.noteOff();
  }
}
