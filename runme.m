clear; close all; clc;
% This script runs an evaluation of the 3d face reconstruction method proposed in
% Unrestricted Facial Geometry Reconstruction Using Image-to-Image Translation
im_file = 'imgs/2327-3.jpg';
img = imread(im_file);
img_size = 512;
show_figs = true;

% Crop input image
FaceDetect = vision.CascadeObjectDetector;
BB = step(FaceDetect,img);
imsz = size(img);

BB(1,1) = max(1,min(imsz(1),BB(1,1)-BB(1,3)*.1));
BB(1,2) = max(1,min(imsz(2),BB(1,2)-BB(1,4)*.1));
BB(1,3) = max(1,min(imsz(1),BB(1,3)*1.3));
BB(1,4) = max(1,min(imsz(1),BB(1,4)*1.3));
img= imcrop(img,BB(1,:));
img = imresize(img, [img_size img_size]);

if show_figs
    figure(1);
    subplot(1,3,1);
    imshow(img);
    title('Cropped Input');
    drawnow;
end

%% Run networks
fprintf('Running Net...');
im_pncc = run_net( img, 'models/pncc_net_float.t7', im_file(1:end-4));
im_depth = run_net( img, 'models/depth_net_float.t7', im_file(1:end-4));
fprintf(' Done!\n');

% Visualize Network Result
if show_figs
    figure(1);
    subplot(1,3,2);
    imshow(im_pncc/255);
    title('Correspondence');
    subplot(1,3,3);
    imshow(im_depth(:,:,3)/255);
    title('Depth');
    drawnow;
end

%% Process network result (scale and mask)

[ Z, pipeline_args ] = raw2depth( img, im_pncc, im_depth );

if show_figs
    figure;
    set(gcf,'color','k');
    sub_1 = subplot(1,2,1);
    h=surf(fliplr(Z),fliplr(img));
    set(h,'LineStyle','none')
    axis equal
    grid off
    box on
    axis off
    view(-180,90)
    light('Position',[0 0 1]);lighting phong;material([.5 .6 .1]);
    title('Textured Network Result','Color', 'w');
    
    sub_2 = subplot(1,2,2);
    h=surf(fliplr(Z));
    set(h,'FaceColor',[.7 .8 1]);
    set(h,'LineStyle','none')
    axis equal
    grid off
    box on
    axis off
    view(-180,90)
    light('Position',[0 0 1]);lighting phong;material([.5 .6 .1]);
    title('Network Result','Color', 'w');
    
    linkprop([sub_1 sub_2], 'View');
end

%% Apply rigid deformation
[mesh_result, pipeline_args] = depth2mesh( pipeline_args, show_figs );

if show_figs
    figure;
    sub_p(1) = subplot(1,2,1);
    surface_show(mesh_result.face,mesh_result.vertex,[.7 .8 1]);material([.5 .6 .3])
    lighting phong;material([.5 .6 .1]);
    title('Mesh Result','Color', 'w');
    sub_p(2) = subplot(1,2,2);
    surface_show(mesh_result.face,mesh_result.vertex,mesh_result.texture);material([.5 .6 .3])
    lighting phong;material([.5 .6 .1]);
    title('Textured Mesh Result','Color', 'w');
    linkprop([sub_p(1) sub_p(2)], 'View');
    drawnow;
end

%% Apply detail extraction

[ fine_result ] = mesh2fine(pipeline_args);

if show_figs
    figure;
    sub_p(1) = subplot(1,2,1);
    surface_show(fine_result.face,fine_result.vertex,[.7 .8 1]);material([.5 .6 .3])
    lighting phong;material([.5 .6 .1]);
    title('Final Result','Color', 'w');
    sub_p(2) = subplot(1,2,2);
    surface_show(fine_result.face,fine_result.vertex,fine_result.texture);material([.5 .6 .3])
    lighting phong;material([.5 .6 .1]);
    title('Textured Final Result','Color', 'w');
    linkprop([sub_p(1) sub_p(2)], 'View');
    drawnow;
end