var animate, camera, clock, composer, elapsedTime, frameCount, init, light, loadModel, maskScene, mesh1, mesh2, mesh3, onWindowResize, outScene, render, renderTarget, renderer, scene, screenHeight, screenWidth, setModel, shader, updateFps;
screenWidth = $(window).width();
screenHeight = $(window).height();

console.log(screenWidth, screenHeight);

clock = new THREE.Clock();
elapsedTime = 0;
frameCount = 0;

init = function() {
  var clearMask, copyPass, mask, normal, outline, renderTargetParameters;
  scene = new THREE.Scene();
  maskScene = new THREE.Scene();
  outScene = new THREE.Scene();
  loadModel();

  camera = new THREE.PerspectiveCamera(40, screenWidth / screenHeight, 50, 10000);
  camera.position.set(0, 100, 400);
  light = new THREE.DirectionalLight(0xffffff);
  light.position.set(1, 1, 1);
  scene.add(light);

  renderer = new THREE.WebGLRenderer({
    width: screenWidth,
    height: screenHeight,
    antialias: true
  });

  renderer.setSize(screenWidth, screenHeight);
  renderer.setClearColor(0xffffff);
  renderer.autoClear = false;
  renderer.gammaInput = true;
  renderer.gammaOutput = true;

  document.body.appendChild(renderer.domElement);
  renderTargetParameters = {
    minFilter: THREE.LinearFilter,
    magFilter: THREE.LinearFilter,
    format: THREE.RGBAFormat,
    stencilBuffer: true
  };
  renderTarget = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, renderTargetParameters);

  composer    = new THREE.EffectComposer(renderer);
  composer.renderTarget1.stencilBuffer = true;
  composer.renderTarget2.stencilBuffer = true;

  normal      = new THREE.RenderPass(scene, camera);
  outline     = new THREE.RenderPass(outScene, camera);
  outline.clear = false;

  mask        = new THREE.MaskPass(maskScene, camera);
  mask.inverse = true;
  clearMask   = new THREE.ClearMaskPass();
  copyPass    = new THREE.ShaderPass(THREE.CopyShader);
  copyPass.renderToScreen = true;

  composer.addPass(normal);
  composer.addPass(mask);
  composer.addPass(outline);
  composer.addPass(clearMask);
  composer.addPass(copyPass);

  window.addEventListener('resize', onWindowResize, false);
};

loadModel = function() {
  // var objLoader = new THREE.OBJLoader()
  // objLoader.load('obj/curve2.obj', function ( object ) {

  //   object.traverse(function( mesh ) {

  //     if (mesh.geometry instanceof THREE.BufferGeometry){
  //       var geometry = new THREE.Geometry().fromBufferGeometry( mesh.geometry );
  //       console.log(geometry);
  //       setModel(geometry)
  //       return
  //     }

  //   });

  // });
  var geo = new THREE.CubeGeometry( 100, 20, 100, 1, 1, 1 );
  // var geo = new THREE.TorusKnotGeometry(40, 10, 50, 20)
  setModel(geo);

  var geo = new THREE.CubeGeometry( 20, 100, 20, 1, 1, 1 );
  // var geo = new THREE.TorusKnotGeometry(40, 10, 50, 20)
  setModel(geo);

}


setModel = function(geometry) {
    console.log(geometry);
    var matColor, matFlat, matShader, outShader, uni, offset, outlineShader, scaled, clone;
    geometry.scaled = THREE.dilateGeometry(geometry.clone(), 3);

    // material = new THREE.MeshBasicMaterial({ color: 0xffffff, transparent:true })
    material = new THREE.MeshBasicMaterial({ color: 0xff0000, transparent:false })
    mesh1 = new THREE.SkinnedMesh(geometry, material);
    // mesh1.scale.multiplyScalar(5)
    // mesh1.scale
    scene.add(mesh1);

    matFlat = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        // skinning: true
    });
    mesh2 = new THREE.SkinnedMesh(geometry, matFlat);
    // mesh2.scale.multiplyScalar(5)
    maskScene.add(mesh2);

    matRed = new THREE.MeshBasicMaterial({
        color: 0x000000,
        // skinning: true
    });
    mesh3 = mesh1.clone();
    // mesh3.scale.multiplyScalar(5)
    mesh3.geometry = mesh1.geometry.scaled;
    mesh3.material = matRed;
    outScene.add(mesh3);
    mesh3.geometry.skinIndices = mesh1.geometry.skinIndices
    mesh3.geometry.skinWeights = mesh1.geometry.skinWeights

};

onWindowResize = function() {
  screenWidth = $(window).width();
  screenHeight = $(window).height();
  renderer.setSize(screenWidth, screenHeight);
};

animate = function() {
  var delta;
  delta = clock.getDelta();
  render(delta);
  // camera.lookAt(mesh1.position)
  return requestAnimationFrame(animate);
};

render = function(delta) {
  if (mesh1) {
    mesh1.rotation.y += 0.01;
    mesh2.rotation.y += 0.01;
    mesh3.rotation.y += 0.01;
    composer.render(delta);
  }
};


$(function(){
  init();
  animate();
})

