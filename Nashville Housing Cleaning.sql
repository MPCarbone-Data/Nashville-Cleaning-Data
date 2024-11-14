Use [Nashville Housing Data]

Select *
FROM [Nashville Housing Data]..Housing

--Change Sale Date

Select SaleDate,Convert(date,SaleDate)
FROM [Nashville Housing Data]..Housing

Update [Nashville Housing Data]..Housing
Set SaleDate = Convert(date,SaleDate)

Alter Table [Nashville Housing Data]..Housing
ADD SaledateConverted Date;

Update [Nashville Housing Data]..Housing
Set SaleDateConverted = Convert(date,SaleDate)

Select SaleDateConverted,Convert(date,SaleDate)
FROM [Nashville Housing Data]..Housing

--Populate Property Address Data

Select *
From [Nashville Housing Data]..Housing
Order By ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
From Housing a
JOIN [Nashville Housing Data]..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
From Housing a
JOIN [Nashville Housing Data]..Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


--Breaking Address into Individual Columns (Address,City,State)

Select PropertyAddress
FROM Housing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as City
FROM Housing

Alter Table Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Housing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter Table Housing
ADD PropertySplitCity nvarchar(255);

Update Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) 

Select *
FROM Housing



Select OwnerAddress
FROM Housing

Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3)
,PARSENAME(Replace(OwnerAddress,',','.'), 2)
,PARSENAME(Replace(OwnerAddress,',','.'), 1)
From Housing


Alter Table Housing
ADD OwnerSplitAddress Nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table Housing
ADD OwnerSplitCity nvarchar(255);

Update Housing
SEt OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table Housing
ADD OwnerSplitState nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

SELECT *
FROM Housing


--Change Y and N to Yes and NO in "Sold as Vacant Field"

Select Distinct(SoldAsVacant),COunt(SoldasVacant)
FROM Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
FROM Housing

Update Housing
Set SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
END



--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Nashville Housing Data]..Housing
--order by parcelID
)
SELECT *-- DELETE
FROM RowNumCTE
WHERE row_num >1


--Delete Unused Columns

SELECT * 
FROM Housing

ALTER Table Housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate 