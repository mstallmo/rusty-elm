import {Elm} from '../elm/Main.elm';
import("../crate/pkg").then(module => {
  const app = Elm.Main.init({
    node: document.getElementById('elm')
  });

  app.ports.hello.subscribe(() => {
    console.log("Hello with Elm Ports!");
    alert("I'm an annoying alert!");
    module.hello();
  });
});
