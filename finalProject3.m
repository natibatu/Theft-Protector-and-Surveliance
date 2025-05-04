% Load the C major scale frequencies
load('c_major_scale.mat');
fprintf('C major scale loaded.\n');

% Create Arduino objects for ultrasonic sensor and buzzer
arduinoUltrasonic = arduino('/dev/cu.usbmodem101', 'Uno', 'Libraries', 'Ultrasonic');
arduinoBuzzer = arduino("/dev/tty.SLAB_USBtoUART", 'Nano3');
fprintf('Arduino objects created.\n');

% Ultrasonic sensor pin configuration
ultrasonicTriggerPin = 'D9';
ultrasonicEchoPin = 'D10';
LightThreshold = 0.5;
Thresholddistance=1;
fprintf('Ultrasonic sensor pins configured.\n');

% Set up the ultrasonic sensor
ultrasonicSensor = ultrasonic(arduinoUltrasonic, ultrasonicTriggerPin, ultrasonicEchoPin);
fprintf('Ultrasonic sensor set up.\n');

% Buzzer pin
buzzerPin = 'D5';



while true
    % Measure distance in centimeters
   
    distance = readDistance(ultrasonicSensor);
% Check if it's dark outside using a custom function
isDark = isitdarkout(arduinoBuzzer, LightThreshold);

    if isDark
        fprintf('Theft protection activated.\n');
        if distance < Thresholddistance
            lightOn(arduinoBuzzer);
             
            fprintf('Unauthorized access detected. Theft protection activated.\n');
             fprintf('Distance: %.2f cm\n', distance);
                 activateAlarm(arduinoBuzzer, buzzerPin, c_major_scale);

             lightOff(arduinoBuzzer);
            % Create a webcam object and capture an image
            fprintf('Distance: %.2f m\n', distance);
            cam = webcam;
            fprintf('Webcam initialized.\n');
            pause(2);
            img = snapshot(cam);
            preprocessedImg = preprocessImage(img);
            imshow(preprocessedImg);
            
            % Save the captured image
            fileName = 'img.jpg';  % You can change the file name as needed
            filePath = fullfile(pwd, fileName);  % Save in the current working directory
            imwrite(preprocessedImg, filePath, 'jpg');
            imshow(preprocessedImg);
            clear cam;
            fprintf('Image saved.\n')
           
        else
            fprintf('No one detected\n');
        end
        
            
    else
        disp('Theft protection alarm is off; it is daytime.');
    end
     disp('Press button or touch the sensor to deactivate TheftProtector ');
            pause(3);
               % Check if the button or touch sensor is pressed
            buttonState = readDigitalPin(arduinoBuzzer, 'D6');
            touchSensor = readDigitalPin(arduinoUltrasonic, 'A0');
            if buttonState || touchSensor
              lightOff(arduinoBuzzer);
              fprintf('Theft Protector Deactivated...')
            break;  % Exit the while loop
            end
end
clear;
% Function to activate the alarm (buzzer)
function activateAlarm(arduino, pin, c_major_scale)
    fprintf('Activating the alarm...\n');
    % Play a tune on the buzzer
    for i = 1:7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
        playTone(arduino, pin, c_major_scale(i), 4);
        pause(0.5);
    end
    configurePin(arduino, pin, 'Unset');
    fprintf('Alarm deactivated.\n');
end

% Function to preprocess the captured image
function preprocessedImg = preprocessImage(img)
    fprintf('Preprocessing the captured image...\n');
    % Convert the image to grayscale (assuming it's not already grayscale)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Resize the image to a common size (e.g., 100x100 pixels)
    targetSize = [100, 100];
    img = imresize(img, targetSize);

    preprocessedImg = img;
    fprintf('Image preprocessing complete.\n');
end

% Function to turn on the light
function lightOn(arduino)
    writeDigitalPin(arduino, 'D4', 1);
    fprintf('Light turned on.\n');
end

% Function to turn off the light
function lightOff(arduino)
    writeDigitalPin(arduino, 'D4', 0);
end
% Function to check darkness
function isdark=isitdarkout(arduino,Lightthreshold)
voltage=readVoltage(arduino,'A6'); 
if voltage<Lightthreshold 
   isdark=true;
else
 isdark=false;
end
end