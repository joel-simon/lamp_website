canvas = null
scenes = []
renderer = null
objLoader = new THREE.OBJLoader()

init = () ->
    canvas = $('.main_canvas')[0]

    $('.lamp_container').each (i) ->
        $lamp_container = $(@)
        model_path = $lamp_container.find(".model_container").data('path')
        scene = new THREE.Scene()

        scene.userData.element = $lamp_container.find('.scene')[0]
        width = $lamp_container.width()
        height = $lamp_container.height()
        camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, -500, 1000)

        camera.aspect = width / height
        camera.updateProjectionMatrix()

        camera.position.z = 2
        scene.userData.camera = camera

        controls = new THREE.OrbitControls( scene.userData.camera, scene.userData.element );
        controls.minDistance = 2
        controls.maxDistance = 5
        controls.enablePan = false
        controls.enableZoom = false
        scene.userData.controls = controls

        objLoader.load '3d/box_wall.obj', (group) ->
            wall_box = group.children[0]
            objLoader.load model_path, (group) ->
                group.scale.multiplyScalar 12
                group.position.multiplyScalar 0
                group.add(wall_box)
                add_out_line(scene, group)
                scene.add group
                #add one random mesh to each scene
                # geometry = geometries[ geometries.length * Math.random() | 0 ]

                # material = new THREE.MeshStandardMaterial( {
                #     color: new THREE.Color().setHSL( Math.random(), 1, 0.75 ),
                #     roughness: 0.5,
                #     metalness: 0,
                #     shading: THREE.FlatShading
                # } );

                # scene.add( new THREE.Mesh( geometry, material ) )

                scene.add( new THREE.HemisphereLight( 0xaaaaaa, 0x444444 ) )

                light = new THREE.DirectionalLight( 0xffffff, 0.5 )
                light.position.set( 1, 1, 1 )
                scene.add( light )

                scenes.push( scene )

    renderer = new THREE.WebGLRenderer( { canvas: canvas, antialias: true, alpha: true} );
    # renderer.setClearColor( 0x000000, 1 );
    renderer.setPixelRatio( window.devicePixelRatio )

add_out_line = (scene,group) ->
  basicWhite = new THREE.MeshBasicMaterial { color: 0xffffff }
  group.traverse ( mesh ) ->
    if mesh instanceof THREE.Mesh
      mesh.material = basicWhite
      mesh.material.polygonOffset = true
      mesh.material.polygonOffsetFactor = 2
      mesh.material.polygonOffsetUnits = 1
      edges = new THREE.EdgesHelper(mesh, 0x000000, 999)
      edges.material.linewidth = 6
      scene.add(edges)

updateSize = () ->
    width = canvas.clientWidth
    height = canvas.clientHeight

    if canvas.width != width || canvas.height != height
        renderer.setSize( width, height, false )

animate = () ->
    render()
    requestAnimationFrame( animate )

render = () ->
    updateSize()
    # renderer.setClearColor( 0xffffff )
    renderer.setScissorTest( false )
    renderer.clear()

    # renderer.setClearColor( 0xe0e0e0 )
    renderer.setScissorTest( true )

    scenes.forEach (scene) ->
        #so something moves
        # scene.children[0].rotation.y = Date.now() * 0.001;

        #get the element that is a place holder for where we want to
        #draw the scene
        element = scene.userData.element

        #get its position relative to the page's viewport
        rect = element.getBoundingClientRect()

        #check if it's offscreen. If so skip it
        if ( rect.bottom < 0 || rect.top  > renderer.domElement.clientHeight ||
             rect.right  < 0 || rect.left > renderer.domElement.clientWidth )
            return  #it's off screen

        # console.log scene

        #set the viewport
        width  = rect.right - rect.left
        height = rect.bottom - rect.top
        left   = rect.left
        bottom = renderer.domElement.clientHeight - rect.bottom

        renderer.setViewport( left, bottom, width, height );
        renderer.setScissor( left, bottom, width, height );

        camera = scene.userData.camera

        camera.aspect = width / height
        camera.updateProjectionMatrix()
        #scene.userData.controls.update();
        renderer.render( scene, camera )
$ ->
    init()
    animate()
