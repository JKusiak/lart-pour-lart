-- dropping the tables in reverse to be able to overwrite their content

DROP TABLE visitors;
DROP TABLE range_of_accesses;
DROP TABLE exhibition_contents;
DROP TABLE ordered_artworks;
DROP TABLE artworks;
DROP TABLE art_styles;
DROP TABLE art_style_translations;
DROP TABLE artwork_translations;
DROP TABLE total_orders;
DROP TABLE tickets;
DROP TABLE exhibitions;
DROP TABLE artists;

----------------------------------------------------------------------
----------------------------------------------------------------------
-- creating tables and adding indexes

CREATE TABLE artists (
    artist_id NUMBER NOT NULL,
    name VARCHAR2(100) NOT NULL,
    surname VARCHAR2(100),
    birthplace VARCHAR2(100),
    dat_of_birth DATE,
    date_of_death DATE
);

----------------------------------------------------------------------

CREATE TABLE exhibitions (
    exhibition_id NUMBER NOT NULL,
    title VARCHAR2(100) NOT NULL,
    date_of_beginning DATE NOT NULL,
    date_of_ending DATE NOT NULL,
    is_adult_only NUMBER(1) NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE exhibition_contents (
    exhib_con_id NUMBER NOT NULL,
    exhibition_id NUMBER NOT NULL,
    artwork_id NUMBER NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE artworks (
    artwork_id NUMBER NOT NULL,
    artist_id NUMBER NOT NULL,
    art_style_id NUMBER NOT NULL,
    description_tranlsation_id NUMBER NOT NULL,
    title VARCHAR2(100),
    year_of_creation DATE,
    price NUMBER NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE artwork_translations (
    translation_id NUMBER NOT NULL,
    text_EN VARCHAR2(4000),
    text_PL VARCHAR2(4000),
    text_FR VARCHAR2(4000)
);

----------------------------------------------------------------------

CREATE TABLE art_styles (
    art_style_id NUMBER NOT NULL,
    description_translation_id NUMBER NOT NULL,
    name VARCHAR(100)
);

----------------------------------------------------------------------

CREATE TABLE art_style_translations (
    translation_id NUMBER NOT NULL,
    text_EN VARCHAR2(4000),
    text_PL VARCHAR2(4000),
    text_FR VARCHAR2(4000)
);

----------------------------------------------------------------------

CREATE TABLE range_of_accesses (
    range_of_access_id NUMBER NOT NULL,
    ticket_id NUMBER NOT NULL,
    exhibition_id NUMBER NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE tickets (
    ticket_id NUMBER NOT NULL,
    has_discount NUMBER(1) NOT NULL,
    price NUMBER NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE visitors (
    visitor_id NUMBER NOT NULL,
    ticket_id NUMBER NOT NULL,
    total_order_id NUMBER,
    name VARCHAR2(100) NOT NULL,
    surname VARCHAR2(100) NOT NULL,
    isUnderage NUMBER(1) NOT NULL,
    time_of_entrance TIMESTAMP NOT NULL,
    city VARCHAR2(100),
    street VARCHAR2(100),
    house_number NUMBER,
    zip_code VARCHAR2(10),
    phone_number NUMBER
);

----------------------------------------------------------------------

CREATE TABLE total_orders (
    total_order_id NUMBER NOT NULL,
    payment NUMBER NOT NULL,
    date_of_order DATE NOT NULL,
    approximate_delivery DATE NOT NULL
);

----------------------------------------------------------------------

CREATE TABLE ordered_artworks (
    ordered_artwork_id NUMBER NOT NULL,
    total_order_id NUMBER NOT NULL,
    artwork_id NUMBER NOT NULL
);



----------------------------------------------------------------------
----------------------------------------------------------------------
-- adding indexes, primary keys and foreign keys to all tables

CREATE UNIQUE INDEX artist_id_pk
ON artists (artist_id);

ALTER TABLE artists
ADD (
    CONSTRAINT artist_id_pk
        PRIMARY KEY (artist_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX exhib_id_pk
ON exhibitions (exhibition_id);

ALTER TABLE exhibitions
ADD (
    CONSTRAINT exhib_id_pk
        PRIMARY KEY (exhibition_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX tickets_id_pk
ON tickets (ticket_id);

ALTER TABLE tickets
ADD (
    CONSTRAINT tickets_id_pk
        PRIMARY KEY (ticket_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX totord_id_pk
ON total_orders(total_order_id);

ALTER TABLE total_orders
ADD (
    CONSTRAINT totord_id_pk
        PRIMARY KEY (total_order_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX art_trans_id_pk
ON artwork_translations (translation_id);

ALTER TABLE artwork_translations
ADD (
    CONSTRAINT art_trans_id_pk
        PRIMARY KEY (translation_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX as_trans_id_pk
ON art_style_translations (translation_id);

ALTER TABLE art_style_translations
ADD (
    CONSTRAINT as_trans_id_pk
        PRIMARY KEY (translation_id)
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX art_style_id_pk
ON art_styles (art_style_id);

ALTER TABLE art_styles
ADD (
    CONSTRAINT art_style_id_pk
        PRIMARY KEY (art_style_id),
    CONSTRAINT as_trans_id_fk
        FOREIGN KEY (description_translation_id)
        REFERENCES art_style_translations
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX artwork_id_pk
ON artworks (artwork_id);

ALTER TABLE artworks
ADD (
    CONSTRAINT artwork_id_pk
        PRIMARY KEY (artwork_id),
    CONSTRAINT artist_id_fk
        FOREIGN KEY (artist_id)
        REFERENCES artists,
    CONSTRAINT art_style_id_fk
        FOREIGN KEY (art_style_id)
        REFERENCES artists,
    CONSTRAINT art_trans_id_fk
        FOREIGN KEY (description_tranlsation_id)
        REFERENCES artwork_translations
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX ordart_id_pk
ON ordered_artworks(ordered_artwork_id);

ALTER TABLE ordered_artworks
ADD (
    CONSTRAINT ordart_id_pk
        PRIMARY KEY (ordered_artwork_id),
    CONSTRAINT totord_id_fk1
        FOREIGN KEY (total_order_id)
        REFERENCES total_orders,
    CONSTRAINT artwork_id_fk2
        FOREIGN KEY (artwork_id)
        REFERENCES artworks
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX exhib_con_id_pk
ON exhibition_contents (exhib_con_id);

ALTER TABLE exhibition_contents
ADD (
    CONSTRAINT exhib_con_id_pk
        PRIMARY KEY (exhib_con_id),
    CONSTRAINT exhib_id_fk1
        FOREIGN KEY (exhibition_id)
        REFERENCES exhibitions,
    CONSTRAINT artwork_id_fk1
        FOREIGN KEY (artwork_id)
        REFERENCES artworks
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX roa_id_pk
ON range_of_accesses (range_of_access_id);

ALTER TABLE range_of_accesses
ADD (
    CONSTRAINT roa_id_pk
        PRIMARY KEY (range_of_access_id),
    CONSTRAINT tickets_id_fk1
        FOREIGN KEY (ticket_id)
        REFERENCES tickets,
    CONSTRAINT exhib_id_fk2
        FOREIGN KEY (exhibition_id)
        REFERENCES exhibitions
);

----------------------------------------------------------------------

CREATE UNIQUE INDEX visitor_id_pk
ON visitors(visitor_id);

ALTER TABLE visitors
ADD (
    CONSTRAINT visitor_id_pk
        PRIMARY KEY (visitor_id),
    CONSTRAINT tickets_id_fk2
        FOREIGN KEY (ticket_id)
        REFERENCES tickets,
    CONSTRAINT totord_id_fk2
        FOREIGN KEY (total_order_id)
        REFERENCES total_orders
);



