extends RichTextLabel

var dialog = ["It was Island of Fate. The island of dreams of every creature living beyond the Great Water. \nPress SPACE or J to continue", "It was full of green-leafed and living creatures on this wonderful island. But not everything was so good... \npress CTRL or K to contunue"]
var page = 0

func _ready():
	set_bbcode(dialog[page])
	set_visible_characters(0)
	set_process_input(true)
	
func _input(event):
	if Input.is_action_pressed("attack") && event.is_pressed():
		if get_visible_characters() > get_total_character_count():
			if page < dialog.size() - 1:
				page += 1
				set_bbcode(dialog[page])
				set_visible_characters(0)
	if Input.is_action_pressed("roll") && event.is_pressed():
		get_tree().change_scene("res://Yard.tscn")
				
func _on_Timer_timeout():
	set_visible_characters(get_visible_characters() + 1)


