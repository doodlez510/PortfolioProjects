/*
Cleaning Data in SQL Queries
*/
Select * 
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate) 

Alter table NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate) 

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	--WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

	
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--Order By ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
ORDER BY 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END

 Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
ORDER BY 2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS( 
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
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
--WHERE row_num >1
)

SELECT *
From RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate