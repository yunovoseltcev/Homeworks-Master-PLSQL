-- Заготовка для unit-тестов

-- Проверка исполнения тестов

select * from payment where payment_id = 128;
/
select * from payment_detail where payment_id = 130;
/
-- Проверка валидности объектов
select status
      ,t.*
  from user_objects t
 where t.object_type in ('TRIGGER', 'PACKAGE', 'PACKAGE BODY')
 order by t.object_type, t.OBJECT_NAME;
/

--1. Создание платежа
declare
  v_description          varchar2(100 char) := 'Платеж создан.';

  v_summa                PAYMENT.SUMMA%type := 1000;
  v_currency_id          CURRENCY.CURRENCY_ID%type := 643;
  v_from_client_id       PAYMENT.FROM_CLIENT_ID%type := 1;
  v_to_client_id         PAYMENT.TO_CLIENT_ID%type := 3;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
  v_payment_id           PAYMENT.PAYMENT_ID%type;
  v_create_dtime_tech    PAYMENT.CREATE_DTIME_TECH%type;
  v_update_dtime_tech    PAYMENT.UPDATE_DTIME_TECH%type;
begin
  v_payment_detail_array.extend(2);
  v_payment_detail_array(1) := t_payment_detail(1,'СБП');
  v_payment_detail_array(2) := t_payment_detail(2,'91.231.88.28');
  
  v_payment_id := payment_api_pack.create_payment(p_summa                => v_summa,
                                                  p_currency_id          => v_currency_id,
                                                  p_from_client_id       => v_from_client_id,
                                                  p_to_client_id         => v_to_client_id,
                                                  p_payment_detail_array => v_payment_detail_array);
                                                  
  select pay.create_dtime_tech, pay.update_dtime_tech
    into v_create_dtime_tech,   v_update_dtime_tech
    from payment pay 
   where pay.payment_id = v_payment_id;
   
  if v_create_dtime_tech != v_update_dtime_tech then
    raise_application_error(-20998, 'Технические даты разные!');
  end if;
  
  dbms_output.put_line(v_description||' Статус: '||payment_api_pack.c_create_status||'. payment_id = '||v_payment_id);
end;
/

--2. Сброс платежа в ошибку
declare
  v_description          varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  
  v_payment_id           PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason               PAYMENT.STATUS_CHANGE_REASON%type := 'недостаточно средств';
  v_create_dtime_tech    PAYMENT.CREATE_DTIME_TECH%type;
  v_update_dtime_tech    PAYMENT.UPDATE_DTIME_TECH%type;
begin
  payment_api_pack.fail_payment(p_payment_id   => v_payment_id,
                                p_reason       => v_reason);
                                
  select pay.create_dtime_tech, pay.update_dtime_tech
    into v_create_dtime_tech,   v_update_dtime_tech
    from payment pay 
   where pay.payment_id = v_payment_id;
   
   if v_create_dtime_tech = v_update_dtime_tech then
    raise_application_error(-20997, 'Технические даты одинаковые!');
  end if;
                                
  dbms_output.put_line (v_description||' Статус: '||payment_api_pack.c_error_status||'. Причина: '||v_reason);
end;
/

--3. Отмена платежа
declare
  v_description     varchar2(100 char) := 'Отмена платежа с указанием причины.';
  
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'ошибка пользователя';
begin
  payment_api_pack.cancel_payment(p_payment_id   => v_payment_id,
                                  p_reason       => v_reason);
  dbms_output.put_line (v_description||' Статус: '||payment_api_pack.c_cancel_status||'. Причина: '||v_reason);
end;
/

--4. Платеж завершен успешно
declare
  v_description     varchar2(100 char) := 'Успешное завершение платежа.';
  
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
  dbms_output.put_line (v_description||' Статус: '||payment_api_pack.c_success_status);
end;
/

--5. Добавление или обновление данных платежа по списку
declare
  v_description          varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  
  v_payment_id           PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
begin
  v_payment_detail_array.extend(1);
  v_payment_detail_array(1) := t_payment_detail(3,'Долг');
  
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id           => v_payment_id,
                                                          p_payment_detail_array => v_payment_detail_array);
  dbms_output.put_line (v_description);
end;
/

--6. Удаление деталей платежа  по списку
declare
  v_description     varchar2(100 char) := 'Детали платежа удалены по списку id_полей';

  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_number_array    t_number_array := t_number_array(1,null,4);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id   => v_payment_id, 
                                                p_number_array => v_number_array);
  dbms_output.put_line (v_description);
end;
/

-------Негативные тесты
-- 1. Создание платежа
declare
  v_summa                PAYMENT.SUMMA%type := 1000;
  v_currency_id          CURRENCY.CURRENCY_ID%type := 643;
  v_from_client_id       PAYMENT.FROM_CLIENT_ID%type := 1;
  v_to_client_id         PAYMENT.TO_CLIENT_ID%type := 3;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
  v_payment_id           PAYMENT.PAYMENT_ID%type;
begin
  v_payment_detail_array.extend(2);
  v_payment_detail_array(1) := t_payment_detail(1,null);
  v_payment_detail_array(2) := t_payment_detail(2,'91.231.88.28');
  
  v_payment_id := payment_api_pack.create_payment(p_summa                => v_summa,
                                                  p_currency_id          => v_currency_id,
                                                  p_from_client_id       => v_from_client_id,
                                                  p_to_client_id         => v_to_client_id,
                                                  p_payment_detail_array => v_payment_detail_array);
  dbms_output.put_line('result function v_payment_id = '||v_payment_id);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Создание платежа. Ошибка: '||sqlerrm);
end;
/

-- 2. Сброс платежа в ошибку
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type;
begin
  payment_api_pack.fail_payment(p_payment_id   => v_payment_id,
                                p_reason       => v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Сброс платежа в ошибку. Ошибка: '||sqlerrm);
end;
/

-- 3. Отмена платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'ошибка пользователя';
begin
  payment_api_pack.cancel_payment(p_payment_id   => null,
                                  p_reason       => v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Отмена платежа. Ошибка: '||sqlerrm);
end;
/

-- 4. Успешное завершение платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Успешное завершение платежа. Ошибка: '||sqlerrm);
end;
/

-- 5. Добавление или обновление данных платежа по списку
declare
  v_payment_id           PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id           => v_payment_id,
                                                          p_payment_detail_array => v_payment_detail_array);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Добавление или обновление данных платежа по списку. Ошибка: '||sqlerrm);
end;
/

-- 6. Удаление деталей платежа  по списку
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_number_array    t_number_array;
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id   => v_payment_id, 
                                                p_number_array => v_number_array);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_invalid_input_parametr then
    dbms_output.put_line('Удаление деталей платежа  по списку. Ошибка: '||sqlerrm);
end;
/

-- 7. Проверка запрета ручного создания платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  insert into PAYMENT (payment_id) values (1);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_manual_changes then
    dbms_output.put_line('Проверка запрета ручного создания платежа. Ошибка: '||sqlerrm);
end;
/

-- 8. Проверка запрета ручного обновления платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  update PAYMENT pay
     set pay.STATUS = payment_api_pack.c_error_status
   where pay.PAYMENT_ID = 13;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_manual_changes then
    dbms_output.put_line('Проверка запрета ручного обновления платежа. Ошибка: '||sqlerrm);
end;
/

-- 9. Проверка запрета ручного удаления платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  delete payment pay where pay.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_delete_forbidden then
    dbms_output.put_line('Проверка запрета ручного удаления платежа. Ошибка: '||sqlerrm);
end;
/

-- 10. Проверка запрета ручного создания деталей платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  insert into payment_detail (payment_id) values (v_payment_id);
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_manual_changes then
    dbms_output.put_line('Проверка запрета ручного создания деталей платежа. Ошибка: '||sqlerrm);
end;
/

-- 11. Проверка запрета ручного обновления деталей платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  update payment_detail pd 
     set field_id = 1 
   where pd.payment_id = v_payment_id;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_manual_changes then
    dbms_output.put_line('Проверка запрета ручного обновления деталей платежа. Ошибка: '||sqlerrm);
end;
/

-- 12. Проверка запрета ручного удаления деталей платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  delete payment_detail;
  
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_manual_changes then
    dbms_output.put_line('Проверка запрета ручного удаления деталей платежа. Ошибка: '||sqlerrm);
end;
/

-- 13. Проверка отсутствия платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 888;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'недостаточно средств';
begin
  payment_api_pack.fail_payment(p_payment_id   => v_payment_id,
                                p_reason       => v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');
exception 
  when payment_common_pack.e_payment_not_found then
    dbms_output.put_line('Проверка отсутствия платежа. Ошибка: '||sqlerrm);
end;
/

------ Тесты для ручных изменений
-- 1. Проверка разрешения ручного обновления платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  payment_common_pack.enable_manual_changes();
  
  update PAYMENT pay
     set pay.STATUS = payment_api_pack.c_cancel_status
   where pay.PAYMENT_ID = 13;
   
  payment_common_pack.disable_manual_changes();
exception 
  when others then
    payment_common_pack.disable_manual_changes();
    raise;
end;
/

-- 2. Проверка разрешения ручного обновления деталей платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := 13;
begin
  payment_common_pack.enable_manual_changes();
  
  update payment_detail pd 
     set field_id = 1 
   where pd.payment_id = v_payment_id;
  
  payment_common_pack.disable_manual_changes();
exception 
  when others then
    payment_common_pack.disable_manual_changes();
    raise;
end;
/

-- 3. Проверка разрешения ручного удаления платежа и его деталей
declare
begin
  payment_common_pack.enable_manual_changes();
  
  delete payment_detail;
  delete payment;
  
  payment_common_pack.disable_manual_changes();
exception 
  when others then
    payment_common_pack.disable_manual_changes();
    raise;
end;
/