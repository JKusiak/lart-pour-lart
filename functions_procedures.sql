SET SERVEROUTPUT ON;

-- 6 procedures




-- 4 functions

CREATE OR REPLACE FUNCTION MEAN_TIME_VISITING_FUN(i_entry_day IN DATE)
RETURN NUMBER
IS
    l_entry_time visitors.time_of_entrance%TYPE;
    l_leave_time visitors.time_of_leaving%TYPE;
    l_mean_visiting_time NUMBER;
    
BEGIN
    
END;
