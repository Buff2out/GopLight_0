extends Area2D



var LeftHero = null

func can_see_player():
	return LeftHero != null


func _on_LeftZone_body_entered(body):
	if body.name == "Hero":
		LeftHero = body


func _on_LeftZone_body_exited(body):
	if body.name == "Hero":
		LeftHero = null
