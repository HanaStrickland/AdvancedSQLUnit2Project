-- Check Constraint for Quota was greater than 0; had to change this to meet prompt requirements
-- ALTER TABLE Sales.SalesPerson drop CONSTRAINT CK_SalesPerson_SalesQuota
-- ALTER TABLE [Sales].[SalesPerson]  WITH CHECK ADD  CONSTRAINT [CK_SalesPerson_SalesQuota] CHECK  (([SalesQuota]>=(0.00)));
-- ALTER table Sales.SalesPersonQuotaHistory drop CONSTRAINT CK_SalesPersonQuotaHistory_SalesQuota
-- ALTER TABLE [Sales].[SalesPersonQuotaHistory]  WITH CHECK ADD  CONSTRAINT [CK_SalesPersonQuotaHistory_SalesQuota] CHECK  (([SalesQuota]>=(0.00)))

/***************************************
* Updating SalesPerson Data
* Author: Hana Strickland
* created: 4/18/2023
*
*
* This procedure takes in json text and updates data in the Sales.SalesPerson and Sales.SalesPersonQuotaHistory table
*
****************************************
*
*
****************************************/

USE AdventureWorks_AdvSql_26_HS
GO

Create PROCEDURE UpdateSalesPersonData @JSON_Variable NVARCHAR(max)
AS

drop table if exists NewSalesPersonData;

select * into NewSalesPersonData
from OpenJSON(@JSON_Variable, '$.SalesGoals')
WITH
(
    SalesPersonID int '$.SalesPerson.Id',
    SalesPersonName VARCHAR(100) '$.SalesPerson.Name',
    QuarterlyGoal FLOAT(4) '$.SalesGoal.QuarterlyGoal',
    SalesBonus FLOAT(4) '$.SalesGoal.SalesBonus',
    SalesPersonCommissionPercent FLOAT(4) '$.SalesPerson.CommissionPercent',
    GoalDate DATE '$.SalesGoal.GoalDate'
) as Salespeople;

-- Update SalesPerson
update Sales.SalesPerson
SET 
    SalesQuota = ISNULL(QuarterlyGoal,0),  
    Bonus = SalesBonus,
    CommissionPct = SalesPersonCommissionPercent,
    ModifiedDate = GETDATE()
from dbo.NewSalesPersonData 
where SalesPersonID = BusinessEntityID

-- If Goal Date has not changed, update
UPDATE Sales.SalesPersonQuotaHistory
SET 
    SalesQuota = ISNULL(QuarterlyGoal,0),
    ModifiedDate = GETDATE(),
    Bonus = SalesBonus,
    CommissionPercent = SalesPersonCommissionPercent
from dbo.NewSalesPersonData 
where 
    SalesPersonID = BusinessEntityID
    and QuotaDate = GoalDate

--If Goal Date Has Changed, insert

INSERT INTO Sales.SalesPersonQuotaHistory (BusinessEntityID,QuotaDate,SalesQuota,rowguid,ModifiedDate,Bonus,CommissionPercent)
SELECT 
    SalesPersonID, 
    GoalDate, 
    ISNULL(QuarterlyGoal,0), 
    NEWID(),
    GETDATE(),
    SalesBonus,
    SalesPersonCommissionPercent
FROM dbo.NewSalesPersonData as n
WHERE NOT EXISTS (select * from Sales.SalesPersonQuotaHistory where BusinessEntityID = n.SalesPersonID and QuotaDate = n.GoalDate)

GO



EXEC UpdateSalesPersonData '{
    "SalesGoals": [
        {
            "SalesPerson": {
                "Id": 274,
                "Name": "Jiang, Stephen",
                "CommissionPercent": 0.0050
            },
            "SalesGoal": {
                "GoalDate": "10-01-2021",  
                "QuarterlyGoal": 100000.0000,
                "SalesBonus": 1000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 275,
                "Name": "Blythe, Michael",
                "CommissionPercent": 0.0120
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 750000.0000,
                "SalesBonus": 4500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 276,
                "Name": "Mitchell, Linda",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 900000.0000,
                "SalesBonus": 2000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 277,
                "Name": "Carson, Jillian",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 2500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 278,
                "Name": "Vargas, Garrett",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 220000.0000,
                "SalesBonus": 700.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 279,
                "Name": "Reiter, Tsvi",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 500000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 280,
                "Name": "Ansman-Wolfe, Pamela",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 250000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 281,
                "Name": "Ito, Shu",
                "CommissionPercent": 0.0100
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 450000.0000,
                "SalesBonus": 2650.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 282,
                "Name": "Saraiva, José",
                "CommissionPercent": 0.0150
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 5000.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 283,
                "Name": "Campbell, David",
                "CommissionPercent": 0.0120
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 225000.0000,
                "SalesBonus": 3500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 284,
                "Name": "Mensa-Annan, Tete",
                "CommissionPercent": 0.0190
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 320000.0000,
                "SalesBonus": 3900.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 285,
                "Name": "Abbas, Syed",
                "CommissionPercent": 0.0000
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "SalesBonus": 0.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 286,
                "Name": "Tsoflias, Lynn",
                "CommissionPercent": 0.0180
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 280000.0000,
                "SalesBonus": 4500.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 287,
                "Name": "Alberts, Amy",
                "CommissionPercent": 0.0000
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "SalesBonus": 0.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 288,
                "Name": "Valdez, Rachel",
                "CommissionPercent": 0.0180
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 425000.0000,
                "SalesBonus": 2200.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 289,
                "Name": "Pak, Jae",
                "CommissionPercent": 0.0200
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 870000.0000,
                "SalesBonus": 6650.0000
            }
        },
        {
            "SalesPerson": {
                "Id": 290,
                "Name": "Varkey Chudukatil, Ranjit",
                "CommissionPercent": 0.0160
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",
                "QuarterlyGoal": 600000.0000,
                "SalesBonus": 1275.0000
            }
        }
    ]
}'


-- Checking Procedure --
-- select * from dbo.NewSalesPersonData where SalesPersonID = 274
-- select * from Sales.SalesPerson where BusinessEntityID = 274
-- select * from Sales.SalesPersonQuotaHistory where BusinessEntityID = 277 order by ModifiedDate desc

/***************************************
* Getting Salesperson Data
* Author: Hana Strickland
* created: 3/26/2023
*
* Parameters: Sales Year
*
* This procedure attempts to return salesperson sales, quota, bonus, commission by quarter and total per year + annual compensation
* if there are no orders for the year chosen, the procedure throws an error
*
****************************************
*
*
****************************************/

USE AdventureWorks_AdvSql_26_HS
GO

CREATE PROCEDURE GetSalesPersonInfo (@SalesYear int)
AS
BEGIN

/** Check If Sales Year Exists in Orders Table **/


if (@SalesYear not in (select distinct year(OrderDate) from Sales.SalesOrderHeader))
BEGIN
        DECLARE @errormsg varchar(100) = concat('No orders exist for sales year ', @SalesYear)
        ; THROW 51000, @errormsg, 1;
END


/** Sales Temp Table **/

;with quarterlydata AS
(
    select distinct SalesPersonID, year(OrderDate) as order_year, order_quarter,
    sum(SubTotal) over (PARTITION by SalesPersonID, order_quarter) as quartery_sales_by_salesperson
    from (select SalesPersonID, OrderDate, DATEPART(QQ, OrderDate) as order_quarter, SubTotal
            from Sales.SalesOrderHeader
            where year(OrderDate) = @SalesYear) as soh
    where SalesPersonID is not null
)
select SalesPersonID, order_year,
    isnull([1],0) as Q1Sales,
    isnull([2],0) as Q2Sales,
    isnull([3],0) as Q3Sales,
    isnull([4],0) as Q4Sales,
    (isnull([1],0) + isnull([2],0) + isnull([3],0) + isnull([4],0)) as yearlyTotal_by_salesperson
into #temp_sales
from quarterlydata
PIVOT
(
    min(quartery_sales_by_salesperson) 
    for order_quarter in ([1],[2],[3],[4])
) as quarterPivot

/** Quota Temp Table **/

;with quotadata as
(
    select BusinessEntityID, year(QuotaDate) as quota_year, DATEPART(QQ, QuotaDate) as quota_quarter, CommissionPercent, SalesQuota
    from Sales.SalesPersonQuotaHistory
    where year(QuotaDate) = @SalesYear
)
select BusinessEntityID, quota_year, CommissionPercent,
    isnull([1],0) as Q1Quota,
    isnull([2],0) as Q2Quota,
    isnull([3],0) as Q3Quota,
    isnull([4],0) as Q4Quota
into #temp_quota
from quotadata
PIVOT
(
    min(SalesQuota) 
    for quota_quarter in ([1],[2],[3],[4])
) as quarterPivot

/** Quota Temp Table **/

;with commisionpercent as
(
    select BusinessEntityID, year(QuotaDate) as quota_year, DATEPART(QQ, QuotaDate) as quota_quarter, CommissionPercent
    from Sales.SalesPersonQuotaHistory
    where year(QuotaDate) = @SalesYear
)
select BusinessEntityID, quota_year,
    isnull([1],0) as Q1commissionpct,
    isnull([2],0) as Q2commissionpct,
    isnull([3],0) as Q3commissionpct,
    isnull([4],0) as Q4commissionpct
into #temp_commissionpercent
from commisionpercent
PIVOT
(
    min(CommissionPercent) 
    for quota_quarter in ([1],[2],[3],[4])
) as quarterPivot

/** Bonus Temp Table **/
;with bonusdata as
(
    select BusinessEntityID, year(QuotaDate) as quota_year, DATEPART(QQ, QuotaDate) as order_quarter, Bonus
    from Sales.SalesPersonQuotaHistory
    where year(QuotaDate) = @SalesYear
)
select BusinessEntityID, quota_year,
    isnull([1],0) as Q1Bonus,
    isnull([2],0) as Q2Bonus,
    isnull([3],0) as Q3Bonus,
    isnull([4],0) as Q4Bonus
into #temp_bonus
from bonusdata
PIVOT
(
    min(Bonus) 
    for order_quarter in ([1],[2],[3],[4])
) as quarterPivot


/** Combine Temp Tables **/


;with all_quarterly_data as
(
    select s.SalesPersonID, CONCAT(p.FirstName, ' ', p.LastName) as SalesPerson, s.order_year as SalesYear,

    -- Q1

    Q1Quota, Q1Sales, Q1commissionpct,
    case
        when Q1Quota = 0 then 0
        when Q1Sales >= Q1Quota then Q1Bonus
        else 0
    end as EarnedBonusQ1,
    (Q1Sales * Q1commissionpct) as Q1Commission,

    -- Q2
    Q2Quota, Q2Sales, Q2commissionpct,
    case
        when Q2Quota = 0 then 0
        when Q2Sales >= Q2Quota then Q2Bonus
        else 0
    end as EarnedBonusQ2,
    (Q2Sales * Q2commissionpct) as Q2Commission,

    -- Q3
    Q3Quota, Q3Sales, Q3commissionpct,
    case
        when Q3Quota = 0 then 0
        when Q3Sales >= Q3Quota then Q3Bonus
        else 0
    end as EarnedBonusQ3,
    (Q3Sales * Q3commissionpct) as Q3Commission,

    -- Q4
    Q4Quota, Q4Sales, Q4commissionpct,
    case
        when Q4Quota = 0 then 0
        when Q4Sales >= Q4Quota then Q4Bonus
        else 0
    end as EarnedBonusQ4,
    (Q4Sales * Q4commissionpct) as Q4Commission
        
    from #temp_sales as s
    join Person.Person as p         on s.SalesPersonID = p.BusinessEntityID
    join #temp_quota as q      on s.SalesPersonID = q.BusinessEntityID
    join #temp_bonus as b      on s.SalesPersonID = b.BusinessEntityID
    join #temp_commissionpercent as c on s.SalesPersonID = c.BusinessEntityID
)
select *,
(Q1Sales + Q2Sales + Q3Sales + Q4Sales) as total_annual_sales,
(EarnedBonusQ1 + EarnedBonusQ2 + EarnedBonusQ3 + EarnedBonusQ4) as total_annual_bonuses,
(Q1Commission + Q2Commission + Q3Commission + Q4Commission) as total_annual_commission,
(EarnedBonusQ1 + EarnedBonusQ2 + EarnedBonusQ3 + EarnedBonusQ4 + Q1Commission + Q2Commission + Q3Commission + Q4Commission) as total_annual_sales_compensation 
from all_quarterly_data

drop table #temp_sales
drop table #temp_bonus
drop table #temp_quota
drop table #temp_commissionpercent
END
GO




--EXEC GetSalesPersonInfo 2020