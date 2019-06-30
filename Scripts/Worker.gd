extends KinematicBody2D

enum state {
	IDLE,
	WALKING,
	WORKING
}

const MOVE_SPEED = 100
const UNIT_TYPE = "Worker"
const STRUCTURE_TYPE = "none"

export var max_health_points = 40
export var health_points = 40
export var damage = 15
export var team = 0
export var carry_capacity = 20
export var current_carry = 0

var current_carry_type

var is_moving = false

# Gather speed per second
var work_speeds = { "gold_mining": 1 }
var last_tick = 0

var elapsed_time = 0

var path = []
var path_index = 0

var work_target = null
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
	
	elapsed_time += delta
	work(elapsed_time)

func move_to(target_pos):
	path = nav.get_simple_path(position, target_pos)
	path_index = 0
	#print(path)

func _physics_process(delta):
	if path_index < path.size():
		var move_vector = (path[path_index] - position)
		if move_vector.length() < 1.5:
			path_index += 1
			current_state = state.IDLE
		else:
			move_and_slide(move_vector.normalized() * MOVE_SPEED)
			current_state = state.WALKING

func work(time):
	var collision
	for i in get_slide_count():
		collision = get_slide_collision(i)
		if collision.collider.STRUCTURE_TYPE != "none":
			current_state = state.WORKING
			is_moving = false
			
	if work_target != null:
		#print(work_target)
		#if position > Vector2(work_target.position.x - 150, work_target.position.y - 150) or position < Vector2(work_target.position.x + 150, work_target.position.y + 150):
		if current_state != state.WORKING:
			move_to(work_target.position)
			is_moving = true
		elif time - last_tick > 1:
			is_moving = false
			if work_target.STRUCTURE_TYPE == "GoldMine":
				current_carry_type = "Gold"
				current_carry += 1

func select():
	health_bar.show()
	$SelectedBox.show()

func deselect():
	health_bar.hide()
	$SelectedBox.hide()