create or replace trigger payment_b_d_restrict
  before delete
  on payment 
declare
begin
  raise_application_error(payment_common_pack.c_error_code_delete_forbidden,
                          payment_common_pack.c_error_msg_delete_forbidden);
end payment_b_d_restrict;
/

