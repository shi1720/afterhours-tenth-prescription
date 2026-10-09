from PIL import Image,ImageDraw
from pathlib import Path
R=Path(__file__).resolve().parents[1] / 'assets'
P={'void':'#080e1b','navy':'#101c2c','blue':'#1c3041','steel':'#2b4654','teal':'#3e6d71','mint':'#a8d9c5','white':'#e0ede0','coral':'#e26f73','red':'#9f4058','gold':'#e2bb7c','darkgold':'#866e53','ice':'#81afbf'}
def new():return Image.new('RGBA',(32,32))
def rect(d,b,c):d.rectangle(b,fill=P.get(c,c))
def line(d,p,c,w=1):d.line(p,fill=P.get(c,c),width=w)
def save(a,n):a.save(R/(n+'.png'))
# Receipt printer with impossibly long strip of unspooling thermal paper.
a=new();d=ImageDraw.Draw(a);rect(d,(3,7,27,21),'void');rect(d,(4,6,26,19),'steel');rect(d,(6,7,24,11),'teal');rect(d,(7,12,23,15),'void');rect(d,(8,16,11,17),'coral');rect(d,(21,7,23,8),'mint');rect(d,(12,13,21,26),'white');rect(d,(12,26,25,29),'white');line(d,[(14,16),(19,16)],'teal');line(d,[(14,19),(19,19)],'teal');line(d,[(14,22),(18,22)],'teal');line(d,[(18,27),(23,27)],'teal');rect(d,(4,20,8,22),'navy');save(a,'receipt_printer')
# Frozen bottles with broken ice crystals.
a=new();d=ImageDraw.Draw(a);rect(d,(3,24,29,28),'steel');rect(d,(4,25,28,26),'ice')
for x,y,h in [(5,11,12),(12,7,16),(21,13,10)]:
 rect(d,(x,y,x+5,y+h),'teal');rect(d,(x+1,y+1,x+4,y+h-1),'ice');rect(d,(x+2,y-3,x+3,y),'white');rect(d,(x+1,y+5,x+4,y+8),'mint');line(d,[(x+1,y+3),(x+2,y+1)],'white')
for x,y in [(3,18),(27,20),(17,4),(19,17)]:line(d,[(x-2,y),(x+2,y)],'mint');line(d,[(x,y-2),(x,y+2)],'mint')
save(a,'frozen_bottles')
# Ticket display with authored 3-by-5 digits.
a=new();d=ImageDraw.Draw(a);rect(d,(4,5,28,22),'void');rect(d,(5,4,27,20),'steel');rect(d,(7,6,25,17),'navy')
digits={'0':['111','101','101','101','111'],'4':['101','101','111','001','001'],'1':['010','110','010','010','111']}
for n,x in zip('041',[9,15,21]):
 for yy,row in enumerate(digits[n]):
  for xx,v in enumerate(row):
   if v=='1':rect(d,(x+xx,9+yy,x+xx,9+yy),'coral')
rect(d,(13,21,19,25),'steel');rect(d,(9,26,23,28),'teal');save(a,'ticket_display')
# Burst pipe, brass collar and frozen black runoff.
a=new();d=ImageDraw.Draw(a);rect(d,(3,5,20,10),'steel');rect(d,(3,5,19,6),'ice');rect(d,(18,9,23,19),'steel');rect(d,(18,10,19,17),'ice');rect(d,(7,3,10,12),'darkgold');rect(d,(8,4,9,11),'gold');rect(d,(17,17,24,20),'void');rect(d,(17,17,19,19),'steel');rect(d,(22,18,24,21),'steel');rect(d,(19,22,21,24),'teal');rect(d,(17,26,23,27),'teal');line(d,[(7,28),(15,28),(17,30),(27,30)],'ice');rect(d,(11,27,13,27),'teal');save(a,'burst_pipe')
# Two seats with a folded coat and a candle between them.
a=new();d=ImageDraw.Draw(a)
for x in [2,20]:
 rect(d,(x,7,x+9,18),'steel');rect(d,(x+1,8,x+8,16),'teal');rect(d,(x,19,x+10,22),'teal');rect(d,(x+1,23,x+2,28),'steel');rect(d,(x+8,23,x+9,28),'steel')
rect(d,(4,11,9,17),'darkgold');rect(d,(5,12,11,20),'gold');line(d,[(7,14),(7,20)],'darkgold');rect(d,(14,21,17,27),'white');rect(d,(15,17,16,20),'gold');rect(d,(15,18,15,19),'white');rect(d,(12,28,19,29),'steel');save(a,'two_seat_memorial')
# Fuse box with an open door and one red wire.
a=new();d=ImageDraw.Draw(a);rect(d,(9,3,27,29),'void');rect(d,(10,2,26,27),'steel');rect(d,(12,5,24,24),'navy');rect(d,(2,7,9,25),'teal');line(d,[(3,8),(3,23)],'mint')
for x in [14,20]:
 for y in [7,14]:rect(d,(x,y,x+2,y+4),'white');rect(d,(x,y+1,x+2,y+2),'darkgold')
line(d,[(15,20),(15,23),(22,23),(22,19)],'coral');rect(d,(27,8,28,9),'gold');rect(d,(29,6,29,7),'white');rect(d,(27,13,29,13),'gold');rect(d,(28,16,28,17),'coral');save(a,'sparking_fusebox')
# Rotary phone with severed cord.
a=new();d=ImageDraw.Draw(a);rect(d,(5,14,26,27),'void');rect(d,(6,13,25,25),'teal');rect(d,(8,12,23,15),'mint');rect(d,(5,6,26,11),'navy');rect(d,(4,8,8,14),'steel');rect(d,(23,8,27,14),'steel');line(d,[(8,7),(23,7)],'teal');d.ellipse((12,16,21,24),fill=P['navy'],outline=P['mint']);rect(d,(15,19,18,21),'teal');line(d,[(27,12),(29,13),(28,16),(30,17),(29,20),(31,21)],'teal');line(d,[(27,25),(29,27)],'teal');save(a,'hall_phone')
# Burnt file with intact handwriting and curled black edges.
a=new();d=ImageDraw.Draw(a);rect(d,(5,4,25,28),'void');rect(d,(6,3,24,26),'darkgold');rect(d,(8,5,23,25),'white');rect(d,(8,5,11,6),'void');rect(d,(7,7,9,10),'void');rect(d,(21,21,24,25),'void');rect(d,(19,24,21,27),'void');line(d,[(12,9),(20,9)],'teal');line(d,[(11,12),(20,12)],'teal');line(d,[(11,15),(18,15)],'teal');line(d,[(11,18),(20,18)],'teal');rect(d,(15,21,17,22),'coral');rect(d,(4,24,5,25),'red');rect(d,(26,28,27,28),'darkgold');save(a,'burnt_file')
# Unsent mail with one impossible red wax seal.
a=new();d=ImageDraw.Draw(a)
for x,y,w,h in [(3,18,18,10),(9,10,20,11),(3,4,20,11)]:
 rect(d,(x,y,x+w,y+h),'void');rect(d,(x,y,x+w-1,y+h-1),'white');line(d,[(x,y),(x+w//2,y+5),(x+w-1,y)],'teal');line(d,[(x,y+h-1),(x+6,y+4)],'mint');rect(d,(x+w-5,y+2,x+w-3,y+4),'gold')
rect(d,(12,8,15,11),'coral');rect(d,(13,9,14,10),'red');save(a,'unsent_letters')
# Memorial board: thirty places, with the thirtieth still blank.
a=new();d=ImageDraw.Draw(a);rect(d,(1,1,30,28),'void');rect(d,(2,1,29,27),'darkgold');rect(d,(3,2,28,26),'navy')
for row in range(5):
 for col in range(6):
  x,y=4+col*4,3+row*4;rect(d,(x,y,x+2,y+2),'mint' if (row,col)!=(4,5) else 'gold');rect(d,(x+1,y+1,x+1,y+1),'teal' if (row,col)!=(4,5) else 'gold')
for x in [6,15,24]:rect(d,(x,26,x+2,30),'white');rect(d,(x+1,23,x+1,25),'gold')
save(a,'name_memorial')
files=['receipt_printer','frozen_bottles','ticket_display','burst_pipe','two_seat_memorial','sparking_fusebox','hall_phone','burnt_file','unsent_letters','name_memorial']
a=Image.new('RGBA',(32*10,32),'#080e1b')
for i,n in enumerate(files):a.alpha_composite(Image.open(R/(n+'.png')),(i*32,0))
a.resize((1280,128),Image.Resampling.NEAREST).save(R/'setpieces_preview.png')
print('Generated10setpieces')
