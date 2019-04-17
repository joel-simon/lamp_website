/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/* This file handles the grid of 3D lamps on the 'more' page.
 */

const objLoader = new THREE.OBJLoader();
let scene = null;
let camera = null;
let renderer = null;
const lamp_groups = [];

// 5 columns and 3 rows.
const lamp_grid = ([0, 1, 2].map((j) => (() => {
    const result = [];
    for (let i = 0; i < 5; i++) {
        result.push(null);
    }
    return result;
})()));

const desk_lamps = ['3d/desk1.obj', '3d/desk3.obj', '3d/desk2.obj','3d/desk0.obj', '3d/desk4.obj' ];
const table_lamps = ['3d/table1.obj','3d/table6.obj','3d/table0.obj', '3d/table5.obj', '3d/table4.obj'];
const wall_lamps = ['3d/wall2.obj', '3d/wall6.obj','3d/wall-1.obj', '3d/wall1.obj','3d/wall5.obj'];

const position = {
    'x': 0,
    'y': 0
};

function load_boxes(callback) {
    objLoader.load('3d/box_wall.obj', box_wall => {
        objLoader.load('3d/box_table.obj', box_table => {
            objLoader.load('3d/box_desk.obj', box_desk => {
                callback({box_wall, box_table, box_desk})
            })
        })
    })
}

$(function() {
    const $container = $('#canvas_container');
    init($container, get_scale());
    $container.css('top', $('.section').first().position().top + $('.section').height() + 20);

    const padd = $container.width() < $container.height() ? 25 : 40;

    load_boxes(({box_wall, box_table, box_desk}) => {

        desk_lamps.forEach(function(path, i) {
            const z = (i * padd) - (2*padd);
            const options = {z:z, y: 25, ry: -Math.PI/2, scale:2};
            add_lamp(path, box_desk.clone(), options, lamp => {
                lamp_grid[0][i] = lamp
            });
        });

        table_lamps.forEach(function(path, i) {
            const z = (i * padd) - (2*padd);
            return add_lamp(path, box_table.clone(), {z, y:0}, lamp => lamp_grid[1][i] = lamp);
        });


        wall_lamps.forEach(function(path, i) {
            const z = (i * padd) - (2*padd);
            return add_lamp(path, box_wall.clone(), {z, y:-30}, lamp => lamp_grid[2][i] = lamp);
        });
    })

    $(window).on('resize', on_resize);
    // $(window).mousemove(mouse_move);
    // setInterval(on_resize, 500);
    return animate();
});


// function mouse_move(event) {
//     position.x = event.clientX / $(window).width();
//     position.y = event.clientY / $(window).height();
// };

function update_positions() {
    const $container = $('#canvas_container');
    const width = $container.width();
    const height = $container.height();

    const vertical_view = $container.width() < $container.height();

    const step = vertical_view ? 30 : 40;//(width/35)
    const offset = vertical_view ? step/2 : 0;

    return Array.from(lamp_grid).map((row, r) =>
        (() => {
            for (let c = 0; c < row.length; c++) {
                var lamp = row[c];
                if (!lamp) { continue; }
                lamp.position.z = (c*step) - (2 * step) - offset;

                // Hide the outer two columns.
                if (vertical_view && (c !== 2) && (c !==3)) {
                    lamp.traverse(  object  => object.visible = false);
                    for (let e of Array.from(lamp.edges)) {
                        e.visible = false
                    }
                } else {
                    lamp.traverse(  object  => object.visible = true);
                    for (let e of Array.from(lamp.edges)) {
                        e.visible = true
                    }
                }
            }
        })());
};

var get_scale = function() {
    let scale;
    // How to scale the camera based on window
    // If in portrait mode, only show 3x3 lamps

    const $container = $('#canvas_container');
    // console.log $container.width(), $container.height()
    if ($container.width() < 500) {
        scale = (6 * ($container.height()))/700;
    } else {
        scale = (6 * ($container.height()))/700;
    }
    return scale;
};

function add_lamp(path, box, {scale, x, y, z, rx, ry, rz}, callback) {
    objLoader.load(path, function(group) {
        group.userData = {};
        group.add(box);

        if (x != null) { group.position.x = x; }

        if (y != null) { group.position.y = y; }
        if (z != null) { group.position.z = z; }

        if (rx != null) { group.rotation.x = rx; }
        if (ry != null) { group.rotation.y = ry; }
        if (rz != null) { group.rotation.z = rz; }

        if (scale != null) { group.scale.setScalar(scale); }

        group.userData.ry = (ry != null) ? ry : 0;
        group.userData.rx = (rx != null) ? rx : 0;
        group.userData.rz = (rz != null) ? rz : 0;

        group.userData.random_noise_x = ((Math.random()*2) - 1)*(Math.PI/32);
        group.userData.random_noise_y = ((Math.random()*2) - 1)*(Math.PI/16);
        group.userData.random_noise_z = ((Math.random()*2) - 1)*(Math.PI/32);

        add_out_line(group);

        lamp_groups.push(group);

        scene.add(group);

        // on_scroll();
        on_resize();
        callback(group);
    })
}

function on_scroll(event) {
    let top;
    const hh = $('.section').first().position().top + $('.section').height() + 20;
    const scroll = $(document).scrollTop();

    const action_start = hh;
    const action_end = (hh + $('.section.models').height()) - $('#canvas_container').height();
    let scroll_percent = 0;

    if (scroll < action_start) {
        top = hh - scroll;

    } else if (scroll > action_end) {
        top = action_end - scroll;
        scroll_percent = 1;

    } else { // IN BETWEEN - DO ACTION.
        top = 0;
        scroll_percent = (scroll - action_start) / (action_end - action_start);
    }

    $('#canvas_container').css('top', top);

    let s = (scroll_percent-.5) * 2;
    s = 1 - Math.pow(Math.abs(s), 2);

    return (() => {
        for (let group of Array.from(lamp_groups)) {

            let y = group.userData.ry;
            var x = -s * group.userData.random_noise_x;
            y += ((3*Math.PI)/2) + (Math.PI*(1-scroll_percent));
            y += -x * group.userData.random_noise_x;
            group.rotation.y = y
            group.rotation.x = x
        }
    })();
};

function on_resize() {
    const $container = $('#canvas_container');
    const width = $container.width();
    const height = $container.height();
    camera.left = width / - 2;
    camera.right = width / 2;
    camera.top = height / 2;
    camera.bottom = height / - 2;

    camera.zoom = get_scale();
    on_scroll();
    renderer.setSize(width, height);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    return update_positions();
};

function init($container, scale) {
    // SCENE
    scene = new THREE.Scene();

    // CAMERA
    const width = $container.width();
    const height = $container.height();
    const aspect = width / height;
    camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, -1000, 1000);
    camera.zoom = scale;
    camera.position.set(-150, 0, 0);
    camera.lookAt(scene.position);
    camera.updateProjectionMatrix();

    // RENDERER
    renderer = new THREE.WebGLRenderer({ preserveDrawingBuffer: false, alpha: true, antialias: true });
    renderer.setSize(width, height);
    renderer.setClearColor(0xffffff, 0);

    // Attach renderer to the container div.
    return $container.append($(renderer.domElement));
};

function update() {
    on_scroll()
}

function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
    return update();
};

const basicWhite = new THREE.MeshBasicMaterial({ color: 0xffffff });

function add_out_line(group) {
    group.edges = [];

    return group.traverse(function( mesh ) {
        if (mesh instanceof THREE.Mesh) {
            mesh.material = basicWhite;
            mesh.material.polygonOffset = true;
            mesh.material.polygonOffsetFactor = 2;
            mesh.material.polygonOffsetUnits = 1;
            mesh.material.side = THREE.DoubleSide;

            const edges = new THREE.EdgesHelper(mesh, 0x000000, 80);
            edges.material.linewidth = 1;

            group.edges.push(edges);
            return scene.add(edges);
        }
    });
};
