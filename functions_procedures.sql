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
    START WITH 19;Procedures;



