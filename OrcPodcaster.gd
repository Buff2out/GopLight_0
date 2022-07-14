extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
#var CircleOfDeath=preload("res://MagicStrike.tscn")
export  var ACCELERATION = 500
export  var MAX_SPEED = 100
export var FRICTION = 2000


signal Hero_Hurt
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE
enum{
	IDLE,
	WANDER,
	CHASE,
	PUNCH
}

onready var MagicTimer = 0
onready var orcStats = $OrcStats
onready var playerDetectionZone = $PlayerDetectionZone
onready var animationOrc = $AnimationOrc
onready var HitZone = $HitZone
onready var LeftZone = $LeftZone
onready var RightZone = $RightZone
onready var UpZone = $UpZone
onready var DownZone = $DownZone
onready var animationStatus = $OrcAnimationTree
onready var player = playerDetectionZone.player
onready var MagicStrike = $MagicStrike
onready var upArea = $UpArea
onready var downArea = $DownArea
onready var Hero = HitZone.Hero
onready var LeftHero = LeftZone.LeftHero
onready var RightHero = RightZone.RightHero
onready var UpHero = UpZone.UpHero
onready var DownHero = DownZone.DownHero
onready var animationStreet = animationStatus.get("parameters/playback")
#onready var G1 = get_node("res://G1.gd")
var G1 = preload ("res://G1.gd")
var ready_left = 0
var ready_right = 0
var ready_up = 0
var ready_down = 0
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 50 * delta)
	knockback = move_and_slide(knockback)
	print(state)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 600 * delta )
			seek_player()
			animationStreet.stop()
			animationStreet.travel("OrcIdle")
			velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
			#animationOrc.play("IdleDown")
		WANDER:
			pass
		CHASE:
			var player = playerDetectionZone.player
			var LeftHero = LeftZone.LeftHero
			var RightHero = RightZone.RightHero
			var DownHero = DownZone.DownHero
			var UpHero = UpZone.UpHero
			animationStreet.stop()
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				if velocity != Vector2.ZERO:
					
					animationStatus.set("parameters/OrcIdle/blend_position", velocity)
					animationStatus.set("parameters/OrcWalk/blend_position", velocity)
					
					animationStreet.travel("OrcWalk")
					
					if LeftHero!=null || RightHero!= null || UpHero!= null || DownHero!= null:
						
						state = PUNCH
					
					
					
					#velocity = velocity.move_toward(velocity * MAX_SPEED, delta * ACCELERATION)
				#else:
					#state = IDLE
					#animationStatus.set("parameters/OrcIdle/blend_position", velocity)
					#animationStatus.set("parameters/OrcWalk/blend_position", velocity)
					#animationStreet.travel("OrcIdle")
					#velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
			else:
				state = IDLE
				
				
		PUNCH:
			var player = playerDetectionZone.player
			var LeftHero = LeftZone.LeftHero
			var RightHero = RightZone.RightHero
			var UpHero = UpZone.UpHero
			var DownHero = DownZone.DownHero
			var velocity2 = Vector2.ZERO
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				print(LeftHero , RightHero, UpHero, DownHero)
				
				if LeftHero!=null:
					if LeftHero.name == "Hero":
						
						velocity = Vector2.ZERO
						velocity2.x = -1
						velocity2.y = 0
						animationStreet.stop()
						
						animationStatus.set("parameters/OrcAttack/blend_position", velocity2)
					
						animationStreet.travel("OrcAttack")
						_attack_cadr_start()
						_attack_cadr_middle()
						#_attack_cadr_end()
						
			
				
				elif RightHero!= null:
					if RightHero.name == "Hero":
						velocity = Vector2.ZERO
						velocity2.x = 1
						velocity2.y = 0
						animationStreet.stop()
						
						animationStatus.set("parameters/OrcAttack/blend_position", velocity2)
					
						animationStreet.travel("OrcAttack")
						_attack_cadr_start()
						_attack_cadr_middle()
						#_attack_cadr_end()
						
	
				elif UpHero!= null:
					if UpHero.name == "Hero":
						velocity = Vector2.ZERO
						velocity2.x = 0
						velocity2.y = -1
						animationStreet.stop()
						
						animationStatus.set("parameters/OrcAttack/blend_position", velocity2)
					
						animationStreet.travel("OrcAttack")
						_attack_cadr_start()
						_attack_cadr_middle()
						#_attack_cadr_end()
						
				elif DownHero!= null:
					if DownHero.name == "Hero":
						velocity = Vector2.ZERO
						velocity2.x = 0
						velocity2.y = 1
						animationStreet.stop()
						
						animationStatus.set("parameters/OrcAttack/blend_position", velocity2)
					
						animationStreet.travel("OrcAttack")
						_attack_cadr_start()
						_attack_cadr_middle()
						#_attack_cadr_end()
						
				else:
					animationStreet.stop()
					state = IDLE
				
				
			
		
				
			
			
	velocity = move_and_slide(velocity)
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
	
func magic_up_state():
	#stop=1
	animationOrc.play("magicUp")
	$MagicStrike.play(0.0)
	var circle = MagicStrike.instance()
	circle.position = player.position
	get_parent().add_child(circle)
	#attack=0
	
	
func magic_up_animation_finished():
	state = IDLE
	
func _on_Hurtbox_area_entered(area):
	orcStats.health -=area.damage
	knockback = area.knockback_vector * 50


func _on_Hurtbox_area_exited(area):
	pass # Replace with function body.


func _on_OrcStats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _attack_cadr_start():
	var Timer1 = MagicTimer+5
	if MagicTimer == Timer1:
		print("AtS")
		emit_signal("Hero_Hurt")
		print("AtS")
func _attack_cadr_middle():
	var Timer2 = MagicTimer+5
	if MagicTimer == Timer2:
		emit_signal("Hero_Hurt")
		print("AtM")
func _attack_cadr_end():
	emit_signal("Hero_Hurt")
	
	print("AtE")
	
	

func _on_RightZone_area_shape_entered(area_id, area, area_shape, self_shape):
		if area != null:
			if is_instance_valid(area):
				if area.name == "HeroHurtbox":
					ready_right=1

func _on_RightZone_area_shape_exited(area_id, area, area_shape, self_shape):
		if area != null:
			if is_instance_valid(area):
				if area.name == "HeroHurtbox":
					ready_right=0


func _on_UpZone_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_up=1


func _on_UpZone_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_up=0



func _on_DownZone_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_down=1

func _on_DownZone_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_down=0

func _on_LeftZone_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_left=1


func _on_LeftZone_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "HeroHurtbox":
				ready_left=0





func _on_AnimationOrc_animation_changed(old_name, new_name):
	pass # Replace with function body.



	


func _on_G1_player_hurt():
	pass
