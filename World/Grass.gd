extends Node2D



func create_grass_effect():
	var GrassEffect = load("res://Effects/GrassEffect.tscn")
	var grassEffect = GrassEffect.instance()
	var yard = get_tree().current_scene
	yard.add_child(grassEffect)
	grassEffect.global_position = global_position


func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
