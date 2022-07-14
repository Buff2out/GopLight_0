extends Area2D



var Hero = null

func can_see_player():
	return Hero != null


func _on_HitZone_body_entered(body):
	Hero = body
	

func _on_HitZone_body_exited(body):
	Hero = null

