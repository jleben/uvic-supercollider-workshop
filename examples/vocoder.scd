(
SynthDef("vocoder_live", { arg out=0, freq = 200;
    var synth_source, real_source,
    fft_synth, fft_real, fft_combined,
    output_signal;

    synth_source =
    HPF.ar( Mix.ar( LFSaw.ar([freq, freq * 2.pow(7/12)], 0, [0.4, 0.6]) ), freq * 1.6 )
    + HPF.ar(WhiteNoise.ar(0.7), (freq * 20).min(5000));

    real_source = SoundIn.ar;

    fft_synth = FFT(LocalBuf(512), synth_source);
    fft_real = FFT(LocalBuf(512), real_source);
    fft_combined = PV_MagMul(fft_synth, fft_real);

    output_signal = 0.03 * IFFT(fft_combined);

    Out.ar(out,  output_signal);
}).add
)

(
SynthDef("fx", {
    var x;
    x = In.ar(0);
    x =
    Compander.ar(x, x,
        thresh: 0.5,
        slopeAbove: 1/70,
        clampTime: 0.002,
        relaxTime: 0.5
    );
    x = x * 0.7;
    x = x + (0.2 * CombN.ar(x, 1, 0.5, 2));
    ReplaceOut.ar(0, Pan2.ar(x));
}).add;
)

(
~make_fx={Synth("fx", target: Server.default, addAction: 'addAfter')};
~make_fx.value;
ServerTree.add(~make_fx);
)

(degree: [0, 2], octave: 5, instrument:\vocoder_live).play
(degree: [0, 6], octave: 5, instrument:\vocoder_live).play
(degree: [0, 2] - 2, octave: 4, instrument:\vocoder_live).play


MIDIIn.connectAll

(
~notes = Array.fill(128);
MIDIdef.noteOn(\akai_note_on, {
    |vel, note|
    "on".postln;
    ~notes[note] = Synth(\vocoder_live, [freq: note.midicps]);
});
MIDIdef.noteOff(\akai_note_off, {
    |vel, note|
    "off".postln;
    if (~notes[note].notNil) { ~notes[note].free; };
    ~notes[note] = nil;
});
)


/////////////////////////


b = Buffer.readChannel(Server.default, "path", channels: 0);

(
SynthDef("vocoder", { arg out=0, buffer=2, freq = 200;
    var inA, chainA, inB, chainB, chain, sig;
    inA =
    HPF.ar( Mix.ar( LFSaw.ar([freq, freq * 2.pow(7/12)], 0, [0.4, 0.6]) ), freq * 1.5 )
    + HPF.ar(WhiteNoise.ar(0.5), (freq * 20).min(5000));
    inB = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer), loop: 1);
    chainA = FFT(LocalBuf(512), inA);
        chainB = FFT(LocalBuf(512), inB);
        chain = PV_MagMul(chainA, chainB);
    sig = IFFT(chain);
        Out.ar([out, out + 1],  0.02 * sig );
}).add
)

(
SynthDef("vocoder_live2", { arg out=0, buffer=2;
    var inA, chainA, inB, chainB, chain, sig;
    inA = SoundIn.ar;
    inB = PlayBuf.ar(1, buffer, BufRateScale.kr(buffer), loop: 1);
    //PlayBuf.ar(1, buffer, BufRateScale.kr(buffer), loop: 1);
    chainA = FFT(LocalBuf(512), inA);
        chainB = FFT(LocalBuf(512), inB);
        chain = PV_MagMul(chainA, chainB);
    sig = IFFT(chain);
        Out.ar([out, out + 1],  0.1 * sig );
}).add
)



(
(
instrument:\vocoder,
buffer: b,
freq: 47.midicps
).play
)


(
(
instrument:\vocoder_live2,
buffer: b,
).play
)

