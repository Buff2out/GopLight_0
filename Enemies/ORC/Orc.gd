extends KinematicBody2D
onready var anim_sprite := $"OrcAnimSprite" as AnimatedSprite
onready var health_bar = $"TPHealth"

const GOAL_DEAD_ZONE = 80
const SPEED = 100 # Скорость
var dir = Vector2(0,0) # Направление
var target = null # объект цель
var spawn_pos # точка появления
var trigger_pos # точка от которой пошло преследование
var cpath # путь (массив
var move = false #двигается
var go_to_spawn = false # признак возвращения на исходную позицию
export(float) var health = 4.5 setget set_health, get_health
var dead = false
var patrool_pos
var vul_left = 0
var vul_right = 0
var vul_up = 0
var vul_down = 0
var inv = 0
var direct = "b"
var ready_left = 0
var ready_right = 0
var ready_up = 0
var ready_down = 0
var stop = 0
var knockdir = Vector2(0,0)
var motion = 0
var knockback = 0
var iks = 2
var igrek = 2
var attack = 0

var CircleOfDeath=preload("res://CircleOfDeath.tscn")

signal start_timer
signal hurt

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	spawn_pos = position
	add_to_group('npcs')
	get_node("../MainCharacter/Camera2D").get_parent().connect("npc_hurt_left", self, "_on_npc_hurt_left")
	get_node("../MainCharacter/Camera2D").get_parent().connect("npc_hurt_right", self, "_on_npc_hurt_right")
	get_node("../MainCharacter/Camera2D").get_parent().connect("npc_hurt_down", self, "_on_npc_hurt_down")
	get_node("../MainCharacter/Camera2D").get_parent().connect("npc_hurt_up", self, "_on_npc_hurt_up")
	get_node("../MainCharacter/Camera2D").get_parent().connect("deinv", self, "_on_deinv")
	emit_signal("start_timer")

func magic():
	stop=1
	anim_sprite.play("magicup")
	$LightningCharge.play(0.0)
	var circle = CircleOfDeath.instance()
	circle.position = target.position
	get_parent().add_child(circle)
	attack=0

func _on_deinv():
	inv = 0

func set_health(val):
	health = val
	health_bar.value = val
	if health <= 0:
		stop=1
		$OrcDed.play(0.0)
		anim_sprite.play("death")
		dead = true
		G.score += 20


func get_health():
	return health

func reset():
	position = spawn_pos
	dead = false
	self.health = 4.5
	target = null
	trigger_pos = null
	go_to_spawn = false
	cpath = null
	move = false
	dir = Vector2(0,0)
	anim_sprite.play("stay_f")

# входящие объекты в область зрения
func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	#print(body.name)
	if body != null:
		if is_instance_valid(body):
			if body.name == 'MainCharacter':
				trigger_pos = position
				target = body


# выход объект(-а/-ов) из области "зрения"
func _on_Area2D_body_shape_exited(body_id, body, body_shape, area_shape):
	if body != null:
		if is_instance_valid(body):
			if body.name == 'MainCharacter':
				target = null
				cpath = null
				go_to_spawn = true


func debug_draw_path():
	if G.debug:
		for p in get_tree().get_nodes_in_group("astar_path_point"):
				if p.get_meta('master') == self:
					p.queue_free()
		if cpath != null:
			for p in cpath: 
				var s = Sprite.new()
				s.texture = G.astar_dbg_point
				s.position = Vector2(p.x,p.y)
				s.add_to_group('astar_path_point')
				s.set_meta('master', self)
				get_parent().add_child(s)


func anim():
	dir = dir.round()
	if dir == Vector2(-1, 0) && stop==0 && dead==false:
		anim_sprite.play('left')
		direct = "l"
	elif dir == Vector2(1, 0) && stop==0 && dead==false:
		anim_sprite.play('right')
		direct = "r"
	elif dir == Vector2(0, -1) && stop==0 && dead==false:
		anim_sprite.play('back')
		direct = "b"
	elif dir == Vector2(0, 1) && stop==0 && dead==false:
		anim_sprite.play('forward')
		direct = "f"
	else: # анимация при простое
		if anim_sprite.animation == 'left':
			anim_sprite.play('stay_l')
		elif anim_sprite.animation == 'right':
			anim_sprite.play('stay_r')
		elif anim_sprite.animation == 'forward':
			anim_sprite.play('stay_f')
		elif anim_sprite.animation == 'back':
			anim_sprite.play('stay_b')


func go_to_point(pos):
	if cpath == null: # путь не существует - создаем
		cpath = G.ASM.get_point_path(
				G.ASM.get_closest_point(Vector3(position.x, position.y, 0)),
				G.ASM.get_closest_point(Vector3(pos.x, pos.y, 0))
		)
		cpath.remove(0) # удаляем точку под своим тайлом, чтобы при начале движения не дрожать
		if cpath == PoolVector3Array():
			cpath = null
		debug_draw_path()
	else: # путь существует
		var d = floor(position.distance_to(Vector2(cpath[0].x, cpath[0].y))) # floor - округление к меньшему
		#print(d)
		if not(d == 0): # дистанция до ближайщей точки в пути не = 0 // P --{d}-> [o]ooooooooX
			# Движемся к точке
			dir = position.direction_to(Vector2(cpath[0].x, cpath[0].y))
			if (stop==0):
				if (knockback==0):
					move_and_slide(dir *  SPEED)
					move = true
					#print('move')
					anim()
				elif (knockback==1):
					knockdir=Vector2(iks, igrek)
					motion=knockdir.normalized()*500
					move_and_slide(motion, Vector2(0,0))
				

			if target:
				if position.distance_to(target.position) <= GOAL_DEAD_ZONE && attack>1:
					move = false
					#cpath = null
					if dead==false:
#							if direct=="l":
#								anim_sprite.play("leftat")
#							elif direct=="r":
#								anim_sprite.play("rightat")
#							elif direct=="b":
#								anim_sprite.play("backat")
#							elif direct=="f":
#								anim_sprite.play("forwardat")
							if target.position.y > self.position.y:
								if abs(target.position.x-self.position.x) >= abs(target.position.y - self.position.y):
									if (target.position.x-self.position.x) > 0:
										if (stop==0):
											anim_sprite.play("rightat")
											stop = 1
									elif (target.position.x-self.position.x) < 0:
										if (stop==0):
											anim_sprite.play("leftat")
											stop = 1
								else:
									if (stop==0):
										anim_sprite.play("forwardat")
										stop = 1
		
							elif target.position.y < self.position.y:
								if abs(target.position.x-self.position.x) >= abs(target.position.y - self.position.y):
									if (target.position.x-self.position.x) > 0:
										if (stop==0):
											anim_sprite.play("rightat")
											stop = 1
									elif (target.position.x-self.position.x) < 0:
										if (stop==0):
											anim_sprite.play("leftat")
											stop = 1
								else:
									if (stop==0):
										anim_sprite.play("backat")
										stop = 1
					dir = Vector2()
					debug_draw_path()
			else:
				if d <= GOAL_DEAD_ZONE and cpath.size() == 1:
					move = false
					cpath = null
					go_to_spawn = false
					dir = Vector2()
					debug_draw_path()
			anim()
		else: # достижение точки
			# удаляем достигнутую точку из пути
			cpath.remove(0)
			# если точек больше нет то достижение цели
			if cpath == PoolVector3Array():
				cpath = null
				if go_to_spawn:
					go_to_spawn = false
				move = false
			debug_draw_path()

		dir = Vector2()


# "вечный цикл" - процесс
func _physics_process(delta):
	if (anim_sprite.animation.match("*at") or anim_sprite.animation.match("magic*")) && (knockback==1):
			knockdir=Vector2(iks, igrek)
			motion=knockdir.normalized()*500
			move_and_slide(motion, Vector2(0,0))
	if target != null:
		if attack==1:
			magic() # преследование
		elif position.distance_to(target.position) > 16:
			go_to_point(target.position)
		else:
			if (stop==0):
				if (knockback==0):
					move_and_slide(position.direction_to(target.position))
				elif knockback==1:
					knockdir=Vector2(iks, igrek)
					motion=knockdir.normalized()*500
					move_and_slide(motion, Vector2(0,0)) 	
	else: # нет преследуемого
		if spawn_pos != null and go_to_spawn: # возврат на точку
			go_to_point(spawn_pos)
			#else: # патрулирование (работает не очень т.к юниты застревают в друг друге и в препятствиях)
			#	if !move:
			#		patrool_pos = get_tree().get_nodes_in_group('npcs')[rand_range(1, len(get_tree().get_nodes_in_group('npcs')))].spawn_pos
			#	if patrool_pos:
			#		go_to_point(patrool_pos)

		
func _on_npc_hurt_left(bonus_dmg_sword):
	if (self.vul_left==1):
		if inv==0: 
			self.health = self.health - bonus_dmg_sword - 1
			inv = 1
			$OrcHurt.play(0.0)
			iks = -1
			igrek = 0
			knockback = 1
			$KnockbackTimer.start()
			anim_sprite.self_modulate = Color.red
			yield(get_tree().create_timer(0.25), "timeout")
			if is_instance_valid(self):
				anim_sprite.self_modulate = Color.white
func _on_npc_hurt_right(bonus_dmg_sword):
	if (self.vul_right==1):
		if inv==0: 
			self.health = self.health - bonus_dmg_sword - 1
			inv = 1
			$OrcHurt.play(0.0)
			iks = 1
			igrek = 0
			knockback = 1
			$KnockbackTimer.start()
			anim_sprite.self_modulate = Color.red
			yield(get_tree().create_timer(0.25), "timeout")
			if is_instance_valid(self):
				anim_sprite.self_modulate = Color.white
func _on_npc_hurt_down(bonus_dmg_sword):
	if (self.vul_down==1):
		if inv==0: 
			self.health = self.health - bonus_dmg_sword - 1
			inv = 1
			$OrcHurt.play(0.0)
			iks = 0
			igrek = 1
			knockback = 1
			$KnockbackTimer.start()
			anim_sprite.self_modulate = Color.red
			yield(get_tree().create_timer(0.25), "timeout")
			if is_instance_valid(self):
				anim_sprite.self_modulate = Color.white
func _on_npc_hurt_up(bonus_dmg_sword):
	if (self.vul_up==1):
		if inv==0: 
			self.health = self.health - bonus_dmg_sword - 1
			inv = 1
			$OrcHurt.play(0.0)
			iks = 0
			igrek = -1
			knockback = 1
			$KnockbackTimer.start()
			anim_sprite.self_modulate = Color.red
			yield(get_tree().create_timer(0.25), "timeout")
			if is_instance_valid(self):
				anim_sprite.self_modulate = Color.white

func _on_LeftAttack_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_left=1


func _on_LeftAttack_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_left=0


func _on_RightAttack_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_right=1


func _on_RightAttack_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_right=0


func _on_UpperAttack_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_up=1



func _on_UpperAttack_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_up=0


func _on_LowerAttack_area_shape_entered(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_down=1


func _on_LowerAttack_area_shape_exited(area_id, area, area_shape, self_shape):
	if area != null:
		if is_instance_valid(area):
			if area.name == "PlayerHitbox":
				ready_down=0


func _on_OrcAnimSprite_frame_changed():
	 if  anim_sprite.frame>5 && anim_sprite.frame<8 && anim_sprite.animation=="rightat" && self.ready_right==1:
			G.emit_signal("player_hurt")
	 elif anim_sprite.frame>5 && anim_sprite.frame<8 && anim_sprite.animation=="leftat" && self.ready_left==1:
			G.emit_signal("player_hurt")
	 elif anim_sprite.frame>5 && anim_sprite.frame<8 && anim_sprite.animation=="forwardat" && self.ready_down==1:
			G.emit_signal("player_hurt")
	 elif anim_sprite.frame>5 && anim_sprite.frame<8 && anim_sprite.animation=="backat" && self.ready_up==1:
			G.emit_signal("player_hurt")
	




func _on_OrcAnimSprite_animation_finished():
	stop=0
	attack=0
	if anim_sprite.animation=="death":
		queue_free() # Replace with function body.


func _on_OrcDed_finished():
	queue_free() # Replace with function body.



func _on_KnockbackTimer_timeout():
	knockback = 0


func _on_Timer_timeout():
	attack=randi()%11+1
	emit_signal("start_timer") # Replace with function body.

