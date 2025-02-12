class_name GameManager

var enemies = []

func start_game():
    # no need to manage packed scene, creates and gets the node reference directly
    var robot = DI.get_mapped(Enemy, Enemy.Type.ROBOT)
    enemies.append(robot)

func get_enemy():
    return enemies.pick_random()
