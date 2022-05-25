extends "res://Scripts/Bullets.gd"

onready var viewport

var instance_id

#VRAY COLLISION:
var vMapSize = Vector2(64,64)
var vCellSize = Vector2(15,15) #Bullet-Dimensions
var vecMap = Lists.mapData
var vRayStart; var vRayDir; var vMapCheck; 
var bTileFound = false
var bulletSpeed = 0.0
var vRayLength1D = Vector2.ZERO
var vStep = Vector2.ZERO
var vRayUnitStepSize = Vector2.ZERO
var vIntersection = Vector2.ZERO
var vPlayer = Vector2.ZERO
var activeCell



var emission_position setget set_emission_position
var emission_direction setget set_emission_direction
var emission_speed setget set_emission_speed
var is_destructible setget set_is_destructible

var player setget set_player_node
var target setget set_target_node

func _ready():
	viewport = get_viewport_rect().size
	generateGrid()

func checkBounds(bullet):
	var bulletPos = bullet[0]
	var dotABAM = (Vector2(0, viewport.y) - Vector2(0,0)).dot( (bulletPos - Vector2(0,0)))
	var dotABAB = (Vector2(0, viewport.y) - Vector2(0,0)).dot((Vector2(0, viewport.y) - Vector2(0,0)))
	var dotACAM = (Vector2(viewport.x, 0) - Vector2(0,0)).dot( (bulletPos - Vector2(0,0)))
	var dotACAC = (Vector2(viewport.x, 0) - Vector2(0,0)).dot((Vector2(viewport.x, 0) - Vector2(0,0)))
	
	if( (dotABAM >= 0 && dotABAM <= dotABAB) && (dotACAM >= 0 &&  dotACAM <= dotACAC) ):
		return 0
	else:
		return 1

func bulletHandlerProcessLoop():
	for i in range(vecMap.size()): #vray collision-grid:
		vecMap[i] = 0

#	for bullet in Lists.n_bullet_list:
#		update_bullet_pos(Lists.n_bullet_list.get(bullet), delta)
#		if checkBounds(Lists.n_bullet_list.get(bullet)):
#			set_inactive(bullet)
#		#vray:
#		if Lists.dest_bullet_list.has(bullet):
#			updateCollisionGrid(Lists.n_bullet_list.get(bullet))
			
#	dda_check(delta)

#	update() ## TODO: DDA DEBUG REMOVE LATER!

#	redrawMultimesh(multimesh2d, mesh_instance)

func request_bullet():
	create_bullet(emission_position, emission_direction, emission_speed, is_destructible)

func updateRemoveQueue():
	if Lists.remove_queue.size() > 0:
		for element in Lists.remove_queue:
			var index = Lists.remove_queue.pop_front()
			Lists.n_bullet_list.erase(index)
			if Lists.dest_bullet_list.has(index):
				Lists.dest_bullet_list.erase(index)

func checkPoint(instance, playerNode, targetNode):
	var dotAMAB
	var dotABAB
	var dotAMAD
	var dotADAD
	## BOX NEW ##
	var target = targetNode.position
	var player = playerNode.position
	var point = (Lists.n_bullet_list.get(instance))[0]
	var PE = (target - player).normalized()
	var PPE = -(PE.rotated(acos(0.5))) * 50
	var PPE2 = PE.rotated(acos(-0.5)) * 50
	
	var RA = (PPE + player)
	var PRD = (-PPE + player)
	var PRB = (-PPE2 + player)
	
	## Player BOX
	dotAMAB = (point - PRB).dot((RA - PRB))
	dotABAB = (RA - PRB).dot((RA - PRB))
	dotAMAD = (point - PRB).dot((PRD - PRB))
	dotADAD = (PRD - PRB).dot((PRD - PRB))

	if( ((dotAMAB >= 0) && (dotAMAB <= dotABAB)) && ( (dotAMAD >= 0) && (dotAMAD <= dotADAD) )):
		# COMPARE ALL POINTS TO PLAYER COLLIDER
		checkPointCollisions(instance, player, 22)

func checkPointCollisions(instance, comparison_position, radius, comparisonArray = null):
	##19(Player collision Redius) + 16(Bullet collision Radius)
	var bulletPos = (Lists.n_bullet_list.get(instance))[0]
	var compVec =  (bulletPos - comparison_position).length()
	if  compVec < radius:
		set_inactive(instance)
		if !comparisonArray == null:
			comparisonArray.erase(comparison_position)

func redrawMultimesh(multimesh2d, mesh_instance, color = Color(.8,.3,0,1)):
	var multi_mesh = multimesh2d.multimesh
	multi_mesh.mesh = mesh_instance.mesh
	multi_mesh.instance_count = Lists.n_bullet_list.size()
	multimesh2d.texture = mesh_instance.get_texture()
	for instance in multi_mesh.instance_count:
		var index = Lists.n_bullet_list.keys()[instance]
		if Lists.dest_bullet_list.has(index):
			multi_mesh.set_instance_color(instance, color)
		var pos = Transform2D()
		pos = pos.translated(Lists.n_bullet_list.get(index)[0])
		multi_mesh.set_instance_transform_2d(instance, pos)

#SETTERS
func set_emission_position(position):
	emission_position = position
func set_emission_direction(direction):
	emission_direction = direction
func set_emission_speed(speed):
	emission_speed = speed
func set_is_destructible(destructible):
	is_destructible = destructible
func set_player_node(playerN):
	player = playerN
func set_target_node(targetN):
	target = targetN
	
#CLEAN-UP
func _exit_tree():
	Lists.n_bullet_list.clear()

## DDA COLLISION GEN:

func generateGrid():
	vMapSize.x = int(viewport.x / vCellSize.x)+2
	vMapSize.y = int(viewport.y / vCellSize.y)+2
	vecMap.resize(vMapSize.x * vMapSize.y)

func updateCollisionGrid(point):
	#FILL COLLISION GRID(0 , 1=collider):
	var vCell = Vector2(int(point[0].x / vCellSize.x),int(point[0].y / vCellSize.y))
	
	if !vecMap[vCell.y * vMapSize.x + vCell.x] == 1:
		vecMap[vCell.y * vMapSize.x + vCell.x] = 1
		# adds cell index
		point[3] = vCell.y * vMapSize.x + vCell.x

func dda_check(delta):
	var vMouseCell = target.position / vCellSize #TARGET
	vRayStart = player.position / vCellSize
	vRayDir = (vMouseCell - vRayStart).normalized()
	#scaling-factor
	vRayUnitStepSize.x = sqrt(1+(vRayDir.y/vRayDir.x)*(vRayDir.y/vRayDir.x))
	vRayUnitStepSize.y = sqrt(1+(vRayDir.x/vRayDir.y)*(vRayDir.x/vRayDir.y))
	vMapCheck = Vector2(int(vRayStart.x), int(vRayStart.y))
	
	#starting cond check:
	if (vRayDir.x < 0): #going left
		vStep.x = -1
		vRayLength1D.x = (vRayStart.x - float(vMapCheck.x)) * vRayUnitStepSize.x #startingRayLength
	else:
		vStep.x = 1
		vRayLength1D.x = (float(vMapCheck.x+1) - vRayStart.x) * vRayUnitStepSize.x
	if (vRayDir.y < 0):
		vStep.y = -1
		vRayLength1D.y = (vRayStart.y - float(vMapCheck.y)) * vRayUnitStepSize.y #startingRayLength
	else:
		vStep.y = 1
		vRayLength1D.y = (float(vMapCheck.y+1) - vRayStart.y) * vRayUnitStepSize.y
	
	var fMaxDistance = 200.0 #rayLength
	var fDistance = 0.0
	bTileFound = false
	while(!bTileFound && fDistance < fMaxDistance):
		if (vRayLength1D.x < vRayLength1D.y):
			vMapCheck.x += vStep.x
			fDistance = vRayLength1D.x
			vRayLength1D.x += vRayUnitStepSize.x
		else:
			vMapCheck.y += vStep.y
			fDistance = vRayLength1D.y
			vRayLength1D.y += vRayUnitStepSize.y
		#Check Array Bounds
		if vMapCheck.x >= 0 && vMapCheck.x < vMapSize.x && vMapCheck.y >= 0 && vMapCheck.y < vMapSize.y:
			#Check Solid Cell
#			if (vMapCheck.y * vMapSize.x + vMapCheck.x) <= vecMap.size():
			if vecMap[vMapCheck.y * vMapSize.x + vMapCheck.x] == 1: #collision = true
				bTileFound = true
	
	if bTileFound:
		activeCell = vMapCheck.y * vMapSize.x + vMapCheck.x
		vIntersection = vRayStart + vRayDir * fDistance #POINT OF COLLISION

#func _draw():
#	if bTileFound:
#		draw_arc(vIntersection * vCellSize,10,0,TAU,6,Color(0,1,0), 2,false)
#		draw_line(player.position, vIntersection*vCellSize, Color(1,1,1), 7, false)
#	#DRAW GRID:
#	for y in range(vMapSize.y):
#		for x in range(vMapSize.x):
#			var cell = vecMap[y * vMapSize.x +x]
#			if cell == 1:
#				draw_rect(Rect2(Vector2(x,y) * vCellSize, vCellSize), Color(0,1,0), true,1,false)
#			draw_rect(Rect2(Vector2(x,y) * vCellSize, vCellSize), Color(1,1,1), false,1,false)

func removeActiveCellObject():
	if bTileFound:
		for bullet in Lists.n_bullet_list:
			if Lists.dest_bullet_list.has(bullet):
				if Lists.n_bullet_list.get(bullet)[3] == activeCell:
					set_inactive(bullet)
