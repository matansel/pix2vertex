function [ vis_Z, pipeline_args ] = raw2depth( img, im_pncc, im_depth )
%Apply preprocessing to the raw network result

pipeline_args = {};

im_depth(im_depth<10 & im_depth>-10) = 0;
im_pncc(im_pncc<10 & im_pncc>-10) = 0;

load models/template;
Sm = [template.X template.Y template.Z];
%Get points from network
net_X = im_depth(:,:,1)*(max(Sm(:,1))-min(Sm(:,1)))/255+min(Sm(:,1));
net_Y = im_depth(:,:,2)*(max(Sm(:,2))-min(Sm(:,2)))/255+min(Sm(:,2));
net_Z = im_depth(:,:,3)*(max(Sm(:,3))-min(Sm(:,3)))/255+min(Sm(:,3));

mask = all(im_depth,3).*all(im_pncc,3);
%mask = ~(all(im_depth<15 & im_depth>-15,3).*all(im_pncc<15 & im_pncc>-15,3));
inds = find(mask); %Look only on existing indices

%Define uniform grid
X = repmat(linspace(-1,1,size(im_depth,1)),size(im_depth,2),1);
Y = repmat(linspace(1,-1,size(im_depth,2)),size(im_depth,1),1)';

%Normalize grid according to the network result
X = (X-mean(X(inds)))/std(X(inds))*std(net_X(inds))+mean(net_X(inds));
Y = (Y-mean(Y(inds)))/std(Y(inds))*std(net_Y(inds))+mean(net_Y(inds));
Z = net_Z;

f=1/(X(1,2)-X(1,1));

%Calculate mask
se = strel('disk',3);
mask = imerode(mask,se);
BW = logical(mask); %%// Coins photo from MATLAB Library
[L, num] = bwlabel(BW, 8);
count_pixels_per_obj = sum(bsxfun(@eq,L(:),1:num));
[~,ind] = max(count_pixels_per_obj);
mask = (L==ind);


vis_Z = Z*f;
vis_Z(~mask) = NaN;

pipeline_args.template = template;
pipeline_args.img = img;
pipeline_args.im_pncc = im_pncc;
pipeline_args.X = X;
pipeline_args.Y = Y;
pipeline_args.Z = Z;
pipeline_args.mask = mask;

end

