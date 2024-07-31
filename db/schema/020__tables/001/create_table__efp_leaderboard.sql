-- migrate:up
-------------------------------------------------------------------------------
-- Table: efp_leaderboard
-------------------------------------------------------------------------------
CREATE TABLE
  public.efp_leaderboard (
    "name" TEXT NOT NULL,
    "address" types.eth_address NOT NULL,
    "avatar" TEXT,
    "mutuals" BIGINT,
    "following" BIGINT,
    "followers" BIGINT,
    "blocks" BIGINT,
    created_at TIMESTAMP
    WITH
      TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP
    WITH
      TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY ("address", "name")
  );

CREATE TRIGGER
  update_efp_leaderboard_updated_at BEFORE
UPDATE
  ON public.efp_leaderboard FOR EACH ROW
EXECUTE
  FUNCTION public.update_updated_at_column();

-- migrate:down
-------------------------------------------------------------------------------
-- Undo Table: efp_leaderboard
-------------------------------------------------------------------------------
DROP TABLE
  IF EXISTS public.efp_leaderboard CASCADE;