extends Area2D



var DownHero = null

func can_see_player():
	return DownHero != null


func _on_DownArea_body_entered(body):
	if body.name == "Hero":
		DownHero = body


func _on_DownArea_body_exited(body):
	if body.name == "Hero":
		DownHero = null
