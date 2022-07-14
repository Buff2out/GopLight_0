extends Area2D


onready var textEdit = $TextEdit
var player = null

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	player = body
	$TextEdit.show()

func _on_PlayerDetectionZone_body_exited(body):
	player = null
	$TextEdit.hide()
