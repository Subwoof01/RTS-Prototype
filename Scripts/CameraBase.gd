extends Node2D

const MOVE_MARGIN = 20
const MOVE_SPEED = 800

var collision_shape_ids = {}  
var selected_units = []
var team = 0
var start_select_pos = Vector2()
var unit_buttons = []

onready var selection_box = get_node("/root/InGame/SelectionBox")
onready var move_arrows_animation = get_node("/root/InGame/MoveArrows")
onready var ui_base = get_node("/root/InGame/UI/Base")

onready var fighter_button = preload("res://Scenes/FighterButton.tscn")
onready var worker_button = preload("res://Scenes/WorkerButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var m_pos = get_viewport().get_mouse_position()
	var m_pos_global = get_parent().get_global_mouse_position()
	
	calc_move(m_pos, delta)
	
	if Input.is_action_just_pressed("main_command"):
		var result = raycast_from_mouse(m_pos_global, 3)
		if result.size() > 0:
			if result.collider.STRUCTURE_TYPE == "GoldMine":
				if selected_units.size() > 0:
					for unit in selected_units:
						if unit.UNIT_TYPE != "Worker":
							break
						else:
							unit.work_target = get_structure_under_mouse(m_pos_global, m_pos)
		else:
			move_selected_units(m_pos_global)
		
	if Input.is_action_just_pressed("alt_command"):
		selection_box.start_select_pos = m_pos_global
		start_select_pos = m_pos_global
	if Input.is_action_pressed("alt_command"):
		selection_box.m_pos = m_pos_global
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("alt_command"):
		select_units(m_pos_global, m_pos)
		
	#print(m_pos_global)
	

func calc_move(m_pos, delta):
	var view_size = get_viewport().size
	var move_vector = Vector2()
	
	# Left
	if m_pos.x < MOVE_MARGIN:
		move_vector.x -= 1
	# Up
	if m_pos.y < MOVE_MARGIN:
		move_vector.y -= 1
	# Right
	if m_pos.x > view_size.x - MOVE_MARGIN:
		move_vector.x += 1
	# Down
	if m_pos.y > view_size.y - MOVE_MARGIN:
		move_vector.y += 1
	
	position.x += move_vector.x * delta * MOVE_SPEED
	position.y += move_vector.y * delta * MOVE_SPEED
	#print(position)

func move_selected_units(m_pos):
	move_arrows_animation.position = m_pos
	move_arrows_animation.show()
	move_arrows_animation.play()
	for unit in selected_units:
		unit.move_to(m_pos)

func select_units(m_pos, m_pos_view):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_select_pos) < 16:
		var u = get_unit_under_mouse(m_pos, m_pos_view)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_select_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units
		create_buttons()

func get_unit_under_mouse(m_pos, m_pos_view):
	var result = raycast_from_mouse(m_pos, 2)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider
	elif result.size() == 0 && m_pos_view.y < 810:
		for unit in selected_units:
			unit.deselect()
		selected_units.clear()
		create_buttons()
	
func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
		
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(unit.position):
			box_selected_units.append(unit)
			
	return box_selected_units
	
func get_structure_under_mouse(m_pos, m_pos_view):
	var result = raycast_from_mouse(m_pos, 3)
	if result:
		return result.collider
	
func raycast_from_mouse(m_pos, collision_mask):
	var space_state = get_world_2d().direct_space_state
	var left = Vector2(m_pos.x - 5, m_pos.y)
	var right = Vector2(m_pos.x + 5, m_pos.y)
	
	var result = space_state.intersect_ray(left, right)
	print(result)
	return result

func _on_MoveArrows_animation_finished():
	move_arrows_animation.stop()
	move_arrows_animation.hide()
	
func create_buttons():
	delete_buttons()
	for unit in selected_units:
		if not unit_buttons.has(unit.name):
			var b 
			if unit.UNIT_TYPE == "Fighter":
				b = fighter_button.instance()
			if unit.UNIT_TYPE == "Worker":
				b = worker_button.instance()
			b.connector(self, unit)
			b.rect_position = Vector2(unit_buttons.size() * 68 + 256, 850)
			ui_base.add_child(b)
			unit_buttons.append(b.name)

func delete_buttons():
	for button in unit_buttons:
		if ui_base.has_node(button):
			var b = ui_base.get_node(button)
			b.queue_free()
			ui_base.remove_child(b)
	unit_buttons.clear()
	
func unit_button_pressed(obj):
	for unit in selected_units:
		if unit.name == obj.name:
			print(unit.name)
			selected_units.erase(unit)
			unit.deselect()
			create_buttons()
			break