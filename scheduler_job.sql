-- Scheduler job to run procedure from DAILY_VISITS_TRACKER_API each day to populate daily_visits table with results 

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name           =>  'track_visitors',
        job_type           =>  'STORED_PROCEDURE',
        job_action         =>  'DAILY_VISITS_TRACKER_API.DAILY_VISITS_UPDATE_PRC',
        start_date         =>   SYSTIMESTAMP,
        repeat_interval    =>  'FREQ=DAILY; BYHOUR=23; BYMINUTE=35',
        enabled            =>   TRUE,
        comments           =>  'Job tracking number of visitors from a given day in the table');
END;


-- sequence used in the procedure to 
CREATE SEQUENCE daily_visits_id_seq
    INCREMENT BY 1
    START WITH 1;

    
BEGIN
  dbms_scheduler.drop_job(job_name => 'track_visitors');
END;