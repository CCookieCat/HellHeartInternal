extends Node2D

var remove_queue = []
## REWORK
var draw_list = {}
var n_bullet_list = {}
var dest_bullet_list = {}

#vray DDA
var mapData = []

var pBullets = {}

var fieldsAOE = []

var active_objects = [] setget set_a_obj,get_obj
var current_player_node setget set_current_player_node

func set_a_obj(obj):
	active_objects.append(obj)

func get_a_obj(index):
	return active_objects[index]
func get_obj():
	return active_objects
func remove_a_obj(object):
	var index = active_objects.find(object)
	active_objects.remove(index)

func add_remove_queue(instance_id):
	remove_queue.push_back(instance_id)
func get_remove_queue_item(index):
	return remove_queue[index]
func get_remove_queue():
	return remove_queue

func set_current_player_node(node):
	current_player_node = node
func get_current_player_node():
	return current_player_node
