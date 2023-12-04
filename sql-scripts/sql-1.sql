-- 1 
CREATE TABLE #measure_history (
	month_code		INT,
	measure_name	VARCHAR(20),
	measure_value	Decimal(18,4)
);
INSERT INTO #measure_history (month_code, measure_name, measure_value) VALUES
	(202305,'quantity', 100),
	(202305,'sale',   12312440.00 ),
	(202305,'margin', 2462488.00),
	(202305,'client', 10),
	(202306,'quantity', 110),
	(202306,'sale', 13814557.68),
	(202306,'margin', 2762911.536),
	(202306,'client', 15),
	(202307,'quantity', 135),
	(202307,'sale', 17293314.4776),
	(202307,'margin', 3458662.8955),
	(202307,'client', 20),
	(202308,'quantity', 150),
	(202308,'sale', 19599089.74),
	(202308,'margin', 3919817.95),
	(202308,'client',25);
-- basic select
select month_code, measure_name, measure_value 
from #measure_history
;
-- basic pivot
with measure_list as (
	select distinct measure_name from #measure_history
)
select month_code, uantity, sale, margin, client from (
	select month_code, measure_name, measure_value 
	from #measure_history
) src
pivot (
	sum(measure_value) for measure_name in (quantity, sale, margin, client)
) pvt
;
---- pivot solution 
declare @col nvarchar(max)
declare @sql nvarchar(max)
set @col = 
	(
		select string_agg([measure_name], ', ') 
		from (select distinct measure_name from #measure_history) measure_list
	) 
set @sql =
	'select month_code, ' + @col + ' 
	from (select month_code, measure_name, measure_value from #measure_history) src
	pivot 
		(sum(measure_value) for measure_name in (' + @col + ')) pvt
	;'
execute (@sql)
;
---- groupby solution 
with basic_select as (
	select month_code, measure_name, measure_value 
	from #measure_history
) 
select 
	month_code 
	, sum(case when measure_name = 'quantity' then measure_value end) as [quantity]
		-- количество реализованного товара
	, sum(case when measure_name = 'sale' then measure_value end) as [sale]
		-- сумма реализации товара
	, sum(case when measure_name = 'margin' then measure_value end) as [margin]
		-- маржа для реализованного товара
	, sum(case when measure_name = 'client' then measure_value end) as [client]
		-- количество клиентов, купивших товар 
from basic_select 
group by month_code 
;
---- groupby solution with added growth rate 
with basic_select as (
	select month_code, measure_name, measure_value 
	from #measure_history
) 
, basic_grouping as (
	select 
		month_code
		, sum(case when measure_name = 'quantity' then measure_value end) as [quantity]
			-- количество реализованного товара
		, sum(case when measure_name = 'sale' then measure_value end) as [sale]
			-- сумма реализации товара (выручка с налогом?)
		, sum(case when measure_name = 'margin' then measure_value end) as [margin]
			-- маржа для реализованного товара
		, sum(case when measure_name = 'client' then measure_value end) as [client]
			-- количество клиентов, купивших товар 
		, sum(case when measure_name = 'sale' then measure_value end) / 
			sum(case when measure_name = 'quantity' then measure_value end) as [price_avg]
			-- средняя цена реализации товара
		, sum(case when measure_name = 'margin' then measure_value end) / 
			sum(case when measure_name = 'quantity' then measure_value end) as [margin_avg]
			-- средняя маржа для товара
		, sum(case when measure_name = 'margin' then measure_value end) / 
			sum(case when measure_name = 'sale' then measure_value end) as [margin_pct]
			-- средняя маржинальность для товара
	from basic_select 
	group by month_code 
)
	select 
		*
		, (sale - lag(sale, 1) over(order by month_code)) / lag(sale, 1) over(order by month_code) as [sale_growth_rate] 
			-- помесячный прирост суммы реализованного товара 
		, (price_avg - lag(price_avg, 1) over(order by month_code)) / lag(price_avg, 1) over(order by month_code) as [price_growth_rate] 
			-- помесячный прирост суммы реализованного товара 
	from basic_grouping 
;
-- делаем вывод о неизменной маржинальности (чтобы отвязаться от масштаба, можно сравнивать как удельные показатели, так и соотношение тоталов)
-- делаем вывод о постоянном влиянии внешнего ценового фактора (про инфляцию можно говорить при доп.вводных, например, динамике закупок / прямой себестоимости) и о бремени для покупателя 
