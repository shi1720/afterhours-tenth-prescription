extends SceneTree
class CaptureMain:
	extends "res://scripts/main.gd"
	func save() -> void: pass
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size = Vector2i(1280,720)
	var app := CaptureMain.new()
	root.add_child(app)
	app.gentle = false
	app.motion = true
	app.start_ward(6)
	app.ward.set_process(false)
	app.ward.startle(1.0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../horror-scene.png"))
	for child in app.ward.sounds.values(): child.stop(); child.stream=null
	app.ambience.stop()
	app.ambience.stream = null
	app.arrival.stop()
	app.arrival.stream = null
	app.queue_free()
	await process_frame
	quit()
