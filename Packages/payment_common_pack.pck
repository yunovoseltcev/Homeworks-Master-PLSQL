create or replace package PAYMENT_COMMON_PACK is

  -- Author  : ЮРА
  -- Created : 21.05.2025 20:14:35
  -- Purpose : Общие объекты API
  
  -- Сообщения ошибок
  c_error_msg_empty_field_id          constant varchar2(100 char) := 'Значение в поле field_id не может быть пустым';
  c_error_msg_empty_field_value       constant varchar2(100 char) := 'ID поля field_value не может быть пустым';
  c_error_msg_empty_collection        constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_payment_id        constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_empty_reason            constant varchar2(100 char) := 'Причина не может быть пустой';
  c_error_msg_delete_forbidden        constant varchar2(100 char) := 'Удаление объекта запрещено';
  c_error_msg_manual_changes          constant varchar2(100 char) := 'Изменения должны выполняться только через API';
  c_error_msg_already_in_final_status constant varchar2(100 char) := 'Объект в конечном статусе. Изменения невозможны';
  c_error_msg_payment_not_found       constant varchar2(100 char) := 'Объект не найден';
  c_error_msg_payment_already_blocked constant varchar2(100 char) := 'Объект уже заблокирован';
  
  -- Коды ошибок
  c_error_code_empty_invalid_input_parametr constant number(10) := -20001;
  c_error_code_delete_forbidden             constant number(10) := -20002;
  c_error_code_manual_changes               constant number(10) := -20003;
  c_error_code_already_in_final_status      constant number(10) := -20104;
  c_error_code_payment_not_found            constant number(10) := -20105;
  c_error_code_payment_already_blocked      constant number(10) := -20106;
  
  -- Объекты исключений
  e_invalid_input_parametr exception;
  pragma exception_init(e_invalid_input_parametr, c_error_code_empty_invalid_input_parametr);
  e_delete_forbidden exception;
  pragma exception_init(e_delete_forbidden, c_error_code_delete_forbidden);
  e_manual_changes exception;
  pragma exception_init(e_manual_changes, c_error_code_manual_changes);
  e_row_blocked exception;
  pragma exception_init(e_row_blocked, -00054);
  e_payment_already_blocked exception;
  pragma exception_init(e_payment_already_blocked, c_error_code_payment_already_blocked);
  e_payment_not_found exception;
  pragma exception_init(e_payment_not_found, c_error_code_payment_not_found);
  
  -- Включить/отключить разрешение менять вручную данные
  procedure enable_manual_changes;
  procedure disable_manual_changes;
  
  -- Разрешены ли изменения в ручном режиме
  function is_manual_changes_allowed return boolean;
  
  -- Блокировка платежа
  procedure try_block_payment(p_payment_id    PAYMENT.PAYMENT_ID%type);

end PAYMENT_COMMON_PACK;
/

create or replace package body PAYMENT_COMMON_PACK is

  -- Константы
  g_is_api boolean := false; -- признак, выполняется ли изменение через API

  -- Переменные
  g_enable_manual_changes boolean := false; -- Разрешены ли изменения не через API
  
  -- Включить/отключить разрешение менять вручную данные
  procedure enable_manual_changes
  is
  begin
    g_enable_manual_changes := true;
  end enable_manual_changes;
  
  procedure disable_manual_changes
  is
  begin
    g_enable_manual_changes := false;
  end disable_manual_changes;
  
  -- Разрешены ли изменения в ручном режиме
  function is_manual_changes_allowed return boolean
  is
  begin
    return g_enable_manual_changes;
  end is_manual_changes_allowed;
  
  -- Блокировка платежа
  procedure try_block_payment(p_payment_id    PAYMENT.PAYMENT_ID%type) 
  is
    v_status PAYMENT.STATUS%type;
  begin
    -- пытаемся заблокировать платеж
    select t.status 
      into v_status
      from payment t 
     where t.payment_id = p_payment_id
       for update nowait;
       
    -- Платеж уже в финальном статусе. Работа запрещена
    if v_status != payment_api_pack.c_create_status then
      raise_application_error(c_error_code_already_in_final_status, 
                              c_error_msg_already_in_final_status);        
    end if;
  exception
    when no_data_found then --Платеж отсутствует
      raise_application_error(c_error_code_payment_not_found, 
                              c_error_msg_payment_not_found);
    when e_row_blocked then -- Платеж уже заблокирован другой сессией
      raise_application_error(c_error_code_payment_already_blocked, 
                              c_error_msg_payment_already_blocked);
  end try_block_payment;

end PAYMENT_COMMON_PACK;
/

