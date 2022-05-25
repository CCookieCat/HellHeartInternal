extends "res://Scripts/Emitter.gd"

onready var bullet_spawn_timer = $SpawnTimer
onready var spawner_object = $Spawner
onready var bullet_sprite = preload("res://Resources/Bullets/bullet_01.png")
onready var dest_bullet_sprite = preload("res://Resources/Bullets/bullet.png")
onready var target = get_parent().get_node("Player")

export var rotation_speed = 20
export var BULLET_SPEED = 100
export var is_destructible = false
export var spawn_rate = .2
export var spawn_point_count = 2
export var radius = 50
export var face_target = false
export var directional_bullets = false


func _ready():
	init_spawn_point_count(spawner_object, spawn_point_count, radius)
	bullet_spawn_timer.wait_time = spawn_rate
	bullet_spawn_timer.start()

func _process(delta):
	update_emitter(spawner_object, rotation_speed, delta, face_target ,target, false)

func _on_SpawnTimer_timeout():
	bullet_spawn_timer.wait_time = spawn_rate
	if !is_destructible:
		update_spawn_point(bullet_sprite, spawner_object, spawn_point_count, 
		radius, BULLET_SPEED, is_destructible, directional_bullets, target)
	else:
		update_spawn_point(dest_bullet_sprite, spawner_object, spawn_point_count, 
		radius, BULLET_SPEED, is_destructible, directional_bullets, target)


func _on_VisibilityNotifier2D_screen_entered():
	Lists.set_a_obj(self)


func _on_VisibilityNotifier2D_screen_exited():
	Lists.remove_a_obj(self)
