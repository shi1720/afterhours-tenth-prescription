"""Original deterministic horror cues. No sampled recordings or external services."""
from pathlib import Path
import math, random, struct, wave
ROOT = Path(__file__).resolve().parents[1] / 'assets'
RATE = 22050
rng = random.Random(107)
def sine(hz, t): return math.sin(math.tau * hz * t)
def write(name, duration, fn):
    values = [fn(i / RATE) for i in range(int(duration * RATE))]
    peak = max(abs(v) for v in values)
    # Short attack/release removes digital clicks. Headroom remains before game gain.
    values = [v * .70 / max(peak, .01) * min(1, i / (RATE * .012), (len(values)-1-i) / (RATE * .08)) for i,v in enumerate(values)]
    with wave.open(str(ROOT / (name + '.wav')), 'wb') as f:
        f.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        f.writeframes(b''.join(struct.pack('<h', round(v * 32767)) for v in values))
def beat(t):
    return sum(math.exp(-max(0,t-start)*28) * (sine(57,t)*.85 + sine(91,t)*.15) if t >= start else 0 for start in [0,.19])
write('heartbeat', .65, beat)
write('horror_sting', 1.15, lambda t: (sine(59,t)*.45 + sine(173-62*t,t)*.25 + sine(349-91*t,t)*.2 + rng.uniform(-.38,.38)) * math.exp(-t*4.5))
write('shadow_breath', 1.65, lambda t: (rng.uniform(-.5,.5)*.55 + sine(113,t)*.10 + sine(227,t)*.06) * math.sin(math.pi*t/1.65)**2 * (.7+.3*sine(17,t)))
write('shelf_creak', 2.2, lambda t: (sine(170+50*math.sin(t*2),t)*.4 + sine(343+30*math.sin(t*3),t)*.15 + rng.uniform(-.08,.08)) * math.sin(math.pi*t/2.2)**2 * (.7+.3*sine(31,t)))
write('pursuit', .85, lambda t: (sine(82,t)*.6 + sine(123,t)*.3 + rng.uniform(-.12,.12)) * math.exp(-t*3) * (.6+.4*sine(7,t)))
