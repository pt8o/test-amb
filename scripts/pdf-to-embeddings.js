const pdfjs = require("pdfjs-dist");
const { writeFileSync } = require("node:fs");
const { Configuration, OpenAIApi } = require("openai");
const { encoding_for_model } = require("tiktoken");

require("dotenv").config();

const { OPENAI_API_KEY, OPENAI_EMBEDDINGS_MODEL, OPENAI_COMPLETIONS_MODEL } =
  process.env;

/**
 * Although we're sending the PDF text to the Embeddings endpoint, right now we only care about counting the tokens
 * later being sent to the Completions model. This will be happening at the server level and exceeding the token limit
 * there will cause the request to fail within the app, which is where failure is more critical.
 */
const tiktoken = encoding_for_model(OPENAI_COMPLETIONS_MODEL);

if (process.argv.length === 2) {
  console.error("Error: no path to PDF file provided");
  return;
}

const filePath = process.argv[2];
const fileName = filePath.split("\\").pop().split("/").pop();

function arrayToCSV(data) {
  return data.map((row) => row.join(",")).join("\n");
}

const configuration = new Configuration({
  apiKey: OPENAI_API_KEY,
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
        model: OPENAI_EMBEDDINGS_MODEL,
        input: vals,
      })
      .then((response) => {
        const data = response.data.data;

        const valsAndEmbeddings = vals.reduce(
          (acc, currentValue, currentIndex) => {
            return [
              ...acc,
              // wrap text & embeddings in double quotes to prevent in-content commas from breaking CSV format
              [
                `"${currentValue}"`,
                `"${JSON.stringify(data[currentIndex].embedding)}"`,
                tiktoken.encode(currentValue).length,
              ],
            ];
          },
          [["text", "embedding", "tokens"]]
        );

        writeFileSync(
          `lib/assets/${fileName}.embeddings.csv`,
          arrayToCSV(valsAndEmbeddings),
          "utf-8",
          (err) => {
            console.error("Error writing CSV file:", err);
          }
        );

        console.log(`Successfully wrote lib/assets/${fileName}.embeddings.csv`);
        tiktoken.free();
      });
  });
});
