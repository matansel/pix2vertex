clear; close all; clc;
%% This script runs an evaluation of the 3d face reconstruction method proposed in
% Unrestricted Facial Geometry Reconstruction Using Image-to-Image Translation
im_file = 'imgs/2327-3.jpg';
img = imread(im_file);
img_size = 512;

%% crop face
FaceDetect = vision.CascadeObjectDetector; 
BB = step(FaceDetect,img);
imsz = size(img);
BB(1,1) = max(1,min(imsz(1),BB(1,1)-BB(1,3)*.2));
BB(1,2) = max(1,min(imsz(2),BB(1,2)-BB(1,4)*.2));
BB(1,3) = max(1,min(imsz(1),BB(1,3)*1.4));
BB(1,4) = max(1,min(imsz(1),BB(1,4)*1.4));
img= imcrop(img,BB(1,:));
img = imresize(img, [img_size img_size]);
figure(1);
subplot(1,3,1);
imshow(img);
title('Cropped Input');
drawnow;

%% Run networks
fprintf('Running Net...');
im_pncc = run_net( img, 'models/pncc_net.t7', im_file(1:end-4));
im_depth = run_net( img, 'models/depth_net.t7', im_file(1:end-4));
fprintf(' Done!\n');

%Visualize Network Result
figure(1);
subplot(1,3,2);
imshow(im_pncc/255);
title('Correspondence');
subplot(1,3,3);
imshow(im_depth(:,:,3)/255);
title('Depth');
drawnow;

%% Apply Deformation and Detail Extraction 
show_figs = true;
[vertex,face,texture] = postprocess(img, im_pncc, im_depth,show_figs);
%Show Result
figure;
sub_p(1) = subplot(1,2,1);
surface_show(face,vertex,[.7 .8 1]);material([.5 .6 .3])
lighting phong;material([.5 .6 .1]);
title('Final Result','Color', 'w');
sub_p(2) = subplot(1,2,2);
surface_show(face,vertex,texture);material([.5 .6 .3])
lighting phong;material([.5 .6 .1]);
title('Textured Final Result','Color', 'w');
linkprop([sub_p(1) sub_p(2)], 'View');
drawnow;