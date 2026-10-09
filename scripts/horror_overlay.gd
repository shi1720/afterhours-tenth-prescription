extends Node2D
## A brief pixel apparition. It never blocks input or changes the simulation.
var remaining := 0.0
var strength := 1.0

func trigger(intensity: float) -> void:
	strength = clampf(intensity,0.3,1)
	remaining = 0.48
	queue_redraw()

func _process(delta: float) -> void:
	if remaining <= 0: return
	remaining = maxf(0,remaining-delta)
	queue_redraw()

func _draw() -> void:
	if remaining <= 0: return
	var alpha := minf(1,remaining/0.22) * strength
	draw_rect(Rect2(0,0,1280,720),Color(0.025,0.012,0.025,alpha*0.75))
	# A face authored on a coarse pixel grid, with no white flash or strobing.
	draw_set_transform(Vector2(448,100),0,Vector2(1.5,1.5))
	var origin := Vector2.ZERO
	var skin := Color(0.34,0.24,0.31,alpha)
	var shadow := Color(0.055,0.045,0.08,alpha)
	var eye := Color(0.91,0.57,0.48,alpha)
	draw_rect(Rect2(origin+Vector2(32,0),Vector2(192,304)),skin)
	draw_rect(Rect2(origin+Vector2(0,48),Vector2(256,192)),skin)
	draw_rect(Rect2(origin+Vector2(16,96),Vector2(96,64)),shadow)
	draw_rect(Rect2(origin+Vector2(144,96),Vector2(96,64)),shadow)
	draw_rect(Rect2(origin+Vector2(48,112),Vector2(32,16)),eye)
	draw_rect(Rect2(origin+Vector2(176,112),Vector2(32,16)),eye)
	draw_rect(Rect2(origin+Vector2(80,208),Vector2(96,112)),shadow)
	for x in [80,112,144]: draw_rect(Rect2(origin+Vector2(x,208),Vector2(16,16)),Color(0.63,0.55,0.54,alpha))
	for x in [32,208]: draw_rect(Rect2(origin+Vector2(x,160),Vector2(16,96)),shadow)
