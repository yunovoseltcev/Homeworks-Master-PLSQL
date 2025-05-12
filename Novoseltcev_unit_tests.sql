-- Заготовка для unit-тестов

-- Проверка исполнения тестов
select * from payment where payment_id = 69;
select * from payment_detail where payment_id = 69;

-- Проверка валидности объектов
select t.status
           ,t.*
  from user_objects t
 where t.object_type in ('FUNCTION', 'PROCEDURE');

--1. Создание платежа
declare
  v_summa                PAYMENT.SUMMA%type := 1000;
  v_currency_id          CURRENCY.CURRENCY_ID%type := 643;
  v_from_client_id       PAYMENT.FROM_CLIENT_ID%type := 1;
  v_to_client_id         PAYMENT.TO_CLIENT_ID%type := 3;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
  v_payment_id           PAYMENT.PAYMENT_ID%type;
begin
  v_payment_detail_array.extend(2);
  v_payment_detail_array(1) := t_payment_detail(1,'СБП');
  v_payment_detail_array(2) := t_payment_detail(2,'91.231.88.28');
  
  v_payment_id := create_payment(p_summa                => v_summa,
                                 p_currency_id          => v_currency_id,
                                 p_from_client_id       => v_from_client_id,
                                 p_to_client_id         => v_to_client_id,
                                 p_payment_detail_array => v_payment_detail_array);
  dbms_output.put_line('result function v_payment_id = '||v_payment_id);
end;

--2. Сброс платежа в ошибку
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'недостаточно средств';
begin
  fail_payment(p_payment_id   => v_payment_id,
               p_reason       => v_reason);
end;

--3. Отмена платежа
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_reason          PAYMENT.STATUS_CHANGE_REASON%type := 'ошибка пользователя';
begin
  cancel_payment(p_payment_id   => v_payment_id,
                 p_reason       => v_reason);
end;

--4. Платеж завершен успешно
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
begin
  successful_finish_payment(p_payment_id => v_payment_id);
end;

--5. Добавление или обновление данных платежа по списку
declare
  v_payment_id           PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_payment_detail_array t_payment_detail_array := t_payment_detail_array();
begin
  v_payment_detail_array.extend(1);
  v_payment_detail_array(1) := t_payment_detail(3,'Долг');
  
  insert_or_update_payment_detail(p_payment_id           => v_payment_id,
                                  p_payment_detail_array => v_payment_detail_array);
end;

--6. Удаление деталей платежа  по списку
declare
  v_payment_id      PAYMENT.PAYMENT_ID%type := payment_seq.currval;
  v_number_array    t_number_array := t_number_array(1,2,4);
begin
  delete_payment_detail(p_payment_id   => v_payment_id, 
                        p_number_array => v_number_array);
end;