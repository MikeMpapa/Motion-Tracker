function [output_figure_handle,varargout]=display_and_place_a_figure(varargin)
% This routine creates and displays a figure.
% Input Arguments:
% figureName,figureHandle,figurePosition,figurePlacementFlag
% If the figure with the name "figureName" exist then that figure will be used and its handle will be returned. No new
% figure will be created in this case (notice that the figureHandle will be irelevant in this case).
% If figureHandle is empty or if it is not a proper figure handle, then this routine creates a new figure.

% figurePlacementFlag=1    Force the placement of the figure everytime
% figurePlacementFlag=0    Do not place the figure
% figurePlacementFlag=[]   (default) Force the placement of the figure only if it does not exist (when it is created).

% figurePosition = 'north', 'south', ...         Move the figure to specified location
% figurePosition=[x,y,width, height]    Position the figure according to the 'position' property
% figurePosition= []    Position the figure such that its overlap with other existing figures is minimized.
%

% number_of_subplots = n Create N subplots (default=1
% Note: if the figure already exists, then the number_of_subplots argument
% is ignored. This means that the number of subplots can not be changed
% after the figure is created.

% Output_arguments:
% If the number_of_subplots =1 then this function only returns output_figure_handle
% if the number_of_subplots > 1 then this function returns
% output_figure_handle and array_of_subplot_handles. Each element in the array_of_subplot_handles
% contains the handles to a subplot.
defaults ={...
    'figureName','',...
    'figureHandle', [],...
    'figurePosition', [],...
    'figurePlacementFlag',[],...
    'number_of_subplots',1};
%                 'create_default_frames',false};
%             [obj.name,obj.parentAxes,create_default_frames] = process_arguments(varargin,defaults);
[figureName,figureHandle,figurePosition,figurePlacementFlag,number_of_subplots] = process_arguments(varargin,defaults);



%% First check to see if a figure with the same name exist
temp_figure_name='';
figure_exist_flag=0;
if ischar(figureName) && ~isempty(figureName)
    %  figureName is passed (and valid)
    output_figure_handle=findobj('name',figureName);
    if isempty(output_figure_handle)
        %  figureName is passed (and valid) but a figure with that name does not exist
        % check to see if the figureHandle is valid
        if ~isempty(figureHandle) && ishandle(figureHandle)
            % figureHandle is valid.
            output_figure_handle=ancestor(figureHandle,'figure');
            if isempty(figurePlacementFlag)
                figurePlacementFlag=0;
            end
        else
            % Figure with figureName does not exist and  figureHandle is not valid. Create a new figure,
            % Create a figure such that its figure number is above 1000 and make sure no other figure has the same number.
            figure_number=1001;
            while ishandle(figure_number)
                figure_number=figure_number+1;
            end
            output_figure_handle=figure(figure_number);
            if isempty(figurePlacementFlag)
                figurePlacementFlag=1;
            end
        end
    end
    set(output_figure_handle,'Name',figureName);
    set(output_figure_handle,'NumberTitle','off','DoubleBuffer','on');
    figure(output_figure_handle);
else
    %  figureName is not passed, or it is invalid
    if ~isempty(figureHandle) && ishandle(figureHandle)
        % figureHandle is valid.
        output_figure_handle=figureHandle;
        if isempty(figurePlacementFlag)
            figurePlacementFlag=0;
        end
    else
        % figureName does not exist and  figureHandle is not valid. Create a new figure,
        % Create a figure such that its figure number is above 1000 and make sure no other figure has the same number.
        figure_number=1001;
        while ishandle(figure_number)
            figure_number=figure_number+1;
        end
        output_figure_handle=figure(figure_number);
        if isempty(figurePlacementFlag)
            figurePlacementFlag=1;
        end
    end
    set(output_figure_handle,'NumberTitle','off','DoubleBuffer','on');
    figure(output_figure_handle);
end
if figurePlacementFlag
    if isempty(figurePosition)
        place_fig()
    elseif ischar(figurePosition)
        movegui(output_figure_handle,figurePosition)
    elseif isnumeric(figurePosition) && (length(figurePosition)==4)
        set(output_figure_handle,'position',figurePosition);
    end
end
%             if number_of_subplots>1
% Create subplots
clf(output_figure_handle);
number_horizontal_subplots=ceil(sqrt(number_of_subplots));
number_vertical_subplots=ceil(number_of_subplots/number_horizontal_subplots);
for subplot_index=1:number_of_subplots
    array_of_subplot_handles(subplot_index)=subplot(number_vertical_subplots,number_horizontal_subplots,subplot_index);
end
varargout{1}=array_of_subplot_handles;
%             end

    function place_fig()
        % Find the best position for the figure.
        handle_to_all_existing_figures=findobj(0,'type','figure');
        index=1;
        existing_figures_position=[];
        for k=1:length(handle_to_all_existing_figures)
            if(handle_to_all_existing_figures(k)~=output_figure_handle)
                temp_units=get(handle_to_all_existing_figures(k),'units');
                set(handle_to_all_existing_figures(k),'units','pixels');
                existing_figures_position{index}=get(handle_to_all_existing_figures(k),'OuterPosition');
                set(handle_to_all_existing_figures(k),'units',temp_units);
                index=index+1;
            end
        end
        %         screen_rectangle=get(0,'MonitorPositions');
        %         screen_rectangle=screen_rectangle(1,:);
        %         screen_rectangle(4)=screen_rectangle(4)-30;
        screen_rectangle=get( 0, 'ScreenSize' );
        screen_rectangle(4)=screen_rectangle(4)-30;
        rec_selected_rectangle=place_rectangle(screen_rectangle,existing_figures_position,get(output_figure_handle,'OuterPosition'));
        % allow for the menu on the top of the figure
        set(output_figure_handle,'OuterPosition',rec_selected_rectangle);
    end
end
