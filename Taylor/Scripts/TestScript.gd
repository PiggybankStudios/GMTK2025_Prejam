extends Node3D


@export var the_script: Script

func _get_configuration_warnings():
	if (not the_script): return ["the_script on home.gd has not been set to a valid value!"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
