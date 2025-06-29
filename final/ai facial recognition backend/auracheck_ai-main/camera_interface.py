import sys
import os
import cv2
from PyQt5.QtWidgets import (QApplication, QWidget, QPushButton, QVBoxLayout, QHBoxLayout, 
                            QLabel, QMessageBox, QDialog, QRadioButton, QGroupBox)
from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtGui import QImage, QPixmap
import tempfile

class CameraWindow(QDialog):
    def __init__(self, parent=None, mode="register"):
        super().__init__(parent)
        self.mode = mode  # "register" or "verify"
        self.captured_image = None
        self.temp_image_path = None
        self.latitude = None
        self.longitude = None
        
        # Set up the camera
        self.cap = cv2.VideoCapture(0)
        if not self.cap.isOpened():
            QMessageBox.critical(self, "Camera Error", "Failed to open camera!")
            self.close()
            return
        
        self.initUI()
        
        # Timer for updating camera feed
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_frame)
        self.timer.start(30)  # Update every 30ms
    
    def initUI(self):
        # Main layout
        main_layout = QVBoxLayout()
        
        # Camera view
        self.camera_label = QLabel()
        self.camera_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(self.camera_label)
        
        # Buttons layout
        button_layout = QHBoxLayout()
        
        # Capture button
        self.capture_btn = QPushButton("Capture")
        self.capture_btn.clicked.connect(self.capture_image)
        button_layout.addWidget(self.capture_btn)
        
        # Confirm button (initially disabled)
        self.confirm_btn = QPushButton("Confirm")
        self.confirm_btn.clicked.connect(self.confirm_image)
        self.confirm_btn.setEnabled(False)
        button_layout.addWidget(self.confirm_btn)
        
        # Retake button (initially disabled)
        self.retake_btn = QPushButton("Retake")
        self.retake_btn.clicked.connect(self.retake_image)
        self.retake_btn.setEnabled(False)
        button_layout.addWidget(self.retake_btn)
        
        # Cancel button
        self.cancel_btn = QPushButton("Cancel")
        self.cancel_btn.clicked.connect(self.reject)
        button_layout.addWidget(self.cancel_btn)
        
        # Add button layout to main layout
        main_layout.addLayout(button_layout)
        
        # Location input for verify mode
        if self.mode == "verify":
            location_group = QGroupBox("Location")
            location_layout = QVBoxLayout()
            
            # For a real application, you would integrate with GPS or allow manual input
            # Here we're just setting default values for demonstration
            self.latitude = 37.7749
            self.longitude = -122.4194
            
            location_info = QLabel(f"Using default location: Lat {self.latitude}, Long {self.longitude}")
            location_layout.addWidget(location_info)
            
            location_group.setLayout(location_layout)
            main_layout.addWidget(location_group)
        
        # Set window properties
        self.setLayout(main_layout)
        title = "Registration Camera" if self.mode == "register" else "Verification Camera"
        self.setWindowTitle(title)
        self.resize(640, 520)
    
    def update_frame(self):
        ret, frame = self.cap.read()
        if ret:
            # Convert BGR to RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Convert to QImage and then QPixmap
            h, w, ch = frame.shape
            img = QImage(frame.data, w, h, ch * w, QImage.Format_RGB888)
            pixmap = QPixmap.fromImage(img)
            
            # Scale the pixmap to fit the label while maintaining aspect ratio
            pixmap = pixmap.scaled(self.camera_label.width(), self.camera_label.height(), 
                                  Qt.KeepAspectRatio)
            
            # Update the label
            self.camera_label.setPixmap(pixmap)
    
    def capture_image(self):
        ret, frame = self.cap.read()
        if ret:
            self.captured_image = frame
            self.timer.stop()  # Stop the camera feed
            
            # Show the captured image
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w, ch = frame.shape
            img = QImage(frame.data, w, h, ch * w, QImage.Format_RGB888)
            pixmap = QPixmap.fromImage(img)
            pixmap = pixmap.scaled(self.camera_label.width(), self.camera_label.height(), 
                                  Qt.KeepAspectRatio)
            self.camera_label.setPixmap(pixmap)
            
            # Enable confirm and retake buttons
            self.confirm_btn.setEnabled(True)
            self.retake_btn.setEnabled(True)
            self.capture_btn.setEnabled(False)
    
    def retake_image(self):
        self.captured_image = None
        self.timer.start(30)  # Restart camera feed
        
        # Reset buttons
        self.confirm_btn.setEnabled(False)
        self.retake_btn.setEnabled(False)
        self.capture_btn.setEnabled(True)
    
    def confirm_image(self):
        if self.captured_image is not None:
            # Save the image to a temporary file
            fd, temp_path = tempfile.mkstemp(suffix='.jpg')
            os.close(fd)
            cv2.imwrite(temp_path, self.captured_image)
            self.temp_image_path = temp_path
            
            # Accept and close the dialog
            self.accept()
    
    def closeEvent(self, event):
        # Release camera when window is closed
        if hasattr(self, 'cap') and self.cap.isOpened():
            self.cap.release()
        event.accept()

def take_picture_for_register():
    """
    Open camera window to take a picture for registration.
    Returns the path to the captured image if successful, None otherwise.
    """
    app = QApplication.instance() or QApplication(sys.argv)
    camera_window = CameraWindow(mode="register")
    result = camera_window.exec_()
    
    if result == QDialog.Accepted and camera_window.temp_image_path:
        return camera_window.temp_image_path
    return None

def take_picture_for_verify():
    """
    Open camera window to take a picture for verification.
    Returns a tuple of (image_path, latitude, longitude) if successful, None otherwise.
    """
    app = QApplication.instance() or QApplication(sys.argv)
    camera_window = CameraWindow(mode="verify")
    result = camera_window.exec_()
    
    if result == QDialog.Accepted and camera_window.temp_image_path:
        return (camera_window.temp_image_path, camera_window.latitude, camera_window.longitude)
    return None

if __name__ == "__main__":
    # Stand-alone test
    app = QApplication(sys.argv)
    result = take_picture_for_verify()
    if result:
        print(f"Image captured at: {result[0]}")
        print(f"Location: {result[1]}, {result[2]}")
    else:
        print("No image captured.")
