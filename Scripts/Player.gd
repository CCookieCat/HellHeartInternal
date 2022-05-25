extends KinematicBody2D

onready var bullet_scene =preload("res://Scenes/Bullet_Instance.tscn")
onready var target = self

onready var area2d = $Area2D
onready var root_node = get_node("..")

onready var position_node = $Position2D
onready var spawn_timer = $SpawnTimer

export var face_target = true

var velocity = Vector2()
const ACCELERATION = 6000

var selection = 0
var direction

var id = 0

func _ready():
	#connect raycast-signal to world node:
	area2d.connect("body_shape_entered", root_node, "_on_Player_body_shape_entered")
	Lists.set_current_player_node(self)

func _input(event):
		if event.is_action_pressed("screen_input"):
			print(str(get_global_transform()))
			face_target = false

func _process(delta):
	velocity.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	velocity.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	velocity.normalized()
	velocity = move_and_slide(ACCELERATION * velocity * delta)
	
	
	if Input.is_action_just_pressed("target_object"):
		face_target = true
		if Lists.get_obj().empty():
			face_target = false
		selection = clamp(selection, 0, Lists.get_obj().size())
		if face_target:
			target = Lists.get_a_obj(selection)
			print(str(target))
			selection += 1
			if selection >= (Lists.get_obj()).size():
				selection = 0
	if face_target:
		active_target(target)
	else:
		if !velocity == Vector2.ZERO:
			position_node.rotation_degrees = rad2deg(velocity.angle())

	if Input.is_action_just_pressed("fire_bullets"):
		if spawn_timer.is_stopped():
			print("timer started")
			spawn_timer.start()
		else:
			spawn_timer.stop()

func active_target(target):
	var playerdir = (target.position - self.position).normalized()
	position_node.rotation_degrees = rad2deg(playerdir.angle())

# TODO: MAKE DDA-RAYCAST SYSTEM FOR EACH LINE BULLET with steps being bullet rectangle !! #

func spawn_bullets():
	var position = self.global_position
	direction = position_node.rotation_degrees
	create_pBullets(position, direction, 500)

func _on_SpawnTimer_timeout():
	BulletLoader.removeActiveCellObject()
	
func create_pBullets(spawn_position, direction, bullet_speed):
	id = (id + 1) % 65535
	var dir = -(spawn_position - Vector2(spawn_position.x + cos((direction * PI) / 180.0),
				spawn_position.y + sin((direction * PI) / 180.0))).normalized()
	var bullet = [spawn_position, dir, bullet_speed]
	
	Lists.pBullets[id] = bullet
	id += 1
