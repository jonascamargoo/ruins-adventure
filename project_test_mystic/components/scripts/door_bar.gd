extends Area2D

class_name DoorComponent

var _player_ref: CharacterBody2D = null

@export_category("Variables")
#1250 por 370
#522 por 236
@export var _teleport_position: Vector2

@export_category("Objects")
@export var _animation: AnimationPlayer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(_body) -> void:
	$DoorFx.play()
	
	if _body is CharacterBody2D:
		_player_ref = _body
		_animation.play("open")

func _on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "open":
		_player_ref.global_position = _teleport_position
		
