boxTexture = new THREE.ImageUtils.loadTexture 'imgs/textures/rice_paper_1_s.jpg'
boxMaterial = new THREE.MeshBasicMaterial { map: boxTexture, transparent:true, opacity: .9 }

baseTexture = new THREE.ImageUtils.loadTexture 'imgs/textures/cherry3_s.jpg'
baseMaterial = new THREE.MeshLambertMaterial { map: baseTexture }

model_cache = {}
objLoader = new THREE.OBJLoader()

class window.ModelViewer
  constructor: ($parent) ->
    @active = true
    @loaded = false
    @animating = false
    @default_rotation = { z:0, y:Math.PI }

    @scene = new THREE.Scene()

    # Lighting
    ambient = new THREE.AmbientLight( 0x444444 )
    @scene.add ambient
    directionalLight = new THREE.DirectionalLight( 0xffeedd )
    directionalLight.position.set 0, 100, 100
    @scene.add directionalLight

    # CAMERA
    @camera = new THREE.OrthographicCamera @width / - 2, @width / 2, @height / 2, @height / - 2, 1, 1000
    @scene.add @camera
    @camera.position.set(0,0,600)
    @camera.lookAt @scene.position

    # RENDERER
    @renderer = new THREE.WebGLRenderer { preserveDrawingBuffer: false, alpha: true, antialias: true }
    @renderer.setPixelRatio window.devicePixelRatio
    @renderer.setSize @width, @height
    @renderer.setClearColor 0xffffff, 0


    @moveTo $parent

  moveTo: (@$parent, callback) ->
    if $parent.hasClass 'wall'
      box_path = 'obj/box_wall.obj'
    else
      box_path = 'obj/box_desk.obj'
    base_path = "#{$parent.data('path')}.obj"

    @scale = @$parent.height()/100
    @rotation = { z: @default_rotation.z, y: @default_rotation.y, x:0 }

    @width = @$parent.width()
    @height = @$parent.height()

    @$parent.append @renderer.domElement

    if @baseModel
      @scene.remove @baseModel
      @scene.remove @boxModel

    @addModel base_path, (baseModel) =>
      baseModel.scale.multiplyScalar @scale
      @baseModel = baseModel
      @addModel box_path, (boxModel) =>
        boxModel.scale.multiplyScalar @scale
        @boxModel = boxModel
        @loaded = true
        @resize()
        @addBoxTexture()
        @addBaseTexture()

  resize: () ->

    @width = @$parent.width()
    @height = @$parent.height()
    # console.log 'resize', @width, @height
    bBox = new THREE.Box3().setFromObject(@scene);

    # if (bBox.size().y / @height) > (bBox.size().x / @width)
    #   @setScale @height/50
    # else
    @setScale @width/40

    @renderer.setSize @width, @height
    @camera.left = @width / - 2
    @camera.right = @width / 2
    @camera.top = @height / 2
    @camera.bottom = @height / - 2
    # @camera.lookAt @scene.position
    @camera.updateProjectionMatrix()

  animate: () =>
    if @active
      @update()
      @renderer.render @scene, @camera

  setScale: (@scale) ->
    @boxModel.scale.set @scale, @scale, @scale
    @baseModel.scale.set @scale, @scale, @scale

  update: () ->
    @baseModel.rotation.x = @rotation.x
    @baseModel.rotation.y = @rotation.y
    @baseModel.rotation.z = @rotation.z

    @boxModel.rotation.x = @rotation.x
    @boxModel.rotation.y = @rotation.y
    @boxModel.rotation.z = @rotation.z

  hideBox: () ->
    @boxModel.visible = false
    @boxModel.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh._minEdges.visible = false

  showBox: () ->
    @boxModel.visible = true
    @boxModel.traverse ( mesh ) ->
      if mesh instanceof THREE.Mesh
        mesh._minEdges.visible = true

  addBoxTexture: () ->
    # texture.wrapS = texture.wrapT = THREE.RepeatWrapping
    # texture.repeat.set( 1,1 )
    @boxModel.traverse ( mesh ) =>
      if mesh instanceof THREE.Mesh
        mesh.material = boxMaterial
        mesh.material.needsUpdate = true

  addBaseTexture: () ->
    # texture.wrapS = texture.wrapT = THREE.RepeatWrapping
    @baseModel.traverse ( mesh ) =>
      if mesh instanceof THREE.Mesh
        mesh.material = baseMaterial
        mesh.material.needsUpdate = true
    # @baseModel.castShadow = true

  addModel: (model_path, callback) ->
    if model_path in model_cache
      @scene.add model_cache[model_path]
      callback model_cache[model_path]
    else
      objLoader.load model_path, ( object ) =>
        @scene.add object
        callback object
      # object.traverse ( mesh ) =>
      #   if mesh instanceof THREE.Mesh
      #     mesh.material.map = texture
      #     mesh.geometry.computeFaceNormals()
      #     mesh.material = basicWhite
      #     color =  0x000000
      #     edges = new THREE.EdgesHelper( mesh, color, 999 )
      #     edges.material.linewidth = 4
      #     @scene.add edges
      #     mesh._minEdges = edges

  reset: () ->
    @animating = true
    tween = new TWEEN.Tween(@rotation)
      .to(@default_rotation, 200)
      .easing TWEEN.Easing.Linear.None
      .start()
      .onComplete(() => @animating = false)

  toImage: () ->
    image = @renderer.domElement.toDataURL("image/png")
    image.replace "image/png", "image/octet-stream"
