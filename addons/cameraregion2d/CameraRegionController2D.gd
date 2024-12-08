@tool
extends Node2D
## A node that manages [member camera] based on [member target_node]'s region.
##
## [b]CameraRegionController2D[/b] is a node that manages [Camera2D] behavior based on the [member target_node]'s interactions with [CameraRegion2D] nodes.
## It enables seamless [member camera] movement between defined regions and includes features such as camera shake effects and customizable transitions.
class_name CameraRegionController2D


## The [Camera2D] that this [CameraRegionController2D] will manage. This must be assigned for the [CameraRegionController2D] to function properly.
@export var camera: Camera2D:
	set(value):
		camera = value
		update_configuration_warnings()
## The [Node2D] that acts as the movement target for the [Camera2D]. This must be assigned for the [CameraRegionController2D] to function properly.
@export var target_node: Node2D:
	set(value):
		target_node = value
		update_configuration_warnings()
## If [code]true[/code], the [CameraRegionController2D] will stop controlling the [member camera]. This also stop the shaking effect.
@export var disabled: bool = false


var _regions: Array[CameraRegion2D]
var _current_region: CameraRegion2D
var _last_region: CameraRegion2D
var _last_position: Vector2
var _transition_progress: float
var _shake_time_left: float = 0.0
var _shake_speed: float = 1.0
var _shake_deviation: float = 10.0
var _shake_decay: float = 0.0
var _shake_random_factor: float = 1.0


## Emitted when the target node enters a new CameraRegion2D.
signal target_entered_region(region: CameraRegion2D)
## Emitted when the target node exits a CameraRegion2D.
signal target_exited_region(region: CameraRegion2D)
## Emitted when a camera transition begins. Only emited when there are transition.
signal transition_started
## Emitted when a camera transition ends. Only emited when there are transition.
signal transition_finished
## Emitted when the camera shake begins.
signal shake_started
## Emitted when the camera shake ends.
signal shake_finished


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	assert(target_node, "Please assign a Node2D to target_node")
	assert(camera, "Please assign a Camera2D to camera")
	_get_regions()
	_update_current_region()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if disabled || !target_node || !camera:
		return
	var target_position = target_node.global_position
	if _current_region:
		if _current_region.has_point(target_position):
			_calculate_camera_position(delta)
		else:
			emit_signal("target_exited_region", _current_region)
			_update_current_region()
	else:
		_update_current_region()
	if _shake_time_left > 0:
		_apply_shake(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var children = get_children()
	var region_count = 0
	var error = []
	if !camera:
		error.append("CameraRegionController2D requires a 'camera' property to function.\nPlease assign a Camera2D node to 'camera'.")
	if !target_node:
		error.append("CameraRegionController2D requires a 'target_node' property to function.\nPlease assign a Node2D to 'target_node'.")
	for child in children:
		if child is CameraRegion2D:
			region_count += 1
	if region_count == 0:
		error.append("CameraRegionController2D only works it has CameraRegion2D as a child.\nPlease add a CameraRegion2D node as a child.")
	return error


func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		if Engine.is_editor_hint():
			_get_configuration_warnings()
		_get_regions()


func _get_regions():
	var temp_regions:Array[CameraRegion2D] = []
	var children = get_children()
	for child in children:
		if child is CameraRegion2D:
			temp_regions.append(child)
	_regions = temp_regions


func _update_current_region():
	_transition_progress = 0
	if _current_region:
		_last_region = _current_region
	_current_region = null
	for region in _regions:
		if region.has_point(target_node.global_position):
			emit_signal("target_entered_region", region)
			if region.transition:
				emit_signal("transition_started")
			_current_region = region
			_last_position = camera.global_position
			break


func _calculate_camera_position(delta):
	var reg_trans = _current_region.transition
	if reg_trans:
		if _transition_progress < reg_trans.transition_time && _last_region:
			if reg_trans.position:
				camera.global_position = lerp(_last_position, _current_region.get_camera_position(target_node.position), reg_trans.position.sample_baked(_transition_progress/reg_trans.transition_time))
			else:
				camera.global_position = _current_region.get_camera_position(target_node.position)
			if reg_trans.zoom:
				camera.zoom = lerp(_last_region.camera_zoom, _current_region.camera_zoom, reg_trans.zoom.sample_baked(_transition_progress/reg_trans.transition_time))
			else:
				camera.zoom = _current_region.camera_zoom
			if reg_trans.rotation:
				camera.rotation = lerp(_last_region.camera_rotation, _current_region.camera_rotation, reg_trans.rotation.sample_baked(_transition_progress/reg_trans.transition_time))
			else:
				camera.rotation = _current_region.camera_rotation
		else:
			camera.global_position = _current_region.get_camera_position(target_node.position)
			camera.zoom = _current_region.camera_zoom
			camera.rotation = _current_region.camera_rotation
			return
		_transition_progress += delta
		if _transition_progress < reg_trans.transition_time:
			emit_signal("transition_finished")
	else:
		camera.global_position = _current_region.get_camera_position(target_node.position)
		camera.zoom = _current_region.camera_zoom
		camera.rotation = _current_region.camera_rotation


## Shakes the [member camera] for a specified [param time], with the given [param speed] and [param deviation].
## If [param decay] is [code]true[/code], the shake effect will gradually diminish in intensity over the duration.
func shake(time: float = 1.0, speed: float = 10.0, deviation: float = 1.0, decay: bool = false):
	_shake_time_left = time
	_shake_speed = speed
	_shake_deviation = deviation
	if decay:
		_shake_decay = deviation/time
	else:
		_shake_decay = 0.0
	_shake_random_factor = randf()
	emit_signal("shake_started")


func _apply_shake(delta):
	camera.offset.x = (cos(4*_shake_time_left*_shake_speed) + sin(5*(1+_shake_random_factor)*_shake_time_left*_shake_speed))*_shake_deviation/2
	camera.offset.y = (sin(4*_shake_time_left*_shake_speed) + cos(5*(1+_shake_random_factor)*_shake_time_left*_shake_speed))*_shake_deviation/2
	_shake_deviation -= _shake_decay*delta
	_shake_time_left -= delta
	if _shake_time_left < 0:
		emit_signal("shake_started")

## Stops the shake immediately.
func stop_shake():
	_shake_time_left = 0
