import React, { useRef, useState } from "react";
import "./QuestionAndAnswer.css";
import { CSRF_TOKEN } from "../../utilities/cookies";
import { AnimatedText } from "../AnimatedText";

export function QuestionAndAnswer() {
  const [question, setQuestion] = useState("What is this book about?");
  const [answer, setAnswer] = useState("");
  const [error, setError] = useState("");
  const [isFetching, setIsFetching] = useState(false);

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  function handleChangeQuestion(ev: React.ChangeEvent<HTMLTextAreaElement>) {
    setAnswer("");
    setError("");
    setQuestion(ev.target.value);
  }

  function handleAskAnother() {
    setAnswer("");
    setError("");
    setQuestion("");
    textareaRef.current?.focus();
  }

  function submitQuestion() {
    if (!question) {
      setError("Question cannot be empty");
      return;
    }

    setIsFetching(true);

    fetch("./ask", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": CSRF_TOKEN,
      } as HeadersInit,
      body: JSON.stringify({ question }),
    }).then((response) => {
      response.json().then((data) => {
        if (data.error) {
          setError(data.error);
        } else {
          setAnswer(data.message);
        }
        setIsFetching(false);
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
        disabled={isFetching}
        ref={textareaRef}
      ></textarea>
      {answer ? (
        <div>
          <b>Answer:</b>
          {` `}
          <AnimatedText text={answer} interval={10} />
        </div>
      ) : null}
      {error ? (
        <div className="__error">
          <b>Error:</b> {error}
        </div>
      ) : null}
      <div className="buttons-container">
        {answer ? (
          <button onClick={handleAskAnother}>Ask another question</button>
        ) : (
          <>
            <button onClick={submitQuestion} disabled={isFetching}>
              {isFetching ? <AnimatedText text="..." loop /> : "Ask a question"}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
