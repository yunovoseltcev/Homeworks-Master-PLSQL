create or replace trigger plsql14_student2.payment_b_iu_api
  before insert or update
  on payment 
declare
begin
  payment_api_pack.is_changes_throuh_api();
end payment_b_iu_api;
/

