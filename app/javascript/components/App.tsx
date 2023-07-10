import React from "react";
import { createRoot } from "react-dom/client";
import { Header } from "./Header";
import { Footer } from "./Footer";
import { QuestionAndAnswer } from "./QuestionAndAnswer";

import "./global.css";
import "./App.css";

function App() {
  return (
    <div id="app">
      <Header />
      <main>
        <div className="text-box-description">
          <p>
            This is an experiment in using AI to make a book's content more
            accessible. Ask a question about this book and AI will answer it in
            real time!
          </p>
          <p>
            Please limit your queries to the book's contents; the AI has been
            instructed to not use outside knowledge.
          </p>
        </div>
        <QuestionAndAnswer />
      </main>
      <Footer />
    </div>
  );
}

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("root");
  const root = createRoot(container!);
  root.render(<App />);
});
