extends Node2D

onready var viewport = get_viewport_rect().size
onready var bullets = get_node("/root/BulletLoader")

var direction = Vector2(0,0)

func activate_bullet(sprite, spawn_position, bullet_direction, 
		bullet_speed, is_destructible):
	bullets.set_emission_position(spawn_position)
	bullets.set_emission_direction(bullet_direction)
	bullets.set_emission_speed(bullet_speed)
	bullets.set_is_destructible(is_destructible)
	bullets.request_bullet()

func update_emitter(spawnerObj, rotation_speed, delta, face_target, target, is_player):
	if is_player:
		spawnerObj.rotation_degrees = -90
	else:
		if !face_target:
			var new_rotation = spawnerObj.rotation_degrees + rotation_speed * delta
			spawnerObj.rotation_degrees = fmod(new_rotation, 360)
		else:
			var playerdir = (target.position - self.position).normalized()
			spawnerObj.rotation_degrees = rad2deg(playerdir.angle())

func init_spawn_point_count(spawnerObj, spawn_point_count, radius):
	if !spawn_point_count == 0:
		var step = 2 * PI / spawn_point_count
		for n in range(spawn_point_count):
			var spawn_point = Node2D.new()
			var pos = Vector2(radius, 0).rotated(step * n)
			spawn_point.position = pos
			spawn_point.rotation = pos.angle()
			spawnerObj.add_child(spawn_point)

func update_spawn_point(sprite, spawnerObj, spawn_point_count, 
	radius, BULLET_SPEED, is_destructible, directional, target):

	if(!spawn_point_count == spawnerObj.get_child_count()):
		for spawn_point in spawnerObj.get_children():
			spawn_point.queue_free()
		init_spawn_point_count(spawnerObj, spawn_point_count, radius)
	for n in spawnerObj.get_children():
		if !directional:
			direction = n.global_rotation_degrees
		else:
			var vec2 = target.position - n.global_position
			direction = (rad2deg(vec2.angle()))
		var testpos = n.get_global_position()
		
		activate_bullet(sprite, testpos, direction, BULLET_SPEED, is_destructible)
