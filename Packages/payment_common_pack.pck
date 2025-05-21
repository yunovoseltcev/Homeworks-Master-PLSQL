create or replace package plsql14_student2.PAYMENT_COMMON_PACK is

  -- Author  : ЮРА
  -- Created : 21.05.2025 20:14:35
  -- Purpose : Общие объекты API
  
  --Сообщения ошибок
  c_error_msg_empty_field_id     constant varchar2(100 char) := 'Значение в поле field_id не может быть пустым';
  c_error_msg_empty_field_value  constant varchar2(100 char) := 'ID поля field_value не может быть пустым';
  c_error_msg_empty_collection   constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_payment_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_empty_reason       constant varchar2(100 char) := 'Причина не может быть пустой';
  
  --Коды ошибок
  c_error_code_empty_invalid_input_parametr constant number(10) := -20001;
  
  --Объекты исключений
  e_invalid_input_parametr exception;
  pragma exception_init(e_invalid_input_parametr, c_error_code_empty_invalid_input_parametr);
  
  --Проверки коллекции t_payment_detail_array
  procedure checkPaymentDetailCollection (p_payment_detail_array t_payment_detail_array);

end PAYMENT_COMMON_PACK;
/

create or replace package body plsql14_student2.PAYMENT_COMMON_PACK is

  --Проверки коллекции t_payment_detail_array
  procedure checkPaymentDetailCollection (p_payment_detail_array t_payment_detail_array) 
  is
  begin
    for i in p_payment_detail_array.first..p_payment_detail_array.last loop
        if p_payment_detail_array(i).field_id is null then
          raise_application_error (c_error_code_empty_invalid_input_parametr, c_error_msg_empty_field_id);
        elsif p_payment_detail_array(i).field_value is null then
          raise_application_error (c_error_code_empty_invalid_input_parametr, c_error_msg_empty_field_value);
        end if;
      end loop;
  end checkPaymentDetailCollection;

end PAYMENT_COMMON_PACK;
/

