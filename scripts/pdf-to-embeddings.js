const pdfjs = require("pdfjs-dist");
const { readFileSync } = require("node:fs");

if (process.argv.length === 2) {
  console.log("Error: no path to PDF file provided");
  return;
}

pdfjs
  .getDocument(process.argv[2])
  .promise.then((doc) => {
    const allPromises = Array.from(
      { length: doc.numPages },
      (_, i) => i + 1
    ).map((pageNumber) => {
      return doc.getPage(pageNumber).then((page) => {
        return page.getTextContent().then((rawText) => {
          return rawText.items.map((item) => item.str).join(" ");
        });
      });
    });

    Promise.all(allPromises).then((vals) => {
      console.log(vals);
    });
  })
  .catch((err) => {
    console.log(err);
  });
