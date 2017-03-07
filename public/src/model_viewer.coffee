objLoader = new THREE.OBJLoader()

scene = null
camera = null
renderer = null
lamp_groups = []

desk_lamps = ['3d/desk1.obj', '3d/desk0.obj', '3d/desk2.obj','3d/desk3.obj', '3d/desk4.obj' ]
table_lamps = ['3d/table1.obj','3d/table6.obj','3d/table0.obj', '3d/table5.obj', '3d/table4.obj']
wall_lamps = ['3d/wall1.obj','3d/wall3.obj','3d/wall0.obj', '3d/wall4.obj', '3d/wall5.obj']

$ ->
    $container = $('#canvas_container')
    init($container, get_scale())
    $container.css 'top', $('.section').first().position().top + $('.section').height() + 20

    for path, i in desk_lamps
        z = (i * 40) - 80
        add_lamp(path, 'desk', {z: z, y: 25, ry: -Math.PI/2, scale:2})

    for path, i in table_lamps
        z = (i * 40) - 80
        add_lamp(path, 'table', {z: z})

    for path, i in wall_lamps
        z = (i * 40) - 80
        add_lamp(path, 'wall', {z: z, y:-30})

    $(document).scroll on_scroll
    $(window).on 'resize', on_resize
    setTimeout on_scroll, 100
    animate()


get_scale = () ->
    """ How to scale the camera based on window
            If in portrait mode, only show 3x3 lamps
    """
    $container = $('#canvas_container')
    if $container.width() < 500
        scale = 12 * ($container.height())/700
    else
        scale = 6 * ($container.height())/700
    scale


add_lamp = (path, type, {scale, x, y, z, rx, ry, rz}) ->
    box_path = switch type
        when 'wall' then  '3d/box_wall.obj'
        when 'table' then '3d/box_table.obj'
        else '3d/box_desk.obj'

    objLoader.load box_path, (box) ->

        objLoader.load path, (group) ->
            group.userData = {}
            group.add(box)

            group.position.x = x if x?

            group.position.y = y if y?
            group.position.z = z if z?

            group.rotation.x = rx if rx?
            group.rotation.y = ry if ry?
            group.rotation.z = rz if rz?

            group.scale.setScalar(scale) if scale?

            group.userData.ry = if ry? then ry else 0

            add_out_line(group)

            lamp_groups.push(group)

            scene.add(group)

            on_scroll()
            on_resize()

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

    $('#canvas_container').css 'top', top

    for group in lamp_groups
        y = group.userData.ry + 3*Math.PI/2 + (Math.PI) * (1-scroll_percent)
        group.rotation.y = y

on_resize = () ->
    $container = $('#canvas_container')
    width = $container.width()
    height = $container.height()
    camera.left = width / - 2
    camera.right = width / 2
    camera.top = height / 2
    camera.bottom = height / - 2

    camera.zoom = get_scale()
    on_scroll()
    renderer.setSize width, height
    camera.aspect = width / height
    camera.updateProjectionMatrix()

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

    aspect = width / height
    camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, -1000, 1000)
    camera.zoom = scale
    camera.position.set(-150, 0, 0)
    camera.lookAt(scene.position)
    camera.updateProjectionMatrix();

    # RENDERER
    renderer = new THREE.WebGLRenderer { preserveDrawingBuffer: false, alpha: true, antialias: true }
    renderer.setSize width, height
    renderer.setClearColor 0xffffff, 0

    # Attach renderer to the container div.
    $container.append $(renderer.domElement)

update = () -> # do nothing

animate = () ->
    requestAnimationFrame animate
    renderer.render scene, camera
    update()

add_out_line = (group) ->
    basicWhite = new THREE.MeshBasicMaterial { color: 0xffffff }
    group.edges = []

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
