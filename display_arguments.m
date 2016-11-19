function display_arguments()
% Farhad Kamangar
% 2012_12_12
[calling_function_name_structure,workspace_index]=dbstack;
% if size(calling_function_name_structure,1)>2;
%     % The parent function was not called from the Matlab workspace. i.e. it was called from another function. There is
%     % no need to set the parameters automatically
%     return;
% end
all_parameters_are_saved_flag=1;
% parameter_gui_was_called_by_itself_flag=0;
call_depth_level= size(calling_function_name_structure,1);
% char_width_in_pixels=10;
edit_background_color=[1,1,1];
maximum_allowed_length_to_display_parameter_value=50;
temp_string=[];
height_of_an_entry_box_in_char=1.5;
distance_between_entry_boxes_in_char=0.1;
% If the arguments_gui is called from a method in a class, then the calling_function_name_structure will have a '.' in
% it. Remove this '.' and return what is on the right side of it. If there are multiple '.'s in the name then select the
% last one.
calling_function_name=calling_function_name_structure(2,1).name;
k=strfind(calling_function_name,'.');
if ~isempty(k)
    calling_function_name=calling_function_name(k(end)+1:end);
end
% if size(calling_function_name_structure,1)>2 && strcmp(calling_function_name_structure(end,1).name,'parameters_gui/run_in_base_ws_push_button_callback') ;
%     % The parameter_gui was called by pusing the run button from itself
%     parameter_gui_was_called_by_itself_flag=1;
% end
parameters_data=[];
% Determine how many variables were past to the calling function
number_of_parameters_passed_to_calling_function=evalin('caller','nargin');
% Create figure
application_parameters_figure_name=[calling_function_name,'  parameters'];
application_parameters_figure_handle=findobj('tag',application_parameters_figure_name);
if isempty(application_parameters_figure_handle) || ~ishandle(application_parameters_figure_handle)
    % figure does not exist. Create it.
    application_parameters_figure_handle=figure('tag',calling_function_name);
    set(application_parameters_figure_handle,'NumberTitle','off','DoubleBuffer','on','Units','characters','resize','off','MenuBar','none');
    %     set(application_parameters_figure_handle,'position',[40,40,40,40]);
    set(application_parameters_figure_handle,'position',[4,4,4,4]);
    set(application_parameters_figure_handle,'tag',application_parameters_figure_name);
    set(application_parameters_figure_handle,'Name',application_parameters_figure_name);
    %     panel_handle_for_parameter_values = uipanel('Parent',application_parameters_figure_handle,'units','pixels');
    panel_handle_for_parameter_values = uipanel('Parent',application_parameters_figure_handle,'units','characters');
end
[parameter_names,parameter_default_values,parameter_tooltip_string,parameter_popup_and_range_string,parameter_type,maximum_length_of_parameter_values]=return_function_parameter_names(calling_function_name);
maximum_length_of_parameter_names=15;
% maximum_length_of_parameter_values=15;
% Read the .mat file which is associated with the calling routine
try
    [pathstr, name, ext, versn] = fileparts(which([calling_function_name,'.m']));
catch
    [pathstr, name, ext] = fileparts(which([calling_function_name,'.m']));
end
% if exist(([calling_function_name,'.mat']),'file')
if exist(fullfile(pathstr,[name,'.mat']),'file')
    try
        load('-mat',calling_function_name);
        % Check to see if the parameter names or popup_menu values have changed (compared to last call);
        if exist('parameters_data','var') && (length(parameter_names)==length(parameters_data.parameter_names))
            for parameter_index=1:length(parameter_names)
                if length(parameter_names{parameter_index})>maximum_length_of_parameter_names
                    maximum_length_of_parameter_names=length(parameter_names{parameter_index});
                end
                if ~strcmp(parameters_data.parameter_names{parameter_index},parameter_names{parameter_index}) || ...
                        ~isequal(parameters_data.parameter_popup_and_range_string{parameter_index},parameter_popup_and_range_string{parameter_index})
                    set_parameters_data_to_default_values();
                    break
                end
            end
        else
            set_parameters_data_to_default_values();
        end
    catch
        set_parameters_data_to_default_values();
    end
else
    set_parameters_data_to_default_values();
end
% Replace the default parameters by the parameters that were passed to the calling function
% Parameters which were passed to the calling function will override saved parameters
for parameter_index=1:number_of_parameters_passed_to_calling_function
    parameters_data.parameter_was_passed_flag{parameter_index}=1;
    % Check the value of the parameter which was passed to the calling function
    size_of_passed_parameter=evalin('caller',['size(',parameters_data.parameter_names{parameter_index},')']);
    if (length(size_of_passed_parameter)>2) || (size_of_passed_parameter(1)>1 && size_of_passed_parameter(2)>1) ||...
            (size_of_passed_parameter(1)>maximum_allowed_length_to_display_parameter_value) || (size_of_passed_parameter(2)>maximum_allowed_length_to_display_parameter_value)
        %passed parameter has 2 or more dimensions, or one of the dimensions is too large. Do not save it in the parameters_data.
        parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
        parameters_data.parameter_values{parameter_index}='Large Array';
        parameters_data.parameter_type{parameter_index}='Large Array';
        all_parameters_are_saved_flag=0;
    else
        % Passed parameters can be saved in the parameters_data structure. However, I need to check their type and save
        % them accordingly
        switch evalin('caller',['class(',parameters_data.parameter_names{parameter_index},')']);
            case 'struct'
                % The input parameter is a structure and it should not be saved in the parameters_data
                parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
                parameters_data.parameter_values{parameter_index}='Structure';
                parameters_data.parameter_type{parameter_index}='Structure';
                all_parameters_are_saved_flag=0;
            case 'cell'
                parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
                parameters_data.parameter_values{parameter_index}='Cell';
                parameters_data.parameter_type{parameter_index}='Cell';
                all_parameters_are_saved_flag=0;
            case 'function_handle'
                parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
                parameters_data.parameter_values{parameter_index}='Function Handle';
                parameters_data.parameter_type{parameter_index}='Function Handle';
                all_parameters_are_saved_flag=0;
            case 'char'
                parameters_data.parameter_values{parameter_index}=evalin('caller',['mat2str(',parameters_data.parameter_names{parameter_index},')']);
                if length(parameters_data.parameter_values{parameter_index})>maximum_allowed_length_to_display_parameter_value
                    parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
                    parameters_data.parameter_values{parameter_index}='Large String';
                    parameters_data.parameter_type{parameter_index}='Large String';
                    all_parameters_are_saved_flag=0;
                else
                    parameters_data.parameter_values{parameter_index}=evalin('caller',['mat2str(',parameters_data.parameter_names{parameter_index},')']);
                    parameters_data.passed_parameter_is_saved_flag{parameter_index}=1;
                    parameters_data.parameter_type{parameter_index}='char';
                    %                     if length(parameters_data.parameter_values{parameter_index})> maximum_length_of_parameter_values
                    %                         maximum_length_of_parameter_values=length(parameters_data.parameter_values{parameter_index});
                    %                     end
                end
                
            otherwise
                if evalin('caller',['isnumeric(',parameters_data.parameter_names{parameter_index},')']);
                    parameters_data.parameter_values{parameter_index}=evalin('caller',['mat2str(',parameters_data.parameter_names{parameter_index},')']);
                    if length(parameters_data.parameter_values{parameter_index})>maximum_allowed_length_to_display_parameter_value
                        parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
                        parameters_data.parameter_values{parameter_index}='Large Numeric Array';
                        parameters_data.parameter_type{parameter_index}='Large Numeric Array';
                        all_parameters_are_saved_flag=0;
                    else
                        parameters_data.parameter_values{parameter_index}=evalin('caller',['mat2str(',parameters_data.parameter_names{parameter_index},')']);
                        parameters_data.passed_parameter_is_saved_flag{parameter_index}=1;
                        parameters_data.parameter_type{parameter_index}='numeric';
                        %                         if length(parameters_data.parameter_values{parameter_index})> maximum_length_of_parameter_values
                        %                             maximum_length_of_parameter_values=length(parameters_data.parameter_values{parameter_index});
                        %                         end
                    end
                end
        end
    end
    if strcmp(parameter_type{parameter_index},'popup')
        parameters_data.parameter_type{parameter_index}='popup';
    end
    if strcmp(parameter_type{parameter_index},'popup_numeric')
        parameters_data.parameter_type{parameter_index}='popup_numeric';
    end
    if strcmp(parameter_type{parameter_index},'popup_logical')
        parameters_data.parameter_type{parameter_index}='popup_logical';
    end
end
% Set the parameter values in the workspace of the calling routine
for parameter_index=number_of_parameters_passed_to_calling_function+1:length(parameters_data.parameter_names)
    parameters_data.parameter_was_passed_flag{parameter_index}=0;
    parameters_data.parameter_type{parameter_index}=parameter_type{parameter_index};
    if parameters_data.passed_parameter_is_saved_flag{parameter_index}
        parameters_data.parameter_tooltip_string{parameter_index}=parameter_tooltip_string{parameter_index};
        parameters_data.parameter_popup_and_range_string{parameter_index}=parameter_popup_and_range_string{parameter_index};
    else
        % Passed parameter was not saved in the previous call. However, in this call no value was passed for this
        % parameter. This means that the default value should be used.
        parameters_data.parameter_was_passed_flag{parameter_index}=0;
        parameters_data.passed_parameter_is_saved_flag{parameter_index}=1;
        parameters_data.parameter_values{parameter_index}=parameter_default_values{parameter_index};
    end
    if strcmp(parameters_data.parameter_type{parameter_index},'slider') || strcmp(parameters_data.parameter_type{parameter_index},'slider')
        % make sure the value of a slider is between its min and max
        eval(['temp_popup_menu_string=',parameters_data.parameter_popup_and_range_string{parameter_index},';']);
        slider_min=temp_popup_menu_string{2};
        slider_max=temp_popup_menu_string{3};
        if str2num(parameters_data.parameter_values{parameter_index})<slider_min
            parameters_data.parameter_values{parameter_index}=num2str(slider_min);
        end
        if str2num(parameters_data.parameter_values{parameter_index})>slider_max
            parameters_data.parameter_values{parameter_index}=num2str(slider_max);
        end
    end
    if isempty(parameters_data.parameter_values{parameter_index})
        eval(['temp=[];'])
    else
        eval(['temp=',parameters_data.parameter_values{parameter_index},';']);
        if (length(parameters_data.parameter_values{parameter_index})>maximum_length_of_parameter_values) && (length(parameters_data.parameter_values{parameter_index})<= maximum_allowed_length_to_display_parameter_value)
            maximum_length_of_parameter_values=length(parameters_data.parameter_values{parameter_index});
        end
        
    end
    assignin('caller',parameters_data.parameter_names{parameter_index},temp);
    if length(parameters_data.parameter_values{parameter_index})<= maximum_allowed_length_to_display_parameter_value
        %         % %         parameters_data.passed_parameter_is_saved_flag{parameter_index}=0;
        %         % %         parameters_data.parameter_values{parameter_index}='Too large to display';
        %     else
        %         if length(parameters_data.parameter_values{parameter_index})> maximum_length_of_parameter_values
        %             maximum_length_of_parameter_values=length(parameters_data.parameter_values{parameter_index});
        %         end
    end
end
save_parameters_data();
create_uicontrols;
drawnow;
    function create_uicontrols()
        figure(application_parameters_figure_handle);
        fig_position=get(application_parameters_figure_handle,'position');
        if (2*length(calling_function_name)) > (maximum_length_of_parameter_values+maximum_length_of_parameter_names)
            temp=(2*length(calling_function_name)-maximum_length_of_parameter_values-maximum_length_of_parameter_names)/2;
            maximum_length_of_parameter_values=maximum_length_of_parameter_values+temp;
            maximum_length_of_parameter_names=maximum_length_of_parameter_names+temp;
            width_of_figure=25+2*length(calling_function_name);
        else
            width_of_figure=25+maximum_length_of_parameter_values+maximum_length_of_parameter_names;
        end
        if width_of_figure <75
            if maximum_length_of_parameter_values<25
                maximum_length_of_parameter_values=25;
            end
            if maximum_length_of_parameter_names<25
                maximum_length_of_parameter_names=25;
            end
            width_of_figure=25+maximum_length_of_parameter_values+maximum_length_of_parameter_names;
        end
        length_of_uicontrol_to_display_parameter_values=maximum_length_of_parameter_values+16;
        length_of_uicontrol_to_display_parameter_names=maximum_length_of_parameter_names+2;
        %         set(application_parameters_figure_handle,'position',[fig_position(1),fig_position(2),20+char_width_in_pixels*(length_of_uicontrol_to_display_parameter_values+length_of_uicontrol_to_display_parameter_names),100+20*length(parameters_data.parameter_names)]);
        set(application_parameters_figure_handle,'position',[fig_position(1),fig_position(2),width_of_figure,8+(height_of_an_entry_box_in_char+distance_between_entry_boxes_in_char)*length(parameters_data.parameter_names)]);
        % Clear the panel for displaying the parameter values
        h=allchild(application_parameters_figure_handle);
        delete(h);
        %         panel_handle_for_parameter_values = uipanel('Parent',application_parameters_figure_handle,'units','pixels');
        panel_handle_for_parameter_values = uipanel('Parent',application_parameters_figure_handle,'units','characters');
        parameter_values_uipanel_position=get(panel_handle_for_parameter_values,'position');
        % end
        %         h = uicontrol(panel_handle_for_parameter_values,'Style', 'text', 'String',calling_function_name, 'Units','pixels',...
        %             'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
        %             'Position', [2, parameter_values_uipanel_position(4)-35 , parameter_values_uipanel_position(3) , 35],'HorizontalAlignment','center','fontsize',14);
        h = uicontrol(panel_handle_for_parameter_values,'Style', 'text', 'String',calling_function_name, 'Units','characters',...
            'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
            'Position', [1, parameter_values_uipanel_position(4)-2*height_of_an_entry_box_in_char-distance_between_entry_boxes_in_char , parameter_values_uipanel_position(3)-3 , 2],'HorizontalAlignment','center','fontsize',14);
        % Fill the gui with uicontrols
        y_position_of_last_entry_box=parameter_values_uipanel_position(4)-2;
        for parameter_index=1:size(parameter_names,1)
            y_position_of_last_entry_box=y_position_of_last_entry_box-height_of_an_entry_box_in_char-distance_between_entry_boxes_in_char;
            h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',[parameters_data.parameter_names{parameter_index},'  '], 'Units','characters',...
                'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
                'Position', [1,y_position_of_last_entry_box-height_of_an_entry_box_in_char-distance_between_entry_boxes_in_char , length_of_uicontrol_to_display_parameter_names+3 , height_of_an_entry_box_in_char]);
            temp_position=get(h,'position');
            long_string_flag=0;
            if length(parameters_data.parameter_values{parameter_index})> maximum_allowed_length_to_display_parameter_value
                long_string_flag=1;
                string_to_display='Too large to display';
            end
            if ~parameters_data.passed_parameter_is_saved_flag{parameter_index}
                long_string_flag=1;
                string_to_display=parameters_data.parameter_values{parameter_index};
            end
            if long_string_flag
                % parameter was not saved. It means it could not fit in an edit box or popup menu.
                edit_background_color=[0.8,0.8,.8];
            else
                edit_background_color=[1,1,1];
            end
            %                 h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit','enable','off', 'String',string_to_display,...
            %                     'Units','characters',...
            %                     'BackgroundColor',[1,1,1], 'HorizontalAlignment','Left',...
            %                     'Position', [temp_position(1)+temp_position(3)+1,temp_position(2),length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
            %                     'userdata',parameter_index);
            
            switch parameters_data.parameter_type{parameter_index}
                case {'numeric','var','char'}
                    h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',parameters_data.parameter_values{parameter_index},...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@change_the_value_of_a_parameter_Callback);
                case 'popup'
                    % This element is a popup menu item
                    eval(['temp_string=',parameters_data.parameter_values{parameter_index},';']);
                    eval(['temp_popup_menu_string=',parameters_data.parameter_popup_and_range_string{parameter_index},';']);
                    passed_argument_matched_possible_choices_flag=0;
                    for index_of_matched_choice=1:length(temp_popup_menu_string)
                        if strcmp(temp_popup_menu_string{index_of_matched_choice},temp_string)
                            passed_argument_matched_possible_choices_flag=1;
                            break;
                        end
                    end
                    if passed_argument_matched_possible_choices_flag
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'popupmenu', 'String',temp_popup_menu_string,...
                            'Units','characters',...
                            'value',index_of_matched_choice,...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index, 'callback',@change_the_value_of_a_parameter_popup_menu_Callback);
                    else
                        % Passed parameter did not match any choice
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit','enable','off', 'String',parameters_data.parameter_values{parameter_index},...
                            'Units','characters',...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index);
                    end
                case 'popup_numeric'
                    % This element is a popup menu item
                    %                         eval(['temp_string=',str2num(parameters_data.parameter_values{parameter_index}),';']);
                    eval(['temp_popup_menu_string=cell2mat(',parameters_data.parameter_popup_and_range_string{parameter_index},');']);
                    
                    temp=find(temp_popup_menu_string==str2num(parameters_data.parameter_values{parameter_index}),1,'first');
                    if isempty(temp)
                        passed_argument_matched_possible_choices_flag=0;
                    else
                        passed_argument_matched_possible_choices_flag=1;
                    end
                    if passed_argument_matched_possible_choices_flag
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'popupmenu', 'String',temp_popup_menu_string,...
                            'Units','characters',...
                            'value',temp,...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index, 'callback',@change_the_value_of_a_parameter_popup_menu_Callback);
                    else
                        % Passed parameter did not match any choice
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit','enable','off', 'String',parameters_data.parameter_values{parameter_index},...
                            'Units','characters',...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index);
                    end
                case 'popup_logical'
                    % This element is a logical popup menu item
                    %                         eval(['temp_string=',(parameters_data.parameter_values{parameter_index}),';']);
                    eval(['temp_popup_menu_string=cell2mat(',parameters_data.parameter_popup_and_range_string{parameter_index},');']);
                    temp=find(temp_popup_menu_string==str2num(parameters_data.parameter_values{parameter_index}),1,'first');
                    if isempty(temp)
                        passed_argument_matched_possible_choices_flag=0;
                    else
                        passed_argument_matched_possible_choices_flag=1;
                    end
                    for k=1:length(temp_popup_menu_string)
                        if temp_popup_menu_string(k)
                            popup_string{k,1}='true';
                        else
                            popup_string{k,1}='false';
                        end
                    end
                    if passed_argument_matched_possible_choices_flag
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'popupmenu', 'String',popup_string,...
                            'Units','characters',...
                            'value',temp,...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index, 'callback',@change_the_value_of_a_parameter_popup_menu_Callback);
                    else
                        % Passed parameter did not match any choice
                        h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit','enable','off', 'String',parameters_data.parameter_values{parameter_index},...
                            'Units','characters',...
                            'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                            'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), length_of_uicontrol_to_display_parameter_values , height_of_an_entry_box_in_char],...
                            'userdata',parameter_index);
                    end
                    
                case 'file'
                    h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',parameters_data.parameter_values{parameter_index},...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), (length_of_uicontrol_to_display_parameter_values-3)  , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@change_the_name_of_a_file_Callback);
                    temp_position=get(h,'position');
                    hs = uicontrol(panel_handle_for_parameter_values,'Style', 'pushbutton','String','F', ...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3),temp_position(2), 3 , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@open_file_pushbutton_Callback);
                    setappdata(hs,'file_name_edit_handle',h);
                case 'dir'
                    h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',parameters_data.parameter_values{parameter_index},...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), (length_of_uicontrol_to_display_parameter_values-3)  , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@change_directory_Callback);
                    temp_position=get(h,'position');
                    hs = uicontrol(panel_handle_for_parameter_values,'Style', 'pushbutton','String','D', ...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3),temp_position(2), 3 , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@open_dir_pushbutton_Callback);
                    setappdata(hs,'directory_edit_handle',h);
                    
                case 'slider'
                    eval(['temp_popup_menu_string=',parameters_data.parameter_popup_and_range_string{parameter_index},';']);
                    slider_min=temp_popup_menu_string{2};
                    slider_max=temp_popup_menu_string{3};
                    
                    h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',parameters_data.parameter_values{parameter_index},...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), (length_of_uicontrol_to_display_parameter_values-3) , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@change_the_value_of_a_slider_parameter_Callback);
                    temp_position=get(h,'position');
                    hs = uicontrol(panel_handle_for_parameter_values,'Style', 'slider', ...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Max',slider_max,'Min',slider_min,'value',str2num(parameters_data.parameter_values{parameter_index}),...
                        'Position', [temp_position(1)+temp_position(3),temp_position(2), 3 ,height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@click_the_value_of_a_slider_parameter_Callback);
                    setappdata(hs,'edit_box_handle',h);
                    setappdata(h,'slider_handle',hs);
                case 'intslider'
                    eval(['temp_popup_menu_string=',parameters_data.parameter_popup_and_range_string{parameter_index},';']);
                    slider_min=temp_popup_menu_string{2};
                    slider_max=temp_popup_menu_string{3};
                    
                    h = uicontrol(panel_handle_for_parameter_values,'Style', 'edit', 'String',parameters_data.parameter_values{parameter_index},...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Position', [temp_position(1)+temp_position(3)+1,temp_position(2), (length_of_uicontrol_to_display_parameter_values-3) , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@change_the_value_of_a_intslider_parameter_Callback);
                    temp_position=get(h,'position');
                    hs = uicontrol(panel_handle_for_parameter_values,'Style', 'slider', ...
                        'Units','characters',...
                        'BackgroundColor',edit_background_color, 'HorizontalAlignment','Left',...
                        'Max',slider_max,'Min',slider_min,'value',str2num(parameters_data.parameter_values{parameter_index}),...
                        'sliderstep',[1/abs(slider_max-slider_min),1/abs(slider_max-slider_min)], ...
                        'Position', [temp_position(1)+temp_position(3),temp_position(2), 3 , height_of_an_entry_box_in_char],...
                        'userdata',parameter_index, 'callback',@click_the_value_of_a_intslider_parameter_Callback);
                    setappdata(hs,'edit_box_handle',h);
                    setappdata(h,'slider_handle',hs);
                    
                otherwise
                    
            end
            if ~isempty(parameters_data.parameter_tooltip_string{parameter_index})
                set(h,'TooltipString',parameters_data.parameter_tooltip_string{parameter_index});
            end
        end
        % Create the run  and reset buttons
        %         panel_handle_for_push_buttons = uipanel('Parent',panel_handle_for_parameter_values,'units','pixels',...
        %             'Position', [4, 4 , parameter_values_uipanel_position(3)-8 , 36]);
        panel_handle_for_push_buttons = uipanel('Parent',panel_handle_for_parameter_values,'units','characters',...
            'Position', [.2, .2 , parameter_values_uipanel_position(3)-1.2 , 3]);
        %         setappdata(application_parameters_figure_handle,'panel_handle_for_push_buttons',panel_handle_for_push_buttons);
        %         handle_for_wait_message = uicontrol(panel_handle_for_parameter_values,'Style', 'text', 'String',[calling_function_name,' is running. Please wait'], 'Units','pixels',...
        %             'Position', [4, 4 , parameter_values_uipanel_position(3)-8 , 36],'ForegroundColor',[1,0,0],'HorizontalAlignment','center','fontsize',14,'visible','off');
        %         setappdata(application_parameters_figure_handle,'handle_for_wait_message',handle_for_wait_message);
        %         if call_depth_level ==2
        %             if all_parameters_are_saved_flag
        %                 h = uicontrol(panel_handle_for_push_buttons,'Style', 'pushbutton', 'String',['Run in the base ws'], 'Units','pixels',...
        %                     'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
        %                     'Position', [2, 2 , floor(parameter_values_uipanel_position(3)/2)-12 , 30],'HorizontalAlignment','center','fontsize',12,...
        %                     'callback',['evalin(''base'',''',calling_function_name,''');']);
        %             end
        %             h = uicontrol(panel_handle_for_push_buttons,'Style', 'pushbutton', 'String',['Reset to Defaults'], 'Units','pixels',...
        %                 'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
        %                 'Position', [floor(parameter_values_uipanel_position(3)/2)+2, 2 , floor(parameter_values_uipanel_position(3)/2)-12 , 30],'HorizontalAlignment','center','fontsize',12,...
        %                 'callback',@reset_to_defaults_pushbutton_callback);
        %
        %         end
        if call_depth_level ==2
            if all_parameters_are_saved_flag
                h = uicontrol(panel_handle_for_push_buttons,'Style', 'pushbutton', 'String',['Run'], 'Units','characters',...
                    'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
                    'Position', [.5, .5 , 2*length('Run')+2, 2],'HorizontalAlignment','center','fontsize',12,...
                    'callback',['evalin(''base'',''',calling_function_name,''');']);
            end
            h = uicontrol(panel_handle_for_push_buttons,'Style', 'pushbutton', 'String',['Reset to Defaults'], 'Units','characters',...
                'BackgroundColor',[.9,.9,.9], 'HorizontalAlignment','Right',...
                'Position', [parameter_values_uipanel_position(3)-3-2*length('Reset to Defaults'), .5 , 2*length('Reset to Defaults') , 2],'HorizontalAlignment','center','fontsize',12,...
                'callback',@reset_to_defaults_pushbutton_callback);
            
        end
    end
    function save_parameters_data()
        try
            [pathstr, name, ext, versn] = fileparts(which([calling_function_name,'.m']));
        catch
            [pathstr, name, ext] = fileparts(which([calling_function_name,'.m']));
        end
        if exist('parameters_data','var')
            if exist('preferences_data','var')
                save(fullfile(pathstr,[name,'.mat']),'parameters_data','preferences_data');
            else
                save(fullfile(pathstr,[name,'.mat']),'parameters_data');
            end
        else
            if exist('preferences_data','var')
                save(fullfile(pathstr,[name,'.mat']),'preferences_data');
            end
        end
    end

    function reset_to_defaults_pushbutton_callback(hObject,eventdata, handles)
        try
            [pathstr, name, ext, versn] = fileparts(which([calling_function_name,'.m']));
        catch
            [pathstr, name, ext] = fileparts(which([calling_function_name,'.m']));
        end
        delete(fullfile(pathstr,[name,'.mat']));
        set_parameters_data_to_default_values();
        create_uicontrols;
        save_parameters_data;
    end
    function change_the_value_of_a_parameter_popup_menu_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        temp=get(hObject,'string');
        switch parameters_data.parameter_type{index_of_object}
            case {'popup_numeric', 'popup_logical'}
                eval(['temp_popup_menu_string=cell2mat(',parameters_data.parameter_popup_and_range_string{index_of_object},');']);
                
                parameters_data.parameter_values{index_of_object}=num2str(temp_popup_menu_string(get(hObject,'value')));
                
            case 'popup'
                parameters_data.parameter_values{index_of_object}=['''',temp{get(hObject,'value')},''''];
        end
        parameters_data.parameter_was_passed_flag{index_of_object}=0;
        save_parameters_data();
    end
    function change_the_value_of_a_parameter_Callback(hObject,eventdata, handles)
        index_of_object=get(hObject,'UserData');
        parameters_data.parameter_values{index_of_object}=get(hObject,'string');
        save_parameters_data();
    end
    function change_the_value_of_a_slider_parameter_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        slider_min=get(getappdata(hObject,'slider_handle'),'min');
        slider_max=get(getappdata(hObject,'slider_handle'),'max');
        temp=str2num(get(hObject,'string'));
        if temp<slider_min
            temp=slider_min;
            set(hObject,'string',num2str(temp));
        end
        if temp>slider_max
            temp=slider_max;
            set(hObject,'string',num2str(temp));
        end
        parameters_data.parameter_values{index_of_object}=num2str(temp);
        set(getappdata(hObject,'slider_handle'),'value',temp);
        save_parameters_data();
    end
    function change_the_value_of_a_intslider_parameter_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        slider_min=round(get(getappdata(hObject,'slider_handle'),'min'));
        slider_max=round(get(getappdata(hObject,'slider_handle'),'max'));
        temp=round(str2num(get(hObject,'string')));
        if temp<slider_min
            temp=slider_min;
            set(hObject,'string',num2str(temp));
        end
        if temp>slider_max
            temp=slider_max;
            set(hObject,'string',num2str(temp));
        end
        set(hObject,'string',num2str(temp));
        parameters_data.parameter_values{index_of_object}=num2str(temp);
        set(getappdata(hObject,'slider_handle'),'value',temp);
        save_parameters_data();
    end
    function click_the_value_of_a_slider_parameter_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        parameters_data.parameter_values{index_of_object}=num2str(get(hObject,'value'));
        set(getappdata(hObject,'edit_box_handle'),'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function click_the_value_of_a_intslider_parameter_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        parameters_data.parameter_values{index_of_object}=num2str(round(get(hObject,'value')));
        set(getappdata(hObject,'edit_box_handle'),'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function change_the_name_of_a_file_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        temp=get(hObject,'string');
        % Remove the single quotations if they exist
        temp = strrep(temp, '''', '');
        % remove leading and trailing spaces
        temp=strtrim(temp);
        parameters_data.parameter_values{index_of_object}=['''',temp,''''];
        set(hObject,'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function change_directory_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        temp=get(hObject,'string');
        % Remove the single quotations if they exist
        temp = strrep(temp, '''', '');
        % remove leading and trailing spaces
        temp=strtrim(temp);
        parameters_data.parameter_values{index_of_object}=['''',temp,''''];
        set(hObject,'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function open_file_pushbutton_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        temp=get(getappdata(hObject,'file_name_edit_handle'),'string');
        % Remove the single quotations if they exist
        temp = strrep(temp, '''', '');
        temp=strtrim(temp);
                    try
                [pathstr, temp_file_name, temp_extension, versn] = fileparts(temp);
            catch
                [pathstr, temp_file_name, temp_extension] = fileparts(temp);
            end

            [temp_file_name,temp_directory] = uigetfile(fullfile(pathstr,'*.*'),'Select a file');

%         if exist(temp,'file')
%             [temp_file_name,temp_directory] = uigetfile(temp,'Select a file');
%         else
%             [temp_file_name,temp_directory] = uigetfile(fullfile(pwd,'*.*'),'Select a file');
%         end
        if isequal(temp_file_name,0)
            return
        end
        %         parameters_data.parameter_values{index_of_object}=['''',temp_file_name,''''];
        parameters_data.parameter_values{index_of_object}=['''',fullfile(temp_directory,temp_file_name),''''];
        set(getappdata(hObject,'file_name_edit_handle'),'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function open_dir_pushbutton_Callback(hObject, eventdata, handles)
        index_of_object=get(hObject,'UserData');
        temp=get(getappdata(hObject,'directory_edit_handle'),'string');
        % Remove the single quotations if they exist
        temp = strrep(temp, '''', '');
        temp=strtrim(temp);
        if exist(temp,'dir')
            [temp_directory] = uigetdir(temp,'Select a directory');
        else
            [temp_directory] = uigetdir('','Select a directory');
        end
        if isequal(temp_directory,0)
            return
        end
        parameters_data.parameter_values{index_of_object}=['''',temp_directory,''''];
        set(getappdata(hObject,'directory_edit_handle'),'string',parameters_data.parameter_values{index_of_object});
        save_parameters_data();
    end
    function set_parameters_data_to_default_values()
        
        parameters_data=[];
        for parameter_index=1:length(parameter_names)
            parameters_data.parameter_names{parameter_index}=parameter_names{parameter_index};
            parameters_data.parameter_was_passed_flag{parameter_index}=0;
            parameters_data.passed_parameter_is_saved_flag{parameter_index}=1;
            parameters_data.parameter_type{parameter_index}=parameter_type{parameter_index};
            parameters_data.parameter_popup_and_range_string{parameter_index}=parameter_popup_and_range_string{parameter_index};
            parameters_data.parameter_tooltip_string{parameter_index}=parameter_tooltip_string{parameter_index};
            parameters_data.parameter_values{parameter_index}=parameter_default_values{parameter_index};
            if length(parameter_names{parameter_index})>maximum_length_of_parameter_names
                maximum_length_of_parameter_names=length(parameter_names{parameter_index});
            end
        end
    end
    function [parameter_names,parameter_default_values,parameter_tooltip_string,parameter_popup_and_range_string,parameter_type,maximum_length_of_parameter_values]=return_function_parameter_names(function_name)
        % Given a function_name, this routine parses the function m file and the comment lines and
        % returns the names of the parameters, default value of each parameter, and additional information
        % (such as range and type) for each parameter.
        % The return values are cell structures containing the parameter names and related information from the comment
        % lines. for more infromation about the format of the comment lines refer to the "parameters_gui_example.m"
        % file.
        % Farhad Kamangar Mar. 8, 2010.
        function_name=char(function_name);
        try
            [pathstr, fname, ext, versn]=fileparts(char(function_name));
        catch
            [pathstr, fname, ext]=fileparts(char(function_name));
        end
        parameter_tooltip_string=[];
        parameter_popup_and_range_string=[];
        parameter_default_values=[];
        parameter_type=[];
        maximum_length_of_parameter_values=0;
        if isempty(ext)
            function_name=strcat(function_name,'.m');
        end
        
        fid = fopen(function_name);
        textscan(fid, '%[^(]');
        textscan(fid, '%[(]');
        celltemp=textscan(fid, '%[^)]');
        if isempty(celltemp)
            parameter_names=[];
            %     parameter_default_values=[];
        else
            temp=char(celltemp{1,1});
            if isempty(temp)
                parameter_names=[];
            else
                parameter_names=textscan(temp, '%s', 'delimiter', ', .','multipledelimsasone', 1);
                parameter_names=parameter_names{1};
            end
        end
        fclose(fid);
        if ~isempty(parameter_names)
            % try to find the default values for the parameters
            %             parameter_type='var';
            %             parameter_default_values{i,1}=[];
            %             parameter_popup_and_range_string{i,1}=[];
            help_string=help(function_name);
            for index=1:size(parameter_names,1)
                parameter_type{index,1}='var';
                parameter_default_values{index,1}=[];
                parameter_popup_and_range_string{index,1}=[];
                %                 match_pattern=strcat('(',parameter_names{index},'[\s]*=[\s]*)(\[[^'']*\]|''[^'']*''|[\w.]*)');
                match_pattern=strcat('(',parameter_names{index},'[\s]*=[\s]*)({[\&\+\-\*\\\/\w\s;,''\{\}]*}|\[[\+\-\\\/\*\w\s;,.'']*\]|''[^'']*''|\+?\-?\d[\w.]*)');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    parameter_default_values{index,1}=temp{2};
                    if (length(temp{2})>maximum_length_of_parameter_values) && (length(temp{2})<= maximum_allowed_length_to_display_parameter_value)
                        maximum_length_of_parameter_values=length(temp{2});
                    end
                end
                match_pattern=strcat('(',parameter_names{index},'[\s]*::[\s]*)([^:]*(:[^:]+)*)(::)');
                %          match_pattern=strcat('(',parameter_names{index},'[\s]*::');
                %         match_pattern=strcat('(',parameter_names{index},'[\s]*BB[\s]*)([^B]*(B[^B]+)*)(BB)');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    parameter_tooltip_string{index,1}=temp{2};
                else
                    parameter_tooltip_string{index,1}=[];
                end
                match_pattern=strcat('(',parameter_names{index},'[\s]*=[\s]*popup[\s]*)({[\.\+\-\*\\\/\w\s;,'']*})');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    parameter_popup_and_range_string{index,1}=temp{2};
                    eval(['temp_popup_menu_string=',parameter_popup_and_range_string{index},';']);
                    if isa(temp_popup_menu_string{1},'numeric')
                        parameter_default_values{index,1}=num2str(temp_popup_menu_string{1});
                        parameter_type{index,1}='popup_numeric';
                    elseif isa(temp_popup_menu_string{1},'logical')
                        if temp_popup_menu_string{1}
                            parameter_default_values{index,1}='true';
                        else
                            parameter_default_values{index,1}='false';
                        end
                        parameter_type{index,1}='popup_logical';
                    else
                        parameter_default_values{index,1}=['''',temp_popup_menu_string{1},''''];
                        parameter_type{index,1}='popup';
                    end
                    for k=1:length(temp_popup_menu_string)
                        if (length(temp_popup_menu_string{k})>maximum_length_of_parameter_values) && (length(temp_popup_menu_string{k})<= maximum_allowed_length_to_display_parameter_value)
                            maximum_length_of_parameter_values=length(temp_popup_menu_string{k});
                        end
                    end
                end
                match_pattern=strcat('(\s',parameter_names{index},'[\s]*=[\s]*slider[\s]*)({[\+\-\*\/\w\.\s;,'']*})');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    parameter_popup_and_range_string{index,1}=temp{2};
                    eval(['temp_popup_menu_string=',parameter_popup_and_range_string{index},';']);
                    parameter_default_values{index,1}=num2str(temp_popup_menu_string{1});
                    parameter_type{index,1}='slider';
                    for k=1:length(temp_popup_menu_string)
                        if (length(temp_popup_menu_string{k})>maximum_length_of_parameter_values) && (length(temp_popup_menu_string{k})<= maximum_allowed_length_to_display_parameter_value)
                            maximum_length_of_parameter_values=length(temp_popup_menu_string{k});
                        end
                    end
                end
                match_pattern=strcat('(\s',parameter_names{index},'[\s]*=[\s]*intslider[\s]*)({[\.\+\-\*\/\w\s;,'']*})');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    parameter_popup_and_range_string{index,1}=temp{2};
                    eval(['temp_popup_menu_string=',parameter_popup_and_range_string{index},';']);
                    parameter_default_values{index,1}=num2str(round(temp_popup_menu_string{1}));
                    parameter_type{index,1}='intslider';
                    for k=1:length(temp_popup_menu_string)
                        if (length(temp_popup_menu_string{k})>maximum_length_of_parameter_values) && (length(temp_popup_menu_string{k})<= maximum_allowed_length_to_display_parameter_value)
                            maximum_length_of_parameter_values=length(temp_popup_menu_string{k});
                        end
                    end
                end
                match_pattern=strcat('(',parameter_names{index},'[\s]*=[\s]*file[\s]*)({[\:\+\-\*\/\\\w\.\s;,'']*})');
                [tokens] = regexp(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    eval(['temp_popup_menu_string=',temp{2},';']);
                    parameter_default_values{index,1}=['''',temp_popup_menu_string{1},''''];
                    parameter_type{index,1}='file';
                    for k=1:length(temp_popup_menu_string)
                        if (length(temp_popup_menu_string{k})>maximum_length_of_parameter_values) && (length(temp_popup_menu_string{k})<= maximum_allowed_length_to_display_parameter_value)
                            maximum_length_of_parameter_values=length(temp_popup_menu_string{k});
                        end
                    end
                end
                match_pattern=strcat('(',parameter_names{index},'[\s]*=[\s]*dir[\s]*)({[\:\+\-\*\/\\\w\.\s;,'']*})');
                [tokens] = regexpi(help_string,match_pattern ,'tokens');
                if ~isempty(tokens)
                    temp=tokens{1,1};
                    eval(['temp_popup_menu_string=',temp{2},';']);
                    parameter_default_values{index,1}=['''',temp_popup_menu_string{1},''''];
                    parameter_type{index,1}='dir';
                    for k=1:length(temp_popup_menu_string)
                        if (length(temp_popup_menu_string{k})>maximum_length_of_parameter_values) && (length(temp_popup_menu_string{k})<= maximum_allowed_length_to_display_parameter_value)
                            maximum_length_of_parameter_values=length(temp_popup_menu_string{k});
                        end
                    end
                end
                
            end
        end
    end
end
