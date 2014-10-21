(
SynthDef(\bass, {
    arg gate = 1.0, freq = 150, amp = 0.1, distort = 1.5;
    var distort_env, amp_env, x;

    distort_env = Env.perc(curve:-20).ar;

    amp_env = Env.adsr(
        attackTime:0.00,
        decayTime:0.03,
        sustainLevel: 1.0,
        releaseTime: 0.02
    )
    .ar(doneAction:2, gate: gate);

    x = (0.5 * Saw.ar(freq)) + (2.0 * SinOsc.ar(freq));
    x = RLPF.ar(x, distort_env.linexp(0,1,freq * 1.8, 6000), 0.4);
    x = SinOsc.ar(0, x * distort);
    x = x * amp * amp_env;

    Out.ar(0, Pan2.ar(x));
}).add
)

// Test bass:
(instrument: \bass, degree: 2, octave: 2, dur: 2.0, distort: 1.5).play

(
SynthDef(\lead, {
    arg gate = 1.0, freq = 440, amp = 0.1, wah = 0.5, distort = 2,
    release = 0.07;
    var x, amp_env;

    amp_env = Env.adsr(
        attackTime: 0.005,
        decayTime: 0.01,
        sustainLevel: 0.5,
        releaseTime: release
    ).ar(doneAction:2, gate: gate);

    x = Klang.ar(
        `[
            [1, 2.00, 3, 4],
            [0.5, 1.0, 0.4, 0.7],
            nil
        ],
        freq
    );

    x = x * amp_env * (SinOsc.ar(7, 0.25) * 0.3 + 0.5);
    x = (x * distort).clip(-1,1);
    x = RLPF.ar(x, wah.linexp(0, 1, freq, 2000), 0.3);
    x = x * 0.3 * amp;

    Out.ar(0, Pan2.ar(x));
}).add
)

// Test lead:
(instrument: \lead, degree: 5, dur: 1, distort: 3, wah: 0.5).play

(
SynthDef(\sample, {
    arg buffer, amp = 0.2, rate = 1, dur = 1, release = 0.4;
    var duration, phase, env, x;

    duration = BufFrames.ir(buffer) / SampleRate.ir / rate;
    duration = dur.clip(0, duration);

    release = release.clip(0,1);

    env = Env(
        [1,1,0],
        [duration * (1 - release), duration * release]
    ).ar(doneAction:2);

    x = PlayBuf.ar(1, buffer, rate);
    x = x * env * amp;

    Out.ar(0, Pan2.ar(x));
}).add
)

// Test sample playback:
(
b = Buffer.read(
    Server.default,
    "your/favorite/sample.wav"
)
)

(instrument: \sample, buffer: b, dur: 0.1, release: 0.5, amp: 0.2).play
