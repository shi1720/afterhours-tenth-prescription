from PIL import Image, ImageDraw
import math, random, wave, struct, os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1] / 'assets';ROOT.mkdir(parents=True,exist_ok=True)
P={'void':'#080e1b','navy':'#101c2c','blue':'#1c3041','steel':'#2b4654','teal':'#3e6d71','mint':'#a8d9c5','white':'#e0ede0','coral':'#e26f73','red':'#9f4058','gold':'#e2bb7c','darkgold':'#866e53','black':'#050a13'}
r=random.Random(731)
def new(w=32,h=32,bg=(0,0,0,0)):return Image.new('RGBA',(w,h),bg)
def save(im,name): im.save(ROOT/(name+'.png'))
def rect(d,box,c):d.rectangle(box,fill=P.get(c,c))
def line(d,xy,c,width=1):d.line(xy,fill=P.get(c,c),width=width)
# Floor stone tile
im=new(bg=P['navy']);d=ImageDraw.Draw(im)
rect(d,(1,1,30,30),'blue');line(d,[(1,30),(30,30)],'steel');line(d,[(30,1),(30,30)],'steel')
for i in range(15):
 x,y=r.randrange(2,30),r.randrange(2,30);rect(d,(x,y,x+1,y),'#233b4b')
line(d,[(4,7),(8,7),(10,9)],'#182b3d');save(im,'floor')
# Wall
im=new(bg=P['navy']);d=ImageDraw.Draw(im);rect(d,(0,0,31,23),'steel');rect(d,(1,2,30,5),'teal');rect(d,(0,6,31,20),'blue')
for y in [7,14,21]:
 line(d,[(0,y),(31,y)],'navy')
for x,y in [(8,7),(24,7),(16,14),(2,21),(25,21)]:line(d,[(x,y),(x,y+6)],'navy')
rect(d,(0,24,31,26),'teal');rect(d,(0,27,31,31),'void');save(im,'wall')
# shelves front-facing
im=new();d=ImageDraw.Draw(im);rect(d,(1,1,30,30),'void');rect(d,(2,2,29,27),'steel');rect(d,(4,3,27,25),'navy')
for y in (5,16):
 for x in (6,13,21):
  rect(d,(x,y+2,x+4,y+8),'mint');rect(d,(x+1,y,x+3,y+2),'white');rect(d,(x,y+5,x+4,y+6),'coral' if x==13 else 'teal');rect(d,(x+4,y+2,x+4,y+8),'teal')
 rect(d,(3,y+10,28,y+12),'teal');line(d,[(3,y+10),(28,y+10)],'mint')
rect(d,(4,29,7,31),'navy');rect(d,(25,29,28,31),'navy');save(im,'shelf')
im=new();d=ImageDraw.Draw(im);rect(d,(2,3,29,29),'void');rect(d,(3,2,28,26),'steel');rect(d,(4,3,27,8),'teal')
for y in (10,18):
 rect(d,(4,y,27,y+6),'blue');line(d,[(4,y),(27,y)],'teal');rect(d,(14,y+2,17,y+3),'mint')
line(d,[(6,4),(24,4)],'mint');save(im,'cabinet')
im=new();d=ImageDraw.Draw(im);rect(d,(1,5,30,29),'void');rect(d,(2,3,29,24),'darkgold');rect(d,(3,4,28,21),'gold');rect(d,(4,6,27,20),'#a58c67')
rect(d,(6,7,16,16),'white');line(d,[(8,10),(14,10)],'teal');line(d,[(8,13),(12,13)],'teal');rect(d,(20,8,25,14),'navy');rect(d,(21,9,24,12),'mint');rect(d,(5,25,8,30),'steel');rect(d,(24,25,27,30),'steel');save(im,'desk')
im=Image.open(ROOT/'floor.png');d=ImageDraw.Draw(im)
for box in [(0,12,27,25),(7,7,22,29),(14,3,20,27)]:rect(d,box,'#284d52')
for i in range(28):
 x,y=r.randrange(2,30),r.randrange(8,29);rect(d,(x,y,x+1,y),'teal' if i%3 else 'mint')
save(im,'toxic')
im=new();d=ImageDraw.Draw(im);rect(d,(3,1,28,31),'void');rect(d,(5,2,26,30),'teal');rect(d,(7,5,24,29),'blue');rect(d,(10,7,21,15),'mint');rect(d,(11,8,20,14),'teal');rect(d,(21,20,23,22),'gold');line(d,[(6,30),(25,30)],'mint');save(im,'exit')
im=new();d=ImageDraw.Draw(im);rect(d,(3,3,28,28),'steel');rect(d,(5,5,26,26),'void')
for y in range(8,26,4):line(d,[(7,y),(24,y)],'teal')
rect(d,(13,5,18,6),'gold');save(im,'hatch')
im=new();d=ImageDraw.Draw(im);rect(d,(12,7,19,9),'steel');rect(d,(9,10,22,26),'void');rect(d,(10,10,21,24),'gold');rect(d,(12,12,19,16),'mint');rect(d,(13,18,18,19),'navy');rect(d,(15,16,16,21),'navy');rect(d,(11,11,11,23),'white');save(im,'battery')
im=new();d=ImageDraw.Draw(im);rect(d,(8,5,23,28),'void');rect(d,(7,4,22,26),'white');rect(d,(9,6,20,24),'mint');line(d,[(11,10),(18,10)],'teal');line(d,[(11,13),(18,13)],'teal');line(d,[(11,16),(16,16)],'teal');rect(d,(16,20,19,23),'coral');rect(d,(17,19,18,24),'coral');save(im,'prescription')
im=new();d=ImageDraw.Draw(im);rect(d,(14,1,17,12),'steel');rect(d,(9,10,22,12),'navy');rect(d,(7,13,24,14),'gold');rect(d,(8,15,23,17),'white');line(d,[(10,18),(21,18)],'mint');save(im,'lamp')
# Player sheets
sheet=new(96,128)
for row in range(4):
 for fr in range(3):
  im=new();d=ImageDraw.Draw(im);step= (fr-1)*2;rect(d,(10,27,21,29),'#080e1b');rect(d,(10,19,14,26+step),'navy');rect(d,(17,19,21,26-step),'navy');rect(d,(9,27+step,14,28+step),'black');rect(d,(17,27-step,22,28-step),'black');rect(d,(9,12,22,22),'mint');rect(d,(11,12,20,21),'white');rect(d,(9,14,10,23),'teal');rect(d,(21,14,23,22),'teal');rect(d,(12,3,20,11),'gold');rect(d,(10,2,21,6),'navy');rect(d,(9,4,22,6),'navy')
  if row==3:rect(d,(11,6,21,10),'navy');line(d,[(16,12),(16,20)],'teal')
  else:
   eye=(12 if row==1 else 19 if row==2 else 14);rect(d,(eye,7,eye+1,8),'navy')
   if row==0:rect(d,(18,7,19,8),'navy')
   rect(d,(13,10,18,11),'darkgold');rect(d,(15,13,17,16),'coral');rect(d,(13,18,15,19),'teal')
  if row==1:rect(d,(6,17,10,20),'gold');rect(d,(3,17,6,19),'mint')
  else:rect(d,(22,17,26,20),'gold');rect(d,(26,17,28,19),'mint')
  sheet.alpha_composite(im,(fr*32,row*32))
save(sheet,'player')
sheet=new(128,32)
for fr in range(4):
 im=new();d=ImageDraw.Draw(im);off=fr%2;rect(d,(10,8+off,22,23+off),'red');rect(d,(8,13+off,24,22+off),'red');rect(d,(11,3+off,21,12+off),'coral');rect(d,(12,3+off,20,5+off),'#f2a099');rect(d,(13,7+off,15,8+off),'void');rect(d,(19,7+off,21,8+off),'void');rect(d,(16,11+off,18,13+off),'void');rect(d,(12,15+off,20,20+off),'#bb5b6d')
 for x in range(9,25,4):rect(d,(x,23+off,x+1,26+(x+fr)%3),'coral')
 rect(d,(7,24,8,25),'coral');rect(d,(26,19,27,21),'red');sheet.alpha_composite(im,(fr*32,0))
save(sheet,'enemy')
# title illustration draw at 320x180 and nearest scale, all deliberate pixel edges
im=new(320,180,P['void']);d=ImageDraw.Draw(im)
# central architectural vanishing corridor
poly=lambda points,c:d.polygon(points,fill=P.get(c,c))
poly([(0,0),(320,0),(211,61),(112,61)],'navy');poly([(0,180),(320,180),(211,93),(112,93)],'blue');poly([(0,0),(112,61),(112,93),(0,180)],'#142636');poly([(320,0),(211,61),(211,93),(320,180)],'#152734')
# tile perspective
for y in [101,111,126,148,177]:line(d,[(0,y),(320,y)],'#284453')
for x in range(-240,580,50):line(d,[(161,84),(x,180)],'#284453')
# doorway far
rect(d,(115,51,208,100),'steel');rect(d,(120,55,203,98),'black');rect(d,(131,58,191,98),'#152e35');rect(d,(136,60,186,97),'#24464a');rect(d,(140,61,182,95),'#2f5756')
# dithering back glow
for y in range(61,98):
 for x in range(133,190):
  if (x+y)%4==0 and abs(x-162)<23-abs(y-80)//2:rect(d,(x,y,x,y),'teal')
# exit sign geometric cross
rect(d,(145,44,177,51),'teal');rect(d,(148,46,173,48),'mint');rect(d,(159,43,162,51),'mint')
# shelves blocks left and right along perspective, bottles
for side in [0,1]:
 for depth,(x,y,w,h) in enumerate([(1,30,63,117),(67,46,27,65),(97,56,14,43)]):
  if side:x=320-x-w
  rect(d,(x,y,x+w,y+h),'void');rect(d,(x+2,y+2,x+w-2,y+h-3),'blue');rect(d,(x,y,x+3,y+h),'steel');rect(d,(x+w-3,y,x+w,y+h),'steel')
  for sy in range(y+8,y+h-6,max(11,int(h/4))):
   rect(d,(x+3,sy+13-depth*3,x+w-3,sy+15-depth*3),'teal')
   for bx in range(x+7,x+w-5,max(5,13-depth*4)):
    bw=max(2,6-depth*2);bh=max(4,11-depth*3)
    rect(d,(bx,sy,bx+bw,sy+bh),'mint' if r.random()>.25 else 'coral');rect(d,(bx+1,sy-2,bx+bw-1,sy),'white');rect(d,(bx,sy+bh//2,bx+bw,sy+bh//2+1),'teal')
# ceiling lights and suspended pipes
for x in [58,260]:line(d,[(x,0),(x,18)],'steel',2)
rect(d,(36,18,80,22),'steel');rect(d,(39,23,77,25),'mint');rect(d,(243,18,282,22),'steel');rect(d,(246,23,279,25),'mint')
for x,y in [(53,27),(64,29),(255,29),(271,27)]:rect(d,(x,y,x+1,y+1),'teal')
# scattered paper
poly([(181,129),(196,133),(189,138),(175,133)],'mint');line(d,[(181,132),(190,134)],'teal');poly([(94,151),(107,147),(114,153),(101,157)],'steel')
# red spectral patient at corridor
rect(d,(171,72,180,81),'coral');rect(d,(169,80,182,95),'red');rect(d,(172,82,180,93),'coral');rect(d,(172,75,174,76),'void');rect(d,(178,75,180,76),'void');rect(d,(175,79,177,82),'void');rect(d,(168,85,169,92),'coral')
for x in range(169,184,3):rect(d,(x,95,x+1,98+(x%3)),'red')
for x,y in [(165,78),(185,84),(176,102),(164,94)]:rect(d,(x,y,x,y+1),'coral')
# foreground pharmacist silhouette, coat
poly([(125,180),(129,149),(137,139),(139,130),(137,119),(140,111),(150,108),(160,112),(163,121),(160,132),(164,141),(175,152),(181,180)],'black')
poly([(130,156),(140,140),(147,145),(158,140),(169,157),(173,180),(126,180)],'steel');poly([(140,143),(146,149),(144,180),(133,180)],'teal');poly([(151,149),(158,143),(167,180),(149,180)],'blue');rect(d,(141,113,156,117),'navy');rect(d,(137,119,139,127),'teal');line(d,[(143,154),(142,174)],'mint')
# flashlight beam with sparse dotted wedge
poly([(170,151),(188,124),(206,134),(176,157)],'#29484b');line(d,[(172,153),(195,130)],'teal');rect(d,(166,151,176,156),'darkgold');rect(d,(174,151,178,155),'gold')
# foreground counter edge
poly([(0,170),(64,145),(80,151),(48,180),(0,180)],'navy');line(d,[(0,170),(64,145),(80,151)],'teal',2)
# vignette edge broken black framing
rect(d,(0,0,319,3),'black');rect(d,(0,0,3,179),'black');rect(d,(316,0,319,179),'black');rect(d,(0,177,319,179),'black')
save(im.resize((640,360),Image.Resampling.NEAREST),'title_art')
# Icon / brand pixel cross inside moon broken ring
im=new(128,128,P['void']);d=ImageDraw.Draw(im);d.ellipse((16,16,111,111),fill=P['teal']);d.ellipse((22,22,105,105),fill=P['void']);rect(d,(81,12,119,62),'void');rect(d,(55,33,73,95),'mint');rect(d,(33,55,95,73),'mint');rect(d,(58,38,70,92),'white');rect(d,(73,55,95,60),'white');rect(d,(83,29,91,37),'coral');rect(d,(99,43,105,49),'coral');save(im,'icon')
(ROOT/'logo.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="600" height="160" viewBox="0 0 600 160"><rect width="600" height="160" fill="#080e1b"/><path d="M59 27H79V61H113V81H79V115H59V81H25V61H59Z" fill="#a8d9c5"/><rect x="100" y="23" width="9" height="9" fill="#e26f73"/><text x="143" y="82" font-family="monospace" font-weight="bold" font-size="54" letter-spacing="1" fill="#e0ede0">AFTERHOURS</text><text x="146" y="111" font-family="monospace" font-size="15" letter-spacing="4" fill="#e26f73">THE TENTH PRESCRIPTION</text></svg>''')
# contact sheet
names=['floor','wall','shelf','cabinet','desk','toxic','exit','hatch','battery','prescription','lamp']
contact=new(32*len(names),64,P['void'])
for i,n in enumerate(names):contact.alpha_composite(Image.open(ROOT/(n+'.png')),(i*32,0))
contact.alpha_composite(sheet,(0,32));save(contact.resize((32*len(names)*3,192),Image.Resampling.NEAREST),'asset_preview')
# Audio original synthetic, deterministic rich atmosphere
SR=22050
def write_audio(name,duration,fn):
 n=int(SR*duration);vals=[fn(i/SR,i) for i in range(n)];peak=max(max(vals),-min(vals),.001);gain=min(1,.82/peak)
 with wave.open(str(ROOT/(name+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(b''.join(struct.pack('<h',int(v*gain*32767)) for v in vals))
rng=random.Random(912)
def ambience(t,i):
 # Frequencies are whole multiples of 1/24 for seamless loop
 tones=sum(a*math.sin(2*math.pi*f*t+p) for f,a,p in [(41,.10,0),(55,.035,1),(82,.025,2),(110,.018,.4),(164.75,.014,2),(221,.009,0)])
 swell=.65+.25*math.sin(2*math.pi*t/12)+.1*math.sin(2*math.pi*t/8)
 return tones*swell+math.sin(2*math.pi*622*t)*.006*(.5+.5*math.sin(2*math.pi*t/6)) + rng.uniform(-.002,.002)
write_audio('ambience',24,ambience)
write_audio('pickup',.65,lambda t,i:sum(.17*math.sin(2*math.pi*f*t)*math.exp(-8*max(0,t-k*.09))*(t>=k*.09) for k,f in enumerate([660,880,1100])))
write_audio('step',.16,lambda t,i:(rng.uniform(-1,1)*.17+math.sin(2*math.pi*90*t)*.12)*math.exp(-30*t))
write_audio('pulse',.9,lambda t,i:(math.sin(2*math.pi*(280*t-90*t*t))*.25+math.sin(2*math.pi*560*t)*.05)*math.exp(-5*t)*(min(t*80,1)))
write_audio('door',.8,lambda t,i:(math.sin(2*math.pi*(85*t+30*t*t))*.15+rng.uniform(-.09,.09))*math.exp(-4*t)*min(t*60,1))
write_audio('alarm',1.2,lambda t,i:math.sin(2*math.pi*(640*t+35*math.sin(2*math.pi*3*t)))*.12*min(1,t*50)*min(1,(1.2-t)*10))
write_audio('fail',1.8,lambda t,i:(math.sin(2*math.pi*(150*t-32*t*t))*.23+math.sin(2*math.pi*46*t)*.14+rng.uniform(-.035,.035))*min(1,t*30)*math.exp(-2*t))
write_audio('complete',1.6,lambda t,i:sum(.1*math.sin(2*math.pi*f*t)*math.exp(-3*max(0,t-k*.16))*(t>=k*.16) for k,f in enumerate([330,440,550,660])))
(ROOT/'LICENSE_ASSETS.md').write_text('''# AFTERHOURS asset provenance\n\nThese raster tiles, animation sheets, title illustration, icon, logo and sound recordings were created specifically for AFTERHOURS: The Tenth Prescription by original procedural drawing and sound synthesis. No third-party stock art, copied game sprites, sampled recordings or generative image sources were used.\n\nCopyright © 2026 Shivam Gupta. All rights reserved. The game owner may use, modify, redistribute and commercially exploit these commissioned project assets.\n\nArt: deliberately restricted ink navy, teal, pale mint, coral and warm amber palette. Images use hard pixel edges; title scene is authored at 320 × 180 and scaled 2× with nearest-neighbor sampling.\n\nAudio: original sine-wave, modulation and seeded-noise synthesis at 22,050 Hz, mono 16-bit PCM WAV. Peaks are limited below full scale. Ambience is a 24-second loop with periodic tonal layers.\n\nSprites: player.png is 96 × 128, 32-pixel cells, three columns (walk frame 0, idle frame 1, walk frame 2), four rows (down, left, right, up). enemy.png is 128 × 32, four frames at 32 × 32. All gameplay tiles and pickups are 32 × 32. title_art.png is 640 × 360. icon.png is 128 × 128. asset_preview.png is for development review only.\n''')
print('Generated',len(list(ROOT.iterdir())),'assets')
