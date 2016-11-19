function [figure_handle,axes_handle]=display_an_image(input_image,optional_figure_name,optional_image_title)
% This routine displays an image and places it in an area of the monitor such that its overlap with other existing figures is minimized.
% If the figure with the name "optional_figure_name" exist then that figure will be used. otherwise a new figure will be generated.
% The advantage of this routine, (over calling image() function), is that the display_overlay function can be called later
% (given the name of the figure) to draw an overlay over the image. Also this routine tries to create an image on the display in a
% position that minimizes the overlap with other images.
if nargin==0 || isempty(input_image)
    return;
end
%% First check to see if a figure with the same name exist
temp_figure_name='';
if exist('optional_figure_name','var') && ischar(optional_figure_name) && ~isempty(optional_figure_name)
    figure_handle=findobj('name',optional_figure_name);
    if ishandle(figure_handle)
        % figure exists. Display the image.
        set(0,'CurrentFigure',figure_handle);
%         figure(figure_handle);
%         clf;
        image_handle=imagesc(input_image);
        set(gca,'DataAspectRatio',[1 1 1]);
        axes_handle=get(image_handle,'parent');
        if ndims(input_image)==2
            colormap 'gray'
        end
        if exist('optional_image_title','var')
            title(optional_image_title,'interpreter','none','Color','r');
        end
        return;
    end
    temp_figure_name=optional_figure_name;
end
% Figure does not exist. create it
% Create a figure such that its figure number is above 1000 and make sure no other figure has the same number.
figure_number=1001;
while ishandle(figure_number)
    figure_number=figure_number+1;
end
figure_handle=figure(figure_number);
set(figure_handle,'Name',temp_figure_name);
set(figure_handle,'NumberTitle','off','DoubleBuffer','on');
image_handle=imagesc(input_image);
set(gca,'DataAspectRatio',[1 1 1]);
axes_handle=get(image_handle,'parent');
if ndims(input_image)==2
    colormap 'gray'
end
if exist('optional_image_title','var')
    title(optional_image_title,'interpreter','none','Color','r');
end
% Find the best position for the figure.
handle_to_all_existing_figures=findobj(0,'type','figure');
index=1;
existing_figures_position=[];
for k=1:length(handle_to_all_existing_figures)
    if(handle_to_all_existing_figures(k)~=figure_handle)
        temp_units=get(handle_to_all_existing_figures(k),'units');
        set(handle_to_all_existing_figures(k),'units','pixels');
        existing_figures_position{index}=get(handle_to_all_existing_figures(k),'OuterPosition');
        set(handle_to_all_existing_figures(k),'units',temp_units);
        index=index+1;
    end
end
screen_rectangle=get(0,'MonitorPositions');
screen_rectangle=screen_rectangle(1,:);
screen_rectangle(4)=screen_rectangle(4)-30;

rec_selected_rectangle=place_rectangle(screen_rectangle,existing_figures_position,get(figure_handle,'OuterPosition'));
% allow for the menu on the top of the figure
set(figure_handle,'OuterPosition',rec_selected_rectangle);
end
