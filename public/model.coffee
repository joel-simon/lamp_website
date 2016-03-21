sceneReady = ($container, model, box, state, scene, renderer, camera) ->
  $parent = $container.parent()
  width = $parent.width()
  height = $parent.height()

  hideBox = () ->
    box.visible = false
    box.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh._minEdges.visible = false

  showBox = () ->
    box.visible = true
    box.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh._minEdges.visible = true

  hideBox()

  $container.mouseenter ( event ) ->
    showBox()
    $container.parent().css
      'z-index': 999
      # 'border-style': 'none'

    parentOffset = $parent.offset()
    relX = event.pageX - parentOffset.left
    percX = relX / $parent.width()
    if percX > .5
      state.fromRight = true

  $container.mousemove ( event ) ->
    parentOffset = $parent.offset()
    relX = event.pageX - parentOffset.left
    relY = event.pageY - parentOffset.top

    percX = relX / $parent.width()
    percY = relY / $parent.height()

    xAxis = new THREE.Vector3(0,1,0)

    # if state.fromRight
    #   percX = 1- percX

    state.rotation.y = (percX)* Math.PI
    state.rotation.z = (((percY - 0.50)/4) * Math.PI)

  $container.mouseout ( event ) ->
    hideBox() unless $parent.hasClass 'open'
    $container.parent().css
      'z-index': 0
      border: ''

    state.rotation.z = 0
    state.fromRight = false
    # box.visible = false

    relX = event.pageX - $parent.offset().left
    percX = relX / width
    if percX > .5
      state.turned = true
      state.rotation.y = Math.PI
    else
      state.rotation.y = 0

  $container.click (event) ->
    console.log
    return if $('.lamp.open').length
    $parent = $container.parent()
    # $parent.width '50%'
    # $parent.height '100%'
    $parent.addClass 'open'
    $('.lamp').not($parent).hide()

    $( 'img.lamp' ).show()
    $('#lamps').packery()
    $('#information').show()
    showBox()
    event.stopPropagation()

  animate = () ->
    requestAnimationFrame( animate )
    renderer.render( scene, camera )
    update()

  update = () ->
    model.rotation.y = state.rotation.y
    model.rotation.z = state.rotation.z

    box.rotation.y = state.rotation.y
    box.rotation.z = state.rotation.z


  animate()



addWireFrame = (model, scene, callback) ->
  basicWhite = new THREE.MeshBasicMaterial( { color: 0xffffff } );
  basicBlack = new THREE.MeshBasicMaterial( { color: 0x000000 } );
  objLoader = new THREE.OBJLoader()
  objLoader.load model+'.obj', ( object ) ->
    scene.add object

    object.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh.geometry.computeFaceNormals()
        color =  0x000000
        mesh.material = basicWhite
        edges = new THREE.EdgesHelper( mesh, color, 9999999 )
        edges.material.linewidth = 4
        scene.add edges
        mesh._minEdges = edges

    callback object

window.initModel = ($parent, modelPath, boxPath) ->
  width = $parent.width()
  height = $parent.height()

  state =
    viewingLamp: false
    turned: false
    fromRight: false
    scale: 10
    rotation:
      z:0
      y:0

  $container = $( '<div>' )
  $parent.append $container

  # SCENE
  scene = new THREE.Scene()

  # CAMERA
  camera = new THREE.OrthographicCamera width / - 2, width / 2, height / 2, height / - 2, 1, 1000
  scene.add camera
  camera.position.set(0,0,400)
  camera.lookAt scene.position

  # RENDERER
  renderer = new THREE.WebGLRenderer( {alpha: true, antialias: true })
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( width, height)
  renderer.setClearColor( 0xffffff, 0)
  $container.append( renderer.domElement )

  $parent.resize (event) ->
    width = $parent.width()
    height = $parent.height()
    console.log width, height
    renderer.setSize width, height
    camera.left = width / - 2
    camera.right = width / 2
    camera.top = height / 2
    camera.bottom = height / - 2
    camera.updateProjectionMatrix();


  # LOAD LAMP BASE
  addWireFrame modelPath, scene, (model) ->
    model.scale.multiplyScalar state.scale
    addWireFrame boxPath, scene, (box) ->
      box.scale.multiplyScalar state.scale
      sceneReady $container, model, box, state, scene, renderer, camera

