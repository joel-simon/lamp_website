scene       = null
normal      = null
outline     = null
outScene    = null
maskScene   = null
light       = null
renderer    = null
composer    = null
camera     = null
mesh1       = null
mesh2       = null
mesh3       = null
renderTarget = null

screenWidth  = window.innerWidth
screenHeight = window.innerHeight

clock = new THREE.Clock

elapsedTime = 0
frameCount  = 0

shader =
    'outline' :
        vertex_shader: [
            "uniform float offset;",
            "void main() {",
                "vec4 pos = modelViewMatrix * vec4( position + normal * offset, 1.0 );",
                "gl_Position = projectionMatrix * pos;",
            "}"
        ].join("\n"),

        fragment_shader: [
            "void main(){",
                "gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );",
            "}"
        ].join("\n")


init = () ->

    # SCENE

    scene     = new THREE.Scene
    maskScene = new THREE.Scene
    outScene  = new THREE.Scene
    setModel()

    # CAMERA

    camera = new THREE.PerspectiveCamera 40, screenWidth/screenHeight, 50, 10000
    camera.position.set 0, 0, 400

    # LIGHTS

    light = new THREE.DirectionalLight 0xffffff
    light.position.set 1, 1, 1
    scene.add light

    # RENDERER

    renderer = new THREE.WebGLRenderer
        width: screenWidth
        height: screenHeight
        antialias: true

    renderer.setSize screenWidth, screenHeight
    renderer.setClearColor 0x666666
    renderer.autoClear = false
    renderer.gammaInput = true
    renderer.gammaOutput = true

    document.body.appendChild renderer.domElement

    # EVENTS

    window.addEventListener 'resize', onWindowResize, false

setModel = ->

    geometry = new THREE.TorusKnotGeometry 50, 10, 128, 16

    # shaded model
    matColor = new THREE.MeshPhongMaterial 0xffffff
    mesh1 = new THREE.Mesh geometry, matColor
    scene.add mesh1

    # shader
    uniforms = offset:
        type: "f"
        value: 1

    outShader = shader['outline']

    matShader = new THREE.ShaderMaterial
        uniforms: uniforms,
        vertexShader: outShader.vertex_shader,
        fragmentShader: outShader.fragment_shader,

    mesh3 = new THREE.Mesh geometry, matShader
    mesh3.material.depthWrite = false # <==============
    mesh3.quaternion = mesh1.quaternion
    outScene.add mesh3

onWindowResize = ->

    screenWidth  = window.innerWidth
    screenHeight = window.innerHeight

    camera.aspect = screenWidth / screenHeight

    camera.updateProjectionMatrix()

    renderer.setSize screenWidth, screenHeight

animate = ->

    updateFps()
    requestAnimationFrame animate
    render()

render = ->

    now = Date.now()
    delta = clock.getDelta()

    if mesh1
        mesh1.rotation.y += 0.01

    renderer.render( outScene, camera ) # <==============
    renderer.render( scene, camera ) # <==============

updateFps = ->

    elapsedTime += clock.getDelta()
    frameCount++

    if elapsedTime >= 1
        $('#fps').html frameCount
        frameCount  = 0
        elapsedTime = 0


init()
animate()
