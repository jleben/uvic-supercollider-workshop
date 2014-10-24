// Play FM synthesis and store result in variable "x":
(
x = { arg freq = 400, amp = 0.1, mod = 1.0;
    var x = amp * SinOsc.ar(freq + (mod * freq * SinOsc.ar(freq * 3)));
    Pan2.ar(x)
}.play
)

x
// "x" is now a Synth
x.class
// a Synth represents a node on the server, each node has a unique ID:
x.nodeID
// Try pressing Apple+T (Ctrl+T on Windoze)
// to print the node tree.

// Change synth parameters (arguments to the synth function above):
x.set(\freq, 800)
x.set(\freq, 500)
x.set(\amp, 0.2)
x.set(\amp, 0.05)
x.set(\mod, 6)
x.set(\mod, 10)

// Kill the synth:
x.free

// A Synth is an instance of a SynthDef.
// The "play" method of functions is just shortcut for
// first creating a SynthDef and then a Synth:
(
SynthDef(\FM, { arg freq = 400, amp = 0.1, mod = 1.0;
    var x = amp * SinOsc.ar(freq + (mod * freq * SinOsc.ar(freq * 3)));
    Out.ar(0, Pan2.ar(x))
}).add
)

x = Synth(\FM, [\freq, 200, \amp, 0.2, \mod, 3]);

// Note:
// 1. The UGen composition function becomes an argument
//    to the SyntheDef creation method.
// 2. The SynthDef must be "add"-ed to the server, to be able to
//    create instances of it (Synths)
// 3. An instance of the SynthDef is created when creating a new
//    Synth using the same name-symbol (\FM in our case).
// 4. In the UGen composition function, we needed to add the "Out" UGen
//    (the "play" method was creating it for us behind the scene...)


// Can make multiple Synths based on a SynthDef:
Synth(\FM, [\freq, 500, \amp, 0.1, \mod, 3]);
Synth(\FM, [\freq, 300, \amp, 0.1, \mod, 6]);
Synth(\FM, [\freq, 200, \amp, 0.15, \mod, 2]);

// Synths write to buses using the Out UGen
// and read from buses using the In UGen:

// \rain writes to bus 50,
// \reverb reads from bus 50 and writes to buses 0 and 1
// First couple of buses are mapped to audio device outputs.
(
SynthDef(\rain, { arg freq=800, rate=10;
    var env = Env.perc(0.01,0.05,0.1).ar(gate:Dust.ar(rate));
    Out.ar( 50,
        BPF.ar(PinkNoise.ar * env, freq, 0.8) * 3.0
    )
}).add;
SynthDef(\reverb, {
    Out.ar([0,1], GVerb.ar( In.ar(50), roomsize: 15 ))
}).add
)

// Order of Synths is important.
// By default, Synths are added to beginning of processing queue:
Synth(\reverb)
Synth(\rain)

// ...but order can be defined explicitely:
Synth(\rain, [\freq, 500, \rate, 5], addAction: 'addToHead')
Synth(\reverb, addAction: 'addToTail')
Synth(\rain, [\freq, 1600, \rate, 5], addAction: 'addToHead')

// Check number of input, output, and all buses:
Server.default.options.numOutputBusChannels
Server.default.options.numInputBusChannels
Server.default.options.numAudioBusChannels
// These values can be changed and will take effect after server reboot.

