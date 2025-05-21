create or replace package plsql14_student2.payment_api_pack is

  -- Author  : ЮРА
  -- Created : 11.05.2025 12:45:20
  -- Purpose : API по платежу
  
  --Статусы проведения платежа
  c_create_status   PAYMENT.STATUS%type := 0;
  c_success_status  PAYMENT.STATUS%type := 1;
  c_error_status    PAYMENT.STATUS%type := 2;
  c_cancel_status   PAYMENT.STATUS%type := 3;

  --1. Создание платежа
  function create_payment (p_summa                PAYMENT.SUMMA%type,
                           p_currency_id          CURRENCY.CURRENCY_ID%type,
                           p_from_client_id       PAYMENT.FROM_CLIENT_ID%type,
                           p_to_client_id         PAYMENT.TO_CLIENT_ID%type,
                           p_payment_detail_array t_payment_detail_array,
                           p_create_dtime         timestamp := systimestamp) 
    return PAYMENT.PAYMENT_ID%type;
  
  --2. Сброс платежа в ошибку
  procedure fail_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                          p_reason       PAYMENT.STATUS_CHANGE_REASON%type);
  
  --3. Отмена платежа              
  procedure cancel_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                            p_reason       PAYMENT.STATUS_CHANGE_REASON%type);
  
  --4. Платеж завершен успешно                          
  procedure successful_finish_payment (p_payment_id    PAYMENT.PAYMENT_ID%type);
  
end payment_api_pack;
/

create or replace package body plsql14_student2.payment_api_pack is

  

  -- 1. Создание платежа
  function create_payment (p_summa                PAYMENT.SUMMA%type,
                           p_currency_id          CURRENCY.CURRENCY_ID%type,
                           p_from_client_id       PAYMENT.FROM_CLIENT_ID%type,
                           p_to_client_id         PAYMENT.TO_CLIENT_ID%type,
                           p_payment_detail_array t_payment_detail_array,
                           p_create_dtime         timestamp := systimestamp) 
    return PAYMENT.PAYMENT_ID%type
  is
    v_description     varchar2(100 char) := 'Платеж создан.';
    v_payment_id      PAYMENT.PAYMENT_ID%type;
    
  begin
    if p_payment_detail_array is not empty then
      payment_common_pack.checkPaymentDetailCollection(p_payment_detail_array);
      --Создаем запись о платеже
      insert into PAYMENT values (payment_seq.nextval, p_create_dtime, p_summa,
                                  p_currency_id, p_from_client_id, p_to_client_id,
                                  c_create_status, null, p_create_dtime, p_create_dtime)
      returning PAYMENT_ID into v_payment_id;
      --Создаем запись о детали платежа
      insert into PAYMENT_DETAIL (select v_payment_id, pda.field_id, pda.field_value
                                   from table(p_payment_detail_array) pda
                                  where pda.field_id is not null and pda.field_value is not null);

      dbms_output.put_line(v_description||' Статус: '||c_create_status
                                        ||'. Дата создания записи: '||to_char(p_create_dtime,'dd-mm-yyyy hh24:mi:ss:ff3'));
      dbms_output.put_line('ID платежа = '||v_payment_id);
    else
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_collection);
    end if;
    return v_payment_id;
  end create_payment;
  
  --2. Сброс платежа в ошибку
  procedure fail_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                          p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
  is
    v_description     varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    elsif p_reason is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_reason);
    else
      update PAYMENT pay
         set pay.STATUS = c_error_status,
             pay.STATUS_CHANGE_REASON = p_reason
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;

      dbms_output.put_line (v_description||' Статус: '||c_error_status||'. Причина: '||p_reason);
      dbms_output.put_line('ID платежа = '||p_payment_id);
    end if;
  end fail_payment;
  
  --3. Отмена платежа
  procedure cancel_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                            p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
  is
    v_description     varchar2(100 char) := 'Отмена платежа с указанием причины.';
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    elsif p_reason is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_reason);
    else
      update PAYMENT pay
         set pay.STATUS = c_cancel_status,
             pay.STATUS_CHANGE_REASON = p_reason
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;

      dbms_output.put_line (v_description||' Статус: '||c_cancel_status||'. Причина: '||p_reason);
      dbms_output.put_line('ID платежа = '||p_payment_id);
    end if;
  end cancel_payment;
  
  --4. Платеж завершен успешно
  procedure successful_finish_payment (p_payment_id    PAYMENT.PAYMENT_ID%type)
  is
    v_description     varchar2(100 char) := 'Успешное завершение платежа.';
  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    else
      update PAYMENT pay
         set pay.STATUS = c_success_status
       where pay.PAYMENT_ID = p_payment_id
         and pay.STATUS = 0;
      dbms_output.put_line (v_description||' Статус: '||c_success_status);
      dbms_output.put_line('ID платежа = '||p_payment_id);
    end if;
  end successful_finish_payment;

end payment_api_pack;
/

