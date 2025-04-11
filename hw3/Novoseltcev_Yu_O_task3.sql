/*
  �����: ����������� ���� ��������
  �������� �������: API ��� ��������� ������� � ������� ��������
*/

--1. �������� �������
declare
  v_description varchar2(100 char) := '������ ������.';
  c_create_status number(1) := 0;
begin
  dbms_output.put_line(v_description||' ������: '||c_create_status);
end;
/

--2. ����� ������� � ������
declare
  v_description varchar2(100 char) := '����� ������� � "��������� ������" � ��������� �������.';
  v_reason varchar2(100 char) := '������������ �������';
  c_error_status number(1) := '2';
begin  
  dbms_output.put_line (v_description||' ������: '||c_error_status||'. �������: '||v_reason);
end;
/

--3. ������ �������
declare
  v_description varchar2(100 char) := '������ ������� � ��������� �������.';
  v_reason varchar2(100 char) := '������ ������������';
  c_cancel_status number(1) := 3;
begin  
  dbms_output.put_line (v_description||' ������: '||c_cancel_status||'. �������: '||v_reason);
end;
/

--4. ������ �������� �������
declare
  v_description varchar2(100 char) := '�������� ���������� �������.';
  c_success_status number(1) := 1;
begin  
  dbms_output.put_line (v_description||' ������: '||c_success_status);
end;
/

--5. ���������� ��� ���������� ������ ������� �� ������
declare
  v_description varchar2(100 char) := '������ ������� ��������� ��� ��������� �� ������';
  v_field_id varchar2(10 char) := 'id_����';
  v_value varchar2(10 char) := '��������';
begin  
  dbms_output.put_line (v_description||' '||v_field_id||'/'||v_value);
end;
/

--6. �������� ������� ������� ������
declare
  v_description varchar2(100 char) := '������ ������� ������� �� ������';
  v_fields_id varchar2(10 char) := 'id_�����';
begin  
  dbms_output.put_line (v_description||' '||v_fields_id);
end;
/


select * from payment
