import * as React from "react";
import * as ReactDOM from "react-dom";

const App = () => {
  return <div>Rails + React</div>;
};

document.addEventListener("DOMContentLoaded", () => {
  const rootEl = document.getElementById("root");
  ReactDOM.render(<App />, rootEl);
});