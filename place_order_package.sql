CREATE OR REPLACE TYPE ART_ID_VARRAY_T AS VARRAY(10) OF NUMERIC;


CREATE OR REPLACE PACKAGE PLACE_TRANSACTION_API
IS
    PROCEDURE PLACE_TRANSACTION_PRC(    i_visitor_id IN visitors.visitor_id%TYPE,
                                        i_visitor_city IN visitors.city%TYPE,
                                        i_visitor_street IN visitors.street%TYPE,
                                        i_visitor_zip IN visitors.zip_code%TYPE,
                                        i_visitor_phone IN visitors.phone_number%TYPE,
                                        i_art_id_array IN ART_ID_VARRAY_T);
END PLACE_TRANSACTION_API;





CREATE OR REPLACE PACKAGE BODY PLACE_TRANSACTION_API
IS
    FUNCTION CHECK_NOT_ALREADY_ORDERED_FUN(i_art_id_array IN ART_ID_VARRAY_T)
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


    
    FUNCTION SUM_TOTAL_ARTWORKS_PRICE_FUN(i_art_id_array IN ART_ID_VARRAY_T)
    RETURN NUMBER
    IS
        l_total_payment NUMBER := 0;
        l_artwork_price NUMBER := 0;
        
    BEGIN
        FOR i IN 1..i_art_id_array.COUNT
        LOOP
            SELECT price
            INTO l_artwork_price
            FROM artworks
            WHERE artwork_id = i_art_id_array(i);
           
            l_total_payment := l_total_payment + l_artwork_price;
            END LOOP;
        RETURN l_total_payment;
    END;



    PROCEDURE UPDATE_VISITOR_DELIVERY_DATA_PRC(   i_tot_order_id IN visitors.total_order_id%TYPE,
                                                                    i_visitor_id IN visitors.visitor_id%TYPE,
                                                                    i_visitor_city IN visitors.city%TYPE,
                                                                    i_visitor_street IN visitors.street%TYPE,
                                                                    i_visitor_zip IN visitors.zip_code%TYPE,
                                                                    i_visitor_phone IN visitors.phone_number%TYPE)
        IS
        l_visitor_street VARCHAR2(100) := TRIM(REGEXP_SUBSTR(i_visitor_street, '\D+'));
        l_visitor_house VARCHAR2(10) := TRIM(REGEXP_SUBSTR(i_visitor_street, ' \d+.*'));
        
    BEGIN
        UPDATE visitors
        SET 
            total_order_id = i_tot_order_id,
            city = i_visitor_city, 
            street = l_visitor_street, 
            house_number = l_visitor_house, 
            zip_code = i_visitor_zip, 
            phone_number = i_visitor_phone
        WHERE visitor_id = i_visitor_id;
    END;
    
    
    
    PROCEDURE PLACE_TRANSACTION_PRC(  i_visitor_id IN visitors.visitor_id%TYPE,
                                                        i_visitor_city IN visitors.city%TYPE,
                                                        i_visitor_street IN visitors.street%TYPE,
                                                        i_visitor_zip IN visitors.zip_code%TYPE,
                                                        i_visitor_phone IN visitors.phone_number%TYPE,
                                                        i_art_id_array IN ART_ID_VARRAY_T)
                                                        
    IS
        l_order_date DATE := sysdate;
        l_delivery_date DATE := l_order_date + 14;
        l_tot_order_id NUMBER := total_order_id_seq.NEXTVAL;
        
        l_total_payment NUMBER := 0;
        
    BEGIN
        IF CHECK_NOT_ALREADY_ORDERED_FUN(i_art_id_array) = 1 THEN
        
            INSERT INTO total_orders(total_order_id, payment, date_of_order, approximate_delivery)
            VALUES(l_tot_order_id, l_total_payment, l_order_date, l_delivery_date);
            
            FOR i IN 1..i_art_id_array.COUNT
            LOOP
                DELETE FROM exhibition_contents
                WHERE artwork_id = i_art_id_array(i);
                
                INSERT INTO ordered_artworks(ordered_artwork_id, total_order_id, artwork_id)
                VALUES(ordered_artworks_id_seq.NEXTVAL, l_tot_order_id, i_art_id_array(i));
            END LOOP;
            
            l_total_payment := SUM_TOTAL_ARTWORKS_PRICE_FUN(i_art_id_array);
            
            UPDATE total_orders
            SET payment = l_total_payment
            WHERE total_order_id = l_tot_order_id;
            
            UPDATE_VISITOR_DELIVERY_DATA_PRC(l_tot_order_id, i_visitor_id, i_visitor_city, i_visitor_street, i_visitor_zip, i_visitor_phone);
            
        ELSE
            DBMS_OUTPUT.PUT_LINE('You try to buy an artwork that has already been sold');
            RETURN;
        END IF;
    END;
END;



DECLARE
    artworks_to_buy ART_ID_VARRAY_T;
    
BEGIN
    artworks_to_buy := ART_ID_VARRAY_T(2, 3);

    PLACE_TRANSACTION_API.PLACE_TRANSACTION_PRC(  1,
                            'Washington',
                            'Sezame Street 45',
                            '125-5222',
                            '512872233',
                            artworks_to_buy);
END;







































