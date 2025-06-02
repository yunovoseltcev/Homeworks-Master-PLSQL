create or replace trigger payment_b_d_restrict
  before delete
  on payment 
declare
begin
  payment_api_pack.check_payment_delete_restriction();
end payment_b_d_restrict;
/

