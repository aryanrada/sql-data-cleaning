---Viewing Data 
select * from portfolio.dbo.housing;


---Standardizing date formate
select SaleDate, convert(date, SaleDate)
from portfolio.dbo.housing;

update housing
set SaleDate = convert(date, SaleDate);

alter table housing
add SaleDate2 date;

update housing
set SaleDate2 = convert(date,SaleDate);


---property address data
select * from portfolio.dbo.housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio.dbo.housing a
join portfolio.dbo.housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio.dbo.housing a
join portfolio.dbo.housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---breaking address into individual(Address, City, State)
select PropertyAddress
from portfolio.dbo.housing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from portfolio.dbo.housing

alter table housing
add SplitAddress Nvarchar(255)

update housing
set SplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table housing
add SplitCity Nvarchar(255)

update housing
set SplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select * from portfolio.dbo.housing

select OwnerAddress
from portfolio.dbo.housing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from portfolio.dbo.housing

alter table housing
add OwnerSplitAddress nvarchar(255)

alter table housing
add OwnerSplitCity nvarchar(255)

alter table housing
add OwnerSplitState nvarchar(255)

update housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

update housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

update housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from portfolio.dbo.housing


---changing Y and N as Yes and No in SoldAsVacant
select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio.dbo.housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from portfolio.dbo.housing

update housing
set SoldAsVacant = 
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


---Remove Duplicates
with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID)row_num
from portfolio.dbo.housing)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress

select *
from portfolio.dbo.housing


---Delete Unused Columns
alter table portfolio.dbo.housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * from portfolio.dbo.housing













-----Extra query for reference from someone else code So, Dont Concentrate here

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM '<address of data>'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=<address of data>', [Sheet1$]);
--GO