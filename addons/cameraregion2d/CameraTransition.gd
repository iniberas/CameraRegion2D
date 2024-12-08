@tool
extends Resource
## A [Resource] that represent transition for the camera 
##
## [CameraTransition] is a resource that defines the behavior of a camera transition.
## It uses [Curve] to control the position, zoom, and rotation of the camera over time.
class_name CameraTransition


## The curve controlling the transition of the camera position over time.[br][br]
## - X-axis: Time, normalized from 0 (start of transition) to 1 (end of transition).[br]
## - Y-axis: Value, normalized from 0 (current position) to 1 (next position).[br]
@export var position: Curve
## The curve controlling the transition of the camera zoom over time.[br][br]
## - X-axis: Time, normalized from 0 (start of transition) to 1 (end of transition).[br]
## - Y-axis: Value, normalized from 0 (current zoom) to 1 (next zoom).[br]
@export var zoom: Curve
## The curve controlling the transition of the camera rotation over time.[br][br]
## - X-axis: Time, normalized from 0 (start of transition) to 1 (end of transition).[br]
## - Y-axis: Value, normalized from 0 (current rotation) to 1 (next rotation).[br]
@export var rotation: Curve
## The time it takes for the transition to finish
@export var transition_time: float = 1


func _init():
	if !position:
		position = Curve.new()
		position.add_point(Vector2.ZERO)
		position.add_point(Vector2.ONE)
	if !zoom:
		zoom = Curve.new()
		zoom.add_point(Vector2.ZERO)
		zoom.add_point(Vector2.ONE)
	if !rotation:
		rotation = Curve.new()
		rotation.add_point(Vector2.ZERO)
		rotation.add_point(Vector2.ONE)
