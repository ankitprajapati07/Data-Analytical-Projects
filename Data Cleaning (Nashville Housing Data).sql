/*
Cleaning the Data(Nashville_Housing) 
*/


Select *
From HousingData.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, 
       CONVERT(Date,SaleDate)

From HousingData.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From HousingData.dbo.NashvilleHousing
order by ParcelID



Select a.ParcelID, 
       a.PropertyAddress, 
	   b.ParcelID, 
	   b.PropertyAddress, 
	   ISNULL(a.PropertyAddress,b.PropertyAddress)

From HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)

From HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- <1> Split Property_Address : 


Select PropertyAddress
From HousingData.dbo.NashvilleHousing


SELECT
        SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From HousingData.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From HousingData.dbo.NashvilleHousing



--<2> Split Owner_Address : --------------------------



Select OwnerAddress
From HousingData.dbo.NashvilleHousing


Select
        PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
        PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
        PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

From HousingData.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From HousingData.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change 'Y' and 'N' To 'Yes' and 'No' in "Sold as Vacant" field


Select Distinct(SoldAsVacant), 
       Count(SoldAsVacant)

From HousingData.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant,
       CASE When SoldAsVacant = 'Y' THEN 'Yes'
	        When SoldAsVacant = 'N' THEN 'No'
	        ELSE SoldAsVacant
	        END
From HousingData.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (

Select *,
	   ROW_NUMBER() OVER 
	   (PARTITION BY ParcelID,
				     PropertyAddress,
				     SalePrice,
				     SaleDate,
				     LegalReference
				     ORDER BY UniqueID) row_num

From HousingData.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From HousingData.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From HousingData.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
