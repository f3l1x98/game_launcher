CREATE OR REPLACE FUNCTION trigger_set_updated_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Table: public.developer

-- DROP TABLE public.developer;

CREATE TABLE public.developer
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    website character varying COLLATE pg_catalog."default",
    CONSTRAINT "Gamedeveloper_pkey" PRIMARY KEY (id),
    CONSTRAINT gamedeveloper_name_unqiue_constraint UNIQUE (name)

)

TABLESPACE pg_default;



-- Table: public.game

-- DROP TABLE public.game;

CREATE TABLE public.game
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    description character varying COLLATE pg_catalog."default",
    version character varying COLLATE pg_catalog."default" NOT NULL,
    language character varying COLLATE pg_catalog."default" NOT NULL,
    voting integer DEFAULT 0,
    used_gameengine_enum character varying COLLATE pg_catalog."default" NOT NULL,
    prequel_id integer,
    sequel_id integer,
    path character varying COLLATE pg_catalog."default" NOT NULL,
    metadata_path character varying COLLATE pg_catalog."default" NOT NULL,
    exe_path character varying COLLATE pg_catalog."default" NOT NULL,
    saves_path character varying COLLATE pg_catalog."default",
    archive_filename character varying COLLATE pg_catalog."default" NOT NULL,
    cover_path character varying COLLATE pg_catalog."default",
    images character varying[] NOT NULL DEFAULT '{}'::character varying[],
    website character varying COLLATE pg_catalog."default",
    full_save_available boolean NOT NULL DEFAULT false,
    installed boolean NOT NULL DEFAULT true,
    inserted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_played_at TIMESTAMPTZ,
    has_guide boolean NOT NULL DEFAULT false,
    CONSTRAINT "Game_pkey" PRIMARY KEY (id),
    CONSTRAINT game_name_unique_constraint UNIQUE (name),
    CONSTRAINT fk_game_prequel FOREIGN KEY (prequel_id)
        REFERENCES public.game (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT fk_game_sequel FOREIGN KEY (sequel_id)
        REFERENCES public.game (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

TABLESPACE pg_default;

-- Updated_at timestamp trigger

CREATE TRIGGER set_updated_timestamp
BEFORE UPDATE ON public.game
FOR EACH ROW
EXECUTE FUNCTION trigger_set_updated_timestamp();



-- Table: public.genre

-- DROP TABLE public.genre;

CREATE TABLE public.genre
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    description character varying COLLATE pg_catalog."default",
    CONSTRAINT "Genre_pkey" PRIMARY KEY (id),
    CONSTRAINT genre_name_unique_constraint UNIQUE (name)

)

TABLESPACE pg_default;



-- Table: public.save_profile

-- DROP TABLE public.save_profile;

CREATE TABLE public.save_profile
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    name character varying COLLATE pg_catalog."default" NOT NULL,
    game_id integer NOT NULL,
    active boolean NOT NULL DEFAULT false,
    game_version character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "GameSaveProfile_pkey" PRIMARY KEY (id),
    CONSTRAINT gamesaveprofile_name_gameid_unique_constraint UNIQUE (name, game_id),
    CONSTRAINT fk_gamesaveprofile_game FOREIGN KEY (game_id)
        REFERENCES public.game (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;



-- Table: public.game_genre

-- DROP TABLE public.game_genre;

CREATE TABLE public.game_genre
(
    game_id integer NOT NULL,
    genre_id integer NOT NULL,
    CONSTRAINT "Game_Genre_pkey" PRIMARY KEY (game_id, genre_id),
    CONSTRAINT fk_game_genre_game FOREIGN KEY (game_id)
        REFERENCES public.game (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT fk_game_genre_genre FOREIGN KEY (genre_id)
        REFERENCES public.genre (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;



-- Table: public.game_developer

-- DROP TABLE public.game_developer;

CREATE TABLE public.game_developer
(
    game_id integer NOT NULL,
    developer_id integer NOT NULL,
    CONSTRAINT "Game_Gamedeveloper_pkey" PRIMARY KEY (game_id, developer_id),
    CONSTRAINT fk_game_gamedeveloper_game FOREIGN KEY (game_id)
        REFERENCES public.game (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT fk_game_gamedeveloper_gamedeveloper FOREIGN KEY (developer_id)
        REFERENCES public.developer (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;
