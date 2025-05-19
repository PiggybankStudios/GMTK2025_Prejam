extends CanvasLayer

var selected_level = preload("res://Spaces/space_Main.tscn").instantiate()

var MenuIsMoving = 0
var MenuMoveDecision = 0
var MenuTargetReached = true
var MenuItems = 5
var MenuItem = 5
var MenuTarget = 5
var MenuSpeed = 2
var iterations = 0
var MenuIsPaused = false
var MenuPauseMenu = false
var MainGame = "/root/MainScene_Root"
var SndRotate1 : AudioStreamPlayer
var SndRotate2 : AudioStreamPlayer
var SndClick : AudioStreamPlayer
var quickPauseAfterDecision = false
var quickPausetime = 0
var quickPausetimeMax = 0.3

func _ready():
	SndRotate1 = get_node("SoundEffectRotate1")
	SndRotate2 = get_node("SoundEffectRotate2")
	SndClick = get_node("SoundEffectClick")

func _input(event):
	if MenuIsPaused :
		return
	
	if (event is InputEventMouseButton and event.is_pressed()):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			var mousePos = event.global_position
		#var mousePos = get_local_mouse_position()
			print(event.global_position)
	
	if event.is_action_pressed("ui_left"):
		if (MenuIsMoving == 0 and not quickPauseAfterDecision):
			MenuMoveDecision = 1
			SndRotate1.play()
	elif event.is_action_pressed("ui_right"):
		if (MenuIsMoving == 0 and not quickPauseAfterDecision):
			MenuMoveDecision = -1
			SndRotate2.play()
	elif event.is_action_pressed("ui_accept"):
		print("accept ",MenuItem)
		if (MenuIsMoving == 0 and not quickPauseAfterDecision):
			SndClick.play()
			quickPauseAfterDecision = true
		
func _process(delta):
	if MenuIsPaused :
		return
		
	if quickPauseAfterDecision :
		quickPausetime += delta
		if quickPausetime > quickPausetimeMax :
			quickPausetime = 0
			quickPauseAfterDecision = false
			HandleMenuSelection()
		
	iterations += 1
	if MenuIsMoving != 0 :
		if MenuTargetReached :
			MenuIsMoving = 0
		else:
			var BigGearLeft = get_child(0).get_child(0)
			var BigGearRight = get_child(0).get_child(1)
			var MenuGear = get_child(0).get_child(2)
			var cRot = 2*PI/5
			
			MenuGear.rotation += MenuSpeed*MenuIsMoving*delta
			BigGearLeft.rotation -= MenuSpeed*MenuIsMoving*delta*5/8
			BigGearRight.rotation -= MenuSpeed*MenuIsMoving*delta*5/8
			
			var aRot = MenuGear.rotation
			if aRot > 2*PI:
				MenuGear.rotation -= 2*PI
				aRot -= 2*PI
			elif aRot < 0:
				MenuGear.rotation += 2*PI
				aRot += 2*PI
				
			if MenuIsMoving < 0:
				var localTarget = MenuTarget
				if (localTarget == 0):
					localTarget = 5
				var cDiff = cRot*localTarget - aRot
				if (aRot < cRot*localTarget and abs(cDiff) < 1) :
					MenuTargetReached = true
					MenuMoveDecision = 0
					MenuItem = MenuTarget
					var difference
					MenuGear.rotation += cDiff
					BigGearLeft.rotation -= cDiff*5/8
					BigGearRight.rotation -= cDiff*5/8
					var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
					tLabel.SetAsActive()
			elif MenuIsMoving > 0:
				var localTarget = MenuTarget
				if (localTarget == 5):
					localTarget = 0
				var cDiff = aRot - cRot*localTarget
				if (aRot > cRot*localTarget and abs(cDiff) < 1):
					MenuTargetReached = true
					MenuMoveDecision = 0
					MenuItem = MenuTarget
					MenuGear.rotation -= cDiff
					BigGearLeft.rotation += cDiff*5/8
					BigGearRight.rotation += cDiff*5/8
					var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
					tLabel.SetAsActive()
						
	elif MenuMoveDecision != 0 :
		MenuIsMoving = MenuMoveDecision
		MenuTargetReached = false
		MenuTarget += MenuIsMoving
		if MenuTarget < 1 :
			MenuTarget = MenuItems
		elif MenuTarget > MenuItems :
			MenuTarget = 1
		var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
		tLabel.SetAsPassive()
	
func HandleMenuSelection():
	if (MenuItem == 1): #exit
		get_tree().quit()
	elif (MenuItem == 2): #credits
		pass
	elif (MenuItem == 3): #options
		pass
	elif (MenuItem == 4): #levels
		pass
	elif (MenuItem == 5): #New Game/Continue
		if MenuPauseMenu :
			print("Unpausing game")
			get_tree().root.get_node(MainGame).unPauseMe()
			getPaused()
			MenuPauseMenu = true
		else :
			print("Starting game")
			get_tree().root.add_child(selected_level)
			getPaused()
			var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
			tLabel.setOptionText("Continue")
			MenuPauseMenu = true

func getPaused():
	hide()
	var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
	#tLabel.SetAsPassive()
	process_mode = Node.PROCESS_MODE_DISABLED
	#MenuIsPaused = true
	#print_tree_pretty()
	
func getUnPaused():
	show()
	var tLabel = get_child(0).get_child(2).get_child(5 - MenuItem)
	#tLabel.SetAsActive()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	#MenuIsPaused = false
	
