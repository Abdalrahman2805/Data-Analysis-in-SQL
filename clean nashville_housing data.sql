SET SQL_SAFE_UPDATES = 0;

SELECT * 
FROM housing.nashville_housing;

-- Standrize Data format
SELECT SaleDate
FROM housing.nashville_housing;

update housing.nashville_housing
set SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y'); -- convert(Date,SaleDate);

-- Address data
SELECT PropertyAddress
FROM housing.nashville_housing
where PropertyAddress is null;

select h1.ParcelID, h1.PropertyAddress, h2.ParcelID, h2.PropertyAddress
FROM housing.nashville_housing h1 
join housing.nashville_housing h2
on h1.ParcelID = h2.ParcelID
where h1.UniqueID <> h2.UniqueID;

update  h1 
set PropertyAddress = isnull(h1.PropertyAddress,h2.PropertyAddress)
FROM housing.nashville_housing h1 
join housing.nashville_housing h2 
on h1.ParcelID = h2.ParcelID
and h1.UniqueID <> h2.UniqueID
where h1.PropertyAddress is null;

-- Breaking out address into columns
SELECT PropertyAddress, PropertyStreet, PropertyCity
FROM housing.nashville_housing;

alter table housing.nashville_housing
add PropertyStreet nvarchar(255);

update housing.nashville_housing
set PropertyStreet = SUBSTRING_INDEX(PropertyAddress, ', ', 1);

alter table housing.nashville_housing
add PropertyCity nvarchar(255);

update housing.nashville_housing
set PropertyCity = SUBSTRING_INDEX(PropertyAddress, ', ', -1);

SELECT OwnerAddress, 
	substring_index(OwnerAddress, ',', 1),
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', -2), ', ', 1) AS City,
    substring_index(OwnerAddress, ',', -1)
FROM housing.nashville_housing;

alter table housing.nashville_housing
add OwnerStreet nvarchar(255);

update housing.nashville_housing
set OwnerStreet = SUBSTRING_INDEX(OwnerAddress, ', ', 1);

alter table housing.nashville_housing
add OwnerCity nvarchar(255);

update housing.nashville_housing
set OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', -2), ', ', 1);

alter table housing.nashville_housing
add OwnerState nvarchar(255);

update housing.nashville_housing
set OwnerState = SUBSTRING_INDEX(OwnerAddress, ', ', -1);

SELECT *
FROM housing.nashville_housing;


-- change y and n to yes and no in sold as vacant
SELECT distinct(SoldAsVacant)
FROM housing.nashville_housing;

update housing.nashville_housing
set SoldAsVacant = 'Yes' where  SoldAsVacant = 'Y';

update housing.nashville_housing
set SoldAsVacant = 'No' where  SoldAsVacant = 'N';

update housing.nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'Not' 
    else SoldAsVacant end;
    

-- Remove Duplicates
with duplicates as(
select *,
Row_number() over(
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    order by UniqueID) as roe
from housing.nashville_housing
)
delete t
from housing.nashville_housing t
join duplicates
on t.UniqueID = duplicates.UniqueID
where duplicates.roe>1	;

alter table housing.nashville_housing
drop column PropertyAddress;
alter table housing.nashville_housing
drop column OwnerAddress;

select *
from housing.nashville_housing
