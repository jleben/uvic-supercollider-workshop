// NOTE: Each of these examples plays forever,
// unless it is stopped using Ctrl+C (Linux, Windows) or Cmd+C (Mac OS X)

// Start an example by placing text cursor
// anywhere within the enclosing parenthesis (round brackets)
// and pressing Ctrl+Return (Linux, Windows) or Cmd+C (Mac OS X)

// Random tones
(
fork {
	inf.do {
        (degree: 10.rand, dur: 0.5, amp: (0.5.rand + 0.1).pow(2) ).play;
		0.3.wait;
	}
}
)

/// Three chords
(
var chords = [
    [1,3,5],
    [2,4,6],
    [-2,4,7]
];

var durations = [
    [3/16, 3/16, 2/16],
    [3/16, 3/16, 2/16],
    [3/16, 3/16, 2/16]
];

fork {
	inf.do { arg index;
        var chord_number = index % 3;
        var chord = chords[chord_number];
        var chord_durations = durations[chord_number];
        chord_durations.do { arg duration;
            (degree: chord, dur: duration * 0.5).play;
            (duration * 2).wait;
        }
	}
}
)

/// Resonant noise ramps
// This example reacts to mouse movement
(
{
    var filter_control = MouseY.kr(300, 15000, \exponential);
    var speed_control = MouseX.kr(1.5, 20.0,\exponential);
    var filtered_noise =
    RLPF.ar(
        WhiteNoise.ar,
        freq: Saw.kr(speed_control).lincurve(-1,1,0.1,1.0,4) * filter_control ,
        rq: 0.3 // reciprocal Q (lower = more resonance)
        // BEWARE!!! PROTECT YOUR EARS:
        // with rq = 0.0 the filter self-resonates (feedback builds up)!!!
    );,

    Pan2.ar( filtered_noise * 0.2 );
}.play
)


/// Resonant strikes

// Step 1: Define instrument:
(
SynthDef(\resonant_strikes, { arg freq = 440, amp = 0.1;
    var excitation =
    //Impulse.ar(0.0) +
    WhiteNoise.ar * Env.perc(attackTime:0.0, releaseTime:0.05, curve:-6).ar * amp;
    var harmonics = [1,3,5,7,9,11,11.4,11.7];
    var amps = Array.fill(8, { |i| 1.0 / (i+1) } );
    var decay_times = Array.fill(8, 0.8);
    var resonance = Klank.ar(
        `[harmonics, amps, decay_times],
        excitation,
        freq
    );
    var envelope = Env.perc(0.0, 1.0, level: 0.1, curve: \linear).ar(doneAction:2);
    Out.ar(0, Pan2.ar(resonance * envelope));
}).add;
)

// Step 2: Play instrument:
(
fork {
	inf.do {
        (
            instrument:\resonant_strikes,
            degree: 20.rand,
            octave: 3,
            dur: 0.5,
            amp: 1.0.rand.linexp(0,1,0.1,0.5)
        ).play;
        (1/[8,4].choose).wait;
	}
}
)
