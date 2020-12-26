SET SERVEROUTPUT ON;

-- Package for tracking a total amount of people and the time they stayed in the gallery for each consecutive day,
-- storing the results in a daily_visits table
CREATE OR REPLACE PACKAGE DAILY_VISITS_TRACKER_API
IS
    -- cursor storing information about visitors from a current day (sysdate info)
    CURSOR c_visitors RETURN visitors%ROWTYPE;
    -- function calculating time a particular visitor stayed in the gallery
    FUNCTION TIME_STAYING_FUNC(visitor c_visitors%ROWTYPE) RETURN NUMBER;
    -- procedure calculating total number of visitors from a current day and mean time they stayed in gallery
    PROCEDURE DAILY_VISITS_UPDATE_PRC(o_mean_daily OUT NUMBER);
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



    PROCEDURE DAILY_VISITS_UPDATE_PRC(o_mean_daily OUT NUMBER)
    IS
        l_total_daily_time NUMBER := 0;
        tot_visitors NUMBER := 0;
        
    BEGIN
        FOR visitor IN c_visitors
        LOOP
            l_total_daily_time := l_total_daily_time + TIME_STAYING_FUNC(visitor);
            tot_visitors := tot_visitors + 1;
        END LOOP;
        
        IF tot_visitors = 0 THEN
            o_mean_daily := 0;
        ELSE
            o_mean_daily := ROUND((l_total_daily_time / tot_visitors), 0);
        END IF;
        
        INSERT INTO daily_visits(id, day_measured, visitors_amount, mean_visit_time)
        VALUES(id_seq.NEXTVAL, g_current_time, tot_visitors, o_mean_daily);
    END;
END DAILY_VISITS_TRACKER_API;



-- Scheduler job to run procedure from DAILY_VISITS_TRACKER_API each day to populate daily_visits table with results 

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name           =>  'track_visitors',
        job_type           =>  'STORED_PROCEDURE',
        job_action         =>  'DAILY_VISITS_TRACKER_API.DAILY_VISITS_UPDATE_PRC',
        repeat_interval    =>  'FREQ=DAILY; BYHOUR=23',
        comments           =>  'Job tracking number of visitors from a given day in the table');
END;











