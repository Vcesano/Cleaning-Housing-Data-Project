/*
Cleaning data in SQL queries
*/

Select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------

--Standarize Date format

Select SaleDateConverted, CONVERT(date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

Alter table nashvillehousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------

--Populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------

--Breaking out address into individual columns (address, city, state)

Select propertyaddress
from PortfolioProject..NashvilleHousing

select 
substring(propertyaddress, 1,CHARINDEX(',',propertyaddress)-1) as Address
, substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as City
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress=substring(propertyaddress, 1,CHARINDEX(',',propertyaddress)-1)

Alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity=substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select *
from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'), 3)
, PARSENAME(replace(owneraddress,',','.'), 2)
, PARSENAME(replace(owneraddress,',','.'), 1)
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'), 3)

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'), 2)

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState=PARSENAME(replace(owneraddress,',','.'), 1)

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Solda as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
		end

--------------------------------------------------------------------------------------------

--Remove Duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueID
					)  row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num>1

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------

--Delete Unused columns
select *
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

Alter table PortfolioProject..NashvilleHousing
drop column saledate