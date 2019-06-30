extends TextureButton

signal unit_button_pressed

var connected_unit = null

func _pressed():
	emit_signal("unit_button_pressed")
	
func connector(obj, unit):
	connect("unit_button_pressed", obj, "unit_button_pressed", [self])
	connected_unit = unit
	print(unit.name)
	self.name = unit.name

func _process(delta):
	$HealthBar.max_value = connected_unit.max_health_points
	$HealthBar.value  = connected_unit.health_points