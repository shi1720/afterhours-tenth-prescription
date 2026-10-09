extends SceneTree
func _initialize():
	var f=load("res://assets/fonts/NotoSansKR.ttf")
	print(f.get_supported_variation_list())
	var v=FontVariation.new()
	v.base_font=f
	v.variation_opentype={"wght":500}
	print(v.get_variation_opentype())
	quit()
