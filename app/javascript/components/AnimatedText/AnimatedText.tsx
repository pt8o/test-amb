import React, { useState, useEffect, useRef } from "react";

export function AnimatedText({ text, loop }: { text: string; loop?: boolean }) {
  const [displayText, setDisplayText] = useState(text[0]);
  const intervalRef = useRef<NodeJS.Timer | null>(null);

  function resetAfterDelay() {
    setTimeout(() => {
      if (intervalRef.current) return;
      setDisplayText(text[0]);
      intervalRef.current = generateInterval();
    }, 1000);
  }

  function clearDisplayTextInterval() {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
    intervalRef.current = null;
  }

  function generateInterval() {
    return setInterval(() => {
      setDisplayText((prev) => {
        if (prev.length === text.length) {
          if (loop) {
            resetAfterDelay();
          }
          clearDisplayTextInterval();
          return prev;
        }
        return text.slice(0, prev.length + 1);
      });
    }, 100);
  }

  useEffect(() => {
    intervalRef.current = generateInterval();
    return () => clearDisplayTextInterval();
  }, []);

  return displayText;
}
