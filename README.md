# DI: Dependency Injection Script for Godot Engine

![definex_logo.png](definex_logo.png)

This script provides a Dependency Injection (DI) system for the Godot Engine. It facilitates object creation, dependency management, and binding using various modes (singleton, instance, value, etc.). With this script, you can manage your dependencies more efficiently, especially for large-scale Godot projects.

---

## Features

- **Dependency Injection**: Inject dependencies into nodes dynamically or throughout the scene tree.
- **Binding System**: Bind classes, interfaces, variables, and scenes to be used as dependencies.
- **Flexible Binding Modes**:
  - `INSTANCE`: Creates a new instance every time.
  - `SINGLETON`: A single shared instance for the class.
  - `SCENE_INSTANCE`: Creates an instance of a scene.
  - `SCENE_SINGLETON`: A single shared instance of a scene.
  - `VALUE`: Directly binds a value.
  - `ALL_MAPPED`: Retrieves all mapped dependencies for an interface.
- **Scene Parent Management**: Automatically assigns default parent nodes for created scenes when no parent is specified.
- **Recursive Tree Injection**: Injects dependencies recursively into the scene tree.
- **Interface Mapping**: Supports mapping dependencies to enums for fine-grained control.

---

## How to Use

### 1. **Binding Dependencies**

Use the `bind()` function to bind a class, scene, or value as a dependency. You can bind variables and interfaces:

```gdscript
# Bind to a variable
DI.bind(MyClass, DI.As.SINGLETON).to_var("my_variable")

# Bind to an interface with a mapping
DI.bind(MyClass, DI.As.INSTANCE).to_base(SomeInterface, MyEnum.MY_MAPPING)
```

### 2. **Providing the Scene Tree**

After binding dependencies, call `provide_tree()` to inject dependencies into the scene tree. Should be run from the root node of the main scene.

```gdscript
# Example: Provide the main node for dependency injection
DI.provide_tree(self)
```

### 3. **Injecting Dependencies**

Each node in the tree is inject when `provide_tree` is called, and as the nodes needs dependencies, those are created and inturn injected as soon as its created.

To dynamically create nodes, you can do so using these methods, if a new nodes/objects are created, those are injected right after before returning them:

```gdscript
# Get an instance by variable name
var my_instance = DI.get_with_var_name("my_variable")

# Get an instance by class
var my_instance = DI.get_with_class(MyClass)

# Get a mapped instance
var mapped_instance = DI.get_mapped(SomeInterface, MyEnum.MY_MAPPING)
```

NOT RECOMMENDED If you HAVE to create new objects without using above given methods, you can use `inject` method to inject dependencies.

```gdscript
# Example: Inject dependencies into a dynamically added node
var new_node = my_packed_scene.instantiate()
add_child(new_node)
DI.inject(new_node)
```

### 4. **Scene Parent Management**

Set the default parent for scenes instantiated by the DI system:

```gdscript
# Set the default parent node
DI.set_default_scene_parent(some_parent_node)
```

### 5. Class to Packed Scene mapping

Allows you to manage all packed scene in a seperate scene, so that you don't have to write logic in nodes just so that you can get the reference for the packed scene to create your new nodes.

```gdscript
@export var robot_scene: PackedScene
var mapping = {
    Robot: robot_scene 
}

func _ready() -> void:
    DI.set_dep_class_scene_mapping(mapping)
```

This way DI will keep a cache of all the packed scene, and when ever it needs to create an instance of a node, it'll use the correct packed scene.

---

## Best Practices

- **Bind at Startup**: Perform all bindings in a script that runs early in the game's lifecycle (e.g., in an autoload or a setup script).
- **Avoid Circular Dependencies**: Ensure that your dependencies don't cause circular injections to prevent stack overflow errors.
- **Use `provide_tree` Once**: Call `provide_tree()` after setting up all bindings and loading the main scene in `_ready()`.
---

## Example

Please refer the example scene in the repository for a working example for how things work. But the most important class to look at is main.gd

### main.gd
```gdscript
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
```

---

## Troubleshooting

- **"Circular Dependency" Errors**: Check for circular references in your bindings and fix them to avoid infinite recursion.
- **Missing Dependencies**: Ensure all required bindings are set before calling `provide_tree()`.
- **Parent Nodes for Scenes**: Use `set_default_scene_parent()` if a parent is not specified during scene instantiation.

---

## License

This script is free to use and modify under the [MIT License](https://github.com/adsau59/di-godot/blob/main/LICENSE).

---

Feel free to contribute or report issues to improve this dependency injection system!