SET SERVEROUTPUT ON;

CREATE TABLE daily_visits (
    id NUMBER NOT NULL,
    day_measured DATE NOT NULL,
    visitors_number NUMBER NOT NULL,
    mean_visit_time NUMBER NOT NULL
);


CREATE SEQUENCE id_seq
    INCREMENT BY 1
    START WITH 1;





CREATE OR REPLACE PACKAGE DAILY_VISITS_TRACKER_API
IS
    CURSOR c_visitors RETURN visitors%ROWTYPE;
    FUNCTION TIME_STAYING_FUNC(visitor c_visitors%ROWTYPE) RETURN NUMBER;
    PROCEDURE DAILY_VISITS_UPDATE_PRC(l_mean_daily OUT NUMBER);
END DAILY_VISITS_TRACKER_API;




CREATE OR REPLACE PACKAGE BODY DAILY_VISITS_TRACKER_API
IS
    g_current_time TIMESTAMP := sysdate;
   
    CURSOR c_visitors RETURN visitors%ROWTYPE
    IS
        SELECT *
        FROM visitors
        WHERE EXTRACT(DAY FROM time_of_entrance) = EXTRACT(DAY FROM g_current_time)
        AND EXTRACT(MONTH FROM time_of_entrance) = EXTRACT(MONTH FROM g_current_time)
        AND EXTRACT(YEAR FROM time_of_entrance) = EXTRACT(YEAR FROM g_current_time);
        
        
        
    FUNCTION TIME_STAYING_FUNC(visitor c_visitors%ROWTYPE) 
    RETURN NUMBER
    IS
        l_visitor_daily_time NUMBER := 0;

    BEGIN
        l_visitor_daily_time := TO_NUMBER(EXTRACT(HOUR FROM visitor.time_of_leaving - visitor.time_of_entrance)) * 60
                                + TO_NUMBER(EXTRACT(MINUTE FROM visitor.time_of_leaving - visitor.time_of_entrance));
        RETURN l_visitor_daily_time;
    END;



    PROCEDURE DAILY_VISITS_UPDATE_PRC(l_mean_daily OUT NUMBER)
    IS
        l_total_daily_time NUMBER := 0;
        tot_visitors NUMBER := 0;
        
    BEGIN
        FOR visitor IN c_visitors
        LOOP
            l_total_daily_time := l_total_daily_time + TIME_STAYING_FUNC(visitor);
            tot_visitors := tot_visitors + 1;
        END LOOP;

        l_mean_daily := ROUND((l_total_daily_time / tot_visitors), 0);
        
        INSERT INTO daily_visits(id, day_measured, visitors_number, mean_visit_time)
        VALUES(id_seq.NEXTVAL, g_current_time, tot_visitors, l_mean_daily);
    END;
END DAILY_VISITS_TRACKER_API;

