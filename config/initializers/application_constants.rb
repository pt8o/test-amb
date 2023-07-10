require 'dotenv/load'

OPENAI_API_KEY = ENV['OPENAI_API_KEY']
OPENAI_EMBEDDINGS_ENDPOINT = 'https://api.openai.com/v1/embeddings'
OPENAI_EMBEDDINGS_MODEL = ENV['OPENAI_EMBEDDINGS_MODEL']
OPENAI_COMPLETIONS_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
OPENAI_COMPLETIONS_MODEL = ENV['OPENAI_COMPLETIONS_MODEL']

# API max tokens = 4096
# 150 is a safe max output for a few sentences
MAX_OUTPUT_TOKENS = 150

# Fill up the rest of the tokens with the query.
# Starting at 4096,
# -150 for the return text
# -400 as generous buffer for additional characters in the query
# -46 tokens for the user's question; 120 characters is unlikely to exceed this
MAX_INPUT_TOKENS = 3500
