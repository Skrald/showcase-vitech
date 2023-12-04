-- 2
CREATE TABLE #plan_supply (
	id_sku		INT,
	supply_id	INT,
	date_supply	date,
	quantity 	INT
);
INSERT INTO #plan_supply (id_sku, supply_id, date_supply, quantity) VALUES
	(1,2,'2023.09.01',10),
	(1,4,'2023.09.03',2),
	(1,6,'2023.09.25',3),
	(1,8,'2023.10.25',8),
	(1,10,'2023.11.10',11),
	(2,12,'2023.09.07',4),
	(2,14,'2023.09.10',33),
	(2,16,'2023.10.11',55),
	(2,18,'2023.11.11',12)
;
-- select * from #plan_supply;
go
-- создадим служебную функцию для последовательностей 
CREATE OR ALTER FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
             FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
go 
-- решение с ручным вводом данных
begin
	declare @dtStart as date = '20230901', @dtEnd as date = '20231231' ;
	with sku_list(id_sku) as (select 1 union all select 2) 
	, granularity as (select * from sku_list cross join dbo.GetNums(0, datediff(day, @dtStart, @dtEnd)))
	, granularity_dt as (select id_sku, dateadd(day, n, @dtStart) as dt from granularity)
	, inventory as (select 1 as id_sku, cast(GETDATE() as date) as dt, 5 as qty union all select 2, '2023-12-31', 0) 
	, sales_medians as (select 1 as id_sku, 2 as qty union all select 2, 7) 
	, sales_stats as (select st.id_sku, gt.dt, st.qty from sales_medians st join granularity_dt gt on st.id_sku = gt.id_sku) 
	, warehouse_stats as (
		select 
			gt.id_sku, gt.dt 
			, it.qty as inventory_corr
			, (coalesce(pst.quantity,0) + coalesce(it.qty,0)) as account_debit 
			, sst.qty as sales_expected 
		from granularity_dt gt 
		left join inventory it 
			on gt.id_sku = it.id_sku and gt.dt = it.dt 
		left join #plan_supply pst 
			on gt.id_sku = pst.id_sku and gt.dt = pst.date_supply  
		left join sales_stats sst
			on gt.id_sku = sst.id_sku and gt.dt = sst.dt 
	)
	, calc_1 as (
		select *
		, isnull(sum(account_debit) over (partition by id_sku order by dt), 0) as c1 
		, isnull(sum(sales_expected) over (partition by id_sku order by dt), 0) as c2 
		, coalesce(sum(account_debit) over (partition by id_sku order by dt rows unbounded preceding), 0) - 
			coalesce(sum(sales_expected) over (partition by id_sku order by dt rows unbounded preceding), 0) as partsum 
		from warehouse_stats
	)
	, calc_2 as (select *, min(partsum) over (partition by id_sku order by dt rows unbounded preceding) as mn from calc_1) 
	select 
		id_sku
		, dt
		, partsum + adjust as end_balance 
	from calc_2 
	cross apply(values(case when mn<0 then -mn else 0 end)) as A(adjust) 
end
go