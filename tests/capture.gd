extends SceneTree
var app
func _initialize():
	call_deferred("capture")
func shot(name: String):
	await create_timer(0.22).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/screenshots/"+name+".png")
func capture():
	app=load("res://main.tscn").instantiate()
	root.add_child(app)
	root.size=Vector2i(1280,720)
	await shot("01-title")
	app.show_profile()
	await shot("02-profile")
	app.tutorial_step=2
	app.show_tutorial()
	await shot("03-guide")
	app.show_intro(7)
	await shot("04-briefing")
	app.start_ward(0)
	app.ward.running=false
	await shot("05-gameplay")
	app.lang=1
	app.start_ward(7)
	app.ward.running=false
	await shot("06-korean")
	app.show_choice()
	await shot("07-choice")
	app.lang=0
	app.show_settings()
	await shot("08-settings")
	app.lang=0
	for i in 10:
		app.start_ward(i)
		app.ward.running=false
		await shot("ward-%02d"%(i+1))
	app.ambience.stop()
	root.remove_child(app)
	app.free()
	await create_timer(0.1).timeout
	quit()
