const pdfjs = require("pdfjs-dist");
const { writeFileSync } = require("node:fs");
const { Configuration, OpenAIApi } = require("openai");

require("dotenv").config();

const EMBEDDING_MODEL = "text-embedding-ada-002";

if (process.argv.length === 2) {
  console.log("Error: no path to PDF file provided");
  return;
}

const filePath = process.argv[2];
const fileName = filePath.split("\\").pop().split("/").pop();

function arrayToCSV(data) {
  return data.map((row) => row.join(",")).join("\n");
}

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);

pdfjs.getDocument(filePath).promise.then((doc) => {
  const allPromises = Array.from({ length: doc.numPages }, (_, i) => i + 1).map(
    (pageNumber) => {
      return doc.getPage(pageNumber).then((page) => {
        return page.getTextContent().then((rawText) => {
          return rawText.items.map((item) => item.str).join(" ");
        });
      });
    }
  );

  Promise.all(allPromises).then((vals) => {
    openai
      .createEmbedding({
        model: EMBEDDING_MODEL,
        input: vals,
      })
      .then((response) => {
        const data = response.data.data;

        const valsAndEmbeddings = vals.reduce(
          (acc, currentValue, currentIndex) => {
            return [
              ...acc,
              // wrap all contents in double quotes to prevent in-content commas from breaking CSV format
              [
                `"${currentValue}"`,
                `"${JSON.stringify(data[currentIndex].embedding)}"`,
              ],
            ];
          },
          [["text", "embedding"]]
        );

        writeFileSync(
          `app/lib/assets/${fileName}.embeddings.csv`,
          arrayToCSV(valsAndEmbeddings),
          "utf-8",
          (err) => {
            console.error("Error writing CSV file:", err);
          }
        );
      });
  });
});
