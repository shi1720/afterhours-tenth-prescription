extends Node2D
## Application screens, local profile, English copy, and ward checkpoints.
const Ward = preload("res://scripts/ward.gd")
const Data = preload("res://scripts/levels.gd")
const INK := Color("0b151e")
const PANEL := Color("10232b")
const MINT := Color("9ee4cf")
const PAPER := Color("e8eadc")
const MUTED := Color("96aeb2")
const CORAL := Color("e29682")
var ui: Control
var ward: Node2D
var font: Font = preload("res://assets/fonts/SpaceGrotesk.ttf")
var mono: Font = preload("res://assets/fonts/SpaceMono.ttf")
var art: Texture2D
var profile := ""
var unlocked := 0
var checkpoint := 0
var memories: Array = []
var tutorial_done := false
var tutorial_step := 0
var tutorial_return := "menu"
var screen := "menu"
var gentle := false
var volume := 0.65
var motion := true
var elapsed := 0.0
var total_time := 0.0
var toast := ""
var toast_time := 0.0
var hud_labels: Dictionary = {}
var ambience: AudioStreamPlayer
var intro_index := 0
var transition_lock := false
var session_ending := ""
var settings_from_pause := false
var campaign_complete := false
var high_visibility := false
var world_clip: Control
var compact_layout := false
var browser_callback: JavaScriptObject
var browser_emit_timer := 0.0
var browser_muted := false
var arrival: AudioStreamPlayer
const ARRIVAL_CUES := ["printer", "frost", "ticket", "pipe", "chairs", "fuse", "phone", "archive", "letters", "memorial"]

func _ready() -> void:
	var weighted := FontVariation.new()
	weighted.base_font = font
	weighted.variation_opentype = {2003265652:450}
	font = weighted
	load_save()
	if ResourceLoader.exists("res://assets/title_art.png"): art = load("res://assets/title_art.png")
	world_clip = Control.new()
	world_clip.position = Vector2(32,112)
	world_clip.size = Vector2(864,544)
	world_clip.clip_contents = true
	world_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world_clip)
	ward = Ward.new()
	world_clip.add_child(ward)
	ward.position = Vector2.ZERO
	ward.visible = false
	ward.changed.connect(update_hud)
	ward.finished.connect(on_finished)
	ward.caught.connect(show_failure)
	ward.message.connect(show_toast)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(ui)
	ambience = AudioStreamPlayer.new()
	if ResourceLoader.exists("res://assets/ambience.wav"):
		var stream: AudioStreamWAV = load("res://assets/ambience.wav")
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = int(stream.get_length()*stream.mix_rate)
		ambience.stream = stream
	add_child(ambience)
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.001)))
	arrival = AudioStreamPlayer.new()
	arrival.volume_db = -13
	add_child(arrival)
	if OS.has_feature("web"):
		browser_callback = JavaScriptBridge.create_callback(browser_command)
		var browser_window = JavaScriptBridge.get_interface("window")
		browser_window.afterhoursInput = browser_callback
	show_menu()

func save() -> void:
	var c := ConfigFile.new()
	c.set_value("player","name",profile)
	c.set_value("player","unlocked",unlocked)
	c.set_value("player","checkpoint",checkpoint)
	c.set_value("player","memories",memories)
	c.set_value("player","tutorial",tutorial_done)
	c.set_value("player","ending",session_ending)
	c.set_value("settings","gentle",gentle)
	c.set_value("settings","volume",volume)
	c.set_value("settings","motion",motion)
	c.set_value("settings","high_visibility",high_visibility)
	c.save("user://afterhours.cfg")

func load_save() -> void:
	var c := ConfigFile.new()
	if c.load("user://afterhours.cfg") != OK: return
	profile = str(c.get_value("player","name","" )).substr(0,20)
	unlocked = clampi(int(c.get_value("player","unlocked",0)),0,9)
	checkpoint = clampi(int(c.get_value("player","checkpoint",0)),0,9)
	var stored = c.get_value("player","memories",[])
	if stored is Array:
		for item in stored:
			if item is int and item >= 0 and item < 10 and not memories.has(item): memories.append(item)
	session_ending = str(c.get_value("player","ending",""))
	campaign_complete = session_ending in ["remember","forget"]
	tutorial_done = bool(c.get_value("player","tutorial",false))
	gentle = bool(c.get_value("settings","gentle",false))
	volume = clampf(float(c.get_value("settings","volume",0.65)),0,1)
	motion = bool(c.get_value("settings","motion",true))
	high_visibility = bool(c.get_value("settings","high_visibility",false))

func clear(next: String) -> void:
	screen = next
	for child in ui.get_children():
		child.hide()
		child.queue_free()
	hud_labels.clear()
	ui.modulate = Color(1,1,1,0.65) if motion else Color.WHITE
	if motion: create_tween().tween_property(ui,"modulate",Color.WHITE,0.16)
	world_clip.visible = next == "game"
	ward.visible = next == "game"
	ward.running = next == "game"
	if next != "game":
		ward.touch_direction = Vector2.ZERO
		ward.touch_sneak = false
	queue_redraw()

func box(rect: Rect2, color: Color = PANEL, border: Color = Color("29414a")) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	node.add_theme_stylebox_override("panel",style)
	ui.add_child(node)
	return node

func text_label(value: String, pos: Vector2, size: Vector2, font_size: int = 20, color: Color = PAPER, code: bool = false) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font",mono if code else font)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.position = pos
	label.size = size
	label.text = value
	ui.add_child(label)
	return label

func button(value: String, rect: Rect2, callback: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = value
	b.position = rect.position
	b.size = Vector2(rect.size.x,maxf(rect.size.y,96)) if compact_layout else rect.size
	if compact_layout: b.position.y = minf(b.position.y,620)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font",font)
	b.add_theme_font_size_override("font_size",26 if compact_layout else 18)
	b.add_theme_color_override("font_color",INK if primary else PAPER)
	b.add_theme_color_override("font_hover_color",INK)
	b.add_theme_color_override("font_focus_color",MINT)
	b.add_theme_color_override("font_disabled_color",Color("536c75"))
	for state in ["normal","hover","pressed","focus","disabled"]:
		var st := StyleBoxFlat.new()
		st.bg_color = MINT if (primary or state in ["hover","pressed"]) else Color("142a32")
		if state == "disabled": st.bg_color = Color("0c1c24")
		if state == "focus": st.bg_color = Color("25454d")
		st.border_color = MINT if state in ["hover","focus"] else Color("36515a")
		st.set_border_width_all(1 if state != "focus" else 2)
		st.content_margin_left = 14
		st.content_margin_right = 14
		b.add_theme_stylebox_override(state,st)
	b.pressed.connect(callback)
	ui.add_child(b)
	return b

func header(tag: String, title: String, subtitle: String = "") -> void:
	text_label(tag,Vector2(48,30),Vector2(1120,24),13,MINT,true)
	text_label(title,Vector2(48,72),Vector2(1120,68),38)
	if subtitle != "": text_label(subtitle,Vector2(50,144),Vector2(1110,64),18,MUTED)

func show_menu() -> void:
	clear("menu")
	if compact_layout:
		show_compact_menu()
		return
	text_label("SHIFT 00:00 TO 06:00   /   PIXEL HORROR",Vector2(54,42),Vector2(800,32),12,MINT,true)
	text_label("AFTER\nHOURS",Vector2(48,110),Vector2(610,200),76,PAPER,true)
	text_label("THE TENTH PRESCRIPTION",Vector2(55,326),Vector2(550,38),20,MINT,true)
	text_label("Ten wards. Thirty forgotten names.\nYou are the last pharmacist on duty.",Vector2(56,384),Vector2(510,78),20,PAPER)
	button("Revisit the wards  →" if campaign_complete else "Continue shift  →" if profile != "" else "Begin the night  →",Rect2(56,486,338,54),begin_campaign,true)
	button("Start a new shift",Rect2(56,552,338,44),show_reset)
	button("Ward select",Rect2(410,486,178,54),show_wards)
	button("Archive",Rect2(410,552,178,44),show_archive)
	button("Settings",Rect2(56,610,160,40),show_settings)
	button("Field guide",Rect2(230,610,164,40),open_guide)
	button("Credits",Rect2(410,610,178,40),show_credits)
	text_label("A game by SHIVAM GUPTA",Vector2(56,677),Vector2(600,24),12,MUTED,true)
	text_label("01 - 10  /  OFFLINE SAVE",Vector2(950,672),Vector2(280,24),12,MINT,true)
	if profile != "": text_label("ON DUTY: "+profile,Vector2(740,31),Vector2(350,30),14,MUTED)

func show_compact_menu() -> void:
	text_label("AFTERHOURS",Vector2(48,30),Vector2(1184,75),54,MINT,true)
	text_label("The Tenth Prescription / Thirty names. One light.",Vector2(52,111),Vector2(1150,48),25,PAPER)
	var entries := [
		["Continue shift" if not profile.is_empty() else "Begin the night",begin_campaign],
		["Ward select",show_wards],
		["Start a new shift",show_reset],
		["Archive",show_archive],
		["Settings",show_settings],
		["Field guide",open_guide],
		["Credits",show_credits]]
	for i in entries.size():
		var pos := Vector2(48+(i%2)*600,194+(i/2)*118)
		var item := button(entries[i][0],Rect2(pos,Vector2(560,96)),entries[i][1],i==0)
		item.add_theme_font_size_override("font_size",28)
	text_label("Created by Shivam Gupta / progress stays on this device",Vector2(48,676),Vector2(1170,28),16,MUTED)

func show_profile() -> void:
	clear("profile")
	header("STAFF ACCESS / LOCAL PROFILE","Your shift starts here.","Choose a name for this device. No email, password, or account required.")
	box(Rect2(260,214 if compact_layout else 236,760,390 if compact_layout else 318))
	text_label("NAME ON YOUR BADGE",Vector2(300,238 if compact_layout else 266),Vector2(670,30),20 if compact_layout else 13,MINT,true)
	var entry := LineEdit.new()
	entry.position = Vector2(300,286 if compact_layout else 314)
	entry.size = Vector2(680,74 if compact_layout else 56)
	entry.virtual_keyboard_enabled = true
	entry.max_length = 20
	entry.placeholder_text = "Night pharmacist"
	entry.text = profile
	entry.add_theme_font_override("font",font)
	entry.add_theme_font_size_override("font_size",32 if compact_layout else 24)
	ui.add_child(entry)
	var submit := func():
		profile = entry.text.strip_edges()
		if profile.is_empty(): profile = "Night pharmacist"
		save()
		if tutorial_done: show_intro(checkpoint)
		else:
			tutorial_step = 0
			tutorial_return = "start"
			show_tutorial()
	entry.text_submitted.connect(func(_value): submit.call())
	button("Clock in  →",Rect2(300,382 if compact_layout else 400,680,52),submit,true)
	button("Continue as Night pharmacist",Rect2(300,490 if compact_layout else 560,680,52),func(): entry.text="Night pharmacist"; submit.call())
	if not compact_layout: text_label("Saved only in this browser or device. Clearing browser data removes progress.",Vector2(300,478),Vector2(680,52),14,MUTED)
	button("← Back",Rect2(48,636,160,44),show_menu)
	entry.grab_focus()

func begin_campaign() -> void:
	if profile == "": show_profile()
	elif not tutorial_done:
		tutorial_step = 0
		tutorial_return = "start"
		show_tutorial()
	elif campaign_complete: show_wards()
	else: show_intro(checkpoint)

func open_guide() -> void:
	tutorial_step = 0
	tutorial_return = "menu"
	show_tutorial()

func show_tutorial() -> void:
	clear("tutorial")
	var titles := [["Welcome to the night shift"], ["Find the forgotten records"], ["Light buys you time"], ["Silence is a hiding place"], ["Make it to the hatch"], ["A night worth remembering"]]
	var bodies := [["Move with WASD or arrow keys. This is a game of routes, patience, and listening. Headphones help. Every warning is also visible."], ["Three sealed gold records wait in each ward. Use SPACE nearby to reveal a name. Press E and stay still to recover it. Gold glints appear near your light."], ["Press SPACE to release a light pulse. It stuns nearby shadows for 2.6 seconds and costs 24 charge. Distant shadows hear it. Teal stations refill charge and some resolve  -  but the sound draws attention."], ["Hold SHIFT to walk quietly. Press E beside a tall cabinet to hide, then E again to leave. Shadows cannot touch you while hidden."], ["Recover all three records, then press E at the hatch in the lower-right corner. Each new ward introduces a different survival rule. Read it before entering."], ["ESC pauses the night. The Archive keeps recovered stories. Progress saves after each ward. Settings include volume, a gentler mode and high visibility. You can replay this guide anytime."]]
	header("FIELD GUIDE / "+"%02d OF 06"%(tutorial_step+1),titles[tutorial_step][0])
	box(Rect2(48,206,1184,360))
	text_label(["W A S D","E  /  03","SPACE","SHIFT + E","E  →","ESC"][tutorial_step],Vector2(96,258),Vector2(420,110),45,MINT,true)
	text_label("LEARN THE RULE.\nKEEP YOUR NAME.",Vector2(100,399),Vector2(360,100),18,MUTED,true)
	text_label(bodies[tutorial_step][0],Vector2(558,262),Vector2(605,240),25,PAPER)
	for i in 6: box(Rect2(48+i*47,597,34,4),MINT if i <= tutorial_step else Color("29414a"),Color.TRANSPARENT)
	if tutorial_step > 0: button("← Previous",Rect2(48,636,170,48),func(): tutorial_step-=1; show_tutorial())
	button("Skip guide",Rect2(828,636,180,48),finish_tutorial)
	button("Clock in  →" if tutorial_step == 5 else "Next  →",Rect2(1024,636,208,48),func():
		if tutorial_step == 5: finish_tutorial()
		else: tutorial_step+=1; show_tutorial(),true)

func finish_tutorial() -> void:
	tutorial_done = true
	save()
	if tutorial_return == "start": show_intro(checkpoint)
	else: show_menu()

func show_intro(index: int) -> void:
	intro_index = index
	clear("intro")
	var data: Dictionary = Data.WARDS[index]
	header("DESCENT / WARD "+"%02d / 10"%(index+1),data.title[0],data.patient[0])
	text_label("%02d"%(index+1),Vector2(60,230),Vector2(350,200),138,Color("254b50"),true)
	box(Rect2(450,236,782,242))
	text_label("SURVIVAL RULE",Vector2(486,261),Vector2(690,30),13,MINT,true)
	text_label(data.rule[0],Vector2(486,308),Vector2(690,132),25)
	text_label("SPACE reveals → E recovers → 3 records → hatch",Vector2(450,512),Vector2(770,50),18,MUTED)
	button("Enter ward  →",Rect2(824,624,408,56),func(): start_ward(index),true)
	button("← Return",Rect2(48,636,184,44),show_menu)

func start_ward(index: int) -> void:
	clear("game")
	ward.effects = motion
	ward.high_visibility = high_visibility
	ward.start(index,gentle)
	elapsed = 0
	toast = str(Data.WARDS[index].get("intro",""))
	toast_time = 9
	var arrival_path: String = "res://assets/arrival_" + ARRIVAL_CUES[index] + ".wav"
	if ResourceLoader.exists(arrival_path):
		arrival.stream = load(arrival_path)
		arrival.play()
	configure_world()
	if not ambience.playing and ambience.stream: ambience.play()
	build_hud()

func configure_world() -> void:
	world_clip.position = Vector2(16,96) if compact_layout else Vector2(32,112)
	world_clip.size = Vector2(1000,600) if compact_layout else Vector2(864,544)
	ward.scale = Vector2(1.6,1.6) if compact_layout else Vector2.ONE
	update_world_camera()

func update_world_camera() -> void:
	if not compact_layout:
		ward.position = Vector2.ZERO
		return
	var world_size := Vector2(864,544) * 1.6
	var desired: Vector2 = world_clip.size * 0.5 - ward.player * 1.6
	ward.position = Vector2(clampf(desired.x,world_clip.size.x-world_size.x,0),clampf(desired.y,world_clip.size.y-world_size.y,0)).round()

func resource_bar(pos: Vector2, width: float, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("20343b")
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("background",background)
	bar.add_theme_stylebox_override("fill",fill)
	ui.add_child(bar)
	bar.size = Vector2(width,10)
	return bar

func build_hud() -> void:
	configure_world()
	var side_x := 1044.0 if compact_layout else 928.0
	var side_width := 220.0 if compact_layout else 320.0
	var inner_x := side_x + 16
	var inner_width := side_width - 32
	text_label("AFTERHOURS",Vector2(16 if compact_layout else 32,16),Vector2(600,32),22,MINT,true)
	text_label("WARD "+"%02d / 10"%(ward.level+1)+"  /  "+Data.WARDS[ward.level].title[0],Vector2(16 if compact_layout else 32,49),Vector2(1000,30),19,PAPER)
	box(Rect2(side_x,96 if compact_layout else 112,side_width,600 if compact_layout else 544))
	text_label("NIGHT SHIFT",Vector2(inner_x,128),Vector2(inner_width,28),12,MINT,true)
	hud_labels["records"] = text_label("",Vector2(inner_x,171),Vector2(inner_width,56),27 if compact_layout else 24)
	hud_labels["charge"] = text_label("",Vector2(inner_x,242),Vector2(inner_width,34),25 if compact_layout else 19,MINT)
	hud_labels["charge_bar"] = resource_bar(Vector2(inner_x,282),inner_width,MINT)
	hud_labels["resolve"] = text_label("",Vector2(inner_x,310),Vector2(inner_width,34),25 if compact_layout else 19,CORAL)
	hud_labels["resolve_bar"] = resource_bar(Vector2(inner_x,350),inner_width,CORAL)
	hud_labels["state"] = text_label("",Vector2(inner_x,382),Vector2(inner_width,54),21 if compact_layout else 17,MUTED)
	hud_labels["warning"] = text_label("",Vector2(inner_x,443),Vector2(inner_width,54),20 if compact_layout else 16,CORAL)
	hud_labels["recovery"] = resource_bar(Vector2(inner_x,506),inner_width,Color("e8b85d"))
	hud_labels["recovery_text"] = text_label("",Vector2(inner_x,523),Vector2(inner_width,54),20 if compact_layout else 16,MINT)
	if not compact_layout:
		text_label("WASD move / SHIFT sneak
SPACE reveal / E recover",Vector2(inner_x,568),Vector2(inner_width,48),13,MUTED)
	var pause_button := button("Pause",Rect2(inner_x,638 if compact_layout else 612,inner_width,44 if compact_layout else 36),show_pause)
	if compact_layout:
		pause_button.position.y = 638
		pause_button.size.y = 44
		pause_button.add_theme_font_size_override("font_size",20)
	if compact_layout:
		hud_labels["toast_bg"] = box(Rect2(20,636,992,56),Color(0.04,0.09,0.12,0.94))
	hud_labels["toast"] = text_label("",Vector2(32,640 if compact_layout else 669),Vector2(964 if compact_layout else 1216,52 if compact_layout else 35),21 if compact_layout else 15,MINT)
	hud_labels["prompt"] = text_label("",Vector2(16 if compact_layout else 32,77 if compact_layout else 84),Vector2(1000 if compact_layout else 850,24),14,CORAL)
	update_hud()

func update_hud() -> void:
	if screen != "game" or hud_labels.is_empty(): return
	hud_labels.records.text = ("NAMES  " if compact_layout else "RECORDS  ")+"%d / 3"%ward.collected
	hud_labels.charge.text = "CHARGE   "+"%03d"%int(ward.battery)+"%"
	hud_labels.resolve.text = "RESOLVE  "+"%03d"%int(maxf(0,ward.health))+"%"
	hud_labels.charge_bar.value = ward.battery
	hud_labels.resolve_bar.value = ward.health
	var recovery_value = ward.get("recovery_progress")
	var recovery := clampf(float(recovery_value) / 0.9,0,1) if recovery_value != null else 0.0
	hud_labels.recovery.value = recovery * 100.0
	hud_labels.recovery.visible = recovery > 0
	hud_labels.recovery_text.text = "RECOVERING %02d%% / stay still" % int(recovery*100) if recovery > 0 else ("PULSE READY" if ward.cooldown <= 0 else "PULSE IN %.1fs" % ward.cooldown)
	hud_labels.state.text = "HIDDEN • E to leave" if ward.is_hiding else ("SPACE / LIGHT READY" if ward.cooldown <= 0 and ward.battery >= 24 else ("LOW CHARGE / find station" if ward.battery < 24 else "Light recovering..."))
	if ward.level in [2,8,9]:
		var remaining := 12.0-fmod(ward.alarm_timer,12.0)
		hud_labels.warning.text = "ALARM ACTIVE • HIDE" if remaining > 10 else "BELL IN %02ds"%int(ceil(remaining))
	else:
		hud_labels.warning.text = "STATION COOLDOWN %02ds"%int(ceil(ward.recharge_timer)) if ward.recharge_timer > 0 else "SPACE REVEALS SEALED NAMES"
	var prompts := {"leave": ["E  Leave cabinet"], "record": ["E  Recover record"], "sealed": ["SPACE  Reveal sealed name • then E"], "exit": ["E  Open hatch / descend"], "locked": ["Hatch sealed • recover 3 records"], "charge": ["E  Recharge • noise attracts shadows"], "hide": ["E  Hide in cabinet"]}
	var key: String = ward.prompt()
	hud_labels.prompt.text = prompts[key][0] if prompts.has(key) else "Gold: records   /   Teal: charger   /   Bottom-right: hatch"
	hud_labels.toast.text = toast if toast_time > 0 else "Every name is a person. Bring them back."
	if compact_layout:
		hud_labels.toast.visible = toast_time > 0
		hud_labels.toast_bg.visible = toast_time > 0

func show_toast(en: String, ko: String) -> void:
	toast = en
	toast_time = 5

func show_pause() -> void:
	clear("pause")
	header("SHIFT SUSPENDED","Take a breath.","The ward is paused. Your checkpoint is the beginning of this ward.")
	button("Resume  →",Rect2(390,196 if compact_layout else 252,500,58),resume,true)
	button("Restart this ward",Rect2(390,308 if compact_layout else 328,500,50),func(): start_ward(ward.level))
	button("Settings",Rect2(390,420 if compact_layout else 396,500,50),func(): show_settings(true))
	button("Return to title",Rect2(390,532 if compact_layout else 464,500,50),show_menu)
	if not compact_layout: text_label("E: use / SPACE: stun / SHIFT: quiet steps. Recharge before a risky crossing.",Vector2(280,566),Vector2(760,80),19,MUTED)

func resume() -> void:
	clear("game")
	build_hud()

func show_failure() -> void:
	clear("failure")
	header("SHIFT INTERRUPTED","Your name is still yours.","The archive can wait one more breath. Restart with full charge and resolve.")
	text_label("Try quiet steps. Hide before the shadows get close.\nA pulse gives you a short opening to escape.",Vector2(300,282),Vector2(700,170),27)
	button("Try this ward again  →",Rect2(390,470 if compact_layout else 494,500,58),func(): start_ward(ward.level),true)
	button("Return to title",Rect2(390,582 if compact_layout else 570,500,46),show_menu)

func on_finished() -> void:
	total_time += elapsed
	if not memories.has(ward.level): memories.append(ward.level)
	unlocked = maxi(unlocked,mini(9,ward.level+1))
	checkpoint = mini(9,ward.level+1)
	save()
	clear("memory")
	header("RECORD RESTORED / %02d"%(ward.level+1),"A person, not a number.")
	box(Rect2(120,226,1040,294))
	text_label(Data.WARDS[ward.level].memory[0],Vector2(164,266),Vector2(952,208),27)
	if ward.level == 9:
		button("Open the final record  >",Rect2(790,614,442,56),show_choice,true)
	else:
		button("Descend to the next ward  >",Rect2(790,614,442,56),func(): show_intro(ward.level+1),true)
	button("Return to title",Rect2(48,624,230,44),show_menu)
	text_label("WARD COMPLETE / CHECKPOINT SAVED",Vector2(124,552),Vector2(1000,32),14,MINT,true)

func show_reset() -> void:
	if profile.is_empty():
		begin_campaign()
		return
	clear("reset")
	header("A FRESH NIGHT","Start a new shift?","This replaces your current ward checkpoint and archive. Your badge and settings stay.")
	button("Keep my progress",Rect2(390,300,500,64),show_menu,true)
	button("Begin a fresh shift",Rect2(390,412 if compact_layout else 394,500,64),func():
		checkpoint=0
		unlocked=0
		memories.clear()
		session_ending=""
		campaign_complete=false
		save()
		show_intro(0))

func show_choice() -> void:
	clear("choice")
	header("THE TENTH PRESCRIPTION","What do you leave behind?","The archive offers silence. Your sister asked you to remember.")
	box(Rect2(100,252,510,278))
	box(Rect2(670,252,510,278))
	text_label("Preserve the names",Vector2(132,284),Vector2(446,64),29,MINT)
	text_label("Let the town remember who was lost.\nSome grief belongs in the light.",Vector2(132,370),Vector2(446,120),20)
	text_label("Erase the records",Vector2(702,284),Vector2(446,64),29,CORAL)
	text_label("End the shift. Lock the cabinet.\nPerhaps forgetting is another kind of night.",Vector2(702,370),Vector2(446,120),20)
	button("Remember  →",Rect2(100,558,510,58),func(): show_ending(true),true)
	button("Forget  →",Rect2(670,558,510,58),func(): show_ending(false))

func show_ending(preserve: bool) -> void:
	clear("ending")
	session_ending = "remember" if preserve else "forget"
	campaign_complete = true
	save()
	header("06:00 / DAWN","The names come home." if preserve else "The bell rings again.")
	text_label("At dawn, you pin thirty names to the pharmacy window.\nThe shadows stop at the glass. For the first time,\nthey do not look hungry. They look known.\n\nYour sister's final prescription was never for medicine.\nIt was for someone to remember." if preserve else "You empty the archive. The hatch closes.\nFor one quiet moment, the pharmacy is only a room.\nThen a blank prescription slides beneath the door.\n\nThere is space for one more name.",Vector2(100,242),Vector2(1100,302),25)
	text_label("AFTERHOURS  -  Created by Shivam Gupta",Vector2(100,562),Vector2(1000,40),18,MINT)
	button("Return to title",Rect2(800,634,432,50),show_menu,true)
	button("Read the archive",Rect2(48,634,260,50),show_archive)

func show_wards() -> void:
	clear("wards")
	if compact_layout:
		show_compact_wards()
		return
	header("THE DESCENT / 10 WARDS","Every floor has a rule.","Complete a ward to unlock the next. Revisit any recovered record in the Archive.")
	for i in 10:
		var col := i%5
		var row := i/5
		var pos := Vector2(48+col*240,236+row*172)
		box(Rect2(pos,Vector2(224,152)))
		text_label("%02d"%(i+1),pos+Vector2(16,10),Vector2(192,30),18,MINT if i <= unlocked else MUTED,true)
		text_label(Data.WARDS[i].title[0],pos+Vector2(16,48),Vector2(194,48),17)
		var b := button("Enter →" if i <= unlocked else "Locked",Rect2(pos+Vector2(12,108),Vector2(200,32)),func(): checkpoint=i; begin_campaign() if profile == "" or not tutorial_done else show_intro(i))
		b.disabled = i > unlocked
	button("← Title",Rect2(48,636,200,44),show_menu)

func show_compact_wards() -> void:
	header("THE DESCENT / 10 WARDS","Every floor has a rule.","Swipe to explore recovered wards. Complete each ward to unlock the next.")
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(48,216)
	scroll.size = Vector2(1184,388)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.add_child(scroll)
	var list := GridContainer.new()
	list.columns = 2
	list.add_theme_constant_override("h_separation",20)
	list.add_theme_constant_override("v_separation",18)
	scroll.add_child(list)
	for i in 10:
		var item := button("%02d / "%(i+1)+Data.WARDS[i].title[0]+("  >" if i<=unlocked else " / LOCKED"),Rect2(0,0,560,96),func(): checkpoint=i; begin_campaign() if profile.is_empty() or not tutorial_done else show_intro(i),i<=unlocked)
		ui.remove_child(item)
		list.add_child(item)
		item.position = Vector2.ZERO
		item.custom_minimum_size = Vector2(560,96)
		item.add_theme_font_size_override("font_size",24)
		item.disabled = i>unlocked
	var back := button("Back to title",Rect2(48,622,400,72),show_menu)
	back.add_theme_font_size_override("font_size",26)

func show_archive() -> void:
	clear("archive")
	header("ARCHIVE / "+"%02d / 10"%memories.size(),"No one was just a number.")
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(48,172)
	scroll.size = Vector2(1184,438)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ui.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",16)
	scroll.add_child(list)
	for i in 10:
		var label := Label.new()
		label.add_theme_font_override("font",font)
		label.add_theme_font_size_override("font_size",20)
		label.add_theme_color_override("font_color",PAPER if memories.has(i) else MUTED)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(1140,140 if memories.has(i) else 80)
		label.text = "%02d  /  "% (i+1)+Data.WARDS[i].title[0]+"\n"+(Data.WARDS[i].memory[0] if memories.has(i) else "Record not yet recovered.")
		list.add_child(label)
	button("← Title",Rect2(48,636,200,44),show_menu)

func show_settings(from_pause: bool = false) -> void:
	settings_from_pause = from_pause
	clear("settings")
	header("SETTINGS / MAKE THE NIGHT YOURS","A little control in the dark.")
	text_label("Master volume",Vector2(90,228),Vector2(500,50),25)
	var slider := HSlider.new()
	slider.position = Vector2(650,246)
	slider.size = Vector2(490,32)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = volume
	slider.value_changed.connect(func(v): volume=v; AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.001))); save())
	ui.add_child(slider)
	text_label("Gentle mode",Vector2(90,318),Vector2(530,40),25)
	text_label("Slower shadows, less damage. Applies on ward entry.",Vector2(90,366),Vector2(650,40),16,MUTED)
	button("ON" if gentle else "OFF",Rect2(920,322,220,48),func(): gentle=not gentle; save(); show_settings(from_pause),gentle)
	text_label("Atmospheric animation",Vector2(90,424),Vector2(650,40),25)
	text_label("Title scanlines, pulse rings, and filament flicker.",Vector2(90,470),Vector2(730,40),16,MUTED)
	button("ON" if motion else "OFF",Rect2(920,426,220,48),func(): motion=not motion; save(); show_settings(from_pause),motion)
	text_label("PROFILE: "+ (profile if profile != "" else " - ")+"  /  Saved on this device",Vector2(90,176),Vector2(1000,40),15,MUTED)
	text_label("High visibility",Vector2(90,534),Vector2(650,40),25)
	text_label("Brighter wards. Keeps all rules and enemy behavior.",Vector2(90,580),Vector2(730,36),16,MUTED)
	button("ON" if high_visibility else "OFF",Rect2(920,536,220,48),func(): high_visibility=not high_visibility; ward.high_visibility=high_visibility; save(); show_settings(from_pause),high_visibility)
	ward.effects = motion
	button("← Back",Rect2(48,636,200,44),show_pause if from_pause else show_menu)

func show_credits() -> void:
	clear("credits")
	header("AFTERHOURS / 2026","The people behind the night.")
	text_label("SHIVAM GUPTA\nCreator and product direction\n\nBuilt with Godot 4.5. Original pixel art and synthesized sound.\nAI-assisted implementation, writing, art, and testing with Codex.\nFonts: Space Grotesk and Space Mono (SIL Open Font License).\n\nFictional story. The shadows are an archive's forgotten names.\nNo real medications, clinical advice, or real patient data.",Vector2(80,216),Vector2(1120,380),23)
	button("← Title",Rect2(48,636,200,44),show_menu)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.physical_keycode == KEY_ESCAPE:
		if screen == "game": show_pause()
		elif screen == "pause": resume()
		elif screen == "settings":
			if settings_from_pause: show_pause()
			else: show_menu()
		elif screen in ["archive","wards","credits"]: show_menu()
	if screen == "game":
		if event.physical_keycode == KEY_E: ward.interact()
		if event.physical_keycode == KEY_SPACE: ward.pulse()

func _process(delta: float) -> void:
	if OS.has_feature("web"):
		browser_emit_timer += delta
		if browser_emit_timer >= 0.1:
			browser_emit_timer = 0
			emit_browser_state()
	if screen == "game":
		elapsed += delta
		update_world_camera()
		toast_time = maxf(0,toast_time-delta)
	if motion and screen == "menu": queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),INK)
	if screen == "menu" and art:
		draw_texture_rect(art,Rect2(0,0,1280,720),false)
		draw_rect(Rect2(0,0,638,720),Color(0.025,0.055,0.075,0.96))
		draw_rect(Rect2(638,0,642,720),Color(0.02,0.04,0.06,0.12))
		if motion:
			for y in range(0,720,4): draw_line(Vector2(638,y),Vector2(1280,y),Color(0,0,0,0.11),1)
	else:
		for x in range(0,1280,32): draw_line(Vector2(x,0),Vector2(x,720),Color(0.2,0.45,0.44,0.025))
		for y in range(0,720,32): draw_line(Vector2(0,y),Vector2(1280,y),Color(0.2,0.45,0.44,0.025))
		draw_line(Vector2(48,710),Vector2(1232,710),Color("29414a"),1)

func browser_command(args: Array) -> void:
	if args.is_empty(): return
	var data = JSON.parse_string(str(args[0]))
	if not data is Dictionary: return
	match str(data.get("command","")):
		"move":
			ward.touch_direction = Vector2(clampf(float(data.get("x",0)),-1,1),clampf(float(data.get("y",0)),-1,1)).limit_length(1)
		"sneak": ward.touch_sneak = bool(data.get("value",false))
		"pulse":
			if screen == "game": ward.pulse()
		"use":
			if screen == "game": ward.interact()
		"pause":
			if screen == "game": show_pause()
			elif screen == "pause": resume()
		"mute":
			browser_muted = bool(data.get("value",false))
			AudioServer.set_bus_mute(0,browser_muted)
		"reset": show_reset()
		"layout":
			var requested := bool(data.get("value",false))
			if requested != compact_layout:
				compact_layout = requested
				if screen == "game":
					clear("game")
					build_hud()
				elif screen == "menu": show_menu()
				elif screen == "wards": show_wards()
				else: configure_world()
	emit_browser_state()

func emit_browser_state() -> void:
	if not OS.has_feature("web") or not is_instance_valid(ward): return
	var state := {"screen":screen,"level":ward.level,"records":ward.collected,"charge":ward.battery,"resolve":ward.health}
	JavaScriptBridge.eval("window.dispatchEvent(new CustomEvent('afterhours-state',{detail:"+JSON.stringify(state)+"}));",true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and screen == "game" and is_instance_valid(ward):
		ward.touch_direction = Vector2.ZERO
		ward.touch_sneak = false
		show_pause()
