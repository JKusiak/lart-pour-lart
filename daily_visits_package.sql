SET SERVEROUTPUT ON;

-- Package for tracking a total amount of people and the time they stayed in the gallery for each consecutive day,
-- storing the results in a daily_visits table
CREATE OR REPLACE PACKAGE DAILY_VISITS_TRACKER_API
IS
    -- procedure calculating total number of visitors from a current day and mean time they stayed in gallery
    PROCEDURE DAILY_VISITS_UPDATE_PRC;
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



    PROCEDURE DAILY_VISITS_UPDATE_PRC
    IS
        l_total_daily_time NUMBER := 0;
        tot_visitors NUMBER := 0;
        l_mean_daily NUMBER := 0;
        
    BEGIN
        FOR visitor IN c_visitors
        LOOP
            l_total_daily_time := l_total_daily_time + TIME_STAYING_FUNC(visitor);
            tot_visitors := tot_visitors + 1;
        END LOOP;
        
        IF tot_visitors = 0 THEN
            l_mean_daily := 0;
        ELSE
            l_mean_daily := ROUND((l_total_daily_time / tot_visitors), 0);
        END IF;
        
        INSERT INTO daily_visits(id, day, visitors_amount, mean_visit_time)
        VALUES(daily_visits_id_seq.NEXTVAL, g_current_time, tot_visitors, l_mean_daily);
    END;
END DAILY_VISITS_TRACKER_API;








