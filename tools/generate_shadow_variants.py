from PIL import Image,ImageDraw
from pathlib import Path
R=Path(__file__).resolve().parents[1] / 'assets'
P={'dark':'#4f314d','red':'#9f4058','coral':'#e26f73','pale':'#f1a699','void':'#080e1b','teal':'#3e6d71','ice':'#81afbf','mint':'#a8d9c5','navy':'#1c3041'}
def rect(d,b,c):d.rectangle(b,fill=P.get(c,c))
def line(d,b,c,w=1):d.line(b,fill=P.get(c,c),width=w)
for style in ['veil','cold','hollow','choir']:
 sheet=Image.new('RGBA',(128,32))
 for frame in range(4):
  im=Image.new('RGBA',(32,32));d=ImageDraw.Draw(im);o=frame%2
  if style=='veil':
   d.polygon([(15,2+o),(21,4+o),(25,15+o),(27,27),(19,25),(15,29),(8,25),(4,27),(8,14+o),(10,5+o)],fill=P['dark'])
   d.polygon([(15,3+o),(21,5+o),(23,16+o),(19,25),(16,28),(11,24),(9,16+o),(11,6+o)],fill=P['red'])
   rect(d,(12,8+o,20,16+o),'void');rect(d,(13,10+o,14,10+o),'pale');rect(d,(19,10+o,20,10+o),'pale');line(d,[(11,17+o),(10,23)],'coral');line(d,[(23,17+o),(24,24)],'coral');line(d,[(16,19+o),(15,25)],'dark')
  elif style=='cold':
   d.polygon([(10,3+o),(21,3+o),(23,14+o),(20,19+o),(25,26),(18,24),(15,29),(10,25),(6,27),(10,17+o),(8,11+o)],fill=P['teal'])
   rect(d,(11,4+o,20,14+o),'ice');rect(d,(11,6+o,12,9+o),'mint');rect(d,(13,8+o,15,10+o),'void');rect(d,(19,8+o,21,10+o),'void');line(d,[(16,11+o),(16,14+o)],'navy');rect(d,(11,16+o,21,21+o),'ice');line(d,[(14,17+o),(13,21+o)],'mint');line(d,[(19,20+o),(21,24)],'mint');rect(d,(6,13+o,8,14+o),'ice');rect(d,(24,7+o,25,8+o),'ice')
  elif style=='hollow':
   d.polygon([(13,1+o),(21,3+o),(22,10+o),(19,14+o),(22,21),(25,28),(19,26),(16,30),(12,25),(7,28),(10,17+o),(11,11+o)],fill=P['red'])
   rect(d,(13,3+o,19,10+o),'coral');rect(d,(14,5+o,19,8+o),'void');line(d,[(12,13+o),(10,21)],'pale');line(d,[(21,13+o),(25,23)],'coral');rect(d,(14,15+o,18,22+o),'void');line(d,[(15,14+o),(17,14+o)],'pale');line(d,[(13,24),(11,28)],'coral');line(d,[(21,25),(23,29)],'coral')
  else:
   d.polygon([(7,8+o),(11,3+o),(16,6+o),(22,2+o),(26,8+o),(24,15+o),(27,22),(23,28),(18,25),(15,30),(10,26),(6,29),(4,20),(7,14+o)],fill=P['dark'])
   rect(d,(9,6+o,14,13+o),'coral');rect(d,(18,4+o,23,12+o),'coral');rect(d,(10,8+o,11,9+o),'void');rect(d,(13,9+o,14,10+o),'void');rect(d,(19,7+o,20,8+o),'void');rect(d,(22,7+o,23,8+o),'void');rect(d,(13,14+o,20,21+o),'red');rect(d,(15,15+o,18,18+o),'void');line(d,[(8,17+o),(7,24)],'coral');line(d,[(24,16+o),(25,23)],'coral');line(d,[(13,23),(13,27)],'coral');line(d,[(19,22),(21,26)],'coral')
  sheet.alpha_composite(im,(frame*32,0))
 sheet.save(R/f'enemy_{style}.png')
preview=Image.new('RGBA',(128,128),'#080e1b')
for row,style in enumerate(['veil','cold','hollow','choir']):preview.alpha_composite(Image.open(R/f'enemy_{style}.png'),(0,row*32))
preview.resize((512,512),Image.Resampling.NEAREST).save(R/'shadow_variants_preview.png')
print('4 four-frame shadow sheets generated')
