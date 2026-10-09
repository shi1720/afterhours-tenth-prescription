extends Node2D
## Application screens, local profile, bilingual copy, and ward checkpoints.
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
var font: Font = preload("res://assets/fonts/NotoSansKR.ttf")
var mono: Font = preload("res://assets/fonts/SpaceMono.ttf")
var art: Texture2D
var lang := 0
var profile := ""
var unlocked := 0
var checkpoint := 0
var memories: Array = []
var tutorial_done := false
var tutorial_step := 0
var tutorial_return := "menu"
var screen := "menu"
var demo := false
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

func t(en: String, ko: String) -> String:
	return en if lang == 0 else ko

func _ready() -> void:
	var weighted := FontVariation.new()
	weighted.base_font = font
	weighted.variation_opentype = {2003265652:450}
	font = weighted
	load_save()
	if ResourceLoader.exists("res://assets/title_art.png"): art = load("res://assets/title_art.png")
	ward = Ward.new()
	add_child(ward)
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
	show_menu()

func save() -> void:
	var c := ConfigFile.new()
	c.set_value("player","name",profile)
	c.set_value("player","unlocked",unlocked)
	c.set_value("player","checkpoint",checkpoint)
	c.set_value("player","memories",memories)
	c.set_value("player","tutorial",tutorial_done)
	c.set_value("player","ending",session_ending)
	c.set_value("settings","language",lang)
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
	lang = clampi(int(c.get_value("settings","language",0)),0,1)
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
	ward.visible = next == "game"
	ward.running = next == "game"
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
	label.add_theme_font_override("font",mono if code and lang == 0 else font)
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
	b.size = rect.size
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font",font)
	b.add_theme_font_size_override("font_size",18)
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

func lang_button() -> void:
	button("한국어" if lang == 0 else "ENGLISH",Rect2(1120,26,112,38),switch_language)

func switch_language() -> void:
	lang = 1-lang
	save()
	match screen:
		"menu": show_menu()
		"profile": show_profile()
		"tutorial": show_tutorial()
		"settings": show_settings(settings_from_pause)
		"archive": show_archive()
		"wards": show_wards()
		"intro": show_intro(intro_index)
		"pause": show_pause()
		_: show_menu()

func show_menu() -> void:
	clear("menu")
	text_label("SHIFT 00:00 — 06:00   /   A PIXEL HORROR",Vector2(54,42),Vector2(800,32),12,MINT,true)
	text_label("AFTER\nHOURS",Vector2(48,110),Vector2(610,200),76,PAPER,true)
	text_label(t("THE TENTH PRESCRIPTION","열 번째 처방전"),Vector2(55,326),Vector2(550,38),20,MINT,true)
	text_label(t("Ten wards. Thirty forgotten names.\nYou are the last pharmacist on duty.","열 개의 병동. 잊힌 서른 명의 이름.\n당신은 마지막 야간 약사입니다."),Vector2(56,384),Vector2(510,78),20,PAPER)
	button(t("Revisit the wards  →","병동 다시 방문  →") if campaign_complete else t("Continue shift  →","근무 계속하기  →") if profile != "" else t("Begin the night  →","밤의 근무 시작  →"),Rect2(56,486,338,54),begin_campaign,true)
	button(t("Play 3-ward demo","3개 병동 체험"),Rect2(56,552,338,44),begin_demo)
	button(t("Ward select","병동 선택"),Rect2(410,486,178,54),show_wards)
	button(t("Archive","기록 보관함"),Rect2(410,552,178,44),show_archive)
	button(t("Settings","설정"),Rect2(56,610,160,40),show_settings)
	button(t("Field guide","안내서"),Rect2(230,610,164,40),open_guide)
	button(t("Credits","제작진"),Rect2(410,610,178,40),show_credits)
	text_label(t("A game by SHIVAM GUPTA","SHIVAM GUPTA의 게임"),Vector2(56,677),Vector2(600,24),12,MUTED,true)
	text_label(t("01—10  /  OFFLINE SAVE", "01—10  /  로컬 저장"),Vector2(950,672),Vector2(280,24),12,MINT,true)
	if profile != "": text_label(t("ON DUTY: ","근무 중: ")+profile,Vector2(740,31),Vector2(350,30),14,MUTED)
	lang_button()

func show_profile() -> void:
	clear("profile")
	header(t("STAFF ACCESS / LOCAL PROFILE","직원 출입 / 로컬 프로필"),t("Your shift starts here.","당신의 근무가 시작됩니다."),t("Choose a name for this device. No email, password, or account required.","이 기기에서 사용할 이름을 정하세요. 이메일, 비밀번호, 계정은 필요 없습니다."))
	box(Rect2(260,236,760,318))
	text_label(t("NAME ON YOUR BADGE","명찰에 표시할 이름"),Vector2(300,266),Vector2(670,30),13,MINT,true)
	var entry := LineEdit.new()
	entry.position = Vector2(300,314)
	entry.size = Vector2(680,56)
	entry.max_length = 20
	entry.placeholder_text = t("Night pharmacist","야간 약사")
	entry.text = profile
	entry.add_theme_font_override("font",font)
	entry.add_theme_font_size_override("font_size",24)
	ui.add_child(entry)
	var submit := func():
		profile = entry.text.strip_edges()
		if profile.is_empty(): profile = t("Night pharmacist","야간 약사")
		save()
		if tutorial_done: show_intro(0 if demo else checkpoint)
		else:
			tutorial_step = 0
			tutorial_return = "start"
			show_tutorial()
	entry.text_submitted.connect(func(_value): submit.call())
	button(t("Clock in  →","출근하기  →"),Rect2(300,400,680,52),submit,true)
	text_label(t("Saved only in this browser or device. Clearing browser data removes progress.","이 브라우저 또는 기기에만 저장됩니다. 브라우저 데이터를 삭제하면 진행 기록이 사라집니다."),Vector2(300,478),Vector2(680,52),14,MUTED)
	button(t("← Back","← 뒤로"),Rect2(48,636,160,44),show_menu)
	entry.grab_focus()
	lang_button()

func begin_campaign() -> void:
	demo = false
	if profile == "": show_profile()
	elif not tutorial_done:
		tutorial_step = 0
		tutorial_return = "start"
		show_tutorial()
	elif campaign_complete: show_wards()
	else: show_intro(checkpoint)

func begin_demo() -> void:
	demo = true
	if profile == "": show_profile()
	elif not tutorial_done:
		tutorial_step = 0
		tutorial_return = "start"
		show_tutorial()
	else: show_intro(0)

func open_guide() -> void:
	tutorial_step = 0
	tutorial_return = "menu"
	show_tutorial()

func show_tutorial() -> void:
	clear("tutorial")
	var titles := [["Welcome to the night shift","야간 근무에 오신 것을 환영합니다"],["Find the forgotten records","잊힌 기록을 찾으세요"],["Light buys you time","빛으로 시간을 버세요"],["Silence is a hiding place","조용히 몸을 숨기세요"],["Make it to the hatch","출구로 향하세요"],["A night worth remembering","기억할 가치가 있는 밤"]]
	var bodies := [["Move with WASD or arrow keys. This is a game of routes, patience, and listening. Headphones help, but every warning is also visible.","WASD 또는 방향키로 이동합니다. 길을 찾고, 기다리며, 소리에 귀 기울이세요. 모든 경고는 화면에도 표시됩니다."],["Three sealed gold records wait in each ward. Use SPACE nearby to reveal a name, then E to recover it. Gold glints stay visible in the dark.","각 병동에는 봉인된 금빛 기록 세 개가 있습니다. 가까이서 스페이스 키로 이름을 밝힌 후 E 키로 회수하세요. 금빛은 어둠 속에서도 보입니다."],["Press SPACE to release a light pulse. It stuns nearby shadows for 4.5 seconds and costs 18 charge. Teal stations refill charge and some resolve — but the sound draws attention.","스페이스 키로 빛을 방출하세요. 주변 그림자가 4.5초 멈추고 충전량 18을 씁니다. 청록색 충전소는 충전량과 의지를 회복하지만 소리가 그림자를 부릅니다."],["Hold SHIFT to walk quietly. Press E beside a tall cabinet to hide, then E again to leave. Shadows cannot touch you while hidden.","SHIFT 키를 누르면 조용히 걷습니다. 높은 수납장 옆에서 E 키로 숨고, 다시 눌러 나옵니다. 숨어 있으면 그림자가 닿지 못합니다."],["Recover all three records, then press E at the hatch in the lower-right corner. Each new ward introduces a different survival rule. Read it before entering.","기록 세 개를 모두 찾고 오른쪽 아래 출구에서 E 키를 누르세요. 새 병동마다 다른 생존 규칙이 있습니다. 입장 전에 읽어 보세요."],["ESC pauses the night. The Archive keeps recovered stories. Progress saves after each ward. Settings include volume, Korean / English, and a gentler mode. You can replay this guide anytime.","ESC 키로 일시 정지합니다. 기록 보관함에서 이야기를 읽으세요. 병동을 마칠 때마다 저장됩니다. 설정에서 음량, 언어, 완화 모드를 바꾸고 안내서를 다시 볼 수 있습니다."]]
	header(t("FIELD GUIDE / ","안내서 / ")+"%02d OF 06"%(tutorial_step+1),titles[tutorial_step][lang])
	box(Rect2(48,206,1184,360))
	text_label(["W A S D","E  /  03","SPACE","SHIFT + E","E  →","ESC"][tutorial_step],Vector2(96,258),Vector2(420,110),45,MINT,true)
	text_label(t("LEARN THE RULE.\nKEEP YOUR NAME.","규칙을 익히세요.\n이름을 지키세요."),Vector2(100,399),Vector2(360,100),18,MUTED,true)
	text_label(bodies[tutorial_step][lang],Vector2(558,262),Vector2(605,240),25,PAPER)
	for i in 6: box(Rect2(48+i*47,597,34,4),MINT if i <= tutorial_step else Color("29414a"),Color.TRANSPARENT)
	if tutorial_step > 0: button(t("← Previous","← 이전"),Rect2(48,636,170,48),func(): tutorial_step-=1; show_tutorial())
	button(t("Skip guide","건너뛰기"),Rect2(828,636,180,48),finish_tutorial)
	button(t("Clock in  →","출근하기  →") if tutorial_step == 5 else t("Next  →","다음  →"),Rect2(1024,636,208,48),func():
		if tutorial_step == 5: finish_tutorial()
		else: tutorial_step+=1; show_tutorial(),true)
	lang_button()

func finish_tutorial() -> void:
	tutorial_done = true
	save()
	if tutorial_return == "start": show_intro(0 if demo else checkpoint)
	else: show_menu()

func show_intro(index: int) -> void:
	intro_index = index
	clear("intro")
	var data: Dictionary = Data.WARDS[index]
	header(t("DESCENT / WARD ","하강 / 병동 ")+"%02d / 10"%(index+1),data.title[lang],data.patient[lang])
	text_label("%02d"%(index+1),Vector2(60,230),Vector2(350,200),138,Color("254b50"),true)
	box(Rect2(450,236,782,242))
	text_label(t("SURVIVAL RULE","생존 규칙"),Vector2(486,261),Vector2(690,30),13,MINT,true)
	text_label(data.rule[lang],Vector2(486,308),Vector2(690,132),25)
	text_label(t("SPACE reveals → E recovers → 3 records → hatch","스페이스로 밝히기 → E로 기록 3개 회수 → 출구"),Vector2(450,512),Vector2(770,50),18,MUTED)
	button(t("Enter ward  →","병동 입장  →"),Rect2(824,624,408,56),func(): start_ward(index),true)
	button(t("← Return","← 돌아가기"),Rect2(48,636,184,44),show_menu)
	lang_button()

func start_ward(index: int) -> void:
	clear("game")
	ward.effects = motion
	ward.high_visibility = high_visibility
	ward.start(index,gentle)
	elapsed = 0
	toast = ""
	if not ambience.playing and ambience.stream: ambience.play()
	build_hud()

func build_hud() -> void:
	text_label("AFTERHOURS",Vector2(32,22),Vector2(600,32),22,MINT,true)
	text_label(t("WARD ","병동 ")+"%02d / 10"%(ward.level+1)+"  ·  "+Data.WARDS[ward.level].title[lang],Vector2(32,62),Vector2(880,34),18,PAPER)
	box(Rect2(928,112,320,544))
	text_label(t("NIGHT SHIFT","야간 근무"),Vector2(952,133),Vector2(272,28),12,MINT,true)
	hud_labels["records"] = text_label("",Vector2(952,177),Vector2(272,53),26)
	hud_labels["charge"] = text_label("",Vector2(952,249),Vector2(272,40),18,MINT)
	hud_labels["resolve"] = text_label("",Vector2(952,300),Vector2(272,40),18,CORAL)
	hud_labels["state"] = text_label("",Vector2(952,350),Vector2(272,40),14,MUTED)
	hud_labels["warning"] = text_label("",Vector2(952,385),Vector2(272,28),13,CORAL)
	box(Rect2(952,418,272,1),Color("36515a"),Color.TRANSPARENT)
	text_label(t("WASD / ↑↓←→   Move\nSHIFT   Quiet steps\nSPACE   Light pulse\nE   Recover / Hide / Use\nESC   Pause", "WASD / 방향키   이동\nSHIFT   조용히 걷기\n스페이스   빛 방출\nE   회수 / 숨기 / 사용\nESC   일시 정지"),Vector2(952,438),Vector2(272,156),15,MUTED)
	button(t("Pause  Ⅱ","일시 정지  Ⅱ"),Rect2(952,594,272,40),show_pause)
	hud_labels["toast"] = text_label("",Vector2(32,669),Vector2(1216,35),16,MINT)
	hud_labels["prompt"] = text_label("",Vector2(32,84),Vector2(850,24),13,CORAL)
	update_hud()

func update_hud() -> void:
	if screen != "game" or hud_labels.is_empty(): return
	hud_labels.records.text = t("RECORDS  ","기록  ")+"%d / 3"%ward.collected
	hud_labels.charge.text = t("CHARGE   ","충전량   ")+"%03d"%int(ward.battery)+"%"
	hud_labels.resolve.text = t("RESOLVE  ","의지     ")+"%03d"%int(maxf(0,ward.health))+"%"
	hud_labels.state.text = t("HIDDEN • E to leave","숨음 • E 키로 나가기") if ward.is_hiding else (t("LIGHT READY • SPACE","빛 준비 완료 • 스페이스") if ward.cooldown <= 0 and ward.battery >= 18 else (t("LOW CHARGE • find teal station","충전 부족 • 청록색 충전소") if ward.battery < 18 else t("Light recovering…","빛 회복 중…")))
	if ward.level in [2,8,9]:
		var remaining := 12.0-fmod(ward.alarm_timer,12.0)
		hud_labels.warning.text = t("ALARM ACTIVE • HIDE","경보 작동 • 숨으세요") if remaining > 10 else t("BELL IN %02ds","종까지 %02d초")%int(ceil(remaining))
	else:
		hud_labels.warning.text = t("STATION COOLDOWN %02ds","충전소 대기 %02d초")%int(ceil(ward.recharge_timer)) if ward.recharge_timer > 0 else t("SPACE REVEALS SEALED NAMES","스페이스로 봉인된 이름 밝히기")
	var prompts := {"leave":["E  Leave cabinet","E  수납장에서 나오기"],"record":["E  Recover record","E  기록 회수"],"sealed":["SPACE  Reveal sealed name • then E","스페이스  이름 밝히기 • 다음 E"],"exit":["E  Open hatch / descend","E  출구 열기 / 내려가기"],"locked":["Hatch sealed • recover 3 records","출구 잠김 • 기록 3개 필요"],"charge":["E  Recharge • noise attracts shadows","E  충전 • 소리가 그림자를 부릅니다"],"hide":["E  Hide in cabinet","E  수납장에 숨기"]}
	var key: String = ward.prompt()
	hud_labels.prompt.text = prompts[key][lang] if prompts.has(key) else t("Gold: records   /   Teal: charger   /   Bottom-right: hatch","금빛: 기록   /   청록색: 충전소   /   오른쪽 아래: 출구")
	hud_labels.toast.text = toast if toast_time > 0 else (t("DEMO / FIRST THREE WARDS","체험판 / 첫 세 병동") if demo else t("Every name is a person. Bring them back.","이름마다 한 사람이 있습니다. 그들을 되찾으세요."))

func show_toast(en: String, ko: String) -> void:
	toast = t(en,ko)
	toast_time = 5

func show_pause() -> void:
	clear("pause")
	header(t("SHIFT SUSPENDED","근무 일시 정지"),t("Take a breath.","잠시 숨을 고르세요."),t("The ward is paused. Your checkpoint is the beginning of this ward.","병동이 멈췄습니다. 체크포인트는 이 병동의 시작 지점입니다."))
	button(t("Resume  →","계속하기  →"),Rect2(390,252,500,58),resume,true)
	button(t("Restart this ward","이 병동 다시 시작"),Rect2(390,328,500,50),func(): start_ward(ward.level))
	button(t("Settings","설정"),Rect2(390,396,500,50),func(): show_settings(true))
	button(t("Return to title","제목 화면으로"),Rect2(390,464,500,50),show_menu)
	text_label(t("E: use / SPACE: stun / SHIFT: quiet steps. Recharge before a risky crossing.","E: 사용 / 스페이스: 멈추기 / SHIFT: 조용한 이동. 위험한 통로 전에 충전하세요."),Vector2(280,566),Vector2(760,80),19,MUTED)

func resume() -> void:
	clear("game")
	build_hud()

func show_failure() -> void:
	clear("failure")
	header(t("SHIFT INTERRUPTED","근무 중단"),t("Your name is still yours.","당신의 이름은 아직 당신의 것입니다."),t("The archive can wait one more breath. Restart with full charge and resolve.","기록은 조금 더 기다릴 수 있습니다. 충전량과 의지를 회복하고 다시 시작하세요."))
	text_label(t("Try quiet steps. Hide before the shadows get close.\nA pulse gives you 4.5 seconds to make distance.","조용히 걸으세요. 그림자가 다가오기 전에 숨으세요.\n빛을 방출하면 4.5초 동안 거리를 벌릴 수 있습니다."),Vector2(300,282),Vector2(700,170),27)
	button(t("Try this ward again  →","이 병동 다시 도전  →"),Rect2(390,494,500,58),func(): start_ward(ward.level),true)
	button(t("Return to title","제목 화면으로"),Rect2(390,570,500,46),show_menu)

func on_finished() -> void:
	total_time += elapsed
	if not demo:
		if not memories.has(ward.level): memories.append(ward.level)
		unlocked = maxi(unlocked,mini(9,ward.level+1))
		checkpoint = mini(9,ward.level+1)
		save()
	clear("memory")
	header(t("RECORD RESTORED / ","기록 복구 / ")+"%02d"%(ward.level+1),t("A person, not a number.","숫자가 아닌, 한 사람."))
	box(Rect2(120,226,1040,294))
	text_label(Data.WARDS[ward.level].memory[lang],Vector2(164,266),Vector2(952,208),27)
	if ward.level == 9:
		button(t("Open the final record  →","마지막 기록 열기  →"),Rect2(790,614,442,56),show_choice,true)
	elif demo and ward.level == 2:
		button(t("Finish demo  →","체험 마치기  →"),Rect2(790,614,442,56),show_demo_end,true)
	else: button(t("Descend to the next ward  →","다음 병동으로 내려가기  →"),Rect2(790,614,442,56),func(): show_intro(ward.level+1),true)
	button(t("Return to title","제목 화면으로"),Rect2(48,624,230,44),show_menu)
	text_label(t("WARD COMPLETE • CHECKPOINT SAVED","병동 완료 • 체크포인트 저장됨") if not demo else t("DEMO • campaign save preserved","체험판 • 본편 진행 유지"),Vector2(124,552),Vector2(1000,32),14,MINT,true)

func show_demo_end() -> void:
	clear("demo_end")
	header(t("PROLOGUE COMPLETE","서막 완료"),t("Seven wards still remember you.","일곱 병동이 아직 당신을 기억합니다."),t("You completed the three-ward demo. The full ten-ward campaign is included in this jam edition.","세 병동 체험을 마쳤습니다. 이 게임잼 버전에는 열 병동의 본편이 포함되어 있습니다."))
	text_label(t("The bell has not stopped ringing.","종소리는 아직 멈추지 않았습니다."),Vector2(180,310),Vector2(920,150),36,MINT)
	button(t("Start the full campaign  →","본편 시작  →"),Rect2(390,490,500,58),begin_campaign,true)
	button(t("Return to title","제목 화면으로"),Rect2(390,568,500,48),show_menu)

func show_choice() -> void:
	clear("choice")
	header(t("THE TENTH PRESCRIPTION","열 번째 처방전"),t("What do you leave behind?","무엇을 남기겠습니까?"),t("The archive offers silence. Your sister asked you to remember.","기록 보관소는 침묵을 제안합니다. 누나는 기억해 달라고 부탁했습니다."))
	box(Rect2(100,252,510,278))
	box(Rect2(670,252,510,278))
	text_label(t("Preserve the names","이름을 보존한다"),Vector2(132,284),Vector2(446,64),29,MINT)
	text_label(t("Let the town remember who was lost.\nSome grief belongs in the light.","마을이 잃어버린 사람들을 기억하게 합니다.\n어떤 슬픔은 빛 속에 남아야 합니다."),Vector2(132,370),Vector2(446,120),20)
	text_label(t("Erase the records","기록을 지운다"),Vector2(702,284),Vector2(446,64),29,CORAL)
	text_label(t("End the shift. Lock the cabinet.\nPerhaps forgetting is another kind of night.","근무를 끝내고 수납장을 잠급니다.\n망각도 또 다른 밤일지 모릅니다."),Vector2(702,370),Vector2(446,120),20)
	button(t("Remember  →","기억한다  →"),Rect2(100,558,510,58),func(): show_ending(true),true)
	button(t("Forget  →","잊는다  →"),Rect2(670,558,510,58),func(): show_ending(false))

func show_ending(preserve: bool) -> void:
	clear("ending")
	session_ending = "remember" if preserve else "forget"
	if not demo:
		campaign_complete = true
		save()
	header(t("06:00 / DAWN","06:00 / 새벽"),t("The names come home.","이름들이 돌아옵니다.") if preserve else t("The bell rings again.","종이 다시 울립니다."))
	text_label(t("At dawn, you pin thirty names to the pharmacy window.\nThe shadows stop at the glass. For the first time,\nthey do not look hungry. They look known.\n\nYour sister's final prescription was never for medicine.\nIt was for someone to remember.","새벽, 당신은 약국 창문에 서른 명의 이름을 붙입니다.\n그림자들이 유리 앞에 멈춥니다. 처음으로,\n그들은 굶주려 보이지 않습니다. 기억된 사람처럼 보입니다.\n\n누나의 마지막 처방전은 약을 위한 것이 아니었습니다.\n누군가가 기억해 주기를 바랐던 것입니다.") if preserve else t("You empty the archive. The hatch closes.\nFor one quiet moment, the pharmacy is only a room.\nThen a blank prescription slides beneath the door.\n\nThere is space for one more name.","기록을 비우자 출구가 닫힙니다.\n잠깐의 고요 속에서 약국은 그저 방이 됩니다.\n그러다 빈 처방전 한 장이 문 아래로 밀려옵니다.\n\n아직 이름 하나가 더 들어갈 자리가 있습니다."),Vector2(100,242),Vector2(1100,302),25)
	text_label(t("AFTERHOURS — Created by Shivam Gupta","AFTERHOURS — 제작 Shivam Gupta"),Vector2(100,562),Vector2(1000,40),18,MINT)
	button(t("Return to title","제목 화면으로"),Rect2(800,634,432,50),show_menu,true)
	button(t("Read the archive","기록 보관함 읽기"),Rect2(48,634,260,50),show_archive)

func show_wards() -> void:
	clear("wards")
	header(t("THE DESCENT / 10 WARDS","하강 / 열 병동"),t("Every floor has a rule.","모든 층에는 규칙이 있습니다."),t("Complete a ward to unlock the next. Revisit any recovered record in the Archive.","병동을 완료하면 다음 병동이 열립니다. 되찾은 이야기는 기록 보관함에서 다시 읽을 수 있습니다."))
	for i in 10:
		var col := i%5
		var row := i/5
		var pos := Vector2(48+col*240,236+row*172)
		box(Rect2(pos,Vector2(224,152)))
		text_label("%02d"%(i+1),pos+Vector2(16,10),Vector2(192,30),18,MINT if i <= unlocked else MUTED,true)
		text_label(Data.WARDS[i].title[lang],pos+Vector2(16,48),Vector2(194,48),17)
		var b := button(t("Enter →","입장 →") if i <= unlocked else t("Locked","잠김"),Rect2(pos+Vector2(12,108),Vector2(200,32)),func(): demo=false; checkpoint=i; begin_campaign() if profile == "" or not tutorial_done else show_intro(i))
		b.disabled = i > unlocked
	button(t("← Title","← 제목 화면"),Rect2(48,636,200,44),show_menu)
	lang_button()

func show_archive() -> void:
	clear("archive")
	header(t("ARCHIVE / ","기록 보관함 / ")+"%02d / 10"%memories.size(),t("No one was just a number.","누구도 단지 숫자가 아니었습니다."))
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
		label.text = "%02d  /  "% (i+1)+Data.WARDS[i].title[lang]+"\n"+(Data.WARDS[i].memory[lang] if memories.has(i) else t("Record not yet recovered.","아직 찾지 못한 기록입니다."))
		list.add_child(label)
	button(t("← Title","← 제목 화면"),Rect2(48,636,200,44),show_menu)
	lang_button()

func show_settings(from_pause: bool = false) -> void:
	settings_from_pause = from_pause
	clear("settings")
	header(t("SETTINGS / MAKE THE NIGHT YOURS","설정 / 나만의 밤"),t("A little control in the dark.","어둠 속 작은 통제권."))
	text_label(t("Master volume","전체 음량"),Vector2(90,228),Vector2(500,50),25)
	var slider := HSlider.new()
	slider.position = Vector2(650,246)
	slider.size = Vector2(490,32)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = volume
	slider.value_changed.connect(func(v): volume=v; AudioServer.set_bus_volume_db(0,linear_to_db(maxf(volume,0.001))); save())
	ui.add_child(slider)
	text_label(t("Gentle mode","완화 모드"),Vector2(90,318),Vector2(530,40),25)
	text_label(t("Slower shadows, less damage. Applies on ward entry.","느린 그림자, 적은 피해. 병동 입장 시 적용됩니다."),Vector2(90,366),Vector2(650,40),16,MUTED)
	button(t("ON","켜짐") if gentle else t("OFF","꺼짐"),Rect2(920,322,220,48),func(): gentle=not gentle; save(); show_settings(from_pause),gentle)
	text_label(t("Atmospheric animation","분위기 애니메이션"),Vector2(90,424),Vector2(650,40),25)
	text_label(t("Title scanlines, pulse rings, and filament flicker.","제목 주사선, 빛의 고리, 필라멘트 깜박임 효과."),Vector2(90,470),Vector2(730,40),16,MUTED)
	button(t("ON","켜짐") if motion else t("OFF","꺼짐"),Rect2(920,426,220,48),func(): motion=not motion; save(); show_settings(from_pause),motion)
	text_label(t("PROFILE: ","프로필: ")+ (profile if profile != "" else "—")+t("  /  Saved on this device","  /  이 기기에 저장됨"),Vector2(90,176),Vector2(1000,40),15,MUTED)
	text_label(t("High visibility","높은 가시성"),Vector2(90,534),Vector2(650,40),25)
	text_label(t("Brighter wards. Keeps all rules and enemy behavior.","더 밝은 병동. 규칙과 그림자의 행동은 그대로 유지됩니다."),Vector2(90,580),Vector2(730,36),16,MUTED)
	button(t("ON","켜짐") if high_visibility else t("OFF","꺼짐"),Rect2(920,536,220,48),func(): high_visibility=not high_visibility; ward.high_visibility=high_visibility; save(); show_settings(from_pause),high_visibility)
	ward.effects = motion
	button(t("← Back","← 뒤로"),Rect2(48,636,200,44),show_pause if from_pause else show_menu)
	lang_button()

func show_credits() -> void:
	clear("credits")
	header("AFTERHOURS / 2026",t("The people behind the night.","밤을 만든 사람들."))
	text_label(t("SHIVAM GUPTA\nCreator • product direction • game-jam entrant\n\nBuilt with Godot 4.5. Original procedural pixel art and synthesized sound.\nAI-assisted implementation, writing, art, and testing with Codex.\nFonts: Noto Sans KR and Space Mono (SIL Open Font License).\n\nFictional story. The shadows are an archive's forgotten names.\nNo real medications, clinical advice, or real patient data.","SHIVAM GUPTA\n창작자 • 제품 방향 • 게임잼 참가자\n\nGodot 4.5로 제작. 자체 제작 픽셀 아트와 합성 사운드.\nCodex의 도움으로 구현, 글쓰기, 아트, 테스트를 진행했습니다.\n글꼴: Noto Sans KR, Space Mono (SIL Open Font License).\n\n허구의 이야기입니다. 그림자는 기록에서 잊힌 이름들입니다.\n실제 약물, 의료 조언, 실제 환자 정보는 포함하지 않습니다."),Vector2(80,216),Vector2(1120,380),23)
	button(t("← Title","← 제목 화면"),Rect2(48,636,200,44),show_menu)

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
	if screen == "game":
		elapsed += delta
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
