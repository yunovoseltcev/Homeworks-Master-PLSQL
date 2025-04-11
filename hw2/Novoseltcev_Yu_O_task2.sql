/*
  Автор: Новосельцев Юрий Олегович
  Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/

--1. Создание платежа
declare
  v_str varchar2(100 char) := 'Платеж создан. Статус: 0';
begin
  dbms_output.put_line('Платеж создан. Статус: 0');
end;
/

--2. Сброс платежа в ошибку
declare
  v_str varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины. Статус: 2. Причина: недостаточно средств';
begin  
  dbms_output.put_line (v_str);
end;
/

--3. Отмена платежа
declare
  v_str varchar2(100 char) := 'Отмена платежа с указанием причины. Статус: 3. Причина: ошибка пользователя';
begin  
  dbms_output.put_line (v_str);
end;
/

--4. Платеж завершен успешно
declare
  v_str varchar2(100 char) := 'Успешное завершение платежа. Статус: 1';
begin  
  dbms_output.put_line (v_str);
end;
/

--5. Добавление или обновление данных платежа по списку
declare
  v_str varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
begin  
  dbms_output.put_line (v_str);
end;
/

--6. Удаление деталей платежа списку
declare
  v_str varchar2(100 char) := 'Детали платежа удалены по списку id_полей';
begin  
  dbms_output.put_line (v_str);
end;
/
