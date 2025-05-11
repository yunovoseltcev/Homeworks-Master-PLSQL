/*
  Автор: Новосельцев Юрий Олегович
  Описание скрипта: API для сущностей "Платеж" и "Детали платежа"
*/

--1. Создание платежа
create or replace function create_payment (p_summa                PAYMENT.SUMMA%type,
                                           p_currency_id          CURRENCY.CURRENCY_ID%type,
                                           p_from_client_id       PAYMENT.FROM_CLIENT_ID%type,
                                           p_to_client_id         PAYMENT.TO_CLIENT_ID%type,
                                           p_payment_detail_array t_payment_detail_array,
                                           p_current_time         timestamp := sysdate) return PAYMENT.PAYMENT_ID%type
is
  v_description     varchar2(100 char) := 'Платеж создан.';
  v_payment_id      PAYMENT.PAYMENT_ID%type;

  c_create_status   PAYMENT.STATUS%type := 0;
begin
  --Создаем запись о платеже
  insert into PAYMENT values (payment_seq.nextval, p_current_time, p_summa,
                              p_currency_id, p_from_client_id, p_to_client_id,
                              c_create_status, null, p_current_time, p_current_time)
  returning PAYMENT_ID into v_payment_id;
  dbms_output.put_line(v_description||' Статус: '||c_create_status
                                    ||'. Дата создания записи: '||to_char(p_current_time,'dd-mm-yyyy hh24:mi:ss:ff3'));
  dbms_output.put_line('ID платежа = '||v_payment_id);

  --Проверки значений в коллекции
  if p_payment_detail_array is not empty then
    for i in p_payment_detail_array.first..p_payment_detail_array.last loop
      if p_payment_detail_array(i).field_id is null then
        dbms_output.put_line('Значение в поле field_id не может быть пустым');
      elsif p_payment_detail_array(i).field_value is null then
        dbms_output.put_line('ID поля field_value не может быть пустым');
      end if;
    end loop;
    --Создаем запись о детали платежа
    insert into PAYMENT_DETAIL (select v_payment_id, pda.field_id, pda.field_value
                                 from table(p_payment_detail_array) pda
                                where pda.field_id is not null and pda.field_value is not null);
  else
    dbms_output.put_line('Коллекция не содержит данных');
  end if;
  return v_payment_id;
end;
/

--2. Сброс платежа в ошибку
create or replace procedure fail_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                                          p_current_time timestamp := sysdate,
                                          p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
is
  v_description     varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  c_error_status    PAYMENT.STATUS%type := 2;
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif p_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update PAYMENT pay
       set pay.STATUS = c_error_status,
           pay.STATUS_CHANGE_REASON = p_reason,
           pay.UPDATE_DTIME_TECH = p_current_time
     where pay.PAYMENT_ID = p_payment_id
       and pay.STATUS = 0;

    dbms_output.put_line (v_description||' Статус: '||c_error_status||'. Причина: '||p_reason
                                       ||'. Дата создания записи (День): '||to_char(p_current_time,'DAY'));
    dbms_output.put_line('ID платежа = '||p_payment_id);
  end if;
end;
/

--3. Отмена платежа
create or replace procedure cancel_payment (p_payment_id   PAYMENT.PAYMENT_ID%type,
                                            p_current_time timestamp := sysdate,
                                            p_reason       PAYMENT.STATUS_CHANGE_REASON%type)
is
  v_description     varchar2(100 char) := 'Отмена платежа с указанием причины.';
  c_cancel_status   PAYMENT.STATUS%type := 3;
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif p_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update PAYMENT pay
       set pay.STATUS = c_cancel_status,
           pay.STATUS_CHANGE_REASON = p_reason,
           pay.UPDATE_DTIME_TECH = p_current_time
     where pay.PAYMENT_ID = p_payment_id
       and pay.STATUS = 0;

    dbms_output.put_line (v_description||' Статус: '||c_cancel_status||'. Причина: '||p_reason
                                       ||'. Дата создания записи (Месяц): '||to_char(p_current_time,'MONTH'));
    dbms_output.put_line('ID платежа = '||p_payment_id);
  end if;
end;
/

--4. Платеж завершен успешно
create or replace procedure successful_finish_payment (p_payment_id    PAYMENT.PAYMENT_ID%type,
                                                       p_current_time  timestamp := sysdate)
is
  v_description     varchar2(100 char) := 'Успешное завершение платежа.';
  c_success_status  PAYMENT.STATUS%type := 1;
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    update PAYMENT pay
       set pay.STATUS = c_success_status,
           pay.UPDATE_DTIME_TECH = p_current_time
     where pay.PAYMENT_ID = p_payment_id
       and pay.STATUS = 0;
    dbms_output.put_line (v_description||' Статус: '||c_success_status
                                       ||'. Дата создания записи (1-ый день месяца): '||trunc(p_current_time,'MONTH'));
    dbms_output.put_line('ID платежа = '||p_payment_id);
  end if;
end;
/

--5. Добавление или обновление данных платежа по списку
create or replace procedure insert_or_update_payment_detail(p_payment_id           PAYMENT.PAYMENT_ID%type,
                                                            p_current_time         timestamp := sysdate,
                                                            p_payment_detail_array t_payment_detail_array)
is
  v_description     varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    --Проверки значений в коллекции
    if p_payment_detail_array is not empty then
      for i in p_payment_detail_array.first..p_payment_detail_array.last loop
        if p_payment_detail_array(i).field_id is null then
          dbms_output.put_line('Значение в поле field_id не может быть пустым');
        elsif p_payment_detail_array(i).field_value is null then
          dbms_output.put_line('ID поля field_value не может быть пустым');
        end if;
      end loop;
      merge into PAYMENT_DETAIL pay_d using (select pda.field_id, pda.field_value
                                               from table(p_payment_detail_array) pda
                                              where pda.field_id is not null and pda.field_value is not null) arr
              on (pay_d.PAYMENT_ID = p_payment_id and pay_d.FIELD_ID = arr.FIELD_ID)
            when matched then
              update set pay_d.FIELD_VALUE = arr.FIELD_VALUE
            when not matched then
              insert values (p_payment_id, arr.field_id, arr.field_value);
    else
      dbms_output.put_line('Коллекция не содержит данных');
    end if;
      dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(p_current_time,'dd-mm-yyyy hh24:mi:ss'));
      dbms_output.put_line('ID платежа = '||p_payment_id);
  end if;
end;
/

--6. Удаление деталей платежа  по списку
create or replace procedure delete_payment_detail(p_payment_id   PAYMENT.PAYMENT_ID%type,
                                                  p_current_time timestamp := sysdate,
                                                  p_number_array t_number_array)
is
  v_description     varchar2(100 char) := 'Детали платежа удалены по списку id_полей';

begin
  if p_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    --Проверки значений в коллекции
    if p_number_array is not empty then
      for i in p_number_array.first..p_number_array.last loop
        if p_number_array(i) is null then
          dbms_output.put_line('Значение в поле не может быть пустым');
        end if;
      end loop;
      delete from PAYMENT_DETAIL pay_d
       where pay_d.PAYMENT_ID = p_payment_id
         and pay_d.FIELD_ID in (select pna.column_value from table(p_number_array) pna);
    else
      dbms_output.put_line('Коллекция не содержит данных');
    end if;
    dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(p_current_time,'dd-mm-yyyy hh24:mi:ss'));
    dbms_output.put_line('ID платежа = '||p_payment_id);
  end if;
end;
/