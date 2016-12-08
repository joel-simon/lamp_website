# boxTexture = new THREE.ImageUtils.loadTexture 'imgs/textures/rice_paper_1_s.jpg'

textureLoader = new THREE.TextureLoader();


# boxTexture = new THREE.ImageUtils.loadTexture 'imgs/textures/okawara_512.png'
# boxMaterial = new THREE.MeshBasicMaterial { map: boxTexture, transparent:true, opacity: .95 }

baseTexture = new THREE.ImageUtils.loadTexture 'imgs/textures/cherry3_s.jpg'
baseMaterial = new THREE.MeshLambertMaterial { map: baseTexture, side:THREE.DoubleSide}
objLoader = new THREE.OBJLoader()

wall_box = null
desk_box = null

textureLoader.load 'imgs/textures/okawara_512.png', (boxTexture) ->
  console.log  boxTexture
  boxTexture.wrapS = THREE.RepeatWrapping
  boxTexture.wrapT = THREE.RepeatWrapping
  boxMaterial = new THREE.MeshLambertMaterial { map: boxTexture, transparent:true, opacity: .95 }
  loaded = 0

  objLoader.load 'obj/box_wall.obj', (group) ->
    wall_box = group.children[0]
    wall_box.material = boxMaterial
    loaded += 1
    if loaded == 2
      main()

  objLoader.load 'obj/box_desk.obj', (group) ->
    desk_box = group.children[0]
    desk_box.material = boxMaterial
    loaded += 1
    if loaded == 2
      main()

scene = null
camera = null
renderer = null
objects = []

init = (lamps) ->
  # SCENE
  scene = new THREE.Scene()

  $container = $('#scenecontainer')

  # LIGHTING
  ambient = new THREE.AmbientLight( 0x444444 )
  scene.add ambient
  directionalLight = new THREE.DirectionalLight( 0xffeedd )
  directionalLight.position.set 0, 200, 200
  scene.add directionalLight

  # CAMERA
  width = $container.width()
  height = $container.height()
  camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, 1, 1000
  scene.add camera
  camera.position.set(0,0,300)
  camera.lookAt scene.position

  # RENDERER
  renderer = new THREE.WebGLRenderer { preserveDrawingBuffer: false, alpha: true, antialias: true }
  # renderer.setPixelRatio window.devicePixelRatio
  renderer.setSize width, height
  renderer.setClearColor 0xffffff, 0
  renderer.shadowMapEnabled = true

  # attach renderer to the container div
  $container.append $(renderer.domElement)

  x = 0#$(window).width()/2
  for lamp in lamps
    addLamp scene, lamp, [x, 0, 0], (object) ->
      objects.push(object)
    x += 500#$(window).width()/2

  $(window).on 'resize', () ->
    width = $container.width()
    height = $container.height()
    camera.left = width / - 2
    camera.right = width / 2
    camera.top = height / 2
    camera.bottom = height / - 2
    camera.updateProjectionMatrix()
    renderer.setSize width, height

addLamp = (scene, lamp, position, callback) ->
  objLoader.load lamp.path, (group) ->

    if lamp.type == 'wall'
      group.scale.multiplyScalar 8
    else
      group.scale.multiplyScalar 10
    group.position.x = position[0]
    group.position.y = position[1]
    group.position.z = position[2]
    group.userData = {x: position[0], rx:lamp.rx, ry:lamp.ry, rz:lamp.rz}

    # recursively iter over mesh group
    group.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh.material = baseMaterial

    if lamp.type == 'wall'
      group.add(wall_box.clone())

    else if lamp.type == 'desk'
      group.add(desk_box.clone())

    scene.add group
    callback group
          # mesh.material.map = texture
      #     mesh.geometry.computeFaceNormals()
          # mesh.material = basicWhite
      #     color =  0x000000
      #     edges = new THREE.EdgesHelper( mesh, color, 999 )
      #     edges.material.linewidth = 4
      #     scene.add edges
      #     mesh._minEdges = edges


update = () -> # do nothing
  width = $(window).width()
  for obj in objects
    obj.position.x = obj.userData['x'] - $('#framecontainer').scrollLeft()
    # obj.position.x = obj.userData['x'] - $('#scrollcontainer').scrollTop()
    percX = (obj.position.x+ (width / 2)) / width
    percX = Math.max(Math.min(percX, 1), 0) # bound to [0, 1]
    # obj.rotation.y = obj.userData['ry'] + (percX * Math.PI)# + (-90 * Math.PI / 180)
    # obj.rotation.z = obj.userData['rz'] + (((percX - 0.50)/12) * Math.PI)

animate = () ->
  requestAnimationFrame animate
  renderer.render scene, camera
  update()

  # reset: () ->
  #   animating = true
  #   tween = new TWEEN.Tween(rotation)
  #     .to(default_rotation, 200)
  #     .easing TWEEN.Easing.Linear.None
  #     .start()
  #     .onComplete(() => animating = false)

  # toImage: () ->
  #   image = renderer.domElement.toDataURL("image/png")
  #   image.replace "image/png", "image/octet-stream"
# $ ->
#   # return
#   init()
#   animate()
