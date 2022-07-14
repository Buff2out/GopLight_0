extends Node2D


# Declare member variables here. Examples:
onready var perehod = 1


func _ready():
	set_process_input(true)
	
func _input(event):
	if Input.is_action_pressed("restart") && event.is_pressed():
		get_tree().change_scene("res://Yard.tscn")


signal player_hurt
