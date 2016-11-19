** How to Run **

1. Run Gui.m

2. Edit the parameters (optional)

3. Press "Start Detection" button (calls the motion_detection.m function)

** PARAMETER DEFINITION **

1. camera number --> define camera device ("1" is the default machine webcam)

2. frames to process --> total number of frames to capture

3. objects to track --> total number of different detected objects to track

4. frames to track objects --> for how many frames to track an object

5. motion threshold --> threshold to detect as motion (0 < motion threshold < 1)

6. number of frames to skip --> how many frames to skip before processing the next frame (i.e number of frames to skip=0 means that you want to process all the frames)

7. minimum objects size --> minimum area in capture to identify as an object (measured in pixels)

8. hysteria for tracking --> after how many frames to lock onto a moving object

9. hysteresis for stop tracking --> after how many frames that an object has not been detected to forget its existence

10. maximum track distance between frames --> maximum distance between to sequentially processed frames to identify an object as the same object

** SYSTEM REQUIREMENTS **

1. Matlab 2014a and above

2. webcam library
