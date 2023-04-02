--Standardize the saledate column

select saledate , cast(saledate as date) as Sale_Date

--update Nashville
--set SaleDate = cast(saledate as date) as Sale_Date 
--didn't work

alter table nashville
add Sale_Date date;

update Nashville
set Sale_Date = cast(saledate as date)

select Sale_date
from Nashville





--populate property address date
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , isnull(a.PropertyAddress , b.PropertyAddress)
from Nashville a
join Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

--update the column
update a
set PropertyAddress = isnull(a.PropertyAddress , b.PropertyAddress)
from Nashville a
join Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

select *
from Nashville






--breaking out ProperttyAddress into individual columns (Address , city , state)

select
substring(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1)
,SUBSTRING(PropertyAddress , CHARINDEX(',' , PropertyAddress)  +1 , len(PropertyAddress))
from Nashville


alter table nashville
add Property_Address nvarchar(255);
update Nashville
set Property_Address = substring(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress) -1)

alter table nashville
add Property_City nvarchar(255);
update nashville
set Property_City = SUBSTRING(PropertyAddress , CHARINDEX(',' , PropertyAddress)  +1 , len(PropertyAddress))

select Property_Address, Property_City
from nashville







--partitioning owner address

select
parsename(replace(OwnerAddress , ',' , '.') , 3),
parsename(replace(OwnerAddress , ',' , '.') , 2),
parsename(replace(OwnerAddress , ',' , '.') , 1)
from nashville


alter table nashville
add Owner_Address nvarchar(255);
update nashville
set Owner_Address = parsename(replace(OwnerAddress, ',' , '.') ,3)

alter table nashville
add Owner_City nvarchar(255);
update nashville
set Owner_City = parsename(replace(OwnerAddress, ',' , '.') ,2)

alter table nashville
add Owner_State nvarchar(255);
update nashville
set Owner_State = parsename(replace(OwnerAddress, ',' , '.') ,1)

select Owner_Address , Owner_City , Owner_State
from nashville






--change y and n to yes and no in 'sold as vacant'

select distinct(soldasvacant) , count(soldasvacant)
from Nashville
group by SoldAsVacant


select soldasvacant,
case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else  soldasvacant
end
from Nashville


update nashville
set SoldAsVacant = case
when soldasvacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from nashville

select distinct(soldasvacant) , count(soldasvacant)
from Nashville
group by SoldAsVacant






--duplicate data

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by
		ParcelID, 
		propertyaddress,
		saledate,
		saleprice,
		legalreference
order by UniqueID ) as row_num
from nashville)
--order by ParcelID
delete
from RowNumCTE
where row_num > 1





--delete unused columns

alter table nashville
drop column saledate, taxdistrict, owneraddress , propertyaddress
