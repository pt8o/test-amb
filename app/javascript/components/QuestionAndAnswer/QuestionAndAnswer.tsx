import React, { useState } from "react";
import "./QuestionAndAnswer.css";
import { CSRF_TOKEN } from "../../utilities/cookies";

export function QuestionAndAnswer() {
  const [question, setQuestion] = useState("What is this book about?");
  const [answer, setAnswer] = useState("");
  const [error, setError] = useState("");

  function handleChangeQuestion(ev: React.ChangeEvent<HTMLTextAreaElement>) {
    if (answer) setAnswer("");
    if (error) setError("");
    setQuestion(ev.target.value);
  }

  function clearAnswer() {
    setAnswer("");
  }

  function submitQuestion() {
    fetch("./ask", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": CSRF_TOKEN,
      },
      body: JSON.stringify({ question }),
    }).then((response) => {
      response.json().then((data) => {
        if (data.error) {
          setError(data.error);
        } else {
          setAnswer(data.message);
        }
      });
    });
  }

  return (
    <div id="question-and-answer">
      <textarea
        id="question-box"
        value={question}
        onChange={handleChangeQuestion}
        maxLength={120}
      ></textarea>
      {answer ? (
        <div>
          <b>Answer:</b> {answer}
        </div>
      ) : null}
      {error ? (
        <div className="__error">
          <b>Error:</b> {error}
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
