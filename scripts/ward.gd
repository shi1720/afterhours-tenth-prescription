extends Node2D
## Deterministic ward simulation. Rendering and UI are separate from game state.
signal changed
signal finished
signal caught
signal message(en: String, ko: String)
const W := 27
const H := 17
const TILE := 32
const ORIGIN := Vector2(32, 112)
var level := 0
var grid: Array = []
var player := Vector2(80, 80)
var facing := 0
var moving := false
var fragments: Array[Vector2] = []
var enemies: Array = []
var cabinets: Array[Vector2] = []
var hazards: Array[Vector2i] = []
var station := Vector2(80, 464)
var hatch := Vector2(784, 464)
var collected := 0
var battery := 100.0
var health := 100.0
var is_hiding := false
var running := false
var gentle := false
var time := 0.0
var pulse_time := 0.0
var cooldown := 0.0
var invincible := 0.0
var alarm_timer := 0.0
var recharge_timer := 0.0
var footsteps := 0.0
var deaths := 0
var astar := AStarGrid2D.new()
var sounds: Dictionary = {}
var textures: Dictionary = {}
var move_override := Vector2.ZERO
var touch_direction := Vector2.ZERO
var touch_sneak := false
var recovery_target := Vector2.ZERO
var recovery_progress := 0.0
var test_mode := false
var high_visibility := false
var effects := true
var recovered_names: Array = []
var revealed: Array[Vector2] = []
const NAMES := [
["Yuna","Minho","Hana"],
["Daeun","Jun","Sora"],
["Jisoo","Haneul","Bora"],
["Eun","Seojun","Nari"],
["Mina","Jae","Ara"],
["Haru","Doyun","Sumin"],
["Yuri","Jiwon","Taeyang"],
["Nabi","Siwoo","Eunsu"],
["Yeon","Jin","Dami"],
["Seul","Woojin","Byeol"]]

func block(x: int, y: int, kind: int) -> void:
	grid[y][x] = kind

func _ready() -> void:
	position = ORIGIN
	for key in ["floor", "wall", "shelves", "cabinet", "desk", "toxic", "exit", "battery", "prescription", "player", "enemy", "lamp", "ice_cabinet", "waiting_chair", "archive_boxes", "cold_floor", "archive_floor", "final_floor", "clock", "noticeboard", "plant", "memorial_candles", "cracked_window", "red_bell", "enemy_veil", "enemy_cold", "enemy_hollow", "enemy_choir", "receipt_printer", "frozen_bottles", "ticket_display", "burst_pipe", "two_seat_memorial", "sparking_fusebox", "hall_phone", "burnt_file", "unsent_letters", "name_memorial"]:
		var path: String = "res://assets/" + key + ".png"
		if ResourceLoader.exists(path): textures[key] = load(path)
	for key in ["pickup", "alarm", "step", "pulse", "door", "fail"]:
		var path: String = "res://assets/" + key + ".wav"
		if ResourceLoader.exists(path):
			var sound := AudioStreamPlayer.new()
			sound.stream = load(path)
			sound.volume_db = -12 if key != "step" else -24
			add_child(sound)
			sounds[key] = sound

func sound(key: String) -> void:
	if sounds.has(key): sounds[key].play()

func cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / TILE), floori(p.y / TILE))

func center(p: Vector2i) -> Vector2:
	return Vector2(p * TILE) + Vector2(16, 16)

func start(index: int, easy: bool = false) -> void:
	level = clampi(index, 0, 9)
	gentle = easy
	grid.clear()
	fragments.clear()
	enemies.clear()
	cabinets.clear()
	hazards.clear()
	for y in H:
		var row: Array[int] = []
		for x in W:
			row.append(1 if x == 0 or y == 0 or x == W-1 or y == H-1 else 0)
		grid.append(row)
	# Each ward has a distinct, authored silhouette; the outer loop is always open.
	match level:
		0:
			for bx in [6,13,20]:
				for y in range(3,14):
					if y not in [5,11]: block(bx,y,2); block(bx+1,y,2)
		1:
			for bx in [8,18]:
				for y in range(3,14):
					if y not in [6,10]: block(bx,y,6); block(bx+1,y,6)
			for x in range(11,16): block(x,8,3)
		2:
			for y in [5,9,12]:
				for x in range(4,24,3): block(x,y,4)
			for x in range(9,17): block(x,3,3)
		3:
			for y in [5,11]:
				for x in range(4,23):
					if x not in [8,15,21]: block(x,y,2)
			for y in range(7,10): block(13,y,3)
		4:
			for bx in [5,11,18,23]:
				for y in [5,11]: block(bx,y,4); block(bx,y+1,4)
			for x in range(9,17): block(x,8,3)
		5:
			for i in 4:
				for y in range(3+i%2*3,11+i%2*3): block(5+i*5,y,2)
		6:
			for y in [5,11]:
				for x in range(3,24):
					if x not in [6,7,19,20]: block(x,y,2)
			for x in [9,15]: block(x,8,3)
		7:
			for x in range(4,24,4):
				for y in [4,7,11,12]: block(x,y,5); block(x+1,y,5)
		8:
			for y in range(4,13):
				if y not in [7,8]: block(8,y,2); block(18,y,2)
			for x in range(9,18):
				if x not in [12,13,14]: block(x,4,3); block(x,12,3)
		9:
			for x in [5,10,16,21]:
				for y in [5,11]: block(x,y,5); block(x+1,y,5)
			for y in range(7,10): block(12,y,3); block(14,y,3)
	player = center(Vector2i(2,2))
	station = center(Vector2i(2,14))
	hatch = center(Vector2i(24,14))
	cabinets.assign([center(Vector2i(3,5)),center(Vector2i(11,12)),center(Vector2i(23,5))])
	var targets := [
		[Vector2i(10,2),Vector2i(23,3),Vector2i(17,13)],
		[Vector2i(4,12),Vector2i(14,5),Vector2i(23,9)],
		[Vector2i(4,3),Vector2i(22,7),Vector2i(13,13)],
		[Vector2i(11,3),Vector2i(23,9),Vector2i(7,13)],
		[Vector2i(3,13),Vector2i(14,3),Vector2i(24,8)],
		[Vector2i(9,4),Vector2i(19,12),Vector2i(23,3)],
		[Vector2i(13,3),Vector2i(4,8),Vector2i(22,13)],
		[Vector2i(7,6),Vector2i(23,10),Vector2i(14,13)],
		[Vector2i(13,8),Vector2i(23,3),Vector2i(4,13)],
		[Vector2i(13,8),Vector2i(23,4),Vector2i(7,13)]
	]
	for c in targets[level]: fragments.append(center(c))
	# Clear interactable and actor footprints, then reject hazards on furniture.
	for p in [player,station,hatch]+cabinets+fragments:
		var c := cell(p)
		grid[c.y][c.x] = 0
	for c in [Vector2i(24,2),Vector2i(17,8),Vector2i(10,14)]: grid[c.y][c.x] = 0
	if level in [3,7,9]:
		for x in range(9,24):
			if grid[8][x] == 0: hazards.append(Vector2i(x,8))
		for y in range(10,14):
			if grid[y][15] == 0: hazards.append(Vector2i(15,y))
	astar.region = Rect2i(0,0,W,H)
	astar.cell_size = Vector2(TILE,TILE)
	astar.offset = Vector2(16,16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for y in H:
		for x in W: astar.set_point_solid(Vector2i(x,y),grid[y][x] != 0)
	var count := 1
	if level in [3,4,6,7,8]: count = 2
	if level == 9: count = 3
	var spawn_cells := [Vector2i(24,2),Vector2i(17,8),Vector2i(10,14)]
	if level%3 == 1: spawn_cells = [Vector2i(10,14),Vector2i(24,2),Vector2i(17,8)]
	if level%3 == 2: spawn_cells = [Vector2i(17,8),Vector2i(10,14),Vector2i(24,2)]
	for n in count:
		enemies.append({"pos":center(spawn_cells[n]),"stun":0.0,"path":PackedVector2Array(),"repath":0.0,"target":center(Vector2i(3+n*8,13-n*4)),"alert":0.0,"route":n})
	recovery_target = Vector2.ZERO
	recovery_progress = 0.0
	touch_direction = Vector2.ZERO
	touch_sneak = false
	revealed.clear()
	recovered_names.clear()
	collected = 0
	battery = 100
	health = 100
	is_hiding = false
	time = 0
	pulse_time = 0
	cooldown = 0
	invincible = 2
	alarm_timer = 2
	recharge_timer = 0
	running = true
	changed.emit()
	queue_redraw()

func passable(p: Vector2) -> bool:
	for corner in [Vector2(-7,-7),Vector2(7,-7),Vector2(-7,7),Vector2(7,7)]:
		var c := cell(p+corner)
		if c.x < 0 or c.y < 0 or c.x >= W or c.y >= H or grid[c.y][c.x] != 0: return false
	return true

func direction() -> Vector2:
	if test_mode: return move_override.normalized()
	if touch_direction.length() > 0.1: return touch_direction.normalized()
	return Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).normalized()

func _process(delta: float) -> void:
	if not running: return
	step(minf(delta,0.05))

func step(delta: float) -> void:
	time += delta
	cooldown = maxf(0,cooldown-delta)
	pulse_time = maxf(0,pulse_time-delta)
	invincible = maxf(0,invincible-delta)
	recharge_timer = maxf(0,recharge_timer-delta)
	var d := direction()
	var sneak := touch_sneak or Input.is_physical_key_pressed(KEY_SHIFT)
	moving = d.length() > 0.1 and not is_hiding
	if moving:
		recovery_target = Vector2.ZERO
		recovery_progress = 0.0
		var speed := 88.0 if not sneak else 56.0
		var next := player + Vector2(d.x,0) * speed * delta
		if passable(next): player.x = next.x
		next = player + Vector2(0,d.y) * speed * delta
		if passable(next): player.y = next.y
		facing = (2 if d.x > 0 else 1) if absf(d.x) > absf(d.y) else (0 if d.y > 0 else 3)
		footsteps += delta
		if footsteps > (0.65 if sneak else 0.36):
			footsteps = 0
			if not sneak: sound("step")
	if recovery_target != Vector2.ZERO:
		recovery_progress += delta
		if recovery_progress >= 0.9:
			fragments.erase(recovery_target)
			collected += 1
			battery = minf(100,battery+8)
			sound("pickup")
			var restored: String = NAMES[level][collected-1]
			recovered_names.append(restored)
			message.emit("NAME RESTORED: " + restored + " • %d / 3" % collected, "")
			recovery_target = Vector2.ZERO
			recovery_progress = 0.0
			if collected == 3:
				for shadow in enemies:
					shadow.target = player
					shadow.alert = 6.0
	battery = maxf(0, battery-delta*(0.15 if is_hiding else (1.25 if level == 5 else 0.70)))
	if hazards.has(cell(player)) and not is_hiding and int(time*0.8)%2 == 0:
		health -= delta * (6 if gentle else 13)
	alarm_timer += delta
	var alarm := level in [2,8,9] and fmod(alarm_timer,12.0) < 2.0
	if alarm and floori((alarm_timer-delta)/12) != floori(alarm_timer/12): sound("alarm")
	for enemy in enemies:
		enemy.stun = maxf(0,enemy.stun-delta)
		if enemy.stun > 0: continue
		var dist: float = enemy.pos.distance_to(player)
		var hear_radius := (45.0 if sneak else 160.0) if moving else 0.0
		var sees := dist < 180 and line_of_sight(enemy.pos,player)
		if alarm: hear_radius = 2000
		if not is_hiding and (dist < hear_radius or sees):
			enemy.target = player
			enemy.alert = 4.0
		else:
			enemy.alert = maxf(0,enemy.alert-delta)
			if enemy.alert <= 0 and enemy.pos.distance_to(enemy.target) < 24:
				enemy.route = (int(enemy.route)+1)%4
				var routes := [Vector2i(3,3),Vector2i(22,7),Vector2i(4,13),Vector2i(23,13)]
				enemy.target = center(routes[(int(enemy.route)+level)%4])
		enemy.repath = float(enemy.repath)-delta
		if enemy.repath <= 0 and (enemy.pos.distance_to(center(cell(enemy.pos))) < 2 or enemy.path.size() < 2):
			enemy.repath = 0.45
			enemy.path = astar.get_point_path(cell(enemy.pos),cell(enemy.target))
			# Center the actor before a new turn. Replanning from a half-crossed
			# tile must not cut diagonally across a furniture corner.
			if enemy.path.size() > 1 and enemy.pos.distance_to(enemy.path[0]) > 1:
				enemy.path.insert(0,enemy.pos)
		var speed := (65.0 + level * 5.0) if enemy.alert > 0 else (45.0 + level * 3.0)
		if level == 6: speed += 15
		if gentle: speed *= 0.72
		if enemy.path.size() > 1:
			var target: Vector2 = enemy.path[1]
			var candidate: Vector2 = enemy.pos.move_toward(target,speed*delta)
			if passable(candidate): enemy.pos = candidate
			else: enemy.repath = 0
			if enemy.pos.distance_to(target) < 2: enemy.path.remove_at(0)
		elif enemy.alert > 0 and not is_hiding and cell(enemy.pos) == cell(player):
			var candidate: Vector2 = enemy.pos.move_toward(player,speed*delta)
			if passable(candidate): enemy.pos = candidate
		if dist < 19 and not is_hiding and invincible <= 0:
			health -= 34 if not gentle else 20
			invincible = 2.0
			enemy.stun = 1.6
			sound("fail")
			message.emit("The Unnamed found you. Pulse, hide, or break away.","")
	if health <= 0:
		running = false
		deaths += 1
		caught.emit()
	changed.emit()
	queue_redraw()

func pulse() -> void:
	if not running or is_hiding or cooldown > 0: return
	if battery < 24:
		message.emit("Not enough charge. Find the teal charging station.","")
		return
	battery -= 24
	cooldown = 4.2
	pulse_time = 0.65
	sound("pulse")
	for f in fragments:
		if f.distance_to(player) < 165 and not revealed.has(f): revealed.append(f)
	for enemy in enemies:
		enemy.target = player
		enemy.alert = 6.0
		enemy.repath = 0.0
		if enemy.pos.distance_to(player) < 165: enemy.stun = 4.5 if gentle else 2.6
	changed.emit()

func interact() -> void:
	if not running: return
	if is_hiding:
		is_hiding = false
		message.emit("You leave the cabinet.","")
		return
	for f in fragments:
		if player.distance_to(f) < 44:
			if not revealed.has(f):
				message.emit("This name is sealed. SPACE reveals records in your light.","")
				return
			recovery_target = f
			recovery_progress = 0.0
			message.emit("Recovering the name. Stay still...", "")
			return
	if player.distance_to(hatch) < 48:
		if collected == 3:
			running = false
			sound("door")
			finished.emit()
		else: message.emit("The hatch needs all three records.","")
		return
	if player.distance_to(station) < 48:
		if recharge_timer > 0: return
		battery = 100
		health = minf(100,health+25)
		recharge_timer = 10
		sound("pickup")
		message.emit("Charge restored. The hum carries through the ward.","")
		for enemy in enemies:
			enemy.target = player
			enemy.alert = 5
		return
	for c in cabinets:
		if player.distance_to(c) < 42:
			recovery_target = Vector2.ZERO
			recovery_progress = 0.0
			is_hiding = true
			sound("door")
			message.emit("Hidden. Press E to leave. Stay still; listen.","")
			return
	message.emit("Move closer to a record, cabinet, charger, or hatch.","")

func prompt() -> String:
	if is_hiding: return "leave"
	for f in fragments:
		if player.distance_to(f) < 44: return "record" if revealed.has(f) else "sealed"
	if player.distance_to(hatch) < 48: return "exit" if collected == 3 else "locked"
	if player.distance_to(station) < 48: return "charge"
	for c in cabinets:
		if player.distance_to(c) < 42: return "hide"
	return ""

func sprite(key: String, p: Vector2, size: Vector2 = Vector2(32,32), tint: Color = Color.WHITE) -> void:
	if textures.has(key): draw_texture_rect(textures[key],Rect2(p,size),false,tint)
	else: draw_rect(Rect2(p,size),Color("24414b"))

func _draw() -> void:
	if grid.is_empty(): return
	draw_rect(Rect2(-3,-3,W*TILE+6,H*TILE+6),Color("476263"),false,1)
	for y in H:
		for x in W:
			var p := Vector2(x*TILE,y*TILE)
			var floor_key := "cold_floor" if level == 1 else ("archive_floor" if level in [7,8] else ("final_floor" if level == 9 else "floor"))
			if floor_key == "archive_floor" and (x*17+y*31+x*y*3)%11 > 1: floor_key = "floor"
			var tones := [Color("ffffff"),Color("aac4df"),Color("dcd0bc"),Color("bbd7bb"),Color("cfb6c3"),Color("bfc4db"),Color("d2bdad"),Color("a7c4b9"),Color("bdb3cd"),Color("e4cdae")]
			sprite(floor_key if textures.has(floor_key) else "floor",p,Vector2(32,32),tones[level])
			if grid[y][x] != 0:
				var key: String = ["floor","wall","shelves","desk","waiting_chair","archive_boxes","ice_cabinet"][grid[y][x]]
				sprite(key if textures.has(key) else "desk",p,Vector2(32,32),tones[level])
			elif (x*17+y*31+level)%37 == 0:
				draw_line(p+Vector2(4,25),p+Vector2(15,26),Color("294448"),1)
	# Decorative fixtures ground each ward in a place rather than an abstract maze.
	for x in [3,11,19,24]:
		if grid[1][x] == 0:
			sprite("cracked_window" if level in [0,6,9] else "noticeboard",Vector2(x*32,32))
	for x in [4,15,22]:
		if grid[15][x] == 0: sprite("memorial_candles" if level >= 7 else "plant",Vector2(x*32,15*32))
	var setpiece: String = ["receipt_printer","frozen_bottles","ticket_display","burst_pipe","two_seat_memorial","sparking_fusebox","hall_phone","burnt_file","unsent_letters","name_memorial"][level]
	sprite(setpiece,Vector2(2*32,32))
	sprite("red_bell",Vector2(24*32,32))
	for c in hazards:
		sprite("toxic",Vector2(c*TILE),Vector2(32,32),Color(1,1,1,0.85 if int(time*0.8)%2 == 0 else 0.25))
	for c in cabinets: sprite("cabinet",c-Vector2(16,16))
	sprite("battery",station-Vector2(16,16),Vector2(32,32),Color(0.4,0.7,0.7) if recharge_timer > 0 else Color.WHITE)
	sprite("exit",hatch-Vector2(16,16),Vector2(32,32),Color.WHITE if collected == 3 else Color(0.4,0.55,0.6))
	for f in fragments:
		draw_circle(f,17+sin(time*3)*2,Color(0.85,0.7,0.3,0.08))
		if not revealed.has(f):
			draw_rect(Rect2(f-Vector2(10,11),Vector2(20,22)),Color("8c6b50"),false,1)
		sprite("prescription",f-Vector2(16,17+(round(sin(time*3)*2) if effects else 0)))
	if not is_hiding and (not effects or invincible <= 0 or int(time*4)%2 == 0):
		if textures.has("player"):
			var frame := int(time*8)%3 if moving else 1
			draw_texture_rect_region(textures.player,Rect2(player-Vector2(16,24),Vector2(32,32)),Rect2(frame*32,facing*32,32,32))
		else: draw_circle(player,10,Color("bce7d5"))
	for enemy in enemies:
		var shadow_key: String = ["enemy_veil","enemy_cold","enemy_hollow","enemy_choir"][level%4]
		if textures.has(shadow_key):
			draw_texture_rect_region(textures[shadow_key],Rect2(enemy.pos-Vector2(16,23),Vector2(32,32)),Rect2(int(time*5)%4*32,0,32,32),Color("83d7d1") if enemy.stun > 0 else Color.WHITE)
		else: draw_circle(enemy.pos,10,Color("e57b79"))
	# Pixel darkness: each tile has distance-based opacity; never entirely hides navigation.
	var radius := (230.0 if high_visibility else 180.0) if battery > 0 else 95.0
	if level in [1,7]:
		radius *= 0.80
		if int(time/4)%3 == 2: radius *= 0.60
	if effects and level == 5 and int(time*2)%5 == 0: radius *= 0.7
	for y in H:
		for x in W:
			var distance := center(Vector2i(x,y)).distance_to(player)
			var darkness := clampf((distance-35)/radius,0,0.62 if high_visibility else 0.79)
			if is_hiding: darkness = maxf(darkness,0.4)
			draw_rect(Rect2(x*TILE,y*TILE,TILE,TILE),Color(0.015,0.025,0.04,darkness))
	# Persistent readable wayfinding lights, visible through darkness.
	for f in fragments:
		if revealed.has(f) or f.distance_to(player) < (260 if high_visibility else 200):
			draw_rect(Rect2(f+Vector2(-2,-10),Vector2(4,4)),Color("e3c476"))
	draw_rect(Rect2(station+Vector2(-6,-9),Vector2(12,2)),Color("76d2c5"))
	draw_rect(Rect2(hatch+Vector2(-9,-12),Vector2(18,2)),Color("76d2c5") if collected == 3 else Color("8f6862"))
	if recovery_target != Vector2.ZERO:
		draw_arc(player,22,-PI/2,-PI/2+TAU*minf(1,recovery_progress/0.9),32,Color("e3c476"),3)
	if pulse_time > 0 and not effects:
		draw_arc(player,165,0,TAU,32,Color(0.6,0.95,0.87,0.4),1)
	if pulse_time > 0 and effects:
		var r := (0.65-pulse_time)*255
		draw_arc(player,r,0,TAU,64,Color(0.6,0.95,0.87,pulse_time),2)
	for enemy in enemies:
		if enemy.alert > 0 and enemy.stun <= 0:
			draw_line(enemy.pos+Vector2(0,-27),enemy.pos+Vector2(0,-21),Color("e8a18b"),2)
			draw_rect(Rect2(enemy.pos+Vector2(-1,-18),Vector2(2,2)),Color("e8a18b"))
		elif enemy.stun > 0:
			draw_arc(enemy.pos,18,0,TAU,16,Color("9ee4cf"),1)
	if moving and not is_hiding and not Input.is_physical_key_pressed(KEY_SHIFT) and effects:
		draw_arc(player,22+fmod(time*28,16),0,TAU,24,Color(0.7,0.85,0.8,0.13),1)
	if is_hiding:
		draw_arc(player,20,0,TAU,24,Color("76d2c5"),1)
	if level in [2,8,9] and fmod(alarm_timer,12.0) < 2:
		draw_rect(Rect2(0,0,W*TILE,H*TILE),Color(0.8,0.2,0.15,0.08))

func line_of_sight(a: Vector2, b: Vector2) -> bool:
	var steps := maxi(1,ceili(a.distance_to(b)/12.0))
	for n in range(1,steps):
		var c := cell(a.lerp(b,float(n)/steps))
		if grid[c.y][c.x] != 0: return false
	return true
