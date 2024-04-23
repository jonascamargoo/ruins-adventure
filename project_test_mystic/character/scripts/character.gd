extends CharacterBody2D

@export_category("Variables")
@export var _move_speed: float = 64.0

# significa que vai demorar mais tempo para retornar ao 0
@export var _friction:float = 0.2
# significa que vai demorar mais tempo para acelerar
@export var _acceleration: float = 0.4

# _physics_process eh como se fosse nosso main
func _physics_process(_delta: float) -> void:
	_move()
	move_and_slide()

func _move() -> void:
	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	# verificando se o botao nao esta sendo pressionado
	if _direction != Vector2.ZERO:
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)
	

