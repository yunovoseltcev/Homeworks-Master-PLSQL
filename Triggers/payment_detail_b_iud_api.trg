create or replace trigger payment_detail_b_iud_api
  before insert or update or delete
  on payment_detail 
declare
begin
  payment_detail_api_pack.is_changes_throuh_api();
end payment_detail_b_iud_api;
/

