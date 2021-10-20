# iOS_IMU_Reader
An iOS application that reads IMU data and saves it locally in Files.

Compiled with Xcode and tested on an iPhone X with iOS 12. 

Once activated, the app registers IMU data (accelerometere, gyroscope, magnetometer, etc.) at a frequency of 60Hz, which can be changed from within the code.
Then after clicking stop, the registered data is then saved in an .csv file that can be found in the app's dedicated sandbox in Files. 
Which then can be easily shared with other devices for further treatement.
