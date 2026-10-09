extends SceneTree
## Run: Godot --headless --path . --script tests/test_game.gd
## Saves are backed up byte-for-byte and restored before this process exits.
const Ward = preload("res://scripts/ward.gd")
const Main = preload("res://scripts/main.gd")
const Data = preload("res://scripts/levels.gd")
var checks := 0
var failures: Array[String] = []
var finished_count := 0
var caught_count := 0
var had_save := false
var prior_save := PackedByteArray()

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		print("FAIL: ", label)

func fresh(ward: Node, index: int = 0) -> void:
	ward.start(index)
	ward.test_mode = true
	ward.move_override = Vector2.ZERO
	ward.set_process(false)

func check_labels(app: Node, context: String) -> void:
	# Direct UI labels; archive content is deliberately scrollable and excluded.
	for child in app.ui.get_children():
		if child is Label and child.visible:
			var rect: Rect2 = child.get_global_rect()
			check(rect.position.x >= -1 and rect.position.y >= -1 and rect.end.x <= 1281 and rect.end.y <= 721, context+" label inside viewport "+str(rect)+": "+child.text.left(32))
			check(child.get_line_count()*child.get_line_height() <= rect.size.y+2, context+" label lines fit height: "+child.text.left(32))

func stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer: node.stop()
	for child in node.get_children(): stop_audio(child)

func run() -> void:
	print("AFTERHOURS deterministic simulation and application integration QA")
	root.size = Vector2i(1280,720)
	var save_path := "user://afterhours.cfg"
	had_save = FileAccess.file_exists(save_path)
	if had_save: prior_save = FileAccess.get_file_as_bytes(save_path)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	var w = Ward.new()
	root.add_child(w)
	w.finished.connect(func(): finished_count += 1)
	w.caught.connect(func(): caught_count += 1)
	check(Data.WARDS.size() == 10, "Ten authored wards exist")
	for i in 10:
		fresh(w,i)
		check(w.level == i and w.collected == 0 and w.health == 100 and w.battery == 100, "Ward %d clean reset" % (i+1))
		check(w.fragments.size() == 3 and w.revealed.is_empty(), "Ward %d starts with three sealed records" % (i+1))
		var interactables: Array = [w.player,w.station,w.hatch]
		interactables.append_array(w.fragments)
		interactables.append_array(w.cabinets)
		for e in w.enemies: interactables.append(e.pos)
		for j in interactables.size():
			var point: Vector2 = interactables[j]
			check(w.passable(point), "Ward %d object/spawn %d has physical clearance" % [i+1,j])
			check(not w.astar.get_id_path(w.cell(w.player),w.cell(point)).is_empty(), "Ward %d object/spawn %d reachable" % [i+1,j])
		var reachable := 0
		var walkable := 0
		for y in w.H:
			for x in w.W:
				if w.grid[y][x] == 0:
					walkable += 1
					if not w.astar.get_id_path(w.cell(w.player),Vector2i(x,y)).is_empty(): reachable += 1
		check(reachable == walkable, "Ward %d entire floor connected (%d/%d)" % [i+1,reachable,walkable])
		for c in w.hazards: check(w.grid[c.y][c.x] == 0, "Ward %d hazard on walkable tile" % (i+1))
		check(not w.passable(Vector2(0,0)), "Ward %d boundary collision" % (i+1))
		for key in ["title","rule","memory","patient"]:
			check(Data.WARDS[i][key].size() == 2 and not Data.WARDS[i][key][0].is_empty() and not Data.WARDS[i][key][1].is_empty(), "Ward %d bilingual %s" % [i+1,key])
		# Traverse a real path by applying movement at 60Hz (enemies isolated for geometry test).
		w.enemies.clear()
		var path: PackedVector2Array = w.astar.get_point_path(w.cell(w.player),w.cell(w.hatch))
		for point in path:
			var limit := 0
			while w.player.distance_to(point) > 1.5 and limit < 100:
				w.move_override = w.player.direction_to(point)
				w.step(1.0/60.0)
				limit += 1
			check(limit < 100 and w.passable(w.player), "Ward %d physical route segment %s" % [i+1,point])
		w.move_override = Vector2.ZERO
		check(w.player.distance_to(w.hatch) < 2, "Ward %d physical traversal reaches exit" % (i+1))
		w.interact()
		check(w.running and finished_count == i, "Ward %d locked exit rejects missing records" % (i+1))
		for point in w.fragments.duplicate():
			w.player = point
			check(w.prompt() == "sealed", "Ward %d sealed record proximity prompt" % (i+1))
			var previous_count: int = w.collected
			w.interact()
			check(w.collected == previous_count, "Ward %d sealed record rejects pickup" % (i+1))
			w.cooldown = 0 # Isolate interaction contract; full run below uses actual cooldown.
			w.pulse()
			check(w.revealed.has(point), "Ward %d pulse reveals nearby record" % (i+1))
			check(w.prompt() == "record", "Ward %d record proximity prompt" % (i+1))
			w.interact()
		check(w.collected == 3 and w.fragments.is_empty(), "Ward %d all records recovered exactly once" % (i+1))
		w.player = w.hatch
		w.interact()
		w.interact()
		check(not w.running and finished_count == i+1, "Ward %d completion signal exactly once" % (i+1))
	# Collision under continuous attempted movement.
	fresh(w)
	w.enemies.clear()
	w.player = w.center(Vector2i(5,3))
	w.move_override = Vector2.RIGHT
	for n in 120: w.step(1.0/60.0)
	check(w.player.x < 6*32-7 and w.passable(w.player), "Player cannot walk through shelving")
	w.player = w.center(Vector2i(1,1))
	w.move_override = Vector2.LEFT
	for n in 120: w.step(1.0/60.0)
	check(w.player.x >= 39 and w.passable(w.player), "Player cannot walk through outer wall")
	# Pulse radius, charge, cooldown, resource rejection, hiding rejection.
	fresh(w)
	w.enemies[0].pos = w.player+Vector2(50,0)
	w.pulse()
	check(w.battery == 82 and w.cooldown == 1.8 and w.enemies[0].stun == 4.5, "Pulse consumes 18 charge and stuns nearby enemy for 4.5 sec")
	w.pulse()
	check(w.battery == 82, "Cooldown rejects pulse spam")
	var enemy_before: Vector2 = w.enemies[0].pos
	w.step(0.5)
	check(w.enemies[0].pos == enemy_before and is_equal_approx(w.enemies[0].stun,4.0), "Stunned enemy remains still; timer expires")
	w.cooldown = 0
	w.battery = 17
	w.pulse()
	check(w.battery == 17 and w.cooldown == 0, "Insufficient charge rejects pulse")
	w.battery = 100
	w.is_hiding = true
	w.pulse()
	check(w.battery == 100, "Hidden player cannot pulse")
	# Cabinet interaction, damage protection, frozen movement.
	fresh(w)
	w.player = w.cabinets[0]
	w.interact()
	check(w.is_hiding and w.prompt() == "leave", "Cabinet enters hiding state")
	w.enemies[0].pos = w.player
	w.invincible = 0
	w.move_override = Vector2.RIGHT
	var hidden_pos: Vector2 = w.player
	w.step(0.1)
	check(w.health == 100 and w.player == hidden_pos, "Hiding protects from enemy and prevents movement")
	w.interact()
	check(not w.is_hiding, "Second interaction leaves hiding")
	w.enemies[0].pos = w.player
	w.enemies[0].stun = 0
	w.move_override = Vector2.ZERO
	w.step(0.1)
	check(w.health == 66 and w.invincible > 0, "Enemy contact damages and grants grace interval")
	w.step(0.1)
	check(w.health == 66, "Grace interval prevents consecutive contact damage")
	# Enemy follows valid A* route; no tunneling through obstacles.
	fresh(w,9)
	w.is_hiding = true
	var initial: Vector2 = w.enemies[0].pos
	for n in 1200:
		w.step(1.0/60.0)
		for e in w.enemies: check(not w.astar.is_point_solid(w.cell(e.pos)), "Enemy remains on walkable cells")
	check(w.enemies[0].pos.distance_to(initial) > 32, "Enemy patrol actually advances")
	# Chasing recomputes a moving target; same-cell chase advances without an A* hop.
	fresh(w)
	w.player = w.center(Vector2i(23,2))
	w.step(0.1)
	check(w.enemies[0].alert > 0, "Nearby player triggers chase")
	w.player = w.center(Vector2i(21,2))
	for n in 40: w.step(1.0/60.0)
	check(w.enemies[0].target == w.player and w.enemies[0].path.size() > 0 and w.enemies[0].path[-1] == w.player, "Chasing replans route to moved player")
	w.enemies[0].pos = w.player+Vector2(12,0)
	w.enemies[0].stun = 0
	w.enemies[0].repath = 0
	w.invincible = 10
	var close_distance: float = w.enemies[0].pos.distance_to(w.player)
	w.step(0.1)
	check(w.enemies[0].pos.distance_to(w.player) < close_distance, "Enemy pursues player within same grid cell")
	fresh(w,2)
	w.player = w.center(Vector2i(2,2))
	w.alarm_timer = 11.99
	w.step(0.02)
	check(w.enemies[0].target == w.player and w.enemies[0].alert > 0, "Alarm attracts enemy across the entire ward")
	# Hazard phases, gentle scaling, low-power ward battery drain, recharge.
	fresh(w,3)
	w.enemies.clear()
	w.player = w.center(w.hazards[0])
	w.step(0.1)
	check(is_equal_approx(w.health,98.7), "Active hazard deals 13 damage/sec")
	w.time = 1.3
	var before_health: float = w.health
	w.step(0.1)
	check(w.health == before_health, "Inactive hazard phase deals no damage")
	w.gentle = true
	w.time = 0
	w.step(0.1)
	check(is_equal_approx(w.health,before_health-0.6), "Gentle hazard deals 6 damage/sec")
	fresh(w,5)
	w.enemies.clear()
	w.step(1)
	check(is_equal_approx(w.battery,98.75), "Blackout ward drains 1.25 charge/sec")
	w.player = w.station
	w.battery = 12
	w.health = 50
	w.interact()
	check(w.battery == 100 and w.health == 75 and w.recharge_timer == 10, "Station refills charge and restores 25 resolve")
	w.battery = 50
	w.interact()
	check(w.battery == 50 and w.health == 75, "Station cooldown prevents repeat refill")
	fresh(w)
	w.health = 1
	w.invincible = 0
	w.enemies[0].pos = w.player
	w.step(0.01)
	check(not w.running and caught_count == 1 and w.deaths > 0, "Lethal contact emits failure and stops simulation")
	w._process(1)
	check(caught_count == 1, "Stopped simulation emits no duplicate failure")
	# Full objective route with active enemies, hazards and normal resource rules.
	# Deterministic pilot chooses shortest record order and pulses nearby enemies.
	for index in 10:
		fresh(w,index)
		var reached := true
		var active_steps := 0
		for objective in 4:
			var destination: Vector2 = w.hatch
			if not w.fragments.is_empty():
				var shortest := 99999
				for record in w.fragments:
					var length: int = w.astar.get_id_path(w.cell(w.player),w.cell(record)).size()
					if length < shortest:
						shortest = length
						destination = record
			var route: PackedVector2Array = w.astar.get_point_path(w.cell(w.player),w.cell(destination))
			for point in route:
				var limit := 0
				while w.player.distance_to(point) > 1.5 and limit < 100 and w.running:
					w.move_override = w.player.direction_to(point)
					for enemy in w.enemies:
						if enemy.pos.distance_to(w.player) < 100 and enemy.stun < 0.15: w.pulse()
					w.step(1.0/60.0)
					limit += 1
					active_steps += 1
				if limit >= 100 or not w.running:
					reached = false
					break
			w.move_override = Vector2.ZERO
			if not reached: break
			if w.fragments.has(destination) and not w.revealed.has(destination):
				while w.cooldown > 0 and w.running:
					w.step(1.0/60.0)
					active_steps += 1
				w.pulse()
			w.interact()
		check(reached and w.collected == 3 and not w.running and w.health > 0, "Ward %d normal-mode active-enemy full traversal succeeds" % (index+1))
		print("PLAYTHROUGH ward=%02d seconds=%.2f resolve=%.1f charge=%.1f records=%d" % [index+1,active_steps/60.0,w.health,w.battery,w.collected])
	stop_audio(w)
	await create_timer(0.05).timeout
	w.queue_free()
	await process_frame
	await test_application()
	# Restore user's pre-existing save byte-for-byte, or remove fixture save.
	if had_save:
		var file := FileAccess.open(save_path,FileAccess.WRITE)
		file.store_buffer(prior_save)
		file.close()
		check(FileAccess.get_file_as_bytes(save_path) == prior_save,"Original save restored byte-for-byte")
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
		check(not FileAccess.file_exists(save_path),"Fixture save removed; no user progress altered")
	print("RESULT: %d checks, %d failures" % [checks,failures.size()])
	for failure in failures: print("DEFECT: ",failure)
	quit(0 if failures.is_empty() else 1)

func test_application() -> void:
	var app = Main.new()
	root.add_child(app)
	app.set_process(false)
	app.ambience.stream = null # Audio listening is a separate manual release check.
	app.ward.set_process(false)
	check(app.screen == "menu" and app.profile == "", "Fresh launch presents title and no profile")
	app.show_wards()
	for child in app.ui.get_children():
		if child is Button and child.visible and child.text == "Enter →":
			child.pressed.emit()
			break
	check(app.screen == "profile", "Ward select cannot bypass new-player profile")
	app.begin_campaign()
	check(app.screen == "profile" and not app.demo, "First campaign opens local profile")
	app.profile = "QA 테스트"
	app.begin_campaign()
	check(app.screen == "tutorial" and app.tutorial_step == 0, "First named campaign opens six-page tutorial")
	for i in 6:
		app.tutorial_step = i
		app.show_tutorial()
		check(app.screen == "tutorial", "Tutorial page %d builds" % (i+1))
	app.finish_tutorial()
	check(app.screen == "intro" and app.tutorial_done, "Tutorial finish enters ward briefing")
	app.unlocked = 6
	app.checkpoint = 6
	app.memories = [0,1,2,3,4,5]
	app.lang = 1
	app.gentle = true
	app.volume = 0.35
	app.motion = false
	app.high_visibility = true
	app.save()
	var saved: PackedByteArray = FileAccess.get_file_as_bytes("user://afterhours.cfg")
	app.begin_demo()
	check(app.demo and app.intro_index == 0, "Demo always starts at first ward")
	for i in 3:
		app.start_ward(i)
		app.ward.set_process(false)
		app.on_finished()
		check(app.screen == "memory", "Demo ward %d shows memory" % (i+1))
	check(FileAccess.get_file_as_bytes("user://afterhours.cfg") == saved and app.checkpoint == 6 and app.unlocked == 6 and app.memories.size() == 6, "Demo completion preserves campaign save byte-for-byte")
	app.show_demo_end()
	check(app.screen == "demo_end", "Demo completion screen builds")
	app.begin_campaign()
	check(not app.demo and app.intro_index == 6, "Campaign continues at preserved checkpoint after demo")
	app.start_ward(6)
	check(app.ward.high_visibility and not app.ward.effects and app.ward.gentle, "Ward entry applies visibility, motion and gentle preferences")
	app.ward.set_process(false)
	app.ward.test_mode = true
	app.ward.move_override = Vector2.RIGHT
	var p: Vector2 = app.ward.player
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.physical_keycode = KEY_ESCAPE
	app._unhandled_key_input(escape)
	check(app.screen == "pause", "ESC physical key pauses gameplay")
	var battery: float = app.ward.battery
	app.ward._process(1)
	check(app.screen == "pause" and not app.ward.running and app.ward.player == p and app.ward.battery == battery,"Pause freezes ward movement and resources")
	app.show_settings(true)
	check(not app.ward.running,"Pause settings keep simulation frozen")
	app.switch_language()
	var back: Button
	for child in app.ui.get_children():
		if child is Button and child.visible and child.text in ["← Back","← 뒤로"]: back = child
	check(back != null,"Localized settings expose back button")
	if back:
		back.pressed.emit()
		check(app.screen == "pause", "Language switch in pause settings preserves return-to-pause context")
	app._unhandled_key_input(escape)
	check(app.screen == "game" and app.ward.running and app.ward.player == p,"Resume retains ward state")
	app.on_finished()
	check(app.checkpoint == 7 and app.unlocked == 7 and app.memories.has(6),"Campaign completion advances checkpoint and archive")
	app.show_menu()
	var loaded = Main.new()
	root.add_child(loaded)
	loaded.set_process(false)
	loaded.ward.set_process(false)
	check(loaded.profile == "QA 테스트" and loaded.checkpoint == 7 and loaded.unlocked == 7 and loaded.memories.has(6),"Persisted profile progress reloads")
	check(loaded.lang == app.lang and loaded.gentle and is_equal_approx(loaded.volume,0.35) and not loaded.motion and loaded.high_visibility,"Persisted language/accessibility/audio reloads")
	for language in 2:
		app.lang = language
		for page in 6:
			app.tutorial_step = page
			app.show_tutorial()
			await process_frame
			await process_frame
			check_labels(app,"Language %d tutorial %d" % [language,page+1])
		for view in ["show_menu","show_profile","show_tutorial","show_wards","show_archive","show_settings","show_credits","show_failure","show_demo_end","show_choice"]:
			app.call(view)
			await process_frame
			await process_frame
			check_labels(app,"Language %d %s" % [language,view])
			check(not app.ui.get_children().is_empty(), "Language %d %s builds" % [language,view])
		app.show_ending(true)
		check(app.screen == "ending" and app.session_ending == "remember","Language %d remember ending" % language)
		app.show_ending(false)
		check(app.screen == "ending" and app.session_ending == "forget","Language %d forget ending" % language)
	var ending_reload = Main.new()
	root.add_child(ending_reload)
	ending_reload.set_process(false)
	ending_reload.ward.set_process(false)
	check(ending_reload.campaign_complete and ending_reload.session_ending == "forget", "Final choice persists after application reload")
	ending_reload.begin_campaign()
	check(ending_reload.screen == "wards", "Completed campaign offers replay selection")
	stop_audio(ending_reload)
	ending_reload.queue_free()
	# Untrusted local config values are bounded and archive entries sanitized.
	var invalid := ConfigFile.new()
	invalid.set_value("player","name","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	invalid.set_value("player","unlocked",999)
	invalid.set_value("player","checkpoint",-100)
	invalid.set_value("player","memories",[0,0,9,-1,10,"invalid"])
	invalid.set_value("settings","language",999)
	invalid.set_value("settings","volume",7.5)
	invalid.save("user://afterhours.cfg")
	var sanitized = Main.new()
	root.add_child(sanitized)
	sanitized.set_process(false)
	sanitized.ward.set_process(false)
	check(sanitized.profile.length() == 20 and sanitized.unlocked == 9 and sanitized.checkpoint == 0, "Local profile and checkpoint values bounded")
	check(sanitized.memories == [0,9] and sanitized.lang == 1 and sanitized.volume == 1, "Invalid archive/language/volume sanitized")
	stop_audio(sanitized)
	sanitized.queue_free()
	stop_audio(loaded)
	stop_audio(app)
	await create_timer(0.05).timeout
	loaded.queue_free()
	app.queue_free()
	await process_frame
