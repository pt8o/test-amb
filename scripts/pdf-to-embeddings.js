const pdfjs = require("pdfjs-dist");
const { writeFileSync } = require("node:fs");
const { Configuration, OpenAIApi } = require("openai");

require("dotenv").config()

const EMBEDDING_MODEL = "text-embedding-ada-002";
const COMPLETION_MODEL = "text-ada-001";

if (process.argv.length === 2) {
  console.log("Error: no path to PDF file provided");
  return;
}

const filePath = process.argv[2];
const fileName = filePath.split('\\').pop().split('/').pop();

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);


pdfjs
  .getDocument(filePath)
  .promise.then((doc) => {
    const allPromises = Array.from(
      { length: doc.numPages },
      (_, i) => i + 1
    ).map((pageNumber) => {
      return doc.getPage(pageNumber).then((page) => {
        return page.getTextContent().then((rawText) => {
          return rawText.items.map((item) => item.str).join("\n");
        });
      });
    });

    Promise.all(allPromises).then((vals) => {
      openai.createEmbedding({
        model: EMBEDDING_MODEL,
        input: vals
      }).then(response => {
        const data = response.data.data;
        const valsAndEmbeddings = vals.reduce((acc, currentValue, currentIndex) => {
          return [...acc, {
            value: currentValue,
            embedding: data[currentIndex].embedding
          }]
        }, []);
        writeFileSync(`app/assets/docs/${fileName}.embedding.json`, JSON.stringify(valsAndEmbeddings));
      }).catch((err) => console.log(err));
    });
  })
  .catch((err) => {
    console.log(err);
  });
