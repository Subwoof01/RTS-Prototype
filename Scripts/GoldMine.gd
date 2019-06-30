extends StaticBody2D

const STRUCTURE_TYPE = "GoldMine"

export var total_gold = 8000

onready var nav_map = get_node("/root/InGame/PlayableMap")

func _ready():
	
	var nav_mesh = Transform2D(Vector2(position.x - $CollisionShape2D.scale.x * 64, position.y - $CollisionShape2D.scale.y * 64),
		Vector2(position.x + $CollisionShape2D.scale.x * 64, position.y + $CollisionShape2D.scale.y * 64),
		position)
	
	var nav_polygon = NavigationPolygon.new()
	
	nav_map.navpoly_add(nav_polygon, nav_mesh)
	