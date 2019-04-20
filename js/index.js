import {Elm} from '../.build/main.js';

Elm.Main.init({
  node: document.getElementById('elm')
});

import("../crate/pkg").then(module => {
  module.run();
});
