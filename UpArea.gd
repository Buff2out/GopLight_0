extends Area2D



var UpHero = null

func can_see_player():
	return UpHero != null

func _on_UpArea_body_entered(body):
	if body.name == "Hero":
		UpHero= body


func _on_UpArea_body_exited(body):
	if body.name == "Hero":
		UpHero = null
