SET SERVEROUTPUT ON;

-- 6 procedures




-- 4 functions
-- 1. MEAN_TIME_VISITING_FUN(NUMBER day, NUMBER month, NUMBER year) returns mean visiting time for visitors in a given day




create or replace FUNCTION MEAN_TIME_VISITING_FUN(i_entry_day IN NUMBER, i_entry_month IN NUMBER, i_entry_year IN NUMBER)
RETURN NUMBER
IS
    l_total_daily_time NUMBER := 0;
    l_mean_daily NUMBER := 0;
    tot_rows NUMBER := 0;

    CURSOR c_visitors 
    IS
        SELECT *
        FROM visitors
        WHERE EXTRACT(DAY FROM time_of_entrance) = i_entry_day
        AND EXTRACT(MONTH FROM time_of_entrance) = i_entry_month
        AND EXTRACT(YEAR FROM time_of_entrance) = i_entry_year;

BEGIN
    FOR visitor IN c_visitors
    LOOP
        l_total_daily_time := l_total_daily_time
                            + TO_NUMBER(EXTRACT(HOUR FROM visitor.time_of_leaving - visitor.time_of_entrance)) * 60
                            + TO_NUMBER(EXTRACT(MINUTE FROM visitor.time_of_leaving - visitor.time_of_entrance));
        tot_rows := tot_rows + 1;
    END LOOP;

    l_mean_daily := ROUND((l_total_daily_time / tot_rows), 0);
    
    
    RETURN l_mean_daily;
END;

