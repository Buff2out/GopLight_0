extends Area2D



var RightHero = null

func can_see_player():
	return RightHero != null


func _on_RightArea_body_entered(body):
	if body.name == "Hero":
		RightHero = body


func _on_RightArea_body_exited(body):
	if body.name == "Hero":
		RightHero = null
