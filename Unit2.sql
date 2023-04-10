/* 
- The procedure should take an input of a variable that contains JSON
- The file should be used to update the existing data in the Sales.SalesPerson table
- It should also insert a row for the quota date into the Sales.SalesPersonQuotaHistory table. If a row already exists for the sales person and the quota date, the data should be overwritten
- The history table does not allow for null values. If the sales person has no quota for the period, enter 0's for the null fields. 
*/


drop table if exists SalesPersonPractice
drop table if exists SalesPersonQuotaHistoryPractice
drop table if exists NewSalesPersonData
drop trigger if exists trigger_SalesPersonPractice

select * into SalesPersonPractice from Sales.SalesPerson;
select * into SalesPersonQuotaHistoryPractice from Sales.SalesPersonQuotaHistory;


DECLARE @JSON NVARCHAR(max) = '{
    "SalesGoals": [
        {
            "SalesPerson": {
                "Id": 274,
                "Name": "Jiang, Stephen",
                "CommissionPercent": 0.0050
            },
            "SalesGoal": {
                "GoalDate": "07-01-2021",  
                "QuarterlyGoal": 80000.0000,
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

select * into NewSalesPersonData
from OpenJSON(@JSON, '$.SalesGoals')
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
update dbo.SalesPersonPractice
SET 
    SalesQuota = ISNULL(QuarterlyGoal,0),  
    Bonus = SalesBonus,
    CommissionPct = SalesPersonCommissionPercent,
    ModifiedDate = GETDATE()
from dbo.NewSalesPersonData 
where SalesPersonID = BusinessEntityID

-- If Goal Date has not changed, update
UPDATE dbo.SalesPersonQuotaHistoryPractice
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

INSERT INTO dbo.SalesPersonQuotaHistoryPractice (BusinessEntityID,QuotaDate,SalesQuota,rowguid,ModifiedDate,Bonus,CommissionPercent)
SELECT 
    SalesPersonID, 
    GoalDate, 
    ISNULL(QuarterlyGoal,0), 
    NEWID(),
    GETDATE(),
    SalesBonus,
    SalesPersonCommissionPercent
FROM dbo.NewSalesPersonData as n
WHERE NOT EXISTS (select * from dbo.SalesPersonQuotaHistoryPractice where BusinessEntityID = n.SalesPersonID and QuotaDate = n.GoalDate)


-- select * from NewSalesPersonData
-- select * from SalesPersonPractice
-- select * from SalesPersonQuotaHistoryPractice order by ModifiedDate desc

-- select * from dbo.NewSalesPersonData where SalesPersonID = 274
-- select * from dbo.SalesPersonPractice where BusinessEntityID = 274
-- select * from dbo.SalesPersonQuotaHistoryPractice where BusinessEntityID = 274 order by ModifiedDate desc