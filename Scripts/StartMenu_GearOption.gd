extends Node2D

var activeFlag = false
var growing = true
var tLabel

func _ready():
	tLabel = get_node("Label")

func SetAsActive():
	activeFlag = true	
	
func SetAsPassive():
	activeFlag = false

func setOptionText(tText):
	tLabel.text = tText

func SetFontAndSize(tFont,tSize,tText):
	setOptionText(tText)
	tLabel.position = Vector2(tLabel.position.x, tLabel.position.y)
	tLabel.position = Vector2(tLabel.position.x - tLabel.size.x/2, tLabel.position.y - tLabel.size.y)

func _process(delta):
	if activeFlag :
		if growing :
			tLabel.scale.x += 0.2 * delta
			tLabel.scale.y += 0.2 * delta
		else :
			tLabel.scale.x -= 0.2 * delta
			tLabel.scale.y -= 0.2 * delta
		
		if tLabel.scale.x > 1.2 :
			growing = false
		elif tLabel.scale.x < 1 :
			growing = true
	elif not activeFlag and tLabel.scale.x != 1 :
		tLabel.scale.x = 1
		tLabel.scale.y = 1
