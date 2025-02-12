extends Node
class_name Player

# automatically gets the object
var game_manager: GameManager

func _ready():
    # do initialization which doesn't depend on anything here
    pass


func _injected():
    game_manager.start_game()

    var enemy = game_manager.get_enemy()
    if enemy != null:
        enemy.damage()
