#!/usr/bin/env python3
"""
Comprehensive endpoint testing script for AuraCheck Attendance API
"""
import requests
import json
import os
import time
from datetime import datetime

# API Configuration
API_BASE_URL = "https://auracheck-backend-ed233cba7e31.herokuapp.com"
TEST_USER_EMAIL = "john.doe@ub.edu.cm"
TEST_USER_PASSWORD = "INS002"

class APITester:
    def __init__(self, base_url):
        self.base_url = base_url
        self.token = None
        self.session = requests.Session()
        
    def log_test(self, test_name, success, details=""):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"[{timestamp}] {status} - {test_name}")
        if details:
            print(f"    Details: {details}")
        print()
    
    def test_health_check(self):
        """Test the root health check endpoint"""
        try:
            response = self.session.get(f"{self.base_url}/")
            
            if response.status_code == 200:
                data = response.json()
                self.log_test("Health Check", True, 
                            f"Status: {data.get('status')}, Message: {data.get('message')}")
                return True
            else:
                self.log_test("Health Check", False, 
                            f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Health Check", False, f"Exception: {str(e)}")
            return False
    
    def test_login(self, email, password):
        """Test user login endpoint"""
        try:
            response = self.session.post(
                f"{self.base_url}/login",
                auth=(email, password)
            )
            
            if response.status_code == 200:
                data = response.json()
                self.token = data.get('token')
                user_info = data.get('user', {})
                self.log_test("User Login", True, 
                            f"User: {user_info.get('name')}, Role: {user_info.get('role')}")
                return True
            else:
                self.log_test("User Login", False, 
                            f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("User Login", False, f"Exception: {str(e)}")
            return False
    
    def test_register_endpoint(self):
        """Test face registration endpoint (without actual image)"""
        if not self.token:
            self.log_test("Face Registration", False, "No authentication token")
            return False
        
        try:
            headers = {'Authorization': f'Bearer {self.token}'}
            
            # Test without image file (should fail gracefully)
            response = self.session.post(
                f"{self.base_url}/attendance/register",
                headers=headers
            )
            
            if response.status_code == 400:
                error_msg = response.json().get('error', '')
                if 'No image file provided' in error_msg:
                    self.log_test("Face Registration (No Image)", True, 
                                "Correctly rejected request without image")
                    return True
            
            self.log_test("Face Registration", False, 
                        f"HTTP {response.status_code}: {response.text}")
            return False
            
        except Exception as e:
            self.log_test("Face Registration", False, f"Exception: {str(e)}")
            return False
    
    def test_verify_endpoint(self):
        """Test attendance verification endpoint (without actual image)"""
        if not self.token:
            self.log_test("Attendance Verification", False, "No authentication token")
            return False
        
        try:
            headers = {'Authorization': f'Bearer {self.token}'}
            
            # Test without image file (should fail gracefully)
            response = self.session.post(
                f"{self.base_url}/attendance/verify",
                headers=headers,
                data={
                    'latitude': '3.848',
                    'longitude': '11.502',
                    'session_id': 'test_session_123'
                }
            )
            
            if response.status_code == 400:
                error_msg = response.json().get('error', '')
                if 'No image file provided' in error_msg:
                    self.log_test("Attendance Verification (No Image)", True, 
                                "Correctly rejected request without image")
                    return True
            
            self.log_test("Attendance Verification", False, 
                        f"HTTP {response.status_code}: {response.text}")
            return False
            
        except Exception as e:
            self.log_test("Attendance Verification", False, f"Exception: {str(e)}")
            return False
    
    def test_invalid_token(self):
        """Test endpoints with invalid token"""
        try:
            headers = {'Authorization': 'Bearer invalid_token_12345'}
            
            response = self.session.post(
                f"{self.base_url}/attendance/register",
                headers=headers
            )
            
            if response.status_code == 401:
                self.log_test("Invalid Token Handling", True, 
                            "Correctly rejected invalid token")
                return True
            else:
                self.log_test("Invalid Token Handling", False, 
                            f"HTTP {response.status_code}: {response.text}")
                return False
                
        except Exception as e:
            self.log_test("Invalid Token Handling", False, f"Exception: {str(e)}")
            return False
    
    def run_all_tests(self):
        """Run all endpoint tests"""
        print("🚀 Starting AuraCheck API Endpoint Tests")
        print("=" * 50)
        
        # Test 1: Health Check
        health_ok = self.test_health_check()
        
        # Test 2: User Login  
        login_ok = self.test_login(TEST_USER_EMAIL, TEST_USER_PASSWORD)
        
        # Test 3: Protected endpoints (if login successful)
        if login_ok:
            self.test_register_endpoint()
            self.test_verify_endpoint()
        
        # Test 4: Security tests
        self.test_invalid_token()
        
        print("=" * 50)
        print("🏁 Tests completed!")
        
        return health_ok and login_ok

def main():
    """Main test runner"""
    tester = APITester(API_BASE_URL)
    success = tester.run_all_tests()
    
    if success:
        print("\n🎉 Core API endpoints are working correctly!")
        print("\nNext steps to test:")
        print("1. Test with actual image files for face registration")
        print("2. Test with valid session IDs from your database")
        print("3. Test location-based verification")
        print("4. Test with different user roles")
    else:
        print("\n⚠️  Some tests failed. Check the logs above for details.")

if __name__ == "__main__":
    main()
