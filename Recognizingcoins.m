clc 
clear all
% List of the images to work on
imageList = {'coinImage.png', 'testCoinImage1.png', 'testCoinImage2.png', 'testCoinImage3.png'};

% Create a menu for image selection
selection = menu('Select an image:', imageList);

% Check if an image was selected
if selection ~= 0
    % Load and display the selected image
    imageName = imageList{selection};
    img = imread(imageName);
    imshow(img);
else
    disp('No image selected.');
end
% Convert the image to binary using a threshold of 0.5
imgBW = imbinarize(img, 0.5);

% Create a disk-shaped structuring element with radius 4
se = strel("disk",4,0);

% Perform morphological opening and closing operations on the binary image
% to remove all the noise present in the image and segment only coins
BW = imopen(imgBW,se);
BW = imclose(BW,se);

% Mask the original image using the binary image
maskedImg = img;
maskedImg(~BW) = 0;

% Detect edges in the masked image using the Laplacian of Gaussian method
imgEdge = edge(maskedImg,"log", [],3,'nothinning');

% Create another disk-shaped structuring element with radius 6
se1 = strel("disk",6,0);

% Perform a morphological closing operation on the edge-detected image
imgEdgeC = imclose(imgEdge,se1);

% Filter regions in the edge-detected image based on area to separate valid and invalid coins
valimg = bwpropfilt(imgEdgeC, 'Area', [4000,12000]);
invalimg = bwpropfilt(imgEdgeC, 'Area', [20,4000]);

% Create another disk-shaped structuring element with radius 10
se2 = strel("disk",10,0);

% Perform a morphological closing operation on the valid coins image
BW2 = imclose(valimg,se2);

% Find circles in the valid coins image and count them
[centers, radii] = imfindcircles(BW2,[30,90]);
valCoin = length(centers);
fprintf('Total number of valid coins is %d\n',valCoin)

% Create another disk-shaped structuring element with radius 40 for invalid
% coins
se3 = strel("disk",40,0);

% Perform a morphological closing operation on the invalid coins image
BW3 = imclose(invalimg,se3);

% Find circles in the invalid coins image and count them
[centers, radii] = imfindcircles(BW3,[30,90]);
invalCoin = length(radii);
fprintf('Total number of invalid coins is %d\n',invalCoin)

% Filter regions in the edge-detected image based on area to separate different types of valid coins
valimg0 = bwpropfilt(imgEdgeC, 'Area', [4000,4500]);
valimg1 = bwpropfilt(imgEdgeC, 'Area', [4501,6000]);
valimg2 = bwpropfilt(imgEdgeC, 'Area', [6001,8000]);
valimg5 = bwpropfilt(imgEdgeC, 'Area', [7500,12000]);

% Find circles in each type of valid coin image and count them
[centers0, radii] = imfindcircles(valimg0,[30,90]);
dimes = length(radii);
[centers1, radii] = imfindcircles(valimg1,[30,90]);
nickels = length(radii);
[centers2, radii] = imfindcircles(valimg2,[30,90]);
Quarters = length(radii);
[centers5, radii] = imfindcircles(valimg5,[45,90]);
cents = length(radii);

% Print out the counts of each type of valid coin
fprintf('There are %d cents, %d Quarters, %d Dimes and %d Nickels in the Image.\n',cents, Quarters, dimes ,nickels)

% Calculate and print out the total cost of valid coins in dollars
totalCost = dimes*0.10 + nickels*0.05 + Quarters*0.25 + cents*0.5;
fprintf('Total cost of valid coins is %0.2f Dollars\n',totalCost)

% Draw bounding boxes around valid and invalid coins in the original image
BWpropsValid = regionprops("table", valimg, "BoundingBox");
ValidRect = insertShape(img, "Rectangle", BWpropsValid.BoundingBox, "color", "green", "LineWidth", 4);
BWpropsInvalid = regionprops("table", invalimg, "BoundingBox");

InvalidRect = insertShape(ValidRect, "Rectangle", BWpropsInvalid.BoundingBox, "color", "red", "LineWidth", 4);
% Display the original image with bounding boxes

imshow(InvalidRect);