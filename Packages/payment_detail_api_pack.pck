create or replace package payment_detail_api_pack is

  -- Author  : ЮРА
  -- Created : 11.05.2025 13:12:34
  -- Purpose : API по деталям платежа
  
  --5. Добавление или обновление данных платежа по списку
  procedure insert_or_update_payment_detail(p_payment_id           PAYMENT.PAYMENT_ID%type,
                                            p_payment_detail_array t_payment_detail_array);
  
  --6. Удаление деталей платежа  по списку
  procedure delete_payment_detail(p_payment_id   PAYMENT.PAYMENT_ID%type,
                                  p_number_array t_number_array);                                  

end payment_detail_api_pack;
/

create or replace package body payment_detail_api_pack is
  
  --5. Добавление или обновление данных платежа по списку
  procedure insert_or_update_payment_detail(p_payment_id           PAYMENT.PAYMENT_ID%type,
                                            p_payment_detail_array t_payment_detail_array)
  is
    v_description     varchar2(100 char) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
  begin
    if p_payment_id is null then
      dbms_output.put_line('ID объекта не может быть пустым');
    else
      --Проверки значений в коллекции
      if p_payment_detail_array is not empty then
        payment_common_pack.checkPaymentDetailCollection(p_payment_detail_array);
        merge into PAYMENT_DETAIL pay_d using (select pda.field_id, pda.field_value
                                                 from table(p_payment_detail_array) pda
                                                where pda.field_id is not null and pda.field_value is not null) arr
                on (pay_d.PAYMENT_ID = p_payment_id and pay_d.FIELD_ID = arr.FIELD_ID)
              when matched then
                update set pay_d.FIELD_VALUE = arr.FIELD_VALUE
              when not matched then
                insert values (p_payment_id, arr.field_id, arr.field_value);
      else
        raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                                payment_common_pack.c_error_msg_empty_collection);
      end if;
        dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(systimestamp,'dd-mm-yyyy hh24:mi:ss'));
        dbms_output.put_line('ID платежа = '||p_payment_id);
    end if;
  end insert_or_update_payment_detail;
  
  --6. Удаление деталей платежа  по списку
  procedure delete_payment_detail(p_payment_id   PAYMENT.PAYMENT_ID%type,
                                  p_number_array t_number_array)
  is
    v_description     varchar2(100 char) := 'Детали платежа удалены по списку id_полей';

  begin
    if p_payment_id is null then
      raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                              payment_common_pack.c_error_msg_empty_payment_id);
    else
      --Проверки значений в коллекции
      if p_number_array is not empty then
        delete from PAYMENT_DETAIL pay_d
         where pay_d.PAYMENT_ID = p_payment_id
           and pay_d.FIELD_ID in (select pna.column_value from table(p_number_array) pna);
      else
        raise_application_error(payment_common_pack.c_error_code_empty_invalid_input_parametr,
                                payment_common_pack.c_error_msg_empty_collection);
      end if;
      dbms_output.put_line (v_description||'. Дата создания записи: '||to_char(systimestamp,'dd-mm-yyyy hh24:mi:ss'));
      dbms_output.put_line('ID платежа = '||p_payment_id);
    end if;
  end delete_payment_detail;
  
end payment_detail_api_pack;
/

