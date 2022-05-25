extends Node2D

var direction = Vector2(0,-1)

onready var area2d = $Area2D
onready var root_node = get_node("..")

export var bullet_speed = 200

func _ready():
	area2d.connect("body_shape_entered", root_node, "_on_BulletInstance_body_shape_entered",[self])

func _process(delta):
	self.position += direction * delta * bullet_speed

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
