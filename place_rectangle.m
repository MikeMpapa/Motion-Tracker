function rec_selected_rectangle=place_rectangle(rec_bounded_surface,rec_existing_rectangles,rec_input_rectangle)
% This routine finds the best place to place a rectangle such that it does not overlap with a set of already existing rectangles.
% Inputs:
% rec_bounded_surface  is an area in the form of a rectangle [x,y,width,height]
% rec_existing_rectangles is a set of rectangles in a cell array. each element of the cell must be a rectangle
% rec_input_rectangle is the rectangle to be placed in the area [x,y,width, height]
%
% Output of this routine is a suggestion for the x and y location of the rec_input_rectangle.
% Note: The standard rectangle object in matlab is defined by [xmin,ymin,width,height].
% However, in this routine there are many places that I need to use the x max and y max of the rectangle. I could find
% the x max and y max of the rectangle by using x+width and y+height, but this decreases the efficiency of the program. I decided
% to use a non-standard version of the rectangle form when is needed. The non-standard form is basically [xmin,ymin,xmax,ymax].
% To clarify the code I decided to start the name of all the standard rectangles with "rec_" and start the name of all the
% non-standard rectangle variables with "mrec_" (indicating a modified rectangle).
bounded_surface_min_x=rec_bounded_surface(1);
bounded_surface_min_y=rec_bounded_surface(2);
bounded_surface_max_x=rec_bounded_surface(1)+rec_bounded_surface(3);
bounded_surface_max_y=rec_bounded_surface(2)+rec_bounded_surface(4);
rec_selected_rectangle=rec_input_rectangle;
if isempty(rec_existing_rectangles)
    % if there are no other rectangles, then move the rectangle to the upper left corner of the screen
    rec_selected_rectangle(1)=1;
    rec_selected_rectangle(2)=bounded_surface_max_y-rec_input_rectangle(4)-1;
    return;
end

mrec_largest_free_rectangles{1}=[bounded_surface_min_x,bounded_surface_min_y,bounded_surface_max_x,bounded_surface_max_y];

temp_rec_existing_rectangles=rec_existing_rectangles;
rec_existing_rectangles=[];
index_of_current_rectangle=1;
for k=1:length(temp_rec_existing_rectangles)
    %     Make sure the existing rectangles are not beyond the bundaries of the rec_bounded_surface
    temp_rectangle=return_interesection_of_two_rectangles(rec_bounded_surface,temp_rec_existing_rectangles{k});
    if ~isempty(temp_rectangle)
        rec_existing_rectangles{index_of_current_rectangle}=temp_rectangle;
        mrec_existing_rectangles{index_of_current_rectangle}=[rec_existing_rectangles{index_of_current_rectangle}(1),rec_existing_rectangles{index_of_current_rectangle}(2),rec_existing_rectangles{index_of_current_rectangle}(1)+rec_existing_rectangles{index_of_current_rectangle}(3),rec_existing_rectangles{index_of_current_rectangle}(2)+rec_existing_rectangles{index_of_current_rectangle}(4)];
        index_of_current_rectangle=index_of_current_rectangle+1;
    end
end
for k=1:length(rec_existing_rectangles)
    index_of_mrec_new_largest_free_rectangles=0;
    mrec_new_largest_free_rectangles=[];
    for m=1:length(mrec_largest_free_rectangles);
        mrec_current_rectangle=mrec_existing_rectangles{k};
        mrec_current_largest_free_rectangle=mrec_largest_free_rectangles{m};
        if (mrec_current_rectangle(1) > mrec_current_largest_free_rectangle(3)) || ...
                (mrec_current_rectangle(3) < mrec_current_largest_free_rectangle(1)) || ...
                (mrec_current_rectangle(2) > mrec_current_largest_free_rectangle(4)) || ...
                (mrec_current_rectangle(4) < mrec_current_largest_free_rectangle(2))
            %         Two rectangles do not intersect
            index_of_mrec_new_largest_free_rectangles=index_of_mrec_new_largest_free_rectangles+1;
            mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles}=mrec_current_largest_free_rectangle;
            %             temp_rectangle=mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles};
            %             rectangle('position',[temp_rectangle(1),temp_rectangle(2),...
            %                 temp_rectangle(3)-temp_rectangle(1)+1,temp_rectangle(4)-temp_rectangle(2)+1],'FaceColor','r');
            
            continue;
        end
        %   Find if the right edge of the mrec_current_rectangle intersects with the mrec_current_largest_free_rectangle
        if (mrec_current_rectangle(3) > mrec_current_largest_free_rectangle(1)) && (mrec_current_rectangle(3) < mrec_current_largest_free_rectangle(3))
            % right edge does intersect. Find the reduced mrec_current_largest_free_rectangle
            mrec_current_reduced_rectangle=[mrec_current_rectangle(3),mrec_current_largest_free_rectangle(2),mrec_current_largest_free_rectangle(3),mrec_current_largest_free_rectangle(4)];
            index_of_mrec_new_largest_free_rectangles=index_of_mrec_new_largest_free_rectangles+1;
            mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles}=mrec_current_reduced_rectangle;
            %             temp_rectangle=mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles};
            %             rectangle('position',[temp_rectangle(1),temp_rectangle(2),...
            %                 temp_rectangle(3)-temp_rectangle(1)+1,temp_rectangle(4)-temp_rectangle(2)+1],'FaceColor','r');
        end
        %     find if the top edge of the mrec_current_rectangle intersects with the mrec_current_largest_free_rectangle
        if (mrec_current_rectangle(4) > mrec_current_largest_free_rectangle(2)) && (mrec_current_rectangle(4) < mrec_current_largest_free_rectangle(4))
            % Top edge does intersect. Find the reduced mrec_current_largest_free_rectangle
            %                 mrec_current_reduced_rectangle=[mrec_current_largest_free_rectangle(1),mrec_current_rectangle(4),min(mrec_current_largest_free_rectangle(3),mrec_current_rectangle(3)),mrec_current_largest_free_rectangle(4)];
            mrec_current_reduced_rectangle=[mrec_current_largest_free_rectangle(1),mrec_current_rectangle(4),mrec_current_largest_free_rectangle(3),mrec_current_largest_free_rectangle(4)];
            index_of_mrec_new_largest_free_rectangles=index_of_mrec_new_largest_free_rectangles+1;
            mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles}=mrec_current_reduced_rectangle;
            %             temp_rectangle=mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles};
            %             rectangle('position',[temp_rectangle(1),temp_rectangle(2),...
            %                 temp_rectangle(3)-temp_rectangle(1)+1,temp_rectangle(4)-temp_rectangle(2)+1],'FaceColor','r');
        end
        %     find if the left edge of the mrec_current_rectangle intersects with the mrec_current_largest_free_rectangle
        if (mrec_current_rectangle(1) > mrec_current_largest_free_rectangle(1)) && (mrec_current_rectangle(1) < mrec_current_largest_free_rectangle(3))
            % Left edge does intersect. Find the reduced mrec_current_largest_free_rectangle
            %                 mrec_current_reduced_rectangle=[mrec_current_largest_free_rectangle(1),mrec_current_largest_free_rectangle(2),mrec_current_rectangle(1),min(mrec_current_largest_free_rectangle(4),mrec_current_rectangle(4))];
            mrec_current_reduced_rectangle=[mrec_current_largest_free_rectangle(1),mrec_current_largest_free_rectangle(2),mrec_current_rectangle(1),mrec_current_largest_free_rectangle(4)];
            index_of_mrec_new_largest_free_rectangles=index_of_mrec_new_largest_free_rectangles+1;
            mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles}=mrec_current_reduced_rectangle;
            %             temp_rectangle=mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles};
            %             rectangle('position',[temp_rectangle(1),temp_rectangle(2),...
            %                 temp_rectangle(3)-temp_rectangle(1)+1,temp_rectangle(4)-temp_rectangle(2)+1],'FaceColor','r');
        end
        %     find if the bottom edge of the mrec_current_rectangle intersects with the mrec_current_largest_free_rectangle
        if (mrec_current_rectangle(2) > mrec_current_largest_free_rectangle(2)) && (mrec_current_rectangle(2) < mrec_current_largest_free_rectangle(4))
            % Bottom edge does intersect. Find the reduced mrec_current_largest_free_rectangle
            %                 mrec_current_reduced_rectangle=[max(mrec_current_largest_free_rectangle(1),mrec_current_rectangle(1)),mrec_current_largest_free_rectangle(2),min(mrec_current_largest_free_rectangle(3),mrec_current_rectangle(3)),mrec_current_rectangle(2)];
            mrec_current_reduced_rectangle=[mrec_current_largest_free_rectangle(1),mrec_current_largest_free_rectangle(2),mrec_current_largest_free_rectangle(3),mrec_current_rectangle(2)];
            index_of_mrec_new_largest_free_rectangles=index_of_mrec_new_largest_free_rectangles+1;
            mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles}=mrec_current_reduced_rectangle;
            %             temp_rectangle=mrec_new_largest_free_rectangles{index_of_mrec_new_largest_free_rectangles};
            %             rectangle('position',[temp_rectangle(1),temp_rectangle(2),...
            %                 temp_rectangle(3)-temp_rectangle(1)+1,temp_rectangle(4)-temp_rectangle(2)+1],'FaceColor','r');
        end
    end
    mrec_largest_free_rectangles=mrec_new_largest_free_rectangles;
end
%     mrec_largest_free_rectangles=[];
% mrec_largest_free_rectangles=mrec_new_largest_free_rectangles;
% figure(550);
% clf;
% rectangle('position',rec_bounded_surface);
% for k=1:length(mrec_largest_free_rectangles)
%     rec_current_rectangle=mrec_largest_free_rectangles{k};
%     rec_current_rectangle(3)=rec_current_rectangle(3)-rec_current_rectangle(1)+1;
%     rec_current_rectangle(4)=rec_current_rectangle(4)-rec_current_rectangle(2)+1;
%     rectangle('position',rec_current_rectangle,'FaceColor','r');
% end
% At this point we have a set of largest_free_rectangles. Now we need to find a rectangle large enough to place the input
% rectangle in it. The first step is to find all the rectangles that are large enough to hold the input rectangle. Among these
% rectangles we will select the one which has the highest y value and place the rec_input_rectangle in it. The reason for this
% selection is that I wrote this routine to use it in Matlab to place figures on the monitors such that they do not overlap with
% other existing figures and I prefer my figures to be as close to the top of the monitor as possible.
% rec_selected_rectangle=[0,0,rec_input_rectangle(3),rec_input_rectangle(4)];
max_y_of_rec_selected_rectangle=-realmax;
input_rectangle_was_placed_without_overlap_flag=0;
% for k=1:length(mrec_largest_free_rectangles)
%     mrec_current_largest_free_rectangles=mrec_largest_free_rectangles{k};
%     if (rec_input_rectangle(3) <= (mrec_current_largest_free_rectangles(3)-mrec_current_largest_free_rectangles(1)+1)) && ...
%             (rec_input_rectangle(4) <= (mrec_current_largest_free_rectangles(4)-mrec_current_largest_free_rectangles(2)+1))
%         % mrec_current_largest_free_rectangles is large enough to hold input rectangle
%         if (mrec_current_largest_free_rectangles(4)> max_y_of_rec_selected_rectangle)
%             x=mrec_current_largest_free_rectangles(1);
%             max_y_of_rec_selected_rectangle=mrec_current_largest_free_rectangles(4);
%             input_rectangle_was_placed_without_overlap_flag=1;
%         end
%     end
% end
% if input_rectangle_was_placed_without_overlap_flag
%     rec_selected_rectangle(1)=x;
%     y=max_y_of_rec_selected_rectangle-rec_input_rectangle(4);
% else
% No rectangle was large enough to include the rec_input_rectangle. Just find the rectangle which has minimum overlap with the
% rec_existing_rectangles.
area_of_rec_selected_rectangle=rec_selected_rectangle(3)*rec_selected_rectangle(4)-0.000001;
intersection_area=realmax;
x=0;
y=0;
for k=1:length(mrec_largest_free_rectangles)
    mrec_current_largest_free_rectangles=mrec_largest_free_rectangles{k};
    % Try to place the rec_input_rectangle on the lower right corner of the mrec_current_largest_free_rectangles.
    rec_selected_rectangle(1)=mrec_current_largest_free_rectangles(3)-rec_input_rectangle(3);
    rec_selected_rectangle(2)=mrec_current_largest_free_rectangles(2);
    if (area_of_rec_selected_rectangle)<= rectint(rec_selected_rectangle,rec_bounded_surface)
        % The extends of the rec_selected_rectangle will not go beyond the rec_bounded_surface.
        temp_intersection=0;
        for m=1:length(rec_existing_rectangles)
            temp_intersection=temp_intersection+rectint(rec_selected_rectangle,rec_existing_rectangles{m});
        end
        if temp_intersection <= intersection_area
            if temp_intersection < intersection_area
                % The intersection area between the mrec_current_largest_free_rectangles and the rec_input_rectangle is less than the previous intersection area
                intersection_area=temp_intersection;
                x=rec_selected_rectangle(1);
                y=rec_selected_rectangle(2);
            else
                if (y<rec_selected_rectangle(2))
                    %Select the rectangle which has larger y (higher) and smaller x (left)
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                elseif (y==rec_selected_rectangle(2)) && (x>rec_selected_rectangle(1))
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                end
            end
        end
    end
    % Try to place the rec_input_rectangle on the lower left corner of the mrec_current_largest_free_rectangles.
    rec_selected_rectangle(1)=mrec_current_largest_free_rectangles(1);
    rec_selected_rectangle(2)=mrec_current_largest_free_rectangles(2);
    if (area_of_rec_selected_rectangle)<= rectint(rec_selected_rectangle,rec_bounded_surface)
        % The extends of the rec_selected_rectangle will not go beyond the rec_bounded_surface.
        temp_intersection=0;
        for m=1:length(rec_existing_rectangles)
            temp_intersection=temp_intersection+rectint(rec_selected_rectangle,rec_existing_rectangles{m});
        end
        if temp_intersection <= intersection_area
            if temp_intersection < intersection_area
                % The intersection area between the mrec_current_largest_free_rectangles and the rec_input_rectangle is less than the previous intersection area
                intersection_area=temp_intersection;
                x=rec_selected_rectangle(1);
                y=rec_selected_rectangle(2);
            else
                if (y<rec_selected_rectangle(2))
                    %Select the rectangle which has larger y (higher) and smaller x (left)
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                elseif (y==rec_selected_rectangle(2)) && (x>rec_selected_rectangle(1))
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                end
            end
        end
    end
    % Try to place the rec_input_rectangle on the upper right corner of the mrec_current_largest_free_rectangles.
    rec_selected_rectangle(1)=mrec_current_largest_free_rectangles(3)-rec_input_rectangle(3);
    rec_selected_rectangle(2)=mrec_current_largest_free_rectangles(4)-rec_input_rectangle(4)-1;
    if (area_of_rec_selected_rectangle)<= rectint(rec_selected_rectangle,rec_bounded_surface)
        % The extends of the rec_selected_rectangle will not go beyond the rec_bounded_surface.
        temp_intersection=0;
        for m=1:length(rec_existing_rectangles)
            temp_intersection=temp_intersection+rectint(rec_selected_rectangle,rec_existing_rectangles{m});
        end
        if temp_intersection <= intersection_area
            if temp_intersection < intersection_area
                % The intersection area between the mrec_current_largest_free_rectangles and the rec_input_rectangle is less than the previous intersection area
                intersection_area=temp_intersection;
                x=rec_selected_rectangle(1);
                y=rec_selected_rectangle(2);
            else
                if (y<rec_selected_rectangle(2))
                    %Select the rectangle which has larger y (higher) and smaller x (left)
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                elseif (y==rec_selected_rectangle(2)) && (x>rec_selected_rectangle(1))
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                end
            end
        end
    end
    
    % Try to place the rec_input_rectangle on the upper left corner of the mrec_current_largest_free_rectangles.
    rec_selected_rectangle(1)=mrec_current_largest_free_rectangles(1);
    rec_selected_rectangle(2)=mrec_current_largest_free_rectangles(4)-rec_input_rectangle(4)-1;
    if (area_of_rec_selected_rectangle) <= rectint(rec_selected_rectangle,rec_bounded_surface)
        % The extends of the rec_selected_rectangle will not go beyond the rec_bounded_surface.
        %
        %         if (rec_selected_rectangle(1)>bounded_surface_min_x) && ...
        %             (rec_selected_rectangle(2)>bounded_surface_min_y) && ...
        %             ((rec_selected_rectangle(1)+rec_selected_rectangle(3))< bounded_surface_max_x) && ...
        %             ((rec_selected_rectangle(2)+rec_selected_rectangle(4))< bounded_surface_max_y)
        temp_intersection=0;
        for m=1:length(rec_existing_rectangles)
            temp_intersection=temp_intersection+rectint(rec_selected_rectangle,rec_existing_rectangles{m});
        end
        if temp_intersection <= intersection_area
            if temp_intersection < intersection_area
                % The intersection area between the mrec_current_largest_free_rectangles and the rec_input_rectangle is less than the previous intersection area
                intersection_area=temp_intersection;
                x=rec_selected_rectangle(1);
                y=rec_selected_rectangle(2);
            else
                if (y<rec_selected_rectangle(2))
                    %Select the rectangle which has larger y (higher) and smaller x (left)
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                elseif (y==rec_selected_rectangle(2)) && (x>rec_selected_rectangle(1))
                    x=rec_selected_rectangle(1);
                    y=rec_selected_rectangle(2);
                end
            end
        end
    end
    
    
end
rec_selected_rectangle(1)=x;
rec_selected_rectangle(2)=y;
%
% % Test the results
% figure(551);
% clf
% for k=1:length(mrec_largest_free_rectangles)
%
%     rec_current_rectangle=mrec_largest_free_rectangles{k};
%     rec_current_rectangle(3)=rec_current_rectangle(3)-rec_current_rectangle(1)+1;
%     rec_current_rectangle(4)=rec_current_rectangle(4)-rec_current_rectangle(2)+1;
%     rectangle('position',rec_current_rectangle,'FaceColor','r');
% end
% % rectangle('position',[x,y,rec_input_rectangle(3),rec_input_rectangle(4)],'FaceColor','y');
% rectangle('position',rec_selected_rectangle,'linewidth',3,'edgecolor','b');
%


    function rectangle=return_interesection_of_two_rectangles(rectangle_a,rectangle_b)
        if rectint(rectangle_a,rectangle_b)<=0;
%             Two rectangles do not intersect
            rectangle=[];
            return
        end
        rectangle(1)=max(rectangle_a(1),rectangle_b(1));
        rectangle(2)=max(rectangle_a(2),rectangle_b(2));
        rectangle(3)=min(rectangle_a(1)+rectangle_a(3),rectangle_b(1)+rectangle_b(3))-rectangle(1);
        rectangle(4)=min(rectangle_a(2)+rectangle_a(4),rectangle_b(2)+rectangle_b(4))-rectangle(2);
        
    end
end


