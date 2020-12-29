CREATE OR REPLACE TYPE EXHIBITION_ID_VARRAY_T AS VARRAY(10) OF NUMERIC;

CREATE OR REPLACE PACKAGE VISIT_GALLERY_API
IS
    PROCEDURE VISITOR_ENTER_GALLERY_PRC(i_name IN visitors.name%TYPE,
                                        i_surname IN visitors.surname%TYPE,
                                        i_is_underage IN visitors.is_underage%TYPE,
                                        i_exhibitions_array IN EXHIBITION_ID_VARRAY_T);
                      
    PROCEDURE VISITOR_LEAVE_GALLERY_PRC(i_visitor_id IN visitors.visitor_id%TYPE);          
END VISIT_GALLERY_API;



CREATE OR REPLACE PACKAGE BODY VISIT_GALLERY_API
IS
    PROCEDURE BUY_TICKET_PRC(i_ticket_id IN tickets.ticket_id%TYPE, i_is_underage IN visitors.is_underage%TYPE)
    IS
        l_has_discount NUMBER := 0;
        l_price NUMBER := 0;
        
    BEGIN
        IF i_is_underage = 1 THEN
            l_has_discount := 1;
            l_price := 50;
        ELSE
            l_has_discount := 0;
            l_price := 100;
        END IF;
        
        INSERT INTO tickets(ticket_id, has_discount, price)
        VALUES(i_ticket_id, l_has_discount, l_price);
    END;



    PROCEDURE ASSIGN_ACCESS_PRC(i_ticket_id IN tickets.ticket_id%TYPE, i_exhibitions_array EXHIBITION_ID_VARRAY_T)
    IS
    BEGIN
        FOR i IN 1..i_exhibitions_array.COUNT
        LOOP
            INSERT INTO range_of_accesses(range_of_access_id, ticket_id, exhibition_id)
            VALUES(range_of_acess_id_seq.NEXTVAL, i_ticket_id, i_exhibitions_array(i));
        END LOOP;
    END;
    
    
    
    PROCEDURE VISITOR_LEAVE_GALLERY_PRC(i_visitor_id IN visitors.visitor_id%TYPE)
    IS
    BEGIN
        UPDATE visitors
        SET time_of_leaving = sysdate
        WHERE visitor_id = i_visitor_id;
    END;



    PROCEDURE VISITOR_ENTER_GALLERY_PRC(i_name IN visitors.name%TYPE,
                                        i_surname IN visitors.surname%TYPE,
                                        i_is_underage IN visitors.is_underage%TYPE,
                                        i_exhibitions_array IN EXHIBITION_ID_VARRAY_T)
    IS
        l_ticket_visitor_id NUMBER := ticket_visitor_id_seq.NEXTVAL;
        l_time_of_entrance DATE := sysdate;
        
         e_is_underage_wrong_value EXCEPTION;
        
    BEGIN
        IF i_is_underage !=0 
        OR i_is_underage !=1 THEN
            RAISE e_is_underage_wrong_value;
        END IF;
        
        BUY_TICKET_PRC(l_ticket_visitor_id, i_is_underage);
        
        ASSIGN_ACCESS_PRC(l_ticket_visitor_id, i_exhibitions_array);
    
        INSERT INTO visitors(visitor_id, ticket_id, name, surname, is_underage, time_of_entrance)
        VALUES(l_ticket_visitor_id, l_ticket_visitor_id, i_name, i_surname, i_is_underage, l_time_of_entrance);
        
    EXCEPTION
    WHEN e_is_underage_wrong_value THEN
        DBMS_OUTPUT.PUT_LINE('Value of is_underage has to be either 0 (isn''t) or 1 (is)');
    END;
END;




DECLARE
    exhibitions_to_visit EXHIBITION_ID_VARRAY_T;
BEGIN
    exhibitions_to_visit := EXHIBITION_ID_VARRAY_T(1, 2);
    VISIT_GALLERY_API.VISITOR_ENTER_GALLERY_PRC(  'Test',
                                'Testowski',
                                12,
                                exhibitions_to_visit);
                                
    VISIT_GALLERY_API.VISITOR_LEAVE_GALLERY_PRC(64);                               
END;


