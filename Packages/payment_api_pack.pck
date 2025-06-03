create or replace package payment_api_pack is

  -- Author  : ЮРА
  -- Created : 11.05.2025 12:45:20
  -- Purpose : API по платежу
  
  --Статусы проведения платежа
  c_create_status   PAYMENT.STATUS%type := 0;
  c_success_status  PAYMENT.STATUS%type := 1;
  c_error_status    PAYMENT.STATUS%type := 2;
  c_cancel_status   PAYMENT.STATUS%type := 3;

  -- Создание платежа
  function create_payment (p_summa                PAYMENT.SUMMA%type,
                           p_currency_id          CURRENCY.CURRENCY_ID%type,
                           p_from_client_id       PAYMENT.FROM_CLIENT_ID%type,
                           p_to_client_id         PAYMENT.TO_CLIENT_ID%type,
                           p_payment_detail_array t_payment_detail_array,
                           p_create_dtime         timestamp := systimestamp) 
    return PAYMENT.PAYMENT_ID%type;
  
  -- Сброс платежа в ошибку
  procedure fail_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                          p_reason       PAYMENT.STATUS_CHANGE_REASON%type);
  
  -- Отмена платежа              
  procedure cancel_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                            p_reason       PAYMENT.STATUS_CHANGE_REASON%type);
  
  -- Платеж завершен успешно                          
  procedure successful_finish_payment (p_payment_id    PAYMENT.PAYMENT_ID%type);
  
  -- Проверка вызываемая из триггера
  procedure is_changes_throuh_api;
  
  -- Проверка на удаление вызываемая из триггера
  procedure check_payment_delete_restriction;
  
end payment_api_pack;
/

create or replace package body payment_api_pack is

  g_is_api boolean := false; -- признак, выполняется ли изменение через API

  -- разрешение менять данные
  procedure allow_changes 
  is
  begin
    g_is_api := true;
  end;

  -- запрет менять данные
  procedure disallow_changes 
  is
  begin
    g_is_api := false;
  end;
  
  procedure try_block_payment(p_payment_id    PAYMENT.PAYMENT_ID%type) 
  is
    v_status PAYMENT.STATUS%type;
  begin
    -- пытаемся заблокировать клиента
    select t.status 
      into v_status
      from payment t 
     where t.payment_id = p_payment_id
       for update nowait;
       
    -- Платеж уже в финальном статусе. Работа запрещена
    if v_status != c_create_status then
      raise_application_error(payment_common_pack.c_error_code_already_in_final_status, 
                              payment_common_pack.c_error_msg_already_in_final_status);        
    end if;
  exception
    when no_data_found then --Платеж отсутствует
      raise_application_error(payment_common_pack.c_error_code_payment_not_found, 
                              payment_common_pack.c_error_msg_payment_not_found);
    when payment_common_pack.e_row_blocked then -- Платеж уже заблокирован другой сессией
      raise_application_error(payment_common_pack.c_error_code_payment_already_blocked, 
                              payment_common_pack.c_error_msg_payment_already_blocked);
  end try_block_payment;

  -- Создание платежа
  function create_payment (p_summa                PAYMENT.SUMMA%type,
                           p_currency_id          CURRENCY.CURRENCY_ID%type,
                           p_from_client_id       PAYMENT.FROM_CLIENT_ID%type,
                           p_to_client_id         PAYMENT.TO_CLIENT_ID%type,
                           p_payment_detail_array t_payment_detail_array,
                           p_create_dtime         timestamp := systimestamp) 
    return PAYMENT.PAYMENT_ID%type
  is
    v_payment_id      PAYMENT.PAYMENT_ID%type;
    
  begin
    if p_payment_detail_array is not empty then
      
      allow_changes();
      
      --Создаем запись о платеже
      insert into PAYMENT values (payment_seq.nextval, p_create_dtime, p_summa,
                                  p_currency_id, p_from_client_id, p_to_client_id,
                                  c_create_status, null, p_create_dtime, p_create_dtime)
      returning PAYMENT_ID into v_payment_id;
      --Создаем запись о детали платежа
      payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id => v_payment_id, p_payment_detail_array => p_payment_detail_array);
    else
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_collection);
    end if;
    
    disallow_changes();
    
    return v_payment_id;
    
  exception
    when others then
      disallow_changes();
      raise;
  end create_payment;
  
  -- Сброс платежа в ошибку
  procedure fail_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                          p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
  is
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    elsif p_reason is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_reason);
    else
      try_block_payment(p_payment_id);
      allow_changes();
      
      update PAYMENT pay
         set pay.STATUS = c_error_status,
             pay.STATUS_CHANGE_REASON = p_reason
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;

    end if;
    
    disallow_changes();
    
  exception
    when others then
      disallow_changes();
      raise;
  end fail_payment;
  
  -- Отмена платежа
  procedure cancel_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                            p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
  is
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    elsif p_reason is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_reason);
    else
      try_block_payment(p_payment_id);
      allow_changes();
      
      update PAYMENT pay
         set pay.STATUS = c_cancel_status,
             pay.STATUS_CHANGE_REASON = p_reason
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;

    end if;
    
    disallow_changes();
    
  exception
    when others then
      disallow_changes();
      raise;
  end cancel_payment;
  
  -- Платеж завершен успешно
  procedure successful_finish_payment (p_payment_id    PAYMENT.PAYMENT_ID%type)
  is
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    else
      try_block_payment(p_payment_id);
      allow_changes();
      
      update PAYMENT pay
         set pay.STATUS = c_success_status
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;
    end if;
    
    disallow_changes();
    
  exception
    when others then
      disallow_changes();
      raise;
  end successful_finish_payment;
  
  -- Проверка вызываемая из триггера
  procedure is_changes_throuh_api 
  is
  begin
    if not g_is_api and not payment_common_pack.is_manual_changes_allowed() then
      raise_application_error(payment_common_pack.c_error_code_manual_changes, 
                              payment_common_pack.c_error_msg_manual_changes);
    end if;
  end is_changes_throuh_api;
  
  -- Проверка на удаление вызываемая из триггера
  procedure check_payment_delete_restriction
  is
  begin
    if not payment_common_pack.is_manual_changes_allowed() then
      raise_application_error(payment_common_pack.c_error_code_delete_forbidden,
                              payment_common_pack.c_error_msg_delete_forbidden);
    end if;
  end check_payment_delete_restriction;

end payment_api_pack;
/

