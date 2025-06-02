create or replace package payment_detail_api_pack is

  -- Author  : ЮРА
  -- Created : 11.05.2025 13:12:34
  -- Purpose : API по деталям платежа
  
  -- Добавление или обновление данных платежа по списку
  procedure insert_or_update_payment_detail(p_payment_id           PAYMENT.PAYMENT_ID%type,
                                            p_payment_detail_array t_payment_detail_array);
  
  -- Удаление деталей платежа  по списку
  procedure delete_payment_detail(p_payment_id   PAYMENT.PAYMENT_ID%type,
                                  p_number_array t_number_array); 
                                  
  -- Проверка вызываемая из триггера
  procedure is_changes_throuh_api;                                 

end payment_detail_api_pack;
/

create or replace package body payment_detail_api_pack is
  
  g_is_api boolean := false; -- признак, выполняется ли изменение через API

  -- разрешение менять данные
  procedure allow_changes is
  begin
    g_is_api := true;
  end;

  -- запрет менять данные
  procedure disallow_changes is
  begin
    g_is_api := false;
  end;

  -- Добавление или обновление данных платежа по списку
  procedure insert_or_update_payment_detail(p_payment_id           PAYMENT.PAYMENT_ID%type,
                                            p_payment_detail_array t_payment_detail_array)
  is
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    else
      --Проверки значений в коллекции
      if p_payment_detail_array is not empty then
        payment_common_pack.checkPaymentDetailCollection(p_payment_detail_array);
        
        allow_changes();
        
        merge into PAYMENT_DETAIL pay_d using (select pda.field_id, pda.field_value
                                                 from table(p_payment_detail_array) pda
                                                where pda.field_id is not null and pda.field_value is not null) arr
                on (pay_d.PAYMENT_ID = p_payment_id and pay_d.FIELD_ID = arr.FIELD_ID)
              when matched then
                update set pay_d.FIELD_VALUE = arr.FIELD_VALUE
              when not matched then
                insert values (p_payment_id, arr.field_id, arr.field_value);
      else
        raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                                payment_common_pack.c_error_msg_empty_collection);
      end if;
    end if;
    
    disallow_changes();
    
  exception
    when others then
      disallow_changes();
      raise;
  end insert_or_update_payment_detail;
  
  -- Удаление деталей платежа  по списку
  procedure delete_payment_detail(p_payment_id   PAYMENT.PAYMENT_ID%type,
                                  p_number_array t_number_array)
  is
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    else
      --Проверки значений в коллекции
      if p_number_array is not empty then
        
        allow_changes();
      
        delete from PAYMENT_DETAIL pay_d
         where pay_d.PAYMENT_ID = p_payment_id
           and pay_d.FIELD_ID in (select pna.column_value from table(p_number_array) pna);
      else
        raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                                payment_common_pack.c_error_msg_empty_collection);
      end if;
    end if;
    
    disallow_changes();
    
  exception
    when others then
      disallow_changes();
      raise;
  end delete_payment_detail;
  
  -- Проверка вызываемая из триггера
  procedure is_changes_throuh_api 
  is
  begin
    if not g_is_api and not payment_common_pack.is_manual_changes_allowed() then
      raise_application_error(payment_common_pack.c_error_code_manual_changes, 
                              payment_common_pack.c_error_msg_manual_changes);
    end if;
  end is_changes_throuh_api;
  
end payment_detail_api_pack;
/

