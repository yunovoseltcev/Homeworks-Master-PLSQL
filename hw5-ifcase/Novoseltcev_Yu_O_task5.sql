/*
  Автор: Новосельцев Юрий Олегович
  Описание скрипта: API для сущностей "Платеж" и "Детали платежа"
*/

--1. Создание платежа
declare
  v_description     varchar2(100 char) := 'Платеж создан.';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := 1;
  c_create_status   number(10) := 0;
begin
  dbms_output.put_line(v_description||' Статус: '||c_create_status
                                    ||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss:ff3'));
  dbms_output.put_line('ID платежа = '||v_payment_id);
end;
/

--2. Сброс платежа в ошибку
declare
  v_description     varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  v_reason          varchar2(200 char) := 'недостаточно средств';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := 1;
  c_error_status    number(10) := 2;
begin  
  dbms_output.put_line (v_description||' Статус: '||c_error_status||'. Причина: '||v_reason
                                     ||'. Дата создания записи (День): '||to_char(v_current_time,'DAY'));
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
  if v_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;
  
end;
/

--3. Отмена платежа
declare
  v_description     varchar2(100 char) := 'Отмена платежа с указанием причины.';
  v_reason          varchar2(200 char) := 'ошибка пользователя';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := 1;
  c_cancel_status   number(10) := 3;
begin  
  dbms_output.put_line (v_description||' Статус: '||c_cancel_status||'. Причина: '||v_reason
                                     ||'. Дата создания записи (Месяц): '||to_char(v_current_time,'MONTH'));
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
  if v_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;
end;
/

--4. Платеж завершен успешно
declare
  v_description     varchar2(100 char) := 'Успешное завершение платежа.';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := 1;
  c_success_status  number(10) := 1;
begin  
  dbms_output.put_line (v_description||' Статус: '||c_success_status
                                     ||'. Дата создания записи (1-ый день месяца): '||trunc(v_current_time,'MONTH'));
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--5. Добавление или обновление данных платежа по списку
declare
  v_description     varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := 1;
begin  
  dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss'));
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--6. Удаление деталей платежа списку
declare
  v_description     varchar2(100 char) := 'Детали платежа удалены по списку id_полей';
  v_current_time    timestamp := sysdate;
  v_payment_id      number(38) := null;
begin  
  dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss'));
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/