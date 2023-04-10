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
    select s.SalesPersonID, CONCAT(p.FirstName, ' ', p.LastName) as SalesPerson, s.order_year as SalesYear, q.CommissionPercent,

    -- Q1

    Q1Sales, Q1Quota, 
    case
        when Q1Quota = 0 then 0
        when Q1Sales >= Q1Quota then Q1Bonus
        else 0
    end as EarnedBonusQ1,
    (Q1Sales * q.CommissionPercent) as Q1Commission,

    -- Q2
    Q2Sales, Q2Quota, 
    case
        when Q2Quota = 0 then 0
        when Q2Sales >= Q2Quota then Q2Bonus
        else 0
    end as EarnedBonusQ2,
    (Q2Sales * q.CommissionPercent) as Q2Commission,

    -- Q3
    Q3Sales, Q3Quota, 
    case
        when Q3Quota = 0 then 0
        when Q3Sales >= Q3Quota then Q3Bonus
        else 0
    end as EarnedBonusQ3,
    (Q3Sales * q.CommissionPercent) as Q3Commission,

    -- Q4
    Q4Sales, Q4Quota, 
    case
        when Q4Quota = 0 then 0
        when Q4Sales >= Q4Quota then Q4Bonus
        else 0
    end as EarnedBonusQ4,
    (Q4Sales * q.CommissionPercent) as Q4Commission
        
    from #temp_sales as s
    join Person.Person as p         on s.SalesPersonID = p.BusinessEntityID
    join #temp_quota as q      on s.SalesPersonID = q.BusinessEntityID
    join #temp_bonus as b      on s.SalesPersonID = b.BusinessEntityID
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
END
GO




--EXEC GetSalesPersonInfo 2019