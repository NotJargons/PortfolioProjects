select *
from nashvillehousing; 

select saledate
from nashvillehousing;

-- Changing the date format to the standard for MYSQL

UPDATE nashvillehousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y'); 

-- Property Address

select *
from nashvillehousing
Where PropertyAddress <> 'Null';

-- Looking for null inputs
 
select *
from nashvillehousing
Where PropertyAddress is null;

-- I noticed that there are 29 rows with null values in the property address field and that two rows can have the same ParcelID, indicating they share similar addresses. 
-- The only difference between them is the UniqueID. Therefore, if one row has a unique ID and a property address, 
-- the other row with the same ParcelID should also have a similar address, which would help clean up the null values.

-- Joining the table to itself
-- If the parcelIDs are the same, but UniqueID isn't

select a.MyUnknownColumn, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
IFNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing as a
JOIN nashvillehousing as b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;


UPDATE nashvillehousing as t1, nashvillehousing as t2 
SET 
	t2.propertyaddress = t1.propertyaddress
 WHERE
	t2.propertyaddress IS NULL
    AND t2.parcelid = t1.parcelid
    AND t1.propertyaddress is not null;
    
-- Seperating the PropertyAddress format into (Address, City)

select propertyaddress
from nashvillehousing;

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM nashvillehousing;

-- Creating a PropertySplitAddress and PropertySplitCity columns on the nashvillehousing table

ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- Working on the OwnerAddress Column

SELECT OwnerAddress
FROM nashvillehousing;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnwerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- SoldAsVacant Column has issues with the values 'Yes' or 'No' but some Values are 'N' or 'Y'
-- Making it inconsistent to use

SELECT SoldAsVacant, Count(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant;

-- Changing all Y to 'Yes' and all N to 'No'

UPDATE nashvillehousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
					END;
SELECT SoldAsVacant FROM nashvillehousing;

-- Removing Duplicate data/cells
-- I removed the duplicates using excel initially. So there are no longer duplicates in this dataset

-- Removing Unused Columns 

ALTER TABLE nashvillehousing
DROP COLUMN TaxDistrict,
DROP OwnerAddress,
DROP PropertyAddress;

SELECT * FROM nashvillehousing;
