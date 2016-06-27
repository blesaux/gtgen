%% gtgen.m
% A function for generating gound-truth masks for images
%
% Copyright (C) <2015> Bertrand Le Saux & Adrien Lagrange
% Comments to: bertrand.le_saux@onera.fr
%
% This program is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% If used for published research work, please cite:
% Adrien Lagrange, Bertrand Le Saux, Anne Beaupere, Alexandre Boulch, 
% Adrien Chan-Hon-Tong, Stéphane Herbin, Hicham Randrianarivo, Marin
% Ferecatu, "Benchmarking classification of Earth-observation data: 
% from learning explicit features to convolutional networks", Proc. of
% IGARSS 2015.

function [mask] = paintMask(ima, mask)

if nargin <2
    mask = zeros( size(ima,1), size(ima,2) );
end
if size(mask,1)~=size(ima,1) && size(mask,2)~=size(ima,2)
    error('Existing mask of wrong dimensions. Exiting...');
    return;
end
maskedim = ima;%imfuse( ima, mask,'blend','Scaling','joint');
tmp = maskedim(:,:,2);
tmp(mask==1)=255;
maskedim(:,:,2)=tmp;

% creation of buttons
h1 = uicontrol('Style', 'pushbutton', ...
    'Position', [100 100 200 50], ...
    'String','Export mask',...
    'Callback', @export); %#ok<*NASGU>
h4 = uicontrol('Style', 'text', ...
    'Position', [100 250 200 50], ...
    'String','Brush Size (slide to change bruch size, left click on image to paint, right click to erase...',...
    'Tag','txtErase');
h5 = uicontrol('Style', 'slider', ...
     'Position', [100 300 200 50], ...
     'Value',0,...
     'Max',200,...
     'Min',0,...
     'Tag','sizeErase',...
     'SliderStep',[0.2  0.2]);
h10 = uicontrol('Style', 'pushbutton', ...
     'Position', [80 400 118 50], ...
     'String','Free-hand draw',...
     'Callback', @drawOrErase );
h11 = uicontrol('Style', 'pushbutton', ...
     'Position', [80 600 66 50], ...
     'String','Zoom in',...
     'Callback', @zoomIn);
h12 = uicontrol('Style', 'pushbutton', ...
     'Position', [166 600 66 50], ...
     'String','Zoom out',...
     'Callback', @zoomOut);
h13 = uicontrol('Style', 'pushbutton', ...
     'Position', [254 600 66 50], ...
     'String','pan',...
     'Callback', @panToggle); 

h14 = uicontrol('Style', 'pushbutton', ...
     'Position', [80 500 118 50], ...
     'String','Polygon draw',...
     'Callback', @drawOrErase);
h15 = uicontrol('Style', 'pushbutton', ...
     'Position', [202 500 118 50], ...
     'String','Polygon erase',...
     'Callback', @drawOrErase);
h16 = uicontrol('Style', 'pushbutton', ...
     'Position', [202 400 118 50], ...
     'String','Free-hand erase',...
     'Callback', @drawOrErase);
 
h22 = uicontrol('Style', 'checkbox', ...
     'Position', [80 800 66 50], ...
     'String','Mask',...
     'Value',1,...% checked box
     'Tag','h22',...
     'Callback', @switchMask);
 
 
imshow(maskedim)

% set(gca, 'xlimmode','manual',...
% 'ylimmode','manual',...
% 'zlimmode','manual',...
% 'climmode','manual',...
% 'alimmode','manual');

set(gcf,'Pointer','arrow');
set(gcf,'WindowButtonDownFcn',@startmovit);

% Unpack gui object
gui = get(gcf,'UserData');
% Store gui object
set(gcf,'UserData',{gui;mask;maskedim;ima});




function startmovit(src,evnt) %#ok<INUSD>

% Unpack gui object
temp = get(gcf,'UserData');
gui=temp{1};
mask=temp{2};
maskedim=temp{3};
ima=temp{4};

% Get brush size
hr=findobj(gcf,'Style','Slider','-and','Tag','sizeErase');
r=get(hr,'Value');

% Get cursor state and position
pos = get(gca,'CurrentPoint');
flag_btn = get(src,'SelectionType');
disp(flag_btn);

% Update mask and masked image
[m,n]=size(maskedim);
cm=round(pos(1,2));
cn=round(pos(1,1));
if strcmp(flag_btn,'normal')
    mask(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n))=1;
    maskedim(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2)=255;
elseif strcmp(flag_btn,'alt')
    mask(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n))=0;
    maskedim(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2)=ima(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2);
end
% Check 
%sum(find(mask(:)))

% Re-draw
v=axis;
imshow(maskedim)
axis(v)

% Initialize callback functions
gui.currenthandle = src;
thisfig = gcbf();
set(thisfig,'WindowButtonMotionFcn',@movit);
set(thisfig,'WindowButtonUpFcn',@stopmovit);

% Store gui object
set(gcf,'UserData',{gui;mask;maskedim;ima});


%% move the cursor
function movit(src,evnt) %#ok<INUSD>
% Unpack gui object
ud = get(gcf,'UserData');
mask=ud{2};
maskedim=ud{3};
ima=ud{4};

% Get cursor state and position
flag_btn=get(src,'SelectionType');
try
if isequal(gui.startpoint,[])
    return
end
catch
end
pos = get(gca,'CurrentPoint');
% disp(flag_btn);

% Get brush size
hr=findobj(gcf,'Style','Slider','-and','Tag','sizeErase');
r=get(hr,'Value');

% Update mask and masked image
[m,n]=size(maskedim);
cm=round(pos(1,2));
cn=round(pos(1,1));
if strcmp(flag_btn,'normal')% grow mask pixels
    mask(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n))=1;
    maskedim(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2)=255;
elseif strcmp(flag_btn,'alt')% delete mask pixels
    mask(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n))=0;
    maskedim(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2)=ima(max(cm-r,1):min(cm+r,m),max(cn-r,1):min(cn+r,n),2);
end

% Check 
sum(find(mask(:)))

% Re-draw
v=axis;
imshow(maskedim)
axis(v)
 
% Store gui object
ud{2}=mask;
ud{3}=maskedim;% ima is not modified..
set(gcf,'UserData',ud);

%% relapse button...
function stopmovit(src,evnt) %#ok<INUSD>
% Clean up the evidence ...
thisfig = gcbf();
ud = get(gcf,'UserData'); 
 
set(thisfig,'WindowButtonUpFcn','');
set(thisfig,'WindowButtonMotionFcn','');

set(gcf,'UserData',ud);


%% freehand drawing
function drawOrErase(src,evnt) %#ok<INUSD>

% get handler
h_drawfree   = findobj(gcf,'String','Free-hand draw');
h_erasefree  = findobj(gcf,'String','Free-hand erase');
h_drawpoly   = findobj(gcf,'String','Polygon draw');
h_erasepoly  = findobj(gcf,'String','Polygon erase');

% Unpack gui object
ud = get(gcf,'UserData');
mask=ud{2};
maskedim=ud{3};
ima=ud{4};

% disable pixel brushin'
set(gcf,'WindowButtonDownFcn','');

if src == h_drawfree || src == h_erasefree
    hFH = imfreehand();
elseif src == h_drawpoly || src == h_erasepoly
    hFH = impoly();
end

% Create a binary image ("mask") from the ROI object.
binaryImage = hFH.createMask();
%xy = hFH.getPosition;

% Update mask and masked image
[~,n]=size(maskedim);


% write mask
if src == h_drawfree || src == h_drawpoly
    mask(binaryImage)=1;
    tmp=maskedim(:,:,2);
    tmp(binaryImage)=255;
    maskedim(:,:,2)=tmp;
% erase mask    
elseif src == h_erasefree || src == h_erasepoly
    mask(binaryImage)=0;
    tmp=maskedim(:,:,2);
    tmp2=ima(:,:,2);
    tmp(binaryImage)=tmp2(binaryImage);
    maskedim(:,:,2)=tmp;
end

% Re-draw
v=axis;
imshow(maskedim)
axis(v)

% re-enable pixel selection with the brush
set(gcf,'WindowButtonDownFcn',@startmovit);

% Store gui object
ud{2}=mask;
ud{3}=maskedim;% ima is not modified..
set(gcf,'UserData',ud);


 
%% zoom in
function zoomIn(src,evnt) %#ok<INUSD>

zoom(2);


%% zoom out
function zoomOut(src,evnt) %#ok<INUSD>

zoom(0.5);


%% toggle pan mode
function panToggle(src,evnt) %#ok<INUSD>

pan;

% something to do for coming back ?


%% switch mask
function switchMask(src,evnt) %#ok<INUSD>

% Unpack gui object
temp = get(gcf,'UserData');
mask=temp{2};
maskedim=temp{3};
ima=temp{4};

hr=findobj(gcf,'Style','checkbox','-and','Tag','h22');
valueMask=get(hr,'Value');

if valueMask==0
    maskedim = ima;
else
    bi = (mask>0.5);
    size(bi);
    
    tmp=maskedim(:,:,2);
    tmp(bi)=255;
    maskedim(:,:,2)=tmp;
end
% Re-draw
v=axis;
imshow(maskedim)
axis(v);

% Store gui object
temp{3}=maskedim;
set(gcf,'UserData',temp);



 
%% export the mask
function export(src,evnt) %#ok<INUSD>
% Unpack gui object
temp = get(gcf,'UserData');

mask=temp{2};
sum(find(mask(:)))

save ('mask.mat','mask');
