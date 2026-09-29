# Working rules for this repo

- **Never read, open, print, or edit `.env`.** It holds the user's local
  `GEMINI_API_KEY`. Don't use Read/cat/grep on it, don't include its
  contents in a response, and don't modify it — if a key or model needs to
  change, tell the user what to put in `.env` (or edit `.env.example`, which
  is safe) and let them do it themselves.
