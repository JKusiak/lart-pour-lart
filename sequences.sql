CREATE SEQUENCE total_order_id_seq
    INCREMENT BY 1
    START WITH 13;

CREATE SEQUENCE ordered_artworks_id_seq
    INCREMENT BY 1
    START WITH 19;

CREATE SEQUENCE ticket_visitor_id_seq
    INCREMENT BY 1
    START WITH 64;

CREATE SEQUENCE range_of_acess_id_seq
    INCREMENT BY 1
    START WITH 73;



DROP SEQUENCE total_order_id_seq;
DROP SEQUENCE ordered_artworks_id_seq;
DROP SEQUENCE ticket_visitor_id_seq;
DROP SEQUENCE range_of_acess_id_seq;