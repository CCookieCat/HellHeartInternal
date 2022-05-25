extends Node2D

var id = 0

func create_bullet(spawn_position, direction, bullet_speed, destructible):
	#id = (id + 1) % 65535
	var dir = -(spawn_position - Vector2(spawn_position.x + cos((direction * PI) / 180.0),
				spawn_position.y + sin((direction * PI) / 180.0))).normalized()
	var grid_id = null #vray
	var bullet = [spawn_position, dir, bullet_speed, grid_id]
	
	Lists.n_bullet_list[id] = bullet
	if destructible:
		Lists.dest_bullet_list[id] = bullet

	id += 1

func update_bullet_pos(bullet, delta):
	#bullet.pos += bullet.dir * delta * bullet.speed
	bullet[0] += bullet[1] * delta * bullet[2]

func set_inactive(bullet_id):
	Lists.remove_queue.append(bullet_id)
