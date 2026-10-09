from pathlib import Path
import math,random,wave,struct
R=Path(__file__).resolve().parents[1] / 'assets';SR=22050;rg=random.Random(941)
def sine(f,t):return math.sin(2*math.pi*f*t)
def out(name,dur,fn):
 a=[fn(i/SR) for i in range(int(dur*SR))];peak=max(abs(v) for v in a);scale=min(1,.65/max(peak,.0001))
 with wave.open(str(R/(name+'.wav')),'wb') as w:
  w.setparams((1,2,SR,0,'NONE','not compressed'));w.writeframes(b''.join(struct.pack('<h',int(v*scale*32767)) for v in a))
def burst(t,start,decay=20):return math.exp(-(t-start)*decay) if t>=start else 0
out('arrival_printer',2.2,lambda t:(sine(83,t)*.04+rg.uniform(-.13,.13))*(.3+.7*(int(t*22)%2))*min(1,t*12)*min(1,(2.2-t)*6))
out('arrival_frost',2.0,lambda t:sum((sine(1300+k*197,t)*.035+rg.uniform(-.025,.025))*burst(t,s,14) for k,s in enumerate([.1,.28,.33,.7,1.1,1.22,1.6])))
out('arrival_ticket',1.8,lambda t:(sine(420,t)*.08+sine(631,t)*.03)*sum(burst(t,s,7) for s in [.2,.8,1.4]))
out('arrival_pipe',2.4,lambda t:sum(sine(330+k*210,t)*.12*burst(t,s,30) for k,s in enumerate([.15,.66,1.21,2.02]))+sine(57,t)*.03*math.exp(-t))
out('arrival_chairs',1.8,lambda t:(sine(107+6*math.sin(t*7),t)*.08+sine(163,t)*.035+rg.uniform(-.02,.02))*math.sin(math.pi*t/1.8)**2)
out('arrival_fuse',2.1,lambda t:sum((rg.uniform(-.2,.2)+sine(92,t)*.07)*burst(t,s,38) for s in [.13,.41,.48,.9,1.41,1.8]))
out('arrival_phone',2.7,lambda t:(sine(440,t)*.08+sine(480,t)*.08)*(1 if (.2<t<.9 or 1.45<t<2.15) else 0)*(.65+.35*sine(20,t)))
out('arrival_archive',2.3,lambda t:rg.uniform(-.1,.1)*(sum(burst(t,s,12) for s in [.2,.33,.71,1.2,1.26,1.8]))+sine(49,t)*.02*math.sin(math.pi*t/2.3))
out('arrival_letters',2.0,lambda t:rg.uniform(-.11,.11)*sum(burst(t,s,17) for s in [.1,.3,.55,.83,1.1,1.4,1.7]))
out('arrival_memorial',3.2,lambda t:sum(sine(f,t)*a*burst(t,s,1.8) for f,a,s in [(330,.06,.1),(495,.04,.5),(660,.025,.9)])*min(1,(3.2-t)*3))
print('Generated10originalarrivalcues; PCM22050mono')
