extends CharacterBody2D

var _state_machine

@export_category("Variables")
@export var _move_speed: float = 64.0

# significa que vai demorar mais tempo para retornar ao 0
@export var _friction:float = 0.2
# significa que vai demorar mais tempo para acelerar
@export var _acceleration: float = 0.4

@export_category("Objects")
@export var _animation_tree: AnimationTree = null

func _ready() -> void:
	# a partir desse playback poderemos viajar entre o idle e walk
	_state_machine = _animation_tree["parameters/playback"]

# _physics_process eh como se fosse nosso main
func _physics_process(_delta: float) -> void:
	_move()
	_animate()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	# verificando se o botao nao esta sendo pressionado
	if _direction != Vector2.ZERO:
		# dando um get nos parametros e atribuindo de acordo com a _direction
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)


func _animate() -> void:
	# verificando se o personagem ta em movimento
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")
