function h = surface_show(varargin)
if nargin ==1;
    tri = varargin{1}.tri;
    if isfield(varargin{1},'V')
        x2 = varargin{1}.V(:,1);
        y2 = varargin{1}.V(:,2);
        z2 = varargin{1}.V(:,3);
    else
        x2 = varargin{1}.X;
        y2 = varargin{1}.Y;
        z2 = varargin{1}.Z;
    end;
    if isfield(varargin{1},'I');
        I = varargin{1}.I;
    end;
elseif nargin==2
    tri = varargin{1};
    x2 = varargin{2}(:,1);
    y2 = varargin{2}(:,2);
    z2 = varargin{2}(:,3);
elseif nargin==3
    tri = varargin{1};
    x2 = varargin{2}(:,1);
    y2 = varargin{2}(:,2);
    z2 = varargin{2}(:,3);
    I = varargin{3};
elseif nargin==4
    tri = varargin{1};
    x2 = varargin{2};
    y2 = varargin{3};
    z2 = varargin{4};
elseif nargin==5
    tri = varargin{1};
    x2 = varargin{2};
    y2 = varargin{3};
    z2 = varargin{4};
    I = varargin{5};
end;

if ~exist('I');
    h = trisurf(tri,x2,y2,z2);
    shading interp;
    colormap gray;
else
    if size(I,1)==1
        h=trisurf(tri,x2,y2,z2);
        shading interp;
        set(h,'FaceColor',I);
    else
        if size(I,2)==3;
            
            %I = I-min(min(I));
            %I = (double(I)./double(max(max(I))))*255;
            I(I<0) = 0;
            I(I>255) = 255;
            C=double(I)/255;
            colormap(C);
            h = trisurf(tri,x2,y2,z2,1:size(x2,1),'edgecolor','none');%,'Visible','off');
            %lighting phong;
            shading flat;
        else
            h = trisurf(tri,x2,y2,z2,I);
            shading interp;
            colormap jet;
        end;
    end
end;
axis equal;
set(gcf,'color',[0 0 0]);
axis off;
grid off;
%cameratoolbar;
set(gca,'CameraViewAngleMode','manual');
camtarget([0 0 0]);
%camup([0 1 0]);
campos([0 0 14]);
camproj('perspective');
light('Position',[0 0 1]);lighting phong;material dull

end