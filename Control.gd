extends Control





func _on_MessageTimer_timeout():
	$MessageLabel.hide()


func _on_StartButton1_pressed():
	get_tree().change_scene("res://Begin.tscn")
	$StartButton1.hide()





func _on_SkipButton_pressed():
	$StartButton1.hide()
	$StartButton.hide()
	$SkipButton.hide()
	emit_signal("start_game")
