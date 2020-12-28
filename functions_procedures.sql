SET SERVEROUTPUT ON;

-- function calculating number of multi-access tickets overall or for given two exhibitions
CREATE OR REPLACE FUNCTION MULTI_ACCESS_TICKETS_FUN(i_first_exhib IN range_of_accesses.exhibition_id%TYPE, i_second_exhibition IN range_of_accesses.exhibition_id%TYPE)
RETURN NUMBER
IS
    l_repeated_tickets NUMBER := 0;
    l_access_instance NUMBER := 0;
    l_tickets NUMBER := 0;
    
BEGIN 
    SELECT COUNT(DISTINCT ticket_id), COUNT(range_of_access_id)
    INTO l_tickets, l_access_instance
    FROM range_of_accesses
    WHERE (i_first_exhib = exhibition_id OR i_second_exhibition = exhibition_id) OR (i_first_exhib IS NULL AND i_second_exhibition IS NULL);
    
    l_repeated_tickets := l_access_instance - l_tickets;
    RETURN l_repeated_tickets;
END;

-- procedure displaying information about particular exhibition and how many visitors bought multi-access tickets
CREATE OR REPLACE PROCEDURE DISPLAY_EXHIB_VISITORS_INFO_PRC(i_first_exhib IN range_of_accesses.exhibition_id%TYPE, i_second_exhib IN range_of_accesses.exhibition_id%TYPE)
IS
    l_all_repeated_tickets NUMBER;
    l_repeated_tickets_particular NUMBER;
    l_first_exhib_name exhibitions.title%TYPE;
    l_second_exhib_name exhibitions.title%TYPE;

    CURSOR c_exhibitions_visits
    IS
        SELECT exhibitions.title AS title, COUNT(range_of_accesses.ticket_id) AS no_visit
        FROM range_of_accesses
        INNER JOIN exhibitions
        ON exhibitions.exhibition_id = range_of_accesses.exhibition_id
        GROUP BY title;
        
BEGIN
    FOR exhibition in c_exhibitions_visits
    LOOP
        DBMS_OUTPUT.PUT_LINE('Exhibition ' || exhibition.title || ' was visited ' || exhibition.no_visit || ' times');
    END LOOP;
    
    l_all_repeated_tickets := MULTI_ACCESS_TICKETS_FUN(NULL, NULL);
    l_repeated_tickets_particular := MULTI_ACCESS_TICKETS_FUN(i_first_exhib, i_second_exhib);
    
    SELECT title
    INTO l_first_exhib_name
    FROM exhibitions
    WHERE exhibition_id = i_first_exhib;
    
    SELECT title
    INTO l_second_exhib_name
    FROM exhibitions
    WHERE exhibition_id = i_second_exhib;
    
    dbms_output.new_line();
    DBMS_OUTPUT.PUT_LINE('Out of all visitors, ' || l_all_repeated_tickets || ' bought multi-access tickets.');
    
    DBMS_OUTPUT.PUT_LINE('There are ' || l_repeated_tickets_particular || ' visitors who bought tickets to both ' ||
                        l_first_exhib_name ||' and ' || l_second_exhib_name || ' exhibitions.');
END;

BEGIN
    DISPLAY_EXHIB_VISITORS_INFO_PRC(2, 3);
END;


CREATE SEQUENCE total_order_id_seq
    INCREMENT BY 1
    START WITH 13;

CREATE SEQUENCE ordered_artworks_id_seq
    INCREMENT BY 1
    START WITH 19;

CREATE OR REPLACE TYPE ART_ID_VARRAY_T AS VARRAY(10) OF NUMERIC;




CREATE OR REPLACE PROCEDURE PLACE_TRANSACTION_PRC(  i_visitor_id IN visitors.visitor_id%TYPE,
                                                    i_visitor_city IN visitors.city%TYPE,
                                                    i_visitor_street IN visitors.street%TYPE,
                                                    i_visitor_zip IN visitors.zip_code%TYPE,
                                                    i_visitor_phone IN visitors.phone_number%TYPE,
                                                    i_art_id_array IN ART_ID_VARRAY_T)
                                                    
IS
    l_order_date DATE := sysdate;
    l_delivery_date DATE := l_order_date + 14;
    l_tot_order_id NUMBER := total_order_id_seq.NEXTVAL;
    
    l_visitor_house NUMBER := TO_NUMBER(SUBSTR(2, REGEXP_SUBSTR(i_visitor_street, ' \d+')));
    
    l_artwork_price NUMBER := 0;
    l_total_payment NUMBER := 0;
    
BEGIN
    IF CHECK_NOT_ALREADY_ORDERED_FUN(i_art_id_array) = 1 THEN
    
        UPDATE visitors
        SET city = i_visitor_city, 
            street = i_visitor_street, 
            house_number = l_visitor_house, 
            zip_code = i_visitor_zip, 
            phone_number = i_visitor_phone
        WHERE visitor_id = i_visitor_id;
    
        INSERT INTO total_orders(total_order_id, payment, date_of_order, approximate_delivery)
        VALUES(l_tot_order_id, 0, l_order_date, l_delivery_date);
        
        FOR i IN 1..i_art_id_array.COUNT
        LOOP
            DELETE FROM exhibition_contents
            WHERE artwork_id = i_art_id_array(i);
            
            SELECT price
            INTO l_artwork_price
            FROM artworks
            WHERE artwork_id = i_art_id_array(i);
            
            INSERT INTO ordered_artworks(ordered_artwork_id, total_order_id, artwork_id)
            VALUES(ordered_artworks_id_seq.NEXTVAL, l_tot_order_id, i_art_id_array(i));
           
            l_total_payment := l_total_payment + l_artwork_price;
        END LOOP;
        
        UPDATE total_orders
        SET payment = l_total_payment
        WHERE total_order_id = l_tot_order_id;
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('You try to buy an artwork that has already been sold');
        RETURN;
    END IF;
END;



CREATE OR REPLACE FUNCTION CHECK_NOT_ALREADY_ORDERED_FUN(i_art_id_array IN ART_ID_VARRAY_T)
RETURN NUMBER
IS
    is_one_ordered NUMBER := 0;
    is_any_ordered NUMBER := 0;
    
BEGIN  

    FOR i IN 1..i_art_id_array.COUNT
    LOOP
        SELECT COUNT(*)
        INTO is_one_ordered
        FROM ordered_artworks
        WHERE artwork_id = i_art_id_array(i);
        
        is_any_ordered := is_any_ordered + is_one_ordered;
    END LOOP;
    
    IF is_any_ordered > 0 THEN
        RETURN 0;
    ELSE 
        RETURN 1;
    END IF;
END;




DECLARE
    artworks_to_buy ART_ID_VARRAY_T;
    
BEGIN
    artworks_to_buy := ART_ID_VARRAY_T(3, 4);

    PLACE_TRANSACTION_PRC(  1,
                            'Wroclaw',
                            'xDDDD',
                            '125-5222',
                            512872233,
                            artworks_to_buy);
END;

