/*
  �����: ����������� ���� ��������
  �������� �������: API ��� ��������� ������� � ������� ��������
*/

--1. �������� �������
declare
  v_str varchar2(100 char) := '������ ������. ������: 0';
begin
  dbms_output.put_line('������ ������. ������: 0');
end;
/

--2. ����� ������� � ������
declare
  v_str varchar2(100 char) := '����� ������� � "��������� ������" � ��������� �������. ������: 2. �������: ������������ �������';
begin  
  dbms_output.put_line (v_str);
end;
/

--3. ������ �������
declare
  v_str varchar2(100 char) := '������ ������� � ��������� �������. ������: 3. �������: ������ ������������';
begin  
  dbms_output.put_line (v_str);
end;
/

--4. ������ �������� �������
declare
  v_str varchar2(100 char) := '�������� ���������� �������. ������: 1';
begin  
  dbms_output.put_line (v_str);
end;
/

--5. ���������� ��� ���������� ������ ������� �� ������
declare
  v_str varchar2(100 char) := '������ ������� ��������� ��� ��������� �� ������ id_����/��������';
begin  
  dbms_output.put_line (v_str);
end;
/

--6. �������� ������� ������� ������
declare
  v_str varchar2(100 char) := '������ ������� ������� �� ������ id_�����';
begin  
  dbms_output.put_line (v_str);
end;
/
