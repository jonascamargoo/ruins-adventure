extends CharacterBody2D

var _state_machine
var _is_attacking: bool = false

@export_category("Variables")
@export var _move_speed: float = 64.0


@export var _friction: float = 0.2 # significa que vai demorar mais tempo para retornar ao 0
@export var _acceleration: float = 0.4 # significa que vai demorar mais tempo para acelerar

# Quando crio uma categoria, ela aparece no canto direito da dela, junto com seus respectivos objetos
@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _animation_tree: AnimationTree = null

func _ready() -> void: # chamado quando o nó entra na árvore de cena pela primeira vez.
	_animation_tree.active = true # para ativar a animationTree, caso tenhamos esquecido de reativar ao editar alguma animation
	_state_machine = _animation_tree["parameters/playback"] # a partir desse playback poderemos viajar entre o idle e walk


# o delta eh o intervalo de tempo entre um frame e o outro, a funcao eh chamada a cada delta
func _physics_process(_delta: float) -> void:
	_move()
	_attack()
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
		_animation_tree["parameters/attack/blend_position"] = _direction
		
		velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, _direction.normalized().x * _move_speed, _friction)
	velocity.y = lerp(velocity.y, _direction.normalized().y * _move_speed, _friction)

func _attack() -> void:
	## se o botao de ataque for pressionado e nao tiver nenhum ataque em andamento
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false) # para ele parar de andar enquanto ataca
		_attack_timer.start()
		_is_attacking = true

func _animate() -> void:
	if _is_attacking:
		_state_machine.travel("attack")
		return
		
	# verificando se o personagem ta em movimento
	if velocity.length() > 3:
		_state_machine.travel("walk")
		return
	_state_machine.travel("idle")

# Quando o timer zerar, ele dispara um sinal. Esse sinal é representado por essa função
# Ao zerar, essa função é chamada
func _on_attack_timer_timeout() -> void:
	set_physics_process(true) # voltar a andar enquanto ataca
	_is_attacking = false


func _on_area_2d_body_entered(body) -> void:
	# se o corpo em questao for do tipo inimigo
	if body.is_in_group("enemy"):
		body.update_health(randi_range(1, 5)) # o dano no inimigo sera de 1 a 5
		
