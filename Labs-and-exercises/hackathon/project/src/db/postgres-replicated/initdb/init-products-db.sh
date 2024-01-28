#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL

    CREATE TABLE public.products (
        id bigint NOT NULL,
        name character varying(255) NULL,
        price numeric(19,2) NULL,
        stock bigint NOT NULL
    );

    ALTER TABLE public.products ADD CONSTRAINT products_pkey PRIMARY KEY (id);

    INSERT INTO "public"."products" ("id", "name", "price", "stock")
        VALUES (1, 'Arm64 SoC', 30.00, 600);

    INSERT INTO "public"."products" ("id", "name", "price", "stock")
        VALUES (2, 'IoT breakout board', 8.00, 40);

    INSERT INTO "public"."products" ("id", "name", "price", "stock")
        VALUES (3, 'DAC extension board', 15.50, 750);

    INSERT INTO "public"."products" ("id", "name", "price", "stock")
        VALUES (4, 'Mars comms unit', 6000.00, 0);

EOSQL