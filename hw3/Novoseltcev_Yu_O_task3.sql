/*
  Автор: Новосельцев Юрий Олегович
  Описание скрипта: API для сущностей "Платеж" и "Детали платежа"
*/

--1. Создание платежа
declare
  v_description varchar2(100 char) := 'Платеж создан.';
  c_create_status number(1) := 0;
begin
  dbms_output.put_line(v_description||' Статус: '||c_create_status);
end;
/

--2. Сброс платежа в ошибку
declare
  v_description varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  v_reason varchar2(100 char) := 'недостаточно средств';
  c_error_status number(1) := '2';
begin  
  dbms_output.put_line (v_description||' Статус: '||c_error_status||'. Причина: '||v_reason);
end;
/

--3. Отмена платежа
declare
  v_description varchar2(100 char) := 'Отмена платежа с указанием причины.';
  v_reason varchar2(100 char) := 'ошибка пользователя';
  c_cancel_status number(1) := 3;
begin  
  dbms_output.put_line (v_description||' Статус: '||c_cancel_status||'. Причина: '||v_reason);
end;
/

--4. Платеж завершен успешно
declare
  v_description varchar2(100 char) := 'Успешное завершение платежа.';
  c_success_status number(1) := 1;
begin  
  dbms_output.put_line (v_description||' Статус: '||c_success_status);
end;
/

--5. Добавление или обновление данных платежа по списку
declare
  v_description varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку';
  v_field_id varchar2(10 char) := 'id_поля';
  v_value varchar2(10 char) := 'значение';
begin  
  dbms_output.put_line (v_description||' '||v_field_id||'/'||v_value);
end;
/

--6. Удаление деталей платежа списку
declare
  v_description varchar2(100 char) := 'Детали платежа удалены по списку';
  v_fields_id varchar2(10 char) := 'id_полей';
begin  
  dbms_output.put_line (v_description||' '||v_fields_id);
end;
/
