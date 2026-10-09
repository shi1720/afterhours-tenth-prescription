extends SceneTree
## Genuine 30fps in-engine montage. Gameplay uses ordinary _process and movement.
## Selects three wards directly; this is not a claim of uninterrupted campaign progression.
## The fixture overrides save(), so user progress is never written.
class RecordingMain:
	extends "res://scripts/main.gd"
	func save() -> void:
		pass

const FPS := 30
var app: RecordingMain
var frame_count := 0
var failed := false

func _initialize() -> void:
	call_deferred("record")

func frames(count: int) -> void:
	for i in count:
		await process_frame
		frame_count += 1

func hold(seconds: float) -> void:
	await frames(roundi(seconds*FPS))

func shot(name: String) -> void:
	print("SHOT at %.2fs: %s" % [float(frame_count)/FPS,name])

func walk_to(destination: Vector2) -> bool:
	var w = app.ward
	var route: PackedVector2Array = w.astar.get_point_path(w.cell(w.player),w.cell(destination))
	if route.is_empty(): return false
	for point in route:
		var attempts := 0
		while w.player.distance_to(point) > 1.8 and attempts < 100 and w.running:
			w.move_override = w.player.direction_to(point)
			for enemy in w.enemies:
				if enemy.pos.distance_to(w.player) < 100 and enemy.stun < 0.15: w.pulse()
			await frames(1)
			attempts += 1
		if attempts >= 100 or not w.running:
			w.move_override = Vector2.ZERO
			return false
	w.move_override = Vector2.ZERO
	return true

func play_ward(index: int) -> bool:
	app.show_intro(index)
	shot("Ward %02d briefing" % (index+1))
	await hold(5)
	app.start_ward(index)
	app.ward.test_mode = true
	app.ward.move_override = Vector2.ZERO
	shot("Ward %02d genuine normal-mode gameplay" % (index+1))
	await hold(0.5)
	for objective in 4:
		var destination: Vector2 = app.ward.hatch
		if not app.ward.fragments.is_empty():
			var shortest := 99999
			for record_position in app.ward.fragments:
				var length: int = app.ward.astar.get_id_path(app.ward.cell(app.ward.player),app.ward.cell(record_position)).size()
				if length < shortest:
					shortest = length
					destination = record_position
		if not await walk_to(destination): return false
		if app.ward.fragments.has(destination) and not app.ward.revealed.has(destination):
			while app.ward.cooldown > 0 and app.ward.running: await frames(1)
			if app.ward.battery < 24:
				# Recover from an unexpectedly expensive encounter using the real charger.
				if not await walk_to(app.ward.station): return false
				app.ward.interact()
				if not await walk_to(destination): return false
			app.ward.pulse()
			await hold(0.35) # Let the genuine reveal ring be visible before pickup.
		app.ward.interact()
		if objective < 3: await hold(1.05) # Genuine stationary recovery channel.
	if app.screen != "memory": return false
	shot("Ward %02d real completion memory" % (index+1))
	await hold(6)
	return true

func stop_audio(node: Node) -> void:
	if node is AudioStreamPlayer: node.stop()
	for child in node.get_children(): stop_audio(child)

func record() -> void:
	root.size = Vector2i(1280,720)
	app = RecordingMain.new()
	root.add_child(app)
	if DisplayServer.get_name() == "headless":
		app.ambience.stream = null
		app.ward.sounds.clear() # Dry-run validates control flow; real movie retains audio.
		app.arrival.volume_db = -80
	# In-memory fixture only: the overridden save() prevents writes from all screens.
	app.profile = "Shivam"
	app.volume = 0.65
	AudioServer.set_bus_volume_db(0,linear_to_db(app.volume))
	app.gentle = false
	app.high_visibility = false
	app.motion = true
	app.tutorial_done = true
	app.unlocked = 9
	app.checkpoint = 0
	app.memories = []
	app.session_ending = ""
	app.campaign_complete = false
	app.show_menu()
	shot("Title")
	await hold(6)
	app.tutorial_step = 2
	app.show_tutorial()
	shot("Pulse field-guide card")
	await hold(6)
	for index in [0,1,2]:
		if not await play_ward(index):
			push_error("Recording pilot did not complete ward %d. Do not publish this take." % (index+1))
			failed = true
			break
	if not failed:
		app.show_archive()
		shot("Archive of the three recorded ward completions")
		await hold(5)
		# Editorial preview of the final choice; no claim that the whole campaign was recorded.
		app.show_choice()
		shot("Editorial preview: final choice")
		await hold(5)
		app.show_ending(true)
		shot("Editorial preview: remember ending")
		await hold(10)
		app.show_menu()
		shot("Closing title")
		await hold(7)
	print("RECORDING %s: %d frames, %.2f seconds" % ["FAILED" if failed else "COMPLETE",frame_count,float(frame_count)/FPS])
	stop_audio(app)
	if DisplayServer.get_name() == "headless": OS.delay_msec(200) # Drain Dummy audio thread after rapid dry-run.
	await hold(0.2)
	app.queue_free()
	await process_frame
	quit(1 if failed else 0)
