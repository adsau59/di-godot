extends Node


# idealy mapping dict should be in a different class
@export var robot_scene: PackedScene
@onready var mapping = {
    Robot: robot_scene 
}

func _ready() -> void:
    DI.set_dep_class_scene_mapping(mapping)
    DI.set_default_scene_parent(self)

    # Bind a class as a singleton
    DI.bind(GameManager, DI.As.SINGLETON).to_var("game_manager")
    
    # Bind a scene to be instantiated
    DI.bind(Robot, DI.As.SCENE_INSTANCE).to_base(Enemy, Enemy.Type.ROBOT)
    
    # Bind a variable
    DI.bind($Player, DI.As.VALUE).to_var("player")
    
    # Provide the scene tree
    DI.provide_tree(self)
