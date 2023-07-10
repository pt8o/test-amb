# README

This project is a recreation of [AskMyBook.com](https://askmybook.com/) in Ruby on Rails and React.

It allows you to ask a book questions, and an AI answers the questions for you. The book provided here as an example is Tolstoy's "Stories of My Dogs".

Behind the scenes, here's how it works:

- There's a script that takes a PDF, converts it to plain text, and then generates embeddings for the text using OpenAI.
- When the user asks a question, it also generates embeddings for the question text.
- The question and book embeddings are compared and the book text sections are sorted by the cosine similarity of their embeddings to the question's embeddings.
- The most relevant texts are passed to the OpenAI completions endpoint, and ChatGPT answers the question.

## Setup

For the backend, you need Ruby and `bundler` installed. Then, run `bundle install` to install Ruby dependencies.

For the frontend, you need Node, `npm`, and `yarn` installed. Run `yarn` to install Node dependencies.

In the project root, create a `.env` file, following the pattern in the `.env.example` file. You will need to replace some of the entries with your own secrets, local filenames, etc.

Pass in a path to a PDF file to the script that will fetch the embeddings: `yarn run convert-pdf path/to/file.pdf`. The embeddings CSV file will be saved where it is needed, in `lib/assets/`.

## Run & develop

Run `bin/dev` to run a development server.

## Test

On the backend, there are both standard Rails tests and RSpec tests. To run all Rails tests, just run `rails test`. To run RSpec tests, run `bundle exec rspec path/to/test/file.rb`.

There are currently no frontend tests.
