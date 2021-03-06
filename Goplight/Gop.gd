extends KinematicBody2D

export var MAX_SPEED = 170
export var ACCELERATION = 800
export var ROLL_SPEED = 250
export var FRICTION = 3000

enum{
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationHero = $AnimationHero
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var KnifeHitbox = $HitboxPivot/KnifeHitbox
onready var hurtbox = $Hurtbox

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	set_process_input(true)
	animationTree.active = true
	KnifeHitbox.knockback_vector = roll_vector
	
	

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
	
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		KnifeHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Move/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Move")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, delta * ACCELERATION)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func move():
	velocity = move_and_slide(velocity)
	
func attack_state(detla):
		velocity = Vector2.ZERO
		animationState.travel("Attack")

func roll_animation_finished():
#	velocity = Vector2.ZERO
	state = MOVE

func attack_animation_finished():
		state = MOVE
	


func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(1)
	hurtbox.create_hit_effect()








func _on_OrcPodcaster_Hero_Hurt():
	
	
	stats.health -= 1
	hurtbox.start_invincibility(1.1)
	print ("SAFE ME 3")  
	hurtbox.create_hit_effect()
	
