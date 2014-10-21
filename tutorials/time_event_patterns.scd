
// An event represents a note played on an instrument.

// The following plays events on the default instrument (piano immitation)
// at different degrees of the default scale (major):
(degree: 5).play
(degree: 2).play
(degree: 3).play

// Default amplitude was 0.1. Let's change it:
(degree: 1, amp: 0.2).play
(degree: 1, amp: 0.5).play

// Using an array for a parameter multiplies the event
// for each elemnt of the array:
(degree: [1,3,5]).play
(degree: [1,3,5] + 1).play
(degree: [1,3,5] + 2).play


// "fork" executes a function in a special mode
// where it can be paused an resumed using "wait":
(
fork {
    "foo".postln; // Post "foo"
    1.wait; // Wait 1 second
    "bar".postln; // Post "bar"
}
)

// Yes, fork allows us to play events with pauses in between:
(
fork {
    // Repeat 10 times
    10.do {
        // Play a random degree between 0 and 10
        (degree: 10.rand, dur: 2.0).play;
        0.2.wait;
    }
}
)

// Patterns are classes that help in creation of streams of events.

// A pattern is a template for a stream.

// Pseq generates a stream which is just a sequence of numbers:
p = Pseq.new([1,2,3,-1,-2,-3]);
x = p.asStream;
x.next

// Prand chooses a value at random
p = Prand.new([10,20,30])
x = p.asStream;
x.next

// A pattern can contain other patterns
// This is a random choice between the two sequences:
p = Prand([ Pseq([1,2,3]), Pseq([-1,-2,-3]) ], inf);
x = p.asStream;
30.do { x.next.postln; }

// Example:
(
var pitches, durations;

pitches = Pstutter(
    Pn( Pshuf([1,1,1,1,1,1,2]), inf),
    Pseq([ 0, 2, 4, Prand([5,6,7,8]) ], inf)
).asStream;

durations = Pn( Pshuf([1/4, 1/8, 1/8]), inf).asStream;

fork {
    inf.do {
        var pitch = pitches.next;
        var duration = durations.next;
        (degree: pitch, dur: 0.5, scale: Scale.minor).play;
        duration.wait;
    }
}
)


// Special pattern Pbind combines patterns to generate events
(
var pattern = Pbind(
    \degree, Pseq([1,4,7,6,5], inf),
    \dur, Pseq([1/8, 1/4], inf)
);
// A pattern that produces a stream of events can simply be "played":
pattern.play
)

// Two event streams can be joined by a Ppar pattern
(
var p1, p2;
p1 = Pbind(
    \octave, 5,
    // note: we can do simple math with patterns too (subtracting 1)
    \degree, Pseq([3,2,3,Prand([5,4,6,8]) ], inf) - 1,
    \dur, 1/8,
    \scale, Scale.minor
);
p2 = Pbind(
    \octave, 4,
    \degree, Pseq([1, 5], inf) - 1,
    \dur, Pseq([1, 1/2], inf),
    \scale, Scale.minor
);
Ppar([p1,p2]).play
)
