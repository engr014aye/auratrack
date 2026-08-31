import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List generateWav({
  required int sampleRate,
  required List<double> samples,
}) {
  final numSamples = samples.length;
  final byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
  final blockAlign = 2;
  final subChunk2Size = numSamples * 2;
  final chunkSize = 36 + subChunk2Size;

  final buffer = ByteData(44 + subChunk2Size);
  
  // RIFF header
  buffer.setUint8(0, 0x52); // 'R'
  buffer.setUint8(1, 0x49); // 'I'
  buffer.setUint8(2, 0x46); // 'F'
  buffer.setUint8(3, 0x46); // 'F'
  buffer.setUint32(4, chunkSize, Endian.little);
  buffer.setUint8(8, 0x57);  // 'W'
  buffer.setUint8(9, 0x41);  // 'A'
  buffer.setUint8(10, 0x56); // 'V'
  buffer.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  buffer.setUint8(12, 0x66); // 'f'
  buffer.setUint8(13, 0x6D); // 'm'
  buffer.setUint8(14, 0x74); // 't'
  buffer.setUint8(15, 0x20); // ' '
  buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
  buffer.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

  // data subchunk
  buffer.setUint8(36, 0x64); // 'd'
  buffer.setUint8(37, 0x61); // 'a'
  buffer.setUint8(38, 0x74); // 't'
  buffer.setUint8(39, 0x61); // 'a'
  buffer.setUint32(40, subChunk2Size, Endian.little);

  // write 16-bit PCM samples
  int offset = 44;
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    final intSample = (clamped * 32767.0).round();
    buffer.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }

  return buffer.buffer.asUint8List();
}

void main() {
  final dir = Directory('assets/sounds');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  const sampleRate = 44100;

  // 1. Click sound (50ms crisp tap)
  {
    const duration = 0.05;
    final totalSamples = (sampleRate * duration).round();
    final samples = <double>[];
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t * 100);
      final wave = sin(2 * pi * 1200 * t) * 0.6 + sin(2 * pi * 2400 * t) * 0.4;
      samples.add(wave * envelope * 0.8);
    }
    final wav = generateWav(sampleRate: sampleRate, samples: samples);
    File('assets/sounds/click.wav').writeAsBytesSync(wav);
    print('Generated assets/sounds/click.wav (${wav.length} bytes)');
  }

  // 2. Pop sound (80ms iOS-style bubble pop)
  {
    const duration = 0.09;
    final totalSamples = (sampleRate * duration).round();
    final samples = <double>[];
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final freq = 350.0 + 450.0 * (1.0 - t / duration);
      final envelope = sin(pi * t / duration) * exp(-t * 20);
      final wave = sin(2 * pi * freq * t);
      samples.add(wave * envelope * 0.9);
    }
    final wav = generateWav(sampleRate: sampleRate, samples: samples);
    File('assets/sounds/pop.wav').writeAsBytesSync(wav);
    print('Generated assets/sounds/pop.wav (${wav.length} bytes)');
  }

  // 3. Chime sound (0.65s crystal bell chord E6: 1318Hz + B6: 1975Hz)
  {
    const duration = 0.65;
    final totalSamples = (sampleRate * duration).round();
    final samples = <double>[];
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t * 7.5);
      final w1 = sin(2 * pi * 1318.5 * t);
      final w2 = sin(2 * pi * 1975.5 * t) * 0.5;
      final w3 = sin(2 * pi * 2637.0 * t) * 0.25;
      final wave = (w1 + w2 + w3) / 1.75;
      samples.add(wave * envelope * 0.85);
    }
    final wav = generateWav(sampleRate: sampleRate, samples: samples);
    File('assets/sounds/chime.wav').writeAsBytesSync(wav);
    print('Generated assets/sounds/chime.wav (${wav.length} bytes)');
  }

  // 4. Celebration sound (0.9s triumphant 4-note chord cascade)
  {
    const duration = 0.9;
    final totalSamples = (sampleRate * duration).round();
    final samples = <double>[];
    final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      double wave = 0.0;
      for (int n = 0; n < notes.length; n++) {
        final noteStart = n * 0.12;
        if (t >= noteStart) {
          final noteT = t - noteStart;
          final env = exp(-noteT * 5.0);
          wave += sin(2 * pi * notes[n] * noteT) * env * 0.35;
          wave += sin(2 * pi * notes[n] * 2 * noteT) * env * 0.1;
        }
      }
      samples.add(wave.clamp(-1.0, 1.0));
    }
    final wav = generateWav(sampleRate: sampleRate, samples: samples);
    File('assets/sounds/celebrate.wav').writeAsBytesSync(wav);
    print('Generated assets/sounds/celebrate.wav (${wav.length} bytes)');
  }

  print('Sound asset generation complete.');
}
