/* 

Cleaning Data In SQL Queries

*/


Select * 
from [PortfolioProject]..Nashvillehousing

-----------------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

Select SaleDate, CONVERT(date,saledate)
from [PortfolioProject]..Nashvillehousing

update Nashvillehousing
set SaleDate = CONVERT(date,saledate)

Alter table nashvillehousing
add saledateconverted date;

update Nashvillehousing
set SaleDateconverted = CONVERT(date,saledate)

alter table nashvillehousing 
drop column saledate


-----------------------------------------------------------------------------------------------------------------------------------------

--Populate property address data (fill the property address where property address is null)

Select a.parcelID, b.ParcelID, a.[UniqueID ],a.PropertyAddress, b.[UniqueID ],  isnull(a.propertyaddress,b.PropertyAddress)
from [PortfolioProject]..Nashvillehousing as a
join [PortfolioProject]..Nashvillehousing as b
on a.parcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress,b.PropertyAddress)
from [PortfolioProject]..Nashvillehousing as a
join [PortfolioProject]..Nashvillehousing as b
on a.parcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select * from Nashvillehousing
where PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into indivisual columns (address, city, state)

select propertyaddress
from nashvillehousing


select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
--here we have to select the value wich is before coma, so ||substring (PropertyAddress,1 || is the starting point of the string 
--and ||CHARINDEX(',',PropertyAddress)|| is the end point of the string where as ||-1|| is use to remove the last value from the string 
--CHARINDEX(',',PropertyAddress)
-- if we only select||CHARINDEX(',',PropertyAddress)|| it will give us number of where coma is allocated so charindex is number

SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress)) as Address
from Nashvillehousing

alter table nashvillehousing
add SplitPropertyAddress nvarchar(255)

update Nashvillehousing
set SplitPropertyAddress =SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertyAddressCity nvarchar(255)

update Nashvillehousing
set PropertyAddressCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))


--Now we going to use more easy technique than Substring (we have to split the owner address)

select
PARSENAME (replace(owneraddress,',','.'),3),
PARSENAME (replace(owneraddress,',','.'),2),
PARSENAME (replace(owneraddress,',','.'),1)
from Nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

update Nashvillehousing
set OwnerSplitAddress = PARSENAME (replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update Nashvillehousing
set OwnerSplitCity = PARSENAME (replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update Nashvillehousing
set OwnerSplitState = PARSENAME (replace(owneraddress,',','.'),1)

Select * from Nashvillehousing


-----------------------------------------------------------------------------------------------------------------------------------------

--change Y and N to yes and no 'sold as vacant ' field

select soldasvacant,
case when soldasvacant ='y' then 'Yes'
     when soldasvacant = 'n' then 'No'
	 else soldasvacant
End
from Nashvillehousing

update Nashvillehousing
set SoldAsVacant = case when soldasvacant ='y' then 'Yes'
     when soldasvacant = 'n' then 'No'
	 else soldasvacant
End
from Nashvillehousing



-----------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY  ParcelId,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	order by UniqueID
					) row_num

	from Nashvillehousing
	--order by parcelid
)

DELETE * from RowNumCTE
where row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------------

--Delete Useless Columns 

Alter table Nashvillehousing
Drop Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict


















