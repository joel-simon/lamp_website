var camera, scene, renderer;
var geometry, material, mesh, helper, cube, edges;

$(function(){
    init();
    animate();

})

function init() {

    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.z = 30;

    scene = new THREE.Scene();
    geometry = new THREE.BoxGeometry( 10, 10, 10, 2, 2, 2 );
    material = new THREE.MeshBasicMaterial( { color: 0x000000 } );
    object = new THREE.Mesh( geometry, material );
    // object.visible = false
    edges = new THREE.EdgesHelper( object, 0x00ff00 );
    // console.log('test');
    scene.add( object );
    scene.add( edges );


    console.log(object);
    console.log(edges);
    // renderer = new THREE.CanvasRenderer();
    // renderer.setSize(window.innerWidth, window.innerHeight);
    renderer = new THREE.WebGLRenderer({
        width: $(window).width(),
        height: $(window).height(),
        antialias: true
      });
  //   renderer.setSize(screenWidth, screenHeight);
  // renderer.setClearColor(0xffffff);

    document.body.appendChild(renderer.domElement);

}

function animate() {
    // console.log('animate', mesh.rotation.y);
    // note: three.js includes requestAnimationFrame shim
    requestAnimationFrame(animate);

    object.rotation.x += 0.01;
    object.rotation.y += 0.02;
    // console.log(edges.rotation);

    renderer.render(scene, camera);

}
