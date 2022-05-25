extends Node2D

onready var bullet_loader = get_node("/root/BulletLoader")

var boundsX
var boundsY

var state

func _ready():
	BulletLoader.set_player_node($Player)
	BulletLoader.set_target_node($Enemy)
	BulletLoader.redrawMultimesh($N_BulletMesh, $MeshInstance)

func _physics_process(delta):
	BulletLoader.updateRemoveQueue()
	BulletLoader.bulletHandlerProcessLoop()
	
	for bullet in Lists.n_bullet_list:
		BulletLoader.update_bullet_pos(Lists.n_bullet_list.get(bullet), delta)
		
		if Engine.get_idle_frames() % 2 == 0:
			BulletLoader.checkPoint(bullet, $Player, $Enemy)
			
		if BulletLoader.checkBounds(Lists.n_bullet_list.get(bullet)):
			BulletLoader.set_inactive(bullet)
		if Lists.dest_bullet_list.has(bullet):
			BulletLoader.updateCollisionGrid(Lists.n_bullet_list.get(bullet))
	BulletLoader.dda_check(delta)
	BulletLoader.redrawMultimesh($N_BulletMesh, $MeshInstance)

func _on_Player_body_shape_entered(body_rid, _body, _body_shape_index, _local_shape_index):
	for field in Lists.fieldsAOE:
		if field.body == body_rid:
			print("Hit by Field!")
