extends Line2D

var maxlen = 2
var point

func _physics_process(delta):
	while get_point_count() > maxlen:
		remove_point(0)
