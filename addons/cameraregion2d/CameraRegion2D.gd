@tool
extends Node2D
## A [Node2D] that defines an area for [CameraRegionController2D] to control the camera.
##
## [CameraRegion2D] is a node that represents a specific area where [CameraRegionController2D] adjusts the [member CameraRegionController2D.camera]'s behavior.
## The camera's position, zoom, or rotation are modified based on whether the [member CameraRegionController2D.target_node] is inside this region.
class_name CameraRegion2D

var _eds: EditorSelection
var _selected: bool = false
var _region: Rect2 = Rect2(0,0,-1,-1)

## The dimension of the [CameraRegion2D]. Size must be positive.
@export var size: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")):
	set(value):
		if value.x < 0 || value.y < 0:
			push_error("Size must be positive.")
			return
		size = value
		_region.size = size
		if centered:
			_region.position = -_region.size/2
		else:
			_region.position = Vector2.ZERO
		queue_redraw()
## Determines whether the [CameraRegion2D] is centered around its position.
@export var centered: bool = true:
	set(value):
		centered = value
		if centered:
			_region.position = -_region.size/2
		else:
			_region.position = Vector2.ZERO
		queue_redraw()
## The camera zoom when the target is inside this region
@export_custom(PROPERTY_HINT_LINK, "camera_zoom") var camera_zoom: Vector2 = Vector2.ONE
## The camera rotation when the target is inside this region
@export_range(-360, 360, 0.1, "radians_as_degrees") var camera_rotation: float = 0
## Specifies the transition when entering this region.
@export var transition: CameraTransition


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_eds = EditorInterface.get_selection()
		if not _eds.is_connected("selection_changed", _on_selection_changed):
			_eds.connect("selection_changed", _on_selection_changed)


func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if !transition:
		return 
	if transition.position:
		transition.position.bake()
	if transition.zoom:
		transition.zoom.bake()
	if transition.rotation:
		transition.rotation.bake()


func _draw():
	if Engine.is_editor_hint():
		print(size)
		var c
		if _selected:
			c = Color.hex(0xd1ad00ff)
		else:
			c = Color.hex(0x0099b2ff)
		draw_rect(_region, c, false, -1)


func _get_configuration_warnings() -> PackedStringArray:
	var parent = get_parent()
	if parent && !parent is CameraRegionController2D:
		return ["CameraRegion2D must be a child of CameraRegionController2D to function properly.\nPlease move it under a CameraRegionController node in the scene tree."]
	return []


func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		if what == NOTIFICATION_PARENTED:
			_get_configuration_warnings()


func _on_selection_changed():
	var selected_nodes = _eds.get_selected_nodes()
	if selected_nodes:
		_selected = (selected_nodes[0] == self)
		queue_redraw()


## Returns [code]true[/code] if the region contains the given point. By convention, points on the right and bottom edges are not included.
func has_point(point: Vector2) -> bool:
	return _region.has_point(point - global_position)


## Returns the camera position based on the [param target] position 
func get_camera_position(target: Vector2) -> Vector2:
	var camera_position = Vector2.ZERO
	var camera_size = get_viewport().get_visible_rect().size/camera_zoom
	var w = abs(camera_size.x * cos(camera_rotation)) + abs(camera_size.y * sin(camera_rotation))
	var h = abs(camera_size.y * cos(camera_rotation)) + abs(camera_size.x * sin(camera_rotation))
	if (w > _region.size.x):
		camera_position.x = _region.get_center().x+global_position.x
	else:
		camera_position.x = clamp(target.x, _region.position.x+w/2+global_position.x, _region.end.x-w/2+global_position.x)
	if (h > _region.size.y):
		camera_position.y = _region.get_center().y+global_position.y
	else:
		camera_position.y = clamp(target.y, _region.position.y+h/2+global_position.y, _region.end.y-h/2+global_position.y)		
	return camera_position
