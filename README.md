# showcase-vitech

## SQL-1
> Нового сотрудника попросили подготовить данные для отчета руководству, но данные были подготовлены в неправильной форме.  
Требуется посредством SQL привести таблицу из исходного к правильному формату.
 
Данные были подготовлены в следующем виде:  

<img src=https://github.com/Skrald/showcase-vitech/blob/bbe86a9fc732ad05417dd3abcabff34fb1575b9c/images/sql-1-1.png width=720 height=360>

```sql
CREATE TABLE #measure_history (
	month_code		INT,
	measure_name	VARCHAR(20),
	measure_value	Decimal(18,4)
);
```

```sql
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
```

Итоговая форма должна была быть:  

<img src=https://github.com/Skrald/showcase-vitech/blob/bbe86a9fc732ad05417dd3abcabff34fb1575b9c/images/sql-1-2.png width=720 height=360>

Описание:  

- quantity – кол-во реализованного товара, 
- sale – сумма реализованного товара, 
- margin – маржа реализованного товара, 
- client – кол-во клиентов купивших товар

Требования:  

a)	Предоставить решение как с использованием «group by», так и через pivot  
b)	Дополнительно вывести столбец с месячным приростом продаж  
Дополнительно ответить на вопросы:
a)	Какова динамика изменения маржинальности?  
b)	Имеет ли место быть инфляция? Если да, то переложил ли ее продавец на конечного покупателя?  

## SQL-2

## SQL-3

## Проверка навыков POWER BI

