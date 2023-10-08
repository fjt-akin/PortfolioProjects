

-- INSPECT YOUR DATA SET

SELECT * FROM PortfolioProject..NashvilleHousing;
----------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(DATE,SaleDate) FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(DATE,SaleDate)

SELECT SalesDateConverted FROM PortfolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT * FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

	-- update the null values
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

--check if it worked
SELECT [UniqueID ],ParcelID,PropertyAddress FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null

----------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)

--Working on the PropertyAddress Column
SELECT PropertyAddress FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing

--check if it worked
SELECT * FROM PortfolioProject..NashvilleHousing

-- Working on the Owner Address Column
SELECT OwnerAddress	 FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as OwnerState
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

--check if it worked
SELECT * FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" Field

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


SELECT
	SoldAsVacant, 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N'  THEN 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacantUpdated
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =  
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N'  THEN 'No'
		ELSE SoldAsVacant
	END

-- recheck to see if it worked
SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


----------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumbs as
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference 
	ORDER BY 
		UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE  FROM RowNumbs
WHERE row_num > 1
--ORDER BY PropertyAddress

--Check if the duplicates are gone

WITH RowNumbs as
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference 
	ORDER BY 
		UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT * FROM RowNumbs
WHERE row_num > 1

----------------------------------------------------------------------------
-- Delete Unused Columns

SELECT * FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SA

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate