function omap = overlayHeatmap( backImage , heatmap, colorfun )

if ( strcmp(class(backImage),'char') == 1 ) backImage = imread(backImage); end % if background image is a filename, read in the image
if ( strcmp(class(backImage),'uint8') == 1 ) backImage = double(backImage)/255; end % rescale 8 bit file to 0-1 double

heatMapSize = size(heatmap); % size of the heat map
imSize = size(backImage); % size of the background image 

if ( (heatMapSize(1)~=imSize(1)) || (heatMapSize(2)~=imSize(2)) ) % if heatmap and image are different sizes
  heatmap = imresize( heatmap , [ imSize(1) imSize(2) ] , 'bicubic' ); % rescale the heatmap to match the image size
end
heatmap(heatmap<0)=0; % catch any negative from imresize

if ( size(backImage,3) == 1 ) % if background image is grayscale
  backImage = repmat(backImage,[1 1 3]); % scale up to rgb layer
end
  
if ( nargin == 2 ) % no color function specified 
    colorfun = 'jet'; % use default jet
end
colorfunc = eval(sprintf('%s(50)',colorfun)); % compute 256*3 look up table

heatmap = double(heatmap) / max(heatmap(:)); % % scale heatmap to max 1
omap = 0.8*(1-repmat(heatmap.^0.8,[1 1 3])).*double(backImage)/max(double(backImage(:))) + repmat(heatmap.^0.8,[1 1 3]).* shiftdim(reshape( interp2(1:3,1:50,colorfunc,1:3,1+49*reshape( heatmap , [ prod(size(heatmap))  1 ] ))',[ 3 size(heatmap) ]),1);
omap = real(omap);

