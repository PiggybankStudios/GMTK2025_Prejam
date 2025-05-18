extends Node3D

var mouse_captured: bool = false;
var lookDir: Vector2;

func _ready() -> void:
#
	set_capture_mouse(true);
#

func _physics_process(elapsedSecs: float) -> void:
#
	var timeScale: float = elapsedSecs / Gl.TARGET_SECS;
	if (mouse_captured):
	#
		var inputVec = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down");
		if (inputVec.length() > 0):
		#
			lookDir += inputVec * timeScale * Gl.MOUSE_SENSITIVITY;
		#
	#
	if (Input.is_key_pressed(KEY_LEFT)):
	#
		lookDir.x += 0.1;
	#
	if (Input.is_key_pressed(KEY_RIGHT)):
	#
		lookDir.x -= 1.0;
	#
	
	lookDir.x = fmod(lookDir.x, 2*PI);
	lookDir.y = clamp(lookDir.x, -PI/2.0 + Gl.LOOK_UP_DOWN_CLAMP_EPSILON, PI/2.0 - Gl.LOOK_UP_DOWN_CLAMP_EPSILON);
	
	if (Input.is_key_pressed(KEY_ESCAPE) and mouse_captured):
	#
		set_capture_mouse(false);
	#
	if (not get_window().has_focus() and mouse_captured):
	#
		set_capture_mouse(false);
	#
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_captured):
	#
		set_capture_mouse(true);
	#
	
	rotation.y = lookDir.x;
	# rotation.y = lookDir.y;
#

func _input(event):
#
	pass
#
	
func set_capture_mouse(capture: bool) -> void:
#
	if (mouse_captured != capture):
	#
		if (capture):
		#
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		#
		else:
		#
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		#
		mouse_captured = capture;
	#
#
