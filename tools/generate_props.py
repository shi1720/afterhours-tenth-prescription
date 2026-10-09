from PIL import Image,ImageDraw
from pathlib import Path
import random
R=Path(__file__).resolve().parents[1] / 'assets';rng=random.Random(371)
P={'void':'#080e1b','navy':'#101c2c','blue':'#1c3041','steel':'#2b4654','teal':'#3e6d71','mint':'#a8d9c5','white':'#e0ede0','coral':'#e26f73','red':'#9f4058','gold':'#e2bb7c','darkgold':'#866e53','black':'#050a13','ice':'#81afbf'}
def new():return Image.new('RGBA',(32,32))
def rect(d,b,c):d.rectangle(b,fill=P.get(c,c))
def ln(d,p,c,w=1):d.line(p,fill=P.get(c,c),width=w)
def save(im,n):im.save(R/(n+'.png'))
# Cold storage unit: double frosted glass and exposed compressor.
a=new();d=ImageDraw.Draw(a);rect(d,(2,1,29,30),'void');rect(d,(3,2,28,27),'steel');rect(d,(5,4,26,21),'ice');rect(d,(6,5,25,20),'blue');rect(d,(15,4,16,21),'teal');rect(d,(13,11,13,15),'mint');rect(d,(18,11,18,15),'mint')
for x in (8,20):
 rect(d,(x,8,x+3,16),'mint');rect(d,(x+1,7,x+2,8),'white')
for x,y in ((7,6),(23,6),(8,18),(21,17)):
 ln(d,[(x-1,y),(x+1,y+2),(x-1,y+4)],'ice')
for y in (24,26):ln(d,[(7,y),(24,y)],'navy')
rect(d,(5,29,8,31),'navy');rect(d,(23,29,26,31),'navy');save(a,'ice_cabinet')
# Waiting chair, textile cushion
for n,c in [('waiting_chair','teal')]:
 a=new();d=ImageDraw.Draw(a);rect(d,(7,4,24,17),'void');rect(d,(8,3,23,15),'steel');rect(d,(9,4,22,13),c);ln(d,[(10,5),(20,5)],'mint');rect(d,(5,16,26,21),'navy');rect(d,(7,15,24,19),c);rect(d,(6,22,8,29),'steel');rect(d,(23,22,25,29),'steel');rect(d,(4,13,6,18),'mint');rect(d,(25,13,27,18),'mint');save(a,n)
# Boxes piled unevenly with archive labels
 a=new();d=ImageDraw.Draw(a)
 for x,y,w,h in [(3,16,15,13),(17,17,12,12),(9,4,16,13)]:
  rect(d,(x,y,x+w,y+h),'void');rect(d,(x,y,x+w-1,y+h-1),'darkgold');rect(d,(x+1,y+1,x+w-2,y+2),'gold');rect(d,(x+w//2-1,y,x+w//2+1,y+h-2),'#a68c63');rect(d,(x+3,y+5,x+w-4,y+8),'white');ln(d,[(x+4,y+6),(x+w-5,y+6)],'teal')
 save(a,'archive_boxes')
# Floor variants
for n in ['cold_floor','archive_floor','final_floor','flooded_floor']:
 a=Image.open(R/'floor.png').convert('RGBA');d=ImageDraw.Draw(a)
 if n=='cold_floor':
  rect(d,(1,1,30,30),'#203745');ln(d,[(1,30),(30,30),(30,1)],'steel');
  for x,y in [(3,4),(24,22),(11,12)]:ln(d,[(x,y),(x+3,y+2),(x+2,y+5)],'ice');ln(d,[(x+2,y+1),(x+4,y)],'teal')
 if n=='archive_floor':
  for b in [(4,6,12,14),(19,17,27,25)]:
   rect(d,b,'steel');rect(d,(b[0],b[1],b[2]-1,b[3]-1),'#99ac9f');ln(d,[(b[0]+2,b[1]+3),(b[2]-2,b[1]+3)],'teal');ln(d,[(b[0]+2,b[1]+5),(b[2]-3,b[1]+5)],'teal')
 if n=='final_floor':
  for y in [6,14,22]:
   for x in [4,12,20]:
    ln(d,[(x,y+3),(x,y),(x+3,y+3),(x+3,y)],'mint' if y==14 else 'teal')
 if n=='flooded_floor':
  for b in [(1,11,30,25),(7,4,23,29)]:rect(d,b,'#203f4a')
  for x,y in [(3,13),(14,5),(17,23),(25,17),(8,28)]:ln(d,[(x,y),(x+4,y)],'teal');rect(d,(x+1,y+1,x+2,y+1),'ice')
 save(a,n)
a=new();d=ImageDraw.Draw(a)
for x,y in [(4,6),(12,5),(21,7),(7,17),(16,18),(23,20)]:ln(d,[(x,y+4),(x,y),(x+4,y+4),(x+4,y)],'mint');ln(d,[(x-1,y+7),(x+5,y+7)],'teal')
save(a,'chalk_names')
# Wheelchair from three-quarter top/front
a=new();d=ImageDraw.Draw(a);d.ellipse((3,17,11,30),fill=P['void'],outline=P['mint']);d.ellipse((22,17,30,30),fill=P['void'],outline=P['mint']);rect(d,(8,4,24,17),'steel');rect(d,(10,5,22,16),'teal');ln(d,[(11,6),(20,6)],'mint');rect(d,(8,17,24,22),'navy');rect(d,(10,17,22,20),'teal');ln(d,[(9,20),(11,27),(20,27),(23,20)],'steel',2);ln(d,[(7,9),(7,5),(4,5)],'mint');ln(d,[(25,9),(25,5),(28,5)],'mint');rect(d,(11,28,21,29),'steel');save(a,'wheelchair')
# Window highlights broken star-shaped glass
a=new();d=ImageDraw.Draw(a);rect(d,(2,2,29,29),'void');rect(d,(3,3,28,27),'teal');rect(d,(5,5,26,25),'navy');rect(d,(6,6,25,24),'#192938');rect(d,(15,4,16,26),'steel');rect(d,(4,14,27,15),'steel');ln(d,[(20,6),(19,12),(24,18),(20,20),(22,24)],'ice');ln(d,[(19,12),(17,17),(16,20)],'teal');ln(d,[(19,12),(25,10)],'mint');rect(d,(2,28,29,30),'steel');save(a,'cracked_window')
# bell and clock
a=new();d=ImageDraw.Draw(a);rect(d,(15,3,17,7),'gold');rect(d,(11,7,21,10),'coral');rect(d,(9,11,23,18),'red');rect(d,(8,17,24,21),'coral');rect(d,(6,22,26,24),'darkgold');rect(d,(7,22,25,23),'gold');rect(d,(14,25,18,27),'gold');ln(d,[(11,12),(11,17)],'coral');save(a,'red_bell')
a=new();d=ImageDraw.Draw(a);d.ellipse((4,4,27,27),fill=P['void']);d.ellipse((5,3,26,24),fill=P['teal']);d.ellipse((7,5,24,22),fill=P['white']);ln(d,[(16,8),(16,14),(21,17)],'navy',2)
for x,y in [(15,6),(8,13),(15,20),(22,13)]:rect(d,(x,y,x+1,y+1),'darkgold')
save(a,'clock')
# Notice board with torn notices
a=new();d=ImageDraw.Draw(a);rect(d,(1,3,30,29),'void');rect(d,(2,2,29,27),'darkgold');rect(d,(4,4,27,25),'#695f50')
for x,y,c in [(6,6,'mint'),(17,7,'white'),(11,16,'white')]:rect(d,(x,y,x+7,y+8),c);rect(d,(x+3,y,x+4,y+1),'coral');ln(d,[(x+2,y+4),(x+5,y+4)],'teal');ln(d,[(x+2,y+6),(x+4,y+6)],'teal')
save(a,'noticeboard')
# neglected plant
a=new();d=ImageDraw.Draw(a);rect(d,(11,21,22,29),'darkgold');rect(d,(9,20,24,22),'gold');rect(d,(15,9,16,20),'teal');d.polygon([(15,14),(9,11),(7,5),(13,7),(16,12)],fill=P['teal']);d.polygon([(16,16),(22,9),(26,8),(23,14),(17,18)],fill=P['mint']);d.polygon([(15,10),(15,4),(18,3),(19,7)],fill=P['mint']);rect(d,(12,24,13,27),'gold');save(a,'plant')
# memorial: three lights with softly stepped pixel halos
a=new();d=ImageDraw.Draw(a);rect(d,(4,27,28,29),'steel')
for x,y,h in [(6,16,10),(14,10,16),(23,18,8)]:
 rect(d,(x-2,y-6,x+4,y+1),'#223733');rect(d,(x,y,x+3,y+h),'white');rect(d,(x+3,y+1,x+3,y+h),'gold');rect(d,(x+1,y-4,x+2,y-1),'gold');rect(d,(x+1,y-3,x+1,y-1),'white');rect(d,(x+1,y-5,x+1,y-5),'coral')
save(a,'memorial_candles')
files=['ice_cabinet','waiting_chair','archive_boxes','flooded_floor','chalk_names','wheelchair','cracked_window','red_bell','clock','noticeboard','plant','memorial_candles','cold_floor','archive_floor','final_floor']
contact=Image.new('RGBA',(32*len(files),32),P['void'])
for i,n in enumerate(files):contact.alpha_composite(Image.open(R/(n+'.png')),(i*32,0))
save(contact.resize((32*len(files)*3,96),Image.Resampling.NEAREST),'props_preview')
print('Generated',len(files),'props')
