-- Brigid's tables use gen_random_uuid() and the migrations do not create the
-- extension. Runs once, when the database volume is first initialised.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
