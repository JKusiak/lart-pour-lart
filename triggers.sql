CREATE OR REPLACE TRIGGER VISITORS_BIS_TRG
BEFORE INSERT ON visitors
BEGIN
    IF (TO_CHAR(SYSDATE, 'DY') IN('SUN')) AND (TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '9:00' AND '20:00') THEN
        RAISE_APPLICATION_ERROR(-20500, 'You cant add new visitors outside of business hours which are 9 AM till 8 PM.');  
    END IF;
END;


CREATE OR REPLACE TRIGGER VISITORS_ORDER_BIUR_TRG
BEFORE INSERT OR UPDATE ON visitors FOR EACH ROW
BEGIN
IF :NEW.total_order_id != null OR :OLD.isunderage != 0 THEN
  RAISE_APPLICATION_ERROR(-20500, 'This visitor is underage and cannot make an order');
END IF;
END;




CREATE OR REPLACE TRIGGER VISITORS_BIUR_TRG
BEFORE INSERT OR UPDATE ON visitors FOR EACH ROW
BEGIN
IF :NEW.time_of_entrance !=null OR :NEW.time_of_leaving != null THEN
IF :NEW.time_of_entrance < :NEW.time_of_leaving THEN
dbms_output.put_line('Both updated error');
END IF;
IF :OLD.time_of_entrance < :NEW.time_of_leaving THEN
dbms_output.put_line('leaving updated error');
END IF;
IF (:NEW.time_of_entrance - :NEW.time_of_leaving) >12 THEN
dbms_output.put_line('too much time');
END IF;
END IF;
END;



CREATE TABLE audit_logs (
  id              NUMBER(10)    NOT NULL,
  log_timestamp   TIMESTAMP     NOT NULL,
  username        VARCHAR2(30)  NOT NULL,
  action          VARCHAR2(10)  NOT NULL
);

ALTER TABLE audit_logs ADD (
  CONSTRAINT audit_logs_pk PRIMARY KEY (id)
);

CREATE SEQUENCE audit_logs_seq
  INCREMENT BY 1
    START WITH 10;


CREATE OR REPLACE trigger artists_audit
AFTER UPDATE OR INSERT OR DELETE ON artists
    for each row
    DECLARE 
     audit_id NUMBER := audit_logs_seq.NEXTVAL;

begin
    case
        when inserting then
            INSERT INTO audit_logs (id,log_timestamp,username,action) 
    VALUES(audit_id,   SYSTIMESTAMP ,user, 'Insert on artists');  
        when updating then
             INSERT INTO audit_logs (id,log_timestamp,username,action) 
    VALUES(audit_id, SYSTIMESTAMP , user, 'Update on artist');  
    end case;
end;


