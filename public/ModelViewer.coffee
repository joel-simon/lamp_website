class window.ModelViewer
  constructor: (@$parent, @modelPath, @boxPath, callback) ->
    @active = false
    @scale = 7#10
    @default_rotation = { z:0, y:Math.PI }
    @rotation = { z: @default_rotation.z, y: @default_rotation.y }

    @width = @$parent.width()
    @height = @$parent.height()

    @$container = $( '<div>' )
    @$parent.append @$container

    @scene = new THREE.Scene()
    # CAMERA
    @camera = new THREE.OrthographicCamera @width / - 2, @width / 2, @height / 2, @height / - 2, 1, 1000
    @scene.add @camera
    @camera.position.set(0,0,400)
    @camera.lookAt @scene.position

    # RENDERER
    @renderer = new THREE.WebGLRenderer { preserveDrawingBuffer: true, alpha: true, antialias: false }
    @renderer.setPixelRatio window.devicePixelRatio
    @renderer.setSize @width, @height
    @renderer.setClearColor 0xffffff, 0
    @$container.append @renderer.domElement

    $parent.resize (event) => @resize()

    # LOAD LAMP BASE
    @addModel @modelPath, (baseModel) =>
      baseModel.scale.multiplyScalar @scale
      @baseModel = baseModel
      @addModel @boxPath, (boxModel) =>

        boxModel.scale.multiplyScalar @scale

        @boxModel = boxModel
        # @addBoxTexture()

        @animate()
        callback()

  resize: () ->
    @width = @$parent.width()
    @height = @$parent.height()

    @renderer.setSize @width, @height
    @camera.left = @width / - 2
    @camera.right = @width / 2
    @camera.top = @height / 2
    @camera.bottom = @height / - 2
    @camera.updateProjectionMatrix()

  animate: () =>
    @animateId = requestAnimationFrame @animate
    @renderer.render @scene, @camera
    @update()

  update: () ->
    @baseModel.rotation.y = @rotation.y
    @baseModel.rotation.z = @rotation.z

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
    crateTexture = new THREE.ImageUtils.loadTexture 'imags/textures/rice_paper_1.jpg'
    crateMaterial = new THREE.MeshBasicMaterial { map: crateTexture }
    @boxModel.traverse ( mesh ) =>
      if mesh instanceof THREE.Mesh
        mesh.material = crateMaterial
        mesh.material.needsUpdate = true

  addModel: (model, callback) ->
    basicWhite = new THREE.MeshBasicMaterial { color: 0xffffff }
    basicBlack = new THREE.MeshBasicMaterial { color: 0x000000 }
    objLoader = new THREE.OBJLoader()

    texture = new THREE.Texture()
    loader = new THREE.ImageLoader()
    material = new THREE.MeshBasicMaterial( {
      map: texture
      transparent : true
      side: THREE.DoubleSide
      opacity: 0.8
    } )
    loader.load 'imgs/textures/rice_paper_1.jpg', ( image ) ->
      texture.image = image
      texture.needsUpdate = true

    objLoader.load model+'.obj', ( object ) =>
      @scene.add object
      object.traverse ( mesh ) =>
        if mesh instanceof THREE.Mesh
          mesh.geometry.computeFaceNormals()
          color =  0x000000
          mesh.material = basicWhite

          edges = new THREE.EdgesHelper( mesh, color, 999 )
          edges.material.linewidth = 2
          @scene.add edges
          mesh._minEdges = edges

      callback object

  reset: () ->
    @rotation.y = @default_rotation.y
    @rotation.z = @default_rotation.z

  toImage: () ->
    image = @renderer.domElement.toDataURL("image/png").replace "image/png", "image/octet-stream"
    # @$parent.find('img').attr 'src', @renderer.domElement.toDataURL()
    # cancelAnimationFrame @animateId
    # @$container.remove()
    image
