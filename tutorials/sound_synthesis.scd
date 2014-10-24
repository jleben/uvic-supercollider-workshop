
// Functions have a method called "play",
// which will play an instance of the instrument defined in the function:

{ Pan2.ar( SinOsc.ar(freq:440) ) * 0.2 }.play

// Stop sound by pressing Apple+Period on Mac (Ctrl+Period on other systems)

// Sound processing is defined with a composition of UGens (unit generators)
// Unit generators can be composed in different ways:
// - using mathematical operators
// - by passing one as argument to another

// The output of most UGens is a single channel,
// and would only play on the first output channel:

{ WhiteNoise.ar(0.1) * Pulse.ar(10, 0.02) }.play

// Multiple channels are represented as an array of UGens:
(
{
    [
        SinOsc.ar(200) * Pulse.ar(5, 0.03),
        SinOsc.ar(830) * Pulse.ar(7, 0.04)
    ] * 0.2
}.play
)

// The Pan2 UGen creates an array for us by duplicating
// one channel into two channels and adjusting their amplitude.
(
{
    Pan2.ar(
        in: Pulse.ar(400) * Pulse.ar(12, 0.1) * 0.1,
        pos: SinOsc.kr(1)
    )
}.play
)

// Vibrato:
{ Pan2.ar( SinOsc.ar( freq: 300 + (SinOsc.kr(7) * 10.0) ) * 0.1 ) }.play

// Frequency modulation:
{ Pan2.ar( SinOsc.ar( freq: 300 + (SinOsc.ar(300) * 200.0) ) * 0.1 ) }.play

// Notice the difference in code?

// In the frequency modulation code, we use the "ar" instead of "kr
// version of the modulator.
// "ar" = audio rate
// "kr" = control rate

// Compare: FM using control-rate modulator:
{ Pan2.ar( SinOsc.ar( freq: 300 + (SinOsc.kr(300) * 200.0) ) * 0.1 ) }.play
// Hear aliasing?


// Amplitude modulation:
{ Pan2.ar( SinOsc.ar(300) * SinOsc.ar(200) * 0.1 ) }.play


// Subtractive synthesis:
// Start with a frequency-rich signal (sawtooth, pulse (a.k.a square), ...)
// then use filters to take away from the spectrum:
(
{
    Pan2.ar(
        LPF.ar(
            in: Saw.ar(300),
            freq: SinOsc.kr(0.8) * 1000 + 1200
        ) * 0.1
    )
}.play
)

// Waveshaping (distortion) -
// Feeding a sinusoid through the sine function:
{ Pan2.ar( SinOsc.ar(freq: 0.0, phase: SinOsc.ar(150) * 10) * 0.06 ) }.play

// A simpler alternative that does the same:
{ Pan2.ar( sin( SinOsc.ar(150) * 10 ) * 0.06 ) }.play

// ... or use some kind of soft clipping (sigmoid) function:
// https://en.wikipedia.org/wiki/Sigmoid_function
(
{
    var x = SinOsc.ar(150) * 10;
    var y = tanh(x);
    Pan2.ar(y * 0.1);
}.play
)

// Additive synthesis, the hard way:
(
{
    var freq = 300;
    var signal =
    (1.0 * SinOsc.ar(freq * 1) * SinOsc.kr(1.0).linlin(-1,1,0,1))
    +
    (0.8 * SinOsc.ar(freq * 2) * SinOsc.kr(0.5).linlin(-1,1,0,1))
    +
    (0.6 * SinOsc.ar(freq * 3) * SinOsc.kr(0.7).linlin(-1,1,0,1))
    +
    (0.3 * SinOsc.ar(freq * 4) * SinOsc.kr(0.8).linlin(-1,1,0,1))
    ;
    Pan2.ar(signal * 0.1);
}.play
)

// The simple way: multi-channel expansion:
(
{
    var freq = 300;
    var signal =
    [1.0, 0.8, 0.6, 0.3]
    * SinOsc.ar(freq * (1..4))
    * SinOsc.kr([1.0, 0.5, 0.7, 0.8]).linlin(-1,1,0,1)
    ;
    Pan2.ar( Mix.ar(signal) * 0.1 );
}.play
)

// Granular synthesis:

// Download this audio sample:
// http://webhome.csc.uvic.ca/~jleben/supercollider/cello_phrase.wav

// Load the sample into the buffer number 0
(
b = Buffer.read(
    Server.default,
    path: "an/awesome/sound.wav",
    bufnum: 0
)
)

// Test-play the sample:
b.play

// Now play a granular synthesizer using buffer number 0.
(
{
    var buffer = 0, grains;
    grains = TGrains.ar(
        numChannels: 2,
        trigger: Impulse.ar(MouseY.kr(5,100, \exponential)),
        bufnum: buffer,
        rate: 1,
        centerPos: MouseX.kr(0.0, BufDur.ir(buffer)) + WhiteNoise.ar(0.01),
        dur: 0.1,
        pan: 0,
        amp: 0.4
    );
    grains
}.play
)

// Envelopes, self-terminating sounds:

// Here, the Line UGen kills the synth when it reaches its end value.
(
{
    // "doneAction: 2" means "kill enclosing synth"
    // Try removing it and see what happens...

    var freq, sound;

    freq = Line.ar(start:1, end:0, dur:1.5, doneAction:2);
    freq = freq.lincurve(0, 1, 60, 1000, 12);

    sound = RLPF.ar( Pulse.ar(freq, 0.01), freq: freq * 3, rq: 0.2 );

    Pan2.ar( sound );
}.play
)

// Let's add a more complex envelope for amplitude:
(
{
    // "doneAction: 2" means
    var freq, sound, amp;

    freq = Line.ar(start:1, end:0, dur:1.5);
    freq = freq.lincurve(0, 1, 60, 1000, 12);

    amp = Env.perc(
        attackTime: 0.01,
        releaseTime: 2.0,
        curve: -3,
    ).ar(doneAction:2);

    sound = RLPF.ar( Pulse.ar(freq, 0.01), freq: freq * 3, rq: 0.2 );

    Pan2.ar( sound * amp );
}.play
)


// Define an "instrument" to be played with "events":
(
SynthDef(\ring, {
    // Function arguments get their values from event parameters:
    arg freq = 440, gate = 1;

    var sound, env;

    sound = SinOsc.ar( 2.pow( LFPulse.ar(15) * 7 / 12) * freq );
    sound = sin( sound * 8 );
    sound = CombN.ar(sound, 0.1, 1/freq * 0.5, 0.2);

    env = Env.asr(releaseTime:0.5, curve:-7).ar(2, gate);

    Out.ar(0, Pan2.ar( sound * env * 0.1 ) );
}).add
// We have to "add" the SynthDef to use it as instrument with events
)

// Here are some fine events for you:
(instrument: \ring, degree: 0).play
(instrument: \ring, degree: 3).play
(instrument: \ring, degree: 0, dur: 0.1).play
(instrument: \ring, degree: -4, dur: 0.1).play

