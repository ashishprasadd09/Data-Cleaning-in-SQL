/*

Reading data in SQL Queries

*/

SELECT * 
FROM Project.NashvilleHousing;

---------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS date)
FROM Project.NashvilleHousing;


UPDATE Project.NashvilleHousing
SET SaleDate = CAST(SaleDate AS date);

ALTER TABLE Project.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Project.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS date);

SELECT SaleDateConverted, CAST(SaleDate AS date)
FROM Project.NashvilleHousing; 


-----------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM Project.NashvilleHousing
ORDER BY ParcelID;
WHERE PropertyAddress IS NULL;

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Project.NashvilleHousing A
JOIN Project.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Project.NashvilleHousing A
JOIN Project.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

-----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City and State)

-- Splitting Property Address

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1) ) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+2), LEN(PropertyAddress) ) AS City
FROM Project.NashvilleHousing;


ALTER TABLE Project.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Project.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )


ALTER TABLE Project.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Project.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2 , LEN(PropertyAddress))


Select *
From Project.NashvilleHousing;



-- Splitting Owner Address into (Address, City and State)

Select OwnerAddress
From Project.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project.NashvilleHousing



ALTER TABLE Project.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Project.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Project.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Project.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Project.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Project.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From Project.NashvilleHousing


--------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project.NashvilleHousing;


Update Project.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Project.NashvilleHousing
order by ParcelID
)


-- Look at duplicate rows
	SELECT *
	FROM RowNumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress;

-- Delete duplicate rows 
	DELETE *
	From RowNumCTE
	Where row_num > 1;

-------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From Project.NashvilleHousing


ALTER TABLE Project.Project.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
