import React, { useState } from "react";
import "./QuestionAndAnswer.css";

export function QuestionAndAnswer() {
  const [question, setQuestion] = useState("What is this book about?");
  const [answer, setAnswer] = useState("hi");

  function handleChangeQuestion(ev: React.ChangeEvent<HTMLTextAreaElement>) {
    if (answer) setAnswer("");
    setQuestion(ev.target.value);
  }

  function clearAnswer() {
    setAnswer("");
  }

  function submitQuestion() {
    fetch("./ask", {
      method: "POST",
      body: question,
    });
  }

  return (
    <div id="question-and-answer">
      <textarea
        id="question-box"
        value={question}
        onChange={handleChangeQuestion}
      ></textarea>
      {answer ? (
        <div id="answer-box">
          <b>Answer:</b> {answer}
        </div>
      ) : null}
      <div className="buttons-container">
        {answer ? (
          <button onClick={clearAnswer}>Ask another question</button>
        ) : (
          <>
            <button onClick={submitQuestion}>Ask a question</button>
          </>
        )}
      </div>
    </div>
  );
}
