# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "three", to: "https://ga.jspm.io/npm:three@0.160.0/build/three.module.js"
pin "three/addons/controls/OrbitControls.js", to: "https://ga.jspm.io/npm:three@0.160.0/examples/jsm/controls/OrbitControls.js"
pin "three/addons/loaders/OBJLoader.js", to: "https://ga.jspm.io/npm:three@0.160.0/examples/jsm/loaders/OBJLoader.js"
pin "three/addons/loaders/PLYLoader.js", to: "https://ga.jspm.io/npm:three@0.160.0/examples/jsm/loaders/PLYLoader.js"
pin "three/addons/loaders/STLLoader.js", to: "https://ga.jspm.io/npm:three@0.160.0/examples/jsm/loaders/STLLoader.js"
pin_all_from "app/javascript/controllers", under: "controllers"
