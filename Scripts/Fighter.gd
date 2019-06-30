extends KinematicBody2D

enum state {
	IDLE,
	WALKING
}

const MOVE_SPEED = 150
const UNIT_TYPE = "Fighter"
const STRUCTURE_TYPE = "none"

export var max_health_points = 100
export var health_points = 100
export var damage = 15
export var team = 0

var path = []
var path_index = 0

var current_state = state.IDLE

onready var health_bar = $HealthBar
onready var nav = get_parent()

func _ready():
	pass

func _process(delta):
	if current_state == state.IDLE:
		$AnimatedSprite.animation = "Idle"
	if current_state == state.WALKING:
		$AnimatedSprite.animation = "Walking"
		
	health_bar.max_value = max_health_points
	health_bar.value = health_points

func move_to(target_pos):
	path = nav.get_simple_path(position, target_pos)
	path_index = 0
	print(path)

func _physics_process(delta):
	if path_index < path.size():
		var move_vector = (path[path_index] - position)
		if move_vector.length() < 1.5:
			path_index += 1
			current_state = state.IDLE
		else:
			move_and_slide(move_vector.normalized() * MOVE_SPEED)
			current_state = state.WALKING

func select():
	health_bar.show()
	$SelectedBox.show()

func deselect():
	health_bar.hide()
	$SelectedBox.hide()