use Portfolio

select * from housingdata

/*
Cleaning Data in SQL Queries
*/

-- Standardize Date Format

select SaleDate,CONVERT(date,SaleDate) from housingdata

alter table housingdata Add SaleDateConverted Date;

update housingdata set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted from housingdata



-- Populate Property Address data

Select * From housingdata order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From housingdata a
JOIN housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From housingdata a
JOIN housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress From housingdata

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From housingdata


ALTER TABLE housingdata Add PropertySplitAddress Nvarchar(255);

Update housingdata SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE housingdata Add PropertySplitCity Nvarchar(255);

Update housingdata SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select * From housingdata

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From housingdata

ALTER TABLE housingdata Add OwnerSplitAddress Nvarchar(255);

Update housingdata SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE housingdata Add OwnerSplitCity Nvarchar(255);

Update housingdata SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE housingdata Add OwnerSplitState Nvarchar(255);

Update housingdata SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * From housingdata

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From housingdata
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From housingdata


Update housingdata
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates

WITH cte AS( Select *,ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From housingdata)

Select * From cte Where row_num > 1 Order by PropertyAddress

WITH cte AS( Select *,ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From housingdata)

delete From cte Where row_num > 1


-- Delete Unused Columns

Select * From housingdata

ALTER TABLE housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * From housingdata
