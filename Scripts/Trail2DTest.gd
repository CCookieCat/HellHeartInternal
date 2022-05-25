extends Node2D

onready var tweenNode = $Tween
onready var line2d = $Line2D

export var emissionPos = Vector2(275,500)

var flag = false
var count = 0
var point1 = Vector2.ZERO
var point2 = Vector2.ZERO
var direction
var vCollisionPoint

func _input(event):
	if event.is_action_pressed("screen_input"):
		vCollisionPoint = get_local_mouse_position()
		if count == 0:
			point1 = emissionPos
			count += 1
			#reset
			point2 = Vector2.ZERO
		else:
			point2 = vCollisionPoint
			count = 0
			flag = true

func _physics_process(delta):
	update() #mouse-cursor rendering
	if flag:
		$Line2D.add_point(point1)
		$Line2D.add_point(point2)
		direction = (point2 - point1).normalized()
		flag = false
#	if point1 < point2 && !(point2==Vector2.ZERO):
	if ((point2-point1).length() >= 20) && !(point2==Vector2.ZERO):
		$Line2D.set_point_position(0, calc_point(direction, delta))

func calc_point(direction, delta):
	point1 += direction * delta * 2000
	return point1


func _draw():
	draw_circle(point1, 3, Color(0,0,1,1))
	draw_circle(get_local_mouse_position(), 3, Color(1,1,1,1))
#func _on_Timer_timeout():
#	shoot()
