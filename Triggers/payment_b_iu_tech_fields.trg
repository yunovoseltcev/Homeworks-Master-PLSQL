﻿create or replace trigger plsql14_student2.payment_b_iu_tech_fields
  before insert or update
  on payment 
  for each row
declare
  -- Переменные
  v_current_timestamp payment.create_dtime_tech%type := systimestamp;
begin
  if inserting  then
    :new.create_dtime_tech := v_current_timestamp;
  end if;
  :new.update_dtime_tech := v_current_timestamp;
end payment_b_iu_tech_fields;
/

