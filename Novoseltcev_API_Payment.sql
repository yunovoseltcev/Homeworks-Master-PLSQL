/*
  Автор: Новосельцев Юрий Олегович
  Описание скрипта: API для сущностей "Платеж" и "Детали платежа"
*/

--1. Создание платежа
declare
  v_description     varchar2(100 char) := 'Платеж создан.';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type;
  v_summa           PAYMENT.SUMMA%type := 1000;
  v_currency_id     CURRENCY.CURRENCY_ID%type := 643;
  v_from_client_id  PAYMENT.FROM_CLIENT_ID%type := 1;
  v_to_client_id    PAYMENT.TO_CLIENT_ID%type := 3;
  
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
  
  c_create_status   PAYMENT.STATUS%type := 0;
begin
  --Создаем запись о платеже
  insert into PAYMENT values (payment_seq.nextval, v_current_time, v_summa, 
                              v_currency_id, v_from_client_id, v_to_client_id, 
                              c_create_status, null, v_current_time, v_current_time)
  returning PAYMENT_ID into v_payment_id;
  dbms_output.put_line(v_description||' Статус: '||c_create_status
                                    ||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss:ff3'));
  dbms_output.put_line('ID платежа = '||v_payment_id);

  v_payment_detail_array.extend(2);
  v_payment_detail_array(1) := t_payment_detail(1,'СБП');
  v_payment_detail_array(2) := t_payment_detail(2,'91.231.88.28');
  --Проверки значений в коллекции
  if v_payment_detail_array is not empty then
    for i in v_payment_detail_array.first..v_payment_detail_array.last loop
      if v_payment_detail_array(i).field_id is null then
        dbms_output.put_line('Значение в поле field_id не может быть пустым');
      elsif v_payment_detail_array(i).field_value is null then
        dbms_output.put_line('ID поля field_value не может быть пустым');
      end if;
    end loop;
    --Создаем запись о детали платежа
    insert into PAYMENT_DETAIL (select v_payment_id, pda.field_id, pda.field_value 
                                 from table(v_payment_detail_array) pda 
                                where pda.field_id is not null and pda.field_value is not null);
  else
    dbms_output.put_line('Коллекция не содержит данных');
  end if;
end;
/

--2. Сброс платежа в ошибку
declare
  v_description     varchar2(100 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'недостаточно средств';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  c_error_status    PAYMENT.STATUS%type := 2;
begin  
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update PAYMENT pay
       set pay.STATUS = c_error_status, 
           pay.STATUS_CHANGE_REASON = v_reason,
           pay.UPDATE_DTIME_TECH = v_current_time
     where pay.PAYMENT_ID = v_payment_id
       and pay.STATUS = 0;
    
    dbms_output.put_line (v_description||' Статус: '||c_error_status||'. Причина: '||v_reason
                                       ||'. Дата создания записи (День): '||to_char(v_current_time,'DAY'));
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--3. Отмена платежа
declare
  v_description     varchar2(100 char) := 'Отмена платежа с указанием причины.';
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'ошибка пользователя';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  c_cancel_status   PAYMENT.STATUS%type := 3;
begin  
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  elsif v_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  else
    update PAYMENT pay
       set pay.STATUS = c_cancel_status, 
           pay.STATUS_CHANGE_REASON = v_reason,
           pay.UPDATE_DTIME_TECH = v_current_time
     where pay.PAYMENT_ID = v_payment_id
       and pay.STATUS = 0;
       
    dbms_output.put_line (v_description||' Статус: '||c_cancel_status||'. Причина: '||v_reason
                                       ||'. Дата создания записи (Месяц): '||to_char(v_current_time,'MONTH'));
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--4. Платеж завершен успешно
declare
  v_description     varchar2(100 char) := 'Успешное завершение платежа.';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  c_success_status  PAYMENT.STATUS%type := 1;
begin  
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    update PAYMENT pay
       set pay.STATUS = c_success_status,
           pay.UPDATE_DTIME_TECH = v_current_time
     where pay.PAYMENT_ID = v_payment_id
       and pay.STATUS = 0;
    dbms_output.put_line (v_description||' Статус: '||c_success_status
                                       ||'. Дата создания записи (1-ый день месяца): '||trunc(v_current_time,'MONTH'));
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--5. Добавление или обновление данных платежа по списку
declare
  v_description     varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
begin  
  v_payment_detail_array.extend(1);
  v_payment_detail_array(1) := t_payment_detail(3,'Долг');
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    --Проверки значений в коллекции
    if v_payment_detail_array is not empty then
      for i in v_payment_detail_array.first..v_payment_detail_array.last loop
        if v_payment_detail_array(i).field_id is null then
          dbms_output.put_line('Значение в поле field_id не может быть пустым');
        elsif v_payment_detail_array(i).field_value is null then
          dbms_output.put_line('ID поля field_value не может быть пустым');
        end if;
      end loop;
      merge into PAYMENT_DETAIL pay_d using (select pda.field_id, pda.field_value 
                                               from table(v_payment_detail_array) pda 
                                              where pda.field_id is not null and pda.field_value is not null) arr
              on (pay_d.PAYMENT_ID = v_payment_id and pay_d.FIELD_ID = arr.FIELD_ID)
            when matched then 
              update set pay_d.FIELD_VALUE = arr.FIELD_VALUE
            when not matched then 
              insert values (v_payment_id, arr.field_id, arr.field_value);
    else
      dbms_output.put_line('Коллекция не содержит данных');
    end if;
      dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss'));
      dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/

--6. Удаление деталей платежа  по списку
declare
  v_description     varchar2(100 char) := 'Детали платежа удалены по списку id_полей';
  v_current_time    timestamp := sysdate;
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  
  v_number_array    t_number_array := t_number_array(1,2,4);
begin  
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  else
    --Проверки значений в коллекции
    if v_number_array is not empty then
      for i in v_number_array.first..v_number_array.last loop
        if v_number_array(i) is null then
          dbms_output.put_line('Значение в поле не может быть пустым');
        end if;
      end loop;
      delete from PAYMENT_DETAIL pay_d 
       where pay_d.PAYMENT_ID = v_payment_id 
         and pay_d.FIELD_ID in (select vna.column_value from table(v_number_array) vna);
    else
      dbms_output.put_line('Коллекция не содержит данных');
    end if;
    dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(v_current_time,'dd-mm-yyyy hh24:mi:ss'));
    dbms_output.put_line('ID платежа = '||v_payment_id);
  end if;
end;
/