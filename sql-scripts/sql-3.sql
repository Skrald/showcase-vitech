-- 3 
use DWH;
-- drop table [Reporting].[Customer]; 
create table [Reporting].[Customer] (
	 [customer_id] 	int 	identity(1, 1) 	primary key 	-- ID клиента (пример: 1,2,3,4)
	, [name_full] 	as name_last + ' ' + name_first + ' ' + name_middle persisted 	-- ФИО клиента
	, [name_last] 	nvarchar(80) 	null 	-- Фамилия
	, [name_first] 	nvarchar(80) 	null 	-- Имя
	, [name_middle] 	nvarchar(80) 	default 'Нет отчества' 	-- Отчество 
	, [address_lat] 	decimal(8,6) 	null 	-- Широта адреса
	, [address_lon] 	decimal(9,6) 	null 	-- Долгота адреса
	, [orders_cnt_total] 	smallint 	not null default 0 check (orders_cnt_total >= 0) 	-- Общее кол-во заказов
	, [orders_amount_total] 	decimal(18,2) 	not null default 0 	-- Сумма покупок (два знака после запятой)
	, [register_dt] 	datetime 	null 	-- Дата и время регистрации клиента на сайте 
	, [login] 	nvarchar(255) 	null 	-- Логин
	, [password_hash] 	char(128) 	null 	-- Пароль
	, [ts_ins] 	datetime 	default getdate() 	-- Дата и время создания строки (с текущим временем по умолчанию)
	, [ts_upd] 	datetime 	default getdate() 	-- Дата и время обновления строки (с текущим временем по умолчанию) 
);
go
-- -- test
-- insert into customer (name_last, name_first, name_middle) values ('AA', 'BB', 'CC');
-- select * from customer;