extends Node2D

#CONNECT GLOBAL TIMER-NODE (show mechanic(visual) - wait - execute on timeout)
#CREATE LIST OF HIT CIRCLES AROUND THE MAP - randrange x,y
#CREATE ROTATION HITBOX - area2d + hitbox + rotation script

onready var viewport = get_viewport_rect().size ##

onready var mechTimer = $MechanicTimer
onready var displacementNode = $DisplaceNode
onready var raycast = $DisplaceNode/AOEcast

onready var targetNode

export var use_map_mechs = false
export var is_active = false
export var is_circleAOE = false
export var radius = 40
export var aoeSize = Vector2(0, 1000)
export var rotationSpeed = 3000

var circles_AOE = []

export var is_fieldsAOE = false
var fieldsAOEPosition = []
export var fields_amount = 2

## MM - MATS:
onready var mesh_instance = $Sprite_to_mesh
onready var multimeshInstance2d = $MultiMeshInstance2D
onready var swapSprite = preload("res://Resources/Bullets/bullet_01.png")

enum Type {
	INACTIVE,
	CIRCLE,
	FIELD
}

export (Type) var state

var color = Color(1,1,1,0)
var active = false

var multi_mesh

## vars for arc aoe
export var selected_range = false
var facing # is facing direction of sprite node
export var aoe_scalar_range = 0.5

func _ready():
	targetNode = Lists.get_current_player_node()
	state = 0
	displacementNode.position = viewport * 0.5 ##Center node
	raycast.set_cast_to(aoeSize)
	raycast.position = Vector2(0, radius)
	
#	check_fov()##added

##ADD STATE MACHINE!!!

func _process(delta):
	update()
	match state:
		0:
			pass
		1: ## CIRCLE AOE ##
			if mechTimer.is_stopped() && !active:
				circle_indicator() ##INDICATE AOE
				mechTimer.start()
			if active:
				## DO COLLISION DETECTION ##
				check_zone()
		2: ## FIELDS AOE ##
			if mechTimer.is_stopped() && !active:
				if !fieldsAOEPosition.size() == fields_amount: ## only generated once!
					fieldsAOEPosition.clear()
					generatePositionsList(fields_amount)
				displace_on_mesh()
				mechTimer.start()
			if active:
				## ENABLE COLLISIONS - Swap Sprite ##
				if !Lists.fieldsAOE.size() > 0:
					generateFields(fieldsAOEPosition)
				elif Lists.fieldsAOE.size() > 0 && mechTimer.is_stopped():
					mechTimer.start()
					print("Timer countdown started.")
				else:
					pass

func circle_indicator():
	color = Color(1,1,1,.5)

func _input(event):
	if event.is_action_pressed("screen_input"):
		if !state == 1:
			state = 1
		else:
			 state = 0

func check_fov():
	var enemy_pos = displacementNode.position #DISPLACEMENT POS
	var target_pos = targetNode.position #REPLACE WITH PLAYER
	var dir = (enemy_pos.direction_to(target_pos)).normalized()
	facing = (displacementNode.to_global(Vector2(0,1)) - displacementNode.global_position)
#	print(rad2deg(acos(0.5))) ## ANGLE BETWEEN with ^-1cos
	if dir.dot(facing) > aoe_scalar_range:
		print("HIT BY CONE-AOE")

func check_zone():
	var proximity_vector = (displacementNode.position - targetNode.position).length()
	if (proximity_vector > radius) && (proximity_vector < radius + aoeSize.y):
		if selected_range:
			check_fov()
		else:
			print("HIT BY CIRCLE-AOE")
	else:
		print("SAVE ZONE")
	state = 0
	
func _draw():
	#draw_circle(viewport * .5, radius + aoeSize.y, Color(1,1,1,1))
	var new_radius = radius + (aoeSize.y)*.5
	## ARC AOE: ##
	if active && selected_range:
		#FACING CALCULATED BY DISPLACEMENT NODE GLOBAL ROTATION-FACING
		var aoeVecFrom = facing.rotated(-acos(aoe_scalar_range))
#		var aoeVecTo = aoeVecFrom.rotated(2*acos(aoe_scalar_range)) ## ROTATED BY 2*radians
		var startAngle = Vector2(1,0).angle_to(aoeVecFrom) ## DRAWARC ANGLES START FROM VEC2(1,0) -> this side(goCW)
		var endAngle = startAngle + (2*acos(aoe_scalar_range))
		draw_arc(displacementNode.position,new_radius,startAngle,endAngle,100,color,aoeSize.y)
	elif active:
		## FULL CIRCLE: ##
		draw_arc(displacementNode.position, new_radius, 0, TAU, 100,color,aoeSize.y)
	else:
		pass
	
func generatePositionsList(amount):
	for _i in range(amount):
			var random_position = Vector2(rand_range(0,viewport.x), rand_range(0,viewport.y))
			fieldsAOEPosition.append(random_position)

func displace_on_mesh():
	multi_mesh = multimeshInstance2d.multimesh
	multi_mesh.mesh = mesh_instance.mesh
	multi_mesh.instance_count = fieldsAOEPosition.size()
	multimeshInstance2d.texture = swapSprite ### SWAPPABLE - ADJUST TO MESH SIZE ####
	var count = 0
	for instance in multi_mesh.instance_count:
		var pos = fieldsAOEPosition[count]
		count += 1
		var transform2d = Transform2D(0,pos)
		multi_mesh.set_instance_transform_2d(instance, transform2d)

func cleanFields():
	for field in Lists.fieldsAOE:
		Physics2DServer.free_rid(field.body)
	Lists.fieldsAOE.clear()
	multi_mesh.set_instance_count(0)
	#fieldsAOEPosition.clear()

func generateFields(fieldsAOEPosition):
	var shape = Physics2DServer.rectangle_shape_create()
	Physics2DServer.shape_set_data(shape, Vector2(16,16)) ## revise this!!
	#Physics2DServer Rectangles + position(List[i])
	for i in range(fieldsAOEPosition.size()):
		var body = Physics2DServer.body_create()
		Physics2DServer.body_set_collision_layer(body, 1)
		Physics2DServer.body_set_space(body, get_world_2d().get_space())
		Physics2DServer.body_add_shape(body, shape)
		var transform2d = Transform2D()
		var position = fieldsAOEPosition[i]
		transform2d.origin = position
		Physics2DServer.body_set_mode(body,Physics2DServer.BODY_MODE_STATIC)
		Physics2DServer.body_set_state(body, Physics2DServer.BODY_STATE_TRANSFORM, transform2d)

		var field_info = {"position": position, "body": body}
		Lists.fieldsAOE.append(field_info)

func _on_MechanicTimer_timeout():
	#color = Color(0,0,0,0) #indicator = false
	active = true ##EANBLE MECHANIC LOOP##
	if state == 2 && Lists.fieldsAOE.size() > 0:
		displace_on_mesh() ## clean drawings ## make func later!
		cleanFields()
		active = false
		state = 0
