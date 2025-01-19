extends Node

var _class_bindings = {}

var _var_name_mapping = {}
var _interface_mapping = {}
var _singleton_cache = {}

var _default_node_parent: Node
var _dep_class_scene_mapping: Dictionary

enum As {
    INSTANCE, SINGLETON, SCENE_INSTANCE, SCENE_SINGLETON, VALUE, ALL_MAPPED
}

class Binding:
    var _class: Variant
    var _as: As

    var _interface: Object
    var _mapping: int

    var _injected_parent: bool = false

    func _init(class_: Variant, as_: As):
        self._class = class_
        self._as = as_

    func to_base(interface: Object, mapping: int):
        self._interface = interface
        self._mapping = mapping

        if not DI._interface_mapping.has(interface):
            DI._interface_mapping[interface] = {}

        DI._interface_mapping[interface][mapping] = self

        return self

    func to_var(var_name: String):
        if DI._var_name_mapping.has(var_name):
            DI.logger.error("%s dep already registered" % var_name)

        DI._var_name_mapping[var_name] = self
        return self

    func again():
        if self._class.has_method("bind"):
            self._class.bind()


    # todo remove this if not being used
    ## if set, node being injected as made as parent if its instance is being created
    func injected_node_is_parent():
        if _as != As.SCENE_INSTANCE:
            DI.logger.error("need to_base be As.SCENE_INSTANCE to_base use injected_node_is_parent")

        _injected_parent = true

# Should only be called by main

## sets node to parent for instantiated nodes by default if no parent is given,
## or injected_node_is_parent is not set in binding
func set_default_scene_parent(node: Node):
    _default_node_parent = node

func set_dep_class_scene_mapping(dep_class_scene_mapping: Dictionary):
    _dep_class_scene_mapping = dep_class_scene_mapping

## gives a way for ancestor to bind properties
##  if binding a scene, make sure it exists in packed_scene_mapping.class_mapping
func bind(class_: Variant, as_: As) -> Binding:
    var binding = Binding.new(class_, as_)
    _class_bindings[class_] = binding
    return binding


## loops through all the children and injects everyone in the tree
##  only should be called by main scene once after binding everything
func provide_tree(provider: Node):
    _provide_children(provider)

# can be called by other scripts

## gives a way for dynamically added nodes to inject
##  should not be used in _init or _ready if the node exists when Main scene is first loaded (startup)
##  if causing stack overflow, means, there is circular dependency somewhere
func inject(node: Object):
    # no need to inject if node doesn't have a script
    if node.get_script() == null:
        return

    for _var_name in _var_name_mapping:
        if _var_name in node:
            var binding = _var_name_mapping[_var_name]
            node[_var_name] = _get_instance(binding, node if binding._injected_parent else null)

    if node.has_method("_injected"):
        node._injected()


func get_with_var_name(var_name: String, parent: Node = null):
    return _get_instance(_var_name_mapping[var_name], parent)


func get_with_class(_class, parent: Node = null):
    return _get_instance(_class_bindings[_class], parent)

## return instance of binding mapped with an interface
func get_mapped(interface: Object, enum_value: int, parent: Node = null):
    var binding = _interface_mapping[interface][enum_value]
    return _get_instance(binding, parent)


# private methods
func _get_instance(binding: Binding, parent: Node):
    match binding._as:
        As.INSTANCE:
            return _create(binding._class)
        As.SINGLETON:
            if not _singleton_cache.has(binding._class):
                _singleton_cache[binding._class] = _create(binding._class)
            return _singleton_cache[binding._class]
        As.SCENE_INSTANCE:
            return _instantiate_with_class(binding._class, parent)
        As.SCENE_SINGLETON:
            if not _singleton_cache.has(binding._class):
                _singleton_cache[binding._class] = _instantiate_with_class(binding._class, null)
            return _singleton_cache[binding._class]
        As.VALUE:
            return binding._class
        As.ALL_MAPPED:
            var mapped = {}
            for mapping in _interface_mapping[binding._class]:
                var _b = _interface_mapping[binding._class][mapping]
                mapped[mapping] = _get_instance(_b, parent)
            return mapped


func _provide_children(provider: Node):
    for node in provider.get_children():
        inject(node)
        _provide_children(node)


func _create(_class):
    var obj = _class.new()
    inject(obj)
    return obj

func _instantiate_with_class(_class, parent: Node):
    var scene = _dep_class_scene_mapping[_class]
    return _instantiate(scene, parent)

# no need to inject as provide_tree will inject it along with other nodes
func _instantiate(scene: PackedScene, parent: Node):
    var node = scene.instantiate()
    if parent != null:
        parent.add_child(node)
    else:
        _default_node_parent.add_child(node)
    inject(node)
    return node
