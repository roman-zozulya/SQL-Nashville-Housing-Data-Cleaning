/*
Cleaning Data in SQL Queries
*/

--------------------------------------------------------------------

--Standartize Date Format


SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing

--create column for SaleDate converted
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

--updating data in SaleDateConverted 
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)
-------------------------------------------------------------------------

--Populate Property Address data


SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--getting PropertyAddress using ParcelID and populating NULL values
SELECT a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID,
    b.PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--updating the table
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)


--splitting PropertyAddress on address and city using SUBSTRING
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

--updating table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--getting Address, City, State from OwnerAdress using PARSENAME
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
FROM NashvilleHousing


--updating the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field


SELECT distinct(SoldAsVacant), 
    COUNT(SoldAsVacant)
from NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--replacing values
SELECT SoldAsVacant, 
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM NashvilleHousing


--updating table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END

-----------------------------------------------------------------------------------------

--Remove Duplicates

--partition by the fields with key values of each sale (non unique values) and order by UniqueID field which is unique one
WITH row_num_duplicates AS
    (SELECT *, ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                    PropertyAddress, 
                    SalePrice, 
                    SaleDate, 
                    LegalReference
        ORDER BY UniqueID
        ) row_num
    FROM NashvilleHousing)

--checking result
-- SELECT *
-- FROM row_num_duplicates
-- WHERE row_num > 1
-- ORDER BY PropertyAddress

--deleting duplicates
DELETE
FROM row_num_duplicates
WHERE row_num > 1
------------------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT *
FROM NashvilleHousing

--updating the table
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress