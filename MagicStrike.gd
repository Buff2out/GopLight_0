extends Area2D

var ready_to_animStrike = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$MagicSprite.play("AnimStrike")



func _on_MagicStrike_body_entered(body):
	if body.name=='Hero':
		ready_to_animStrike = 1

func _on_MagicStrike_body_exited(body):
	if body.name=='Hero':
		ready_to_animStrike = 0

func _on_MagicSprite_animation_finished():
	queue_free()


func _on_MagicSprite_frame_changed():
	if $MagicSprite.frame==10:
		$Strike.play(0.0)
	#if $MagicSprite.frame>9 &&  $MagicSprite.frame<20 && ready_to_animStrike==1:
	#	G.emit_signal("destroy")
