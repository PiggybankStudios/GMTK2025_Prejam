extends RigidBody3D

var speed : float = 30.0
var damage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move the bullet forwards
	global_position += -global_transform.basis.z * speed * delta
