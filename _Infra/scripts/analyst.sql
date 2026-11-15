-- Закупки

-- bm_StorageOperations vendors - VendorID
select count(*) as Total,
       count(v.id) as Found
from dbo.bm_StorageOperations s
left join dbo.vendors v on v.id = s.VendorID
where s.VendorID <> 0;

-- bm_StorageOperations bm_ReasonDebit - ReasonID
select count(*) as Total,
       count(r.ID) as Found
from dbo.bm_StorageOperations s
left join dbo.bm_ReasonDebit r on r.ID = s.ReasonID
where s.ReasonID <> 0;

-- product size - SizeID
select count(*) as Total,
       count(z.ID) as Found
from dbo.product p
left join dbo.size z on z.ID = p.SizeID;

-- Продажи

-- bm_StorageOperations_Table journal - SourceID
select count(*) as Total,
       count(j.transnumber) as Found
from dbo.bm_StorageOperations_Table t
left join dbo.journal j on j.transnumber = t.SourceID
where t.SourceID <> 0;

-- bm_StorageOperations_Table bm_ReasonDebit - ReasonID
select count(*) as Total,
       count(r.ID) as Found
from dbo.bm_StorageOperations_Table t
left join dbo.bm_ReasonDebit r on r.ID = t.ReasonID
where t.ReasonID <> 0;

-- journal personnel - loginid
select count(*) as Total,
       count(p.personid) as Found
from dbo.journal j
left join dbo.personnel p on p.personid = try_cast(j.loginid as int)
where j.loginid <> '';

-- Поставщики

-- bm_JournalBarnetDocs journal - TicketNumber
select count(*) as Total,
       count(j.receiptn) as Found
from dbo.bm_JournalBarnetDocs d
left join dbo.journal j on j.receiptn = d.TicketNumber
where d.TicketNumber is not null and d.TicketNumber <> 0;

-- Персонал

-- bm_JournalBarnetDocs personnel - PersonID
select count(*) as Total,
       count(p.personid) as Found
from dbo.bm_JournalBarnetDocs d
left join dbo.personnel p on p.personid = d.PersonID
where d.PersonID <> 0;

-- bm_JournalSessions personnel - PersonID
select count(*) as Total,
       count(p.personid) as Found
from dbo.bm_JournalSessions s
left join dbo.personnel p on p.personid = s.PersonID
where s.PersonID <> 0;

-- bm_PersonnelSecurity personnel - PersonID
select count(*) as Total,
       count(p.personid) as Found
from dbo.bm_PersonnelSecurity x
left join dbo.personnel p on p.personid = x.PersonID
where x.PersonID <> 0;

-- bm_BonusHistory journal - TicketNumber
select count(*) as Total,
       count(j.receiptn) as Found
from dbo.bm_BonusHistory b
left join (select distinct receiptn from dbo.journal) j on j.receiptn = try_cast(b.TicketNumber as numeric(18, 0))
where b.TicketNumber <> '';

-- Остатки

-- bm_StorageOperations bm_ReasonDebit - ReasonID
select count(*) as Total,
       count(r.ID) as Found
from dbo.bm_StorageOperations s
left join dbo.bm_ReasonDebit r on r.ID = s.ReasonID
where s.ReasonID <> 0;