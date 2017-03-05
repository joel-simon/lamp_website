objLoader = new THREE.OBJLoader()

scene = null
camera = null
renderer = null
objects = []

class Lamp
  constructor: (@path, @type, @position, @rotation) ->

V = (a, b, c) ->
  new THREE.Vector3(a, b, c)

desk_lamps = [
  new Lamp('3d/desk1.obj', 'desk', V( 0, 0, 0 ), V(0, 0,0)),
  new Lamp('3d/desk0.obj', 'desk', V( 0, 0, 0 ), V(0, 0,0)),
  new Lamp('3d/desk2.obj', 'desk', V( 0, 0, 0 ), V(0, 0,0)),
  new Lamp('3d/desk3.obj', 'desk', V( 0, 0, 0 ), V(0, 0,0)),
  new Lamp('3d/desk4.obj', 'desk', V( 0, 0, 0 ), V(0, 0,0)),
]
table_lamps = [
  new Lamp('3d/table1.obj', 'table', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/table6.obj', 'table', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/table0.obj', 'table', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/table5.obj', 'table', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/table4.obj', 'table', V( 0, 0, 0 ), V(0, 0, 0)),
]
wall_lamps = [
  new Lamp('3d/wall1.obj', 'wall', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/wall3.obj', 'wall', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/wall0.obj', 'wall', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/wall4.obj', 'wall', V( 0, 0, 0 ), V(0, 0, 0)),
  new Lamp('3d/wall5.obj', 'wall', V( 0, 0, 0 ), V(0, 0, 0))
]

add_box = (path, offset, rotation, scale = 1) ->
  return
  objLoader.load path, (group) ->
    add_out_line(group)
    scene.add(group)
    group.position.add(offset)
    group.rotation.y = rotation.y
    group.scale.setScalar scale

get_scale = () ->
  $container = $('#canvas_container')
  # If in portrait mode, only shoe 3x3 lamps
  if $container.width() < 500
    scale = 12 * ($container.height())/700
  else
    scale = 6 * ($container.height())/700
  scale

$ ->
  $container = $('#canvas_container')

  console.log $container, $container.height(), get_scale($container)
  init($container, get_scale())


  $container.css 'top', $('.section').first().position().top + $('.section').height() + 20

  # DESK LAMPS
  desk_rotation = V(0, -Math.PI/2,0)#V(0, 4*Math.PI/16, 0)
  desk_offset = V(0, 25,0) #V(0, -16, -$(window).width() / (2*20))
  add_lamps(desk_lamps, 2, desk_offset, desk_rotation)


  # TABLE LAMPS
  table_rotation = V(0,0,0)#V(0, -4*Math.PI/16, 0)
  table_offset = V(0,0,0)#V(0, -16, $(window).width() / (2*20))
  add_lamps(table_lamps, 1, table_offset, table_rotation)

  # WALL LAMPS
  wall_rotation = V(0,0,0)#V(0, 4*Math.PI/16, 0)
  add_lamps(wall_lamps, 1, V(0,-30,0), wall_rotation)

  $(document).scroll on_scroll
  setTimeout on_scroll, 100
  animate()



on_scroll = (event) ->
  hh = $('.section').first().position().top + $('.section').height() + 20
  scroll = $(document).scrollTop()
  action_start = hh
  action_end = hh + $('.section.models').height() - $('#canvas_container').height()
  scroll_percent = 0

  if scroll < action_start
    top = hh - scroll
  else if scroll > action_end
    top = action_end - scroll
    scroll_percent = 1
  else # IN BETWEEN - DO ACTION.
    top = 0
    scroll_percent = (scroll - action_start) / (action_end - action_start)
  # top_position = switch scroll
  #   when value
  #     # ...


  $('#canvas_container').css 'top', top
  # scroll_threshold = $('.section.models').height() - $('#canvas_container').height()
  # scrollPercent = Math.min($(@).scrollTop() / scroll_threshold, 1)
  # console.log scrollPercent

  # if scrollPercent > 1
  #   dy = $(document).scrollTop() - scroll_threshold
  #   $('#canvas_container').css 'top', 200 - dy

  for group in lamp_groups
    y = group.userData.ry + 3*Math.PI/2 + (Math.PI) * (1-scroll_percent)
    group.rotation.y = y



# start = Date.time()
init = ($container, scale) ->
  # SCENE
  scene = new THREE.Scene()

  # LIGHTING
  ambient = new THREE.AmbientLight( 0x444444 )
  scene.add ambient
  directionalLight = new THREE.DirectionalLight( 0xffeedd )
  directionalLight.position.set 0, 200, 200
  scene.add directionalLight

  # CAMERA
  width = $container.width()
  height = $container.height()

  console.log 'width=', width, 'height=', height

  aspect = width / height
  camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, -1000, 1000)
  camera.zoom = scale
  camera.position.set(-150, 0, 0)
  camera.lookAt(scene.position)
  camera.updateProjectionMatrix();


  # VIEW_ANGLE = 10
  # ASPECT = width / height
  # NEAR = 0.1
  # FAR = 2000
  # camera = new THREE.PerspectiveCamera( VIEW_ANGLE, ASPECT, NEAR, FAR)
  # scene.add camera
  # camera.position.set(0,0,1000)
  # camera.lookAt scene.position

  # RENDERER
  renderer = new THREE.WebGLRenderer { preserveDrawingBuffer: false, alpha: true, antialias: true }
  renderer.setSize width, height
  renderer.setClearColor 0xffffff, 0


  # Attach renderer to the container div.
  $container.append $(renderer.domElement)

  $(window).on 'resize', () ->
    width = $container.width()
    height = $container.height()
    camera.left = width / - 2
    camera.right = width / 2
    camera.top = height / 2
    camera.bottom = height / - 2

    camera.zoom = get_scale()
    on_scroll()
    # camera.updateProjectionMatrix()
    renderer.setSize width, height
    camera.aspect = width / height
    camera.updateProjectionMatrix()



add_lamps = (lamps, scale, position, rotation) ->
  objects = []

  for lamp, i in lamps
    # console.log lamp, i
    lamp.position.add(position)
    lamp.rotation.add(rotation)
    lamp.position.z += (i * 40) - 80
    addLamp scene, lamp, (object) ->
      object.scale.setScalar scale
      objects.push(object)

  ii = 0
  derp = () ->
    objects[ii].visible = false
    for edge in objects[ii].edges
      edge.visible = false

    ii = (ii + 1) % objects.length
    objects[ii].visible = true
    for edge in objects[ii].edges
      edge.visible = true

  # setInterval derp, 2000

add_out_line = (group) ->
  basicWhite = new THREE.MeshBasicMaterial { color: 0xffffff }
  group.edges = []

  # console.log group
  group.traverse ( mesh ) ->
    if mesh instanceof THREE.Mesh
      mesh.material = basicWhite
      mesh.material.polygonOffset = true
      mesh.material.polygonOffsetFactor = 2
      mesh.material.polygonOffsetUnits = 1

      edges = new THREE.EdgesHelper(mesh, 0x000000, 80)
      edges.material.linewidth = 1

      group.edges.push(edges)
      scene.add(edges)

lamp_groups = []
addLamp = (scene, lamp, callback) ->
  box_path = switch lamp.type
    when 'wall' then '3d/box_wall.obj'
    when 'table' then '3d/box_table.obj'
    else '3d/box_desk.obj'

  objLoader.load box_path, (box) ->
    objLoader.load lamp.path, (group) ->
      group.add(box)
      group.userData.ry = lamp.rotation.y

      add_out_line(group)
      # group.visible = false
      # for edge in group.edges
      #   edge.visible = false

      group.position.x = lamp.position.x
      group.position.y = lamp.position.y
      group.position.z = lamp.position.z

      group.rotation.x = lamp.rotation.x
      group.rotation.y = lamp.rotation.y
      group.rotation.z = lamp.rotation.z

      lamp_groups.push(group)

      scene.add group
      callback group


update = () -> # do nothing
  return
  scrollPercent = $('#model_scroll_container').scrollLeft() /  ($('#scroll').width() - $('#model_scroll_container').width())
  for group in lamp_groups
    # console.log group.userData.ry
    y = group.userData.ry + 3*Math.PI/2 + (Math.PI) * (1-scrollPercent)
    group.rotation.y = y

  # for obj in scene.children
  #   if obj instanceof THREE.Group
  #     console.log obj.userData.y
  #     obj.rotation.y = 3*Math.PI/2 + (Math.PI) * (1-scrollPercent)

animate = () ->
  requestAnimationFrame animate
  renderer.render scene, camera
  update()
