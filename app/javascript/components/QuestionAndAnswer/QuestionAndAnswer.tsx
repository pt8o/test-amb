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

    setError("");
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

  function randomQuestion() {
    const questions = [
      "Are these true stories or fiction?",
      "How many dogs did Tolstoy have?",
      "What were the dogs' names?",
      "How many chapters are in the book?",
      "What kind of dogs did Tolstoy have?",
      "Were both dogs alive at the same time?",
      "What were the dogs like?",
      "Where did Tolstoy and his dogs live?",
      "What happens in the story with the convicts?",
    ];

    const randomQuestion =
      questions[Math.floor(Math.random() * questions.length)];
    setQuestion(randomQuestion);
  }

  return (
    <div id="question-and-answer">
      <div id="question-box-container">
        <textarea
          id="question-box"
          value={question}
          onChange={handleChangeQuestion}
          maxLength={120}
          disabled={isFetching}
          ref={textareaRef}
          rows={3}
        ></textarea>
        <div id="character-counter">{question.length} / 120</div>
      </div>
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
              {isFetching ? <AnimatedText text="..." loop /> : "Ask"}
            </button>
            <button
              onClick={randomQuestion}
              disabled={isFetching}
              className="__secondary"
            >
              Get a random question
            </button>
          </>
        )}
      </div>
    </div>
  );
}
