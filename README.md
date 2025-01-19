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

Use the `bind()` function to bind a class, scene, or value as a dependency.

```gdscript
# Example: Bind a class as a singleton
DI.bind(MyClass, DI.As.SINGLETON)

# Example: Bind a scene to be instantiated as needed
DI.bind(MyScene, DI.As.SCENE_INSTANCE)

# Example: Bind a value
DI.bind("SomeValue", DI.As.VALUE)
```

You can also bind variables and interfaces:

```gdscript
# Bind to a variable
DI.bind(MyClass, DI.As.SINGLETON).to_var("my_variable")

# Bind to an interface with a mapping
DI.bind(MyClass, DI.As.INSTANCE).to_base(SomeInterface, MyEnum.MY_MAPPING)
```

### 2. **Providing the Scene Tree**

After binding dependencies, call `provide_tree()` to inject dependencies into the scene tree.

```gdscript
# Example: Provide the scene tree for dependency injection
DI.provide_tree(get_tree().root)
```

### 3. **Injecting Dependencies**

For nodes added dynamically, you can call `inject()` to inject dependencies (not recommended):

```gdscript
# Example: Inject dependencies into a dynamically added node
DI.inject(new_node)
```

You can also access instances directly using the variable name, class, or mapping:

```gdscript
# Get an instance by variable name
var my_instance = DI.get_with_var_name("my_variable")

# Get an instance by class
var my_instance = DI.get_with_class(MyClass)

# Get a mapped instance
var mapped_instance = DI.get_mapped(SomeInterface, MyEnum.MY_MAPPING)
```

### 4. **Scene Parent Management**

Set the default parent for scenes instantiated by the DI system:

```gdscript
# Set the default parent node
DI.set_default_scene_parent(some_parent_node)
```

---

## Best Practices

- **Bind at Startup**: Perform all bindings in a script that runs early in the game's lifecycle (e.g., in an autoload or a setup script).
- **Avoid Circular Dependencies**: Ensure that your dependencies don't cause circular injections to prevent stack overflow errors.
- **Use `provide_tree` Once**: Call `provide_tree()` after setting up all bindings and loading the main scene in `_ready()`.
---

## Example

Here's a complete example of setting up and using the DI system:

```gdscript
# Setup Script
extends Node

func _ready():
    # Bind a class as a singleton
    DI.bind(PlayerManager, DI.As.SINGLETON)
    
    # Bind a scene to be instantiated
    DI.bind(PlayerScene, DI.As.SCENE_INSTANCE)
    
    # Bind a variable
    DI.bind(GameSettings, DI.As.VALUE).to_var("game_settings")
    
    # Provide the scene tree
    DI.provide_tree(get_tree().root)
```

```gdscript
# Player Script
extends Node

# Injected variable
onready var game_settings = null

func _injected():
    print("Dependencies injected! Settings:", game_settings)
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