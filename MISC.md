# Misc. thoughts on the project: design decisions, lessons learned, future work, etc.

## PDF script

One of the interesting aspects of this project is the fact that the original AskMyBook.com was written in Python, and there is an official Python library from OpenAI. This is not the case for Ruby; the OpenAI website links to two unofficial Ruby gems. Tech is built on small unofficial libraries like this, but still I tend to prefer using official libraries when possible.

When I first tackled the PDF-to-embeddings script, I opted to write that in JavaScript, partly since I'm just more comfortable in that language but also because I was able to use the official OpenAI Node.js library. When I later made an attempt to rewrite the script in Ruby, I couldn't get the `embeddings` method from the `ruby-openai` library to accept a string array as input, only a single string, which was a dealbreaker. If we really wanted to make this a Ruby-first project then I could directly query the API endpoint (as I did later in the Rails code). For now I've left the script in JS.

## Token counting

The above script splits the PDF into pages and fetches embeddings for each page, and also counts the number of tokens that the page would take if submitted to the Completions endpoint, saving all of this together in the CSV. Then, when the user asks a question, the backend compares the question's embeddings with the book's embeddings and sorts all of the book's text sections (pages) from most to least relevant. It adds these one at a time to an array until it reaches the token limit, and then this array is passed to the OpenAI Completions endpoint.

However, the pages are pretty big; in the PDF I used, a full page of text exceeds 700 tokens. We could probably get more granular results by having the script cut up the text into smaller sections, allowing more content to fit into the query.

I did not bother counting the max tokens before hitting the Embeddings endpoint. I know that the text I chose is pretty short so this wouldn't be necessary, but we'd need it to support a larger PDF.

I've also made some fuzzy guesses in setting the `MAX_INPUT_TOKENS` value (which you can read in the comments in `config/initializers/application_constants.rb`). If we wanted to really optimize this we could count the tokens of the preamble that is sent before the sorted text, and the user's question, and even the additional code characters (brackets, quotation marks, etc.) which are included in the token count.

## Development

I prioritized getting up and running quickly which led to some problems later on.

SQLite is very easy to plug-and-play but is not good for deployment; Heroku specifically recommends against it. I spun up the app with SQLite but later had to spend some time reconfiguring the app to use Postgres.

I found a quick way to get a React app served from a Rails app. The React app itself runs in watcher mode and during development it hot reloads well, but the Rails app does not hot reload on the JS file change! I only spent a few minutes exploring this but it seems like I should have chosen a different build/dev pipeline to prioritize HMR. This was a small headache during development.

## Testing

Frontend testing would be nice. I wasn't as concerned with the frontend tests. I feel like the backend is where there are more moving parts and breaking points, whereas on the frontend the user's surface area of interaction is quite small. I can click through to every possible frontend state in a matter of seconds. Nonetheless, in production everything should have automated tests as a best practice.

On the backend, I was using `rails test` just because it's the default. Later I needed some more robust mocking of the methods of imported modules, which I found was easier to do with RSpec. I thought I could set things up so the RSpec tests would also run with the `rails test` command but this wasn't trivial; maybe I just need to spend some more time looking into it. For now there are two parallel test suites, which works but isn't ideal.

## Typing

The backend code isn't typed at all; worth exploring.

The frontend types are not the most robust. Inference handles most of it. At the very least the response from the `/ask` endpoint should be typed!

## Throttling

Since each new question (a) hits the OpenAI API, which costs real life money, and (b) creates a new database entry, it's worth having some guardrails in place to prevent abuse. Maybe throttling the requests, or detecting a lot of nonsense questions in a row. The frontend does not allow the user to hit the `/ask` endpoint while a request is in progress but there's no restrictions on the backend; at the moment there's nothing stopping a savvy user from programmatically chucking loads of hits to the endpoint. The input is also not sanitized.

## Code style

I've written the `OpenaiRequest` as a module in `lib/utils/` with a few methods (`openai_request`, `get_embeddings`, `get_completion`). This works but does not feel "Rails-y" as an approach. I think this would be better as a class, with these functions as class methods, so we would invoke them more like a library, e.g. `OpenaiRequest.completion(query)`. This looks pretty close to how the Ruby OpenAI gems worked. It would not be too hard of a refactor.

## UX

I've matched the existing design. Sometimes I wonder whether old questions/answers should stay up in a chat-style interface, though I do like the simplicity.

The saved questions get answered instantly while new questions go to OpenAI, and that request can take a long time, sometimes several seconds. This discrepancy is weird UX and I wonder how we could let the user know that some questions will take longer to answer than others, without them needing to know about how the machine works.

## Error handling

This is probably the weakest part of the app at the moment. The frontend is sent a pretty generic error message, and backend errors are not logged anywhere.
