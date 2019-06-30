extends Node2D

const box_colour = Color(1, 1, 1)
const box_line_width = 3

var is_visible = false
var m_pos = Vector2()
var start_select_pos = Vector2()

func _draw():
	if is_visible && start_select_pos != m_pos:
		draw_line(start_select_pos, Vector2(m_pos.x, start_select_pos.y), box_colour, box_line_width)
		draw_line(start_select_pos, Vector2(start_select_pos.x, m_pos.y), box_colour, box_line_width)
		draw_line(m_pos, Vector2(m_pos.x, start_select_pos.y), box_colour, box_line_width)
		draw_line(m_pos, Vector2(start_select_pos.x, m_pos.y), box_colour, box_line_width)
		#print("m_pos: %s" % m_pos)
		
func _process(delta):
	update()
