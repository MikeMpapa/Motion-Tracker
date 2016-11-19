%Papakostas,Michalis
%1001110587
%2015-02-06
%Assignment_01


function motion_detection(Camera_number,...
    total_number_of_frames_to_process,...
    motion_threshold,...
    number_of_frames_to_skip,...
    number_of_largest_objects_to_track,...
    hysteresis_for_tracking,...
    hysteresis_for_no_tracking,...
    frames_to_track_objects,...
    minimum_possible_object,...
    minimum_track_distance)
% Farhad Kamangar Jan 20, 2015.
% Camera_number= intslider {1,1,10};
% total_number_of_frames_to_process = intslider{100,1,10000};
% motion_threshold= intslider{20,1,255};
% number_of_frames_to_skip = intslider{1,1,100};
% number_of_largest_objects_to_track=intslider{3,1,100};
% hysteresis_for_tracking=intslider{5,1,100};
% hysteresis_for_no_tracking=intslider{5,1,100};
% frames_to_track_objects=intslider{3,1,15};
% minimum_possible_object=intslider{1000,50,30000};
% minimum_track_distance=intslider{100,50,400};



% Camera_number = 1;
% total_number_of_frames_to_process = 250;
% motion_threshold = 20;
% number_of_frames_to_skip = 1;
% number_of_largest_objects_to_track = 2;
% hysteresis_for_tracking = 5;
% hysteresis_for_no_tracking = 7;
% frames_to_track_objects = 6;
% minimum_possible_object = 1000; %pixels of area
% minimum_track_distance = 200; %pixels to accept the objects track

display_arguments();

%Other variables
colors = ['y';'b';'r';'g';'m';'c';'w';'k'];
empty_track = -1 ;%flag to recognise an empty track
assigned_centroids =[];

%Object variables
hysterisis_lock = zeros(1,number_of_largest_objects_to_track); %histeris to lock
hysterisis_unlock = zeros(1,number_of_largest_objects_to_track); %histeris to lock
track_index = zeros(number_of_largest_objects_to_track,1); %object history
track = NaN(frames_to_track_objects,2,number_of_largest_objects_to_track); %frames to track an object



camera_list = webcamlist;
current_camera = webcam(Camera_number);
current_frame = snapshot(current_camera);
previous_frame = current_frame;
gray_current_frame = double(rgb2gray(current_frame));
gray_previous_frame = double(rgb2gray(current_frame));
gray_previous_previous_frame = double(rgb2gray(current_frame));
[fig_handle_1,subplot_handles_1] = display_and_place_a_figure('Motion Detection','number_of_subplots',4);se = strel('disk',6);




for frame_index = 1 : total_number_of_frames_to_process
    frame_index;
    current_frame = snapshot(current_camera);
    subplot_index = 1;
   
    
    if mod(frame_index,number_of_frames_to_skip)==0
    

    gray_previous_previous_frame=gray_previous_frame;
    gray_previous_frame=gray_current_frame;
    gray_current_frame=double(rgb2gray(current_frame));
    diff_1=abs(gray_current_frame-gray_previous_frame);
    diff_2=abs(gray_previous_frame-gray_previous_previous_frame);
    motion_frame=min(diff_1,diff_2);
    axes(subplot(subplot_handles_1(subplot_index)));
    subplot_index=subplot_index+1;
    imagesc(motion_frame);
    
    thresholded_frame=motion_frame>motion_threshold;
    [labels, number] = bwlabel(thresholded_frame, 8);
    colored_labeled_frame = label2rgb(labels, @hsv, [0,0,0], 'shuffle');
    axes(subplot(subplot_handles_1(subplot_index)));
    subplot_index=subplot_index+1;
    imagesc(colored_labeled_frame);
    dilated_image = imdilate(thresholded_frame,se);
    
    [labels, number] = bwlabel(dilated_image, 8);
    dialated_colored_labeled_frame = label2rgb(labels, @hsv, [0,0,0], 'shuffle');
    axes(subplot(subplot_handles_1(subplot_index)));
    subplot_index=subplot_index+1;
    imagesc(dialated_colored_labeled_frame);
    
    current_frame;
    axes(subplot(subplot_handles_1(subplot_index)));
    subplot_index=subplot_index+1;
    imagesc(current_frame);

    s = regionprops(dilated_image, 'Area','Centroid','BoundingBox');
   
    
    
    if  size(s,1) > 0
        
        % MICHALIS PAPAKOSTAS-PHD CANDIDATE
        % DEP. OF COMPUTER SCIENCE-UNIVERISTY OF TEXAS,ARLINGTON
        % SPRING 2015 
        % CSE6367-COMPUTER VISION-PROJECT1

        
        %select the objects which are largers than a specific size
        objects = cat(1,s.Area);
        indexes_largest_objects = find(objects > minimum_possible_object); 
        if length(indexes_largest_objects)>0
               
               largest_objects = sort(objects(indexes_largest_objects),'descend');
               
               if length(indexes_largest_objects) > number_of_largest_objects_to_track
                    largest_objects = largest_objects(1:number_of_largest_objects_to_track);
               end
               clear indexes_largest_objects
               for i = 1:length(largest_objects)
                        indexes_largest_objects(i) = find(objects == largest_objects(i));
               end
               
                
                %centroids of current objects
                %max(length(centroids_largest_objects)) = number_of_largest_objects_to_track
                centroids = cat(1,s.Centroid);
                centroids_largest_objects = centroids(indexes_largest_objects,:);

                %number of objects in frame to track ,
                %max_possible(objects_in_frame) = number_of_largest_objects_to_track
                objects_in_frame = length(largest_objects) ;
                
             
                
                %if no previous object has been detected (i.e 1st frame)
                if isnan(track)
                    hysterisis_unlock=zeros(1,number_of_largest_objects_to_track); %hysteris unlock is initialised
                    for i = 1:objects_in_frame
                        track_index(i) = track_index(i) + 1;                        
                        track(track_index(i),:,i) = centroids_largest_objects(i,:);
                        hysterisis_lock(i)=hysterisis_lock(i) + 1;
                    end    
                    %clea/empty variables which change from frame2frame
                    assigned_centroids=[];
                    clear indexes_largest_objects largest_objects centroids_largest_objects ;
                    continue; % all centroids assigned --> go to the next frame
                end
                
                
                
                %Compare current centroids to previous
                index = 1;
                for i = 1:number_of_largest_objects_to_track %for all the objects
                    no_matched_object = 0;
                    for j = 1:size(centroids_largest_objects,1) %for all the centroids
                        if track_index(i) > 0 %if the track is not empty
                            track_distance = pdist2(centroids_largest_objects(j,:),track(track_index(i),:,i)); %find the distance
                            %if the centroid has already been assigned we
                            %skip it
                            if find(assigned_centroids == j) > 0
                                continue;
                            end
                            if track_distance < minimum_track_distance %if it is close assign it
                                assigned_centroids(index) = j;
                                no_matched_object = 1;
                                index = index+1;
                                hysterisis_unlock(i) = 0; 
                                hysterisis_lock(i) = hysterisis_lock(i)+1;                            
                                track_index(i) = track_index(i) + 1;                               
                                track(track_index(i),:,i) = centroids_largest_objects(j,:);
                                break;
                            end
                        else
                            empty_track = i; %if we have an empty track we store its index
                        end
                    end
                    %the object wasn't found in this frame
                    if no_matched_object == 0
                        hysterisis_unlock(i) = hysterisis_unlock(i)+1;
                    end
                end
                
                
                 

                
                %if we have an empty track and a new object we
                %assign this object to that track
                if length(assigned_centroids) < size(centroids_largest_objects,1) && empty_track ~= -1
                   for i =1 : number_of_largest_objects_to_track
                        for j = 1 : size(centroids_largest_objects,1)
                            %find which centroid is unassigned
                            if find(assigned_centroids == j) > 0 
                                continue;
                            else
                                unassigned_centroid_index = j; 
                                break;
                            end
                        end
                       % assign the centroid to the empty track
                        hysterisis_lock(empty_track) =  hysterisis_lock(empty_track) + 1;
                        hysterisis_unlock(empty_track) = 0;                       
                        track_index(empty_track) = track_index(empty_track) + 1;                       
                        track( track_index(empty_track),:,empty_track) = centroids_largest_objects(unassigned_centroid_index,:);
                        empty_track = -1;
                        unassigned_centroid_index = -1;
                        break;
                    end
                end
                
                %check if all objects are still valid
                for i =1 : number_of_largest_objects_to_track
                    %if no_track hysterisis threshold reached delete object 
                     if hysterisis_unlock(i) >= hysteresis_for_no_tracking 
                         track(:,:,i) = nan;
                         hysterisis_lock(i) = 0;
                         track_index(i) = 0;
                         hysterisis_unlock(i) = 0;
                         continue;
                     end
                end


         %plot objects in the frame
         for i = 1:objects_in_frame             
                                    
             %if track hysterisis threshold reached and the object is in the frame --> plot track
             if hysterisis_lock(i) >= hysteresis_for_tracking & hysterisis_unlock(i) == 0
                      hold on
                      x = track(:,1,i)';
                      y = track(:,2,i)';
                      plot(x,y,[colors(i) '-s']);
             end
             
             % Plot detected Objects  
             index = indexes_largest_objects(i);
             rec = s(index).BoundingBox;
             rectangle('Position',rec,'edgeColor',colors(i));
             hold on
             plot(s(index).Centroid(1),s(index).Centroid(2),['w+']);            
             
         end
         
         
         %track_index --> check if we reached the tracking limit 
         %If 'YES' --> delete the first detected position
         for i = 1 : number_of_largest_objects_to_track
             if track_index(i) == frames_to_track_objects
                  track_index(i) = track_index(i) - 1;
                  track(1:end-1,:,i) =  track(2:end,:,i);
                  track(end,:,i) = nan;
             end
         end
                    
        %clea/empty variables which change from frame2frame
        assigned_centroids=[];
        clear indexes_largest_objects largest_objects centroids_largest_objects ;
        else
            % if no large enough objects were found in the frame increase
            % hystrisis of all previously found objects
            hysterisis_unlock = hysterisis_unlock + 1;
            tmp = find(hysterisis_unlock >= hysteresis_for_no_tracking);
            track(:,:,tmp) = nan;
            hysterisis_lock(tmp) = 0;
            track_index(tmp) = 0;
            hysterisis_unlock(tmp) = 0;
            
            %clear/empty variables which change from frame2frame
            assigned_centroids=[];
            clear indexes_largest_objects largest_objects centroids_largest_objects ;

            continue; % empty frame --> go to the next frame
        
        end
        
       
    else
        % if no objects were found in the frame increase
        % hystrisis of all previously found objects
        hysterisis_unlock = hysterisis_unlock + 1;
        tmp = find(hysterisis_unlock >= hysteresis_for_no_tracking);
        track(:,:,tmp) = nan;
        hysterisis_lock(tmp) = 0;
        track_index(tmp) = 0;
        hysterisis_unlock(tmp) = 0;
        %clear/empty variables which change from frame2frame
        assigned_centroids=[];
        clear indexes_largest_objects largest_objects centroids_largest_objects ;

        continue; % empty frame --> go to the next frame
        
    end

    end
end
clear('current_camera');