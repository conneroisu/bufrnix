package com.example.validation;

import build.buf.protovalidate.Validator;
import build.buf.protovalidate.exceptions.ValidationException;

import com.example.protos.v1.User;
import com.example.protos.v1.UserProfile;

import java.util.Arrays;

public class UserValidationExample {
    public static void main(String[] args) {
        try {
            // Create a validator instance
            Validator validator = new Validator();
            
            System.out.println("=== Java Protovalidate Example ===\n");
            
            // Test 1: Valid user
            System.out.println("Test 1: Valid User");
            User validUser = createValidUser();
            testValidation(validator, validUser, "Valid User");
            
            // Test 2: Invalid user - empty name
            System.out.println("\nTest 2: Invalid User - Empty Name");
            User invalidUser1 = User.newBuilder(validUser)
                .setName("")
                .build();
            testValidation(validator, invalidUser1, "User with empty name");
            
            // Test 3: Invalid user - invalid email
            System.out.println("\nTest 3: Invalid User - Invalid Email");
            User invalidUser2 = User.newBuilder(validUser)
                .setEmail("not-an-email")
                .build();
            testValidation(validator, invalidUser2, "User with invalid email");
            
            // Test 4: Invalid user - age out of range
            System.out.println("\nTest 4: Invalid User - Age Out of Range");
            User invalidUser3 = User.newBuilder(validUser)
                .setAge(200)
                .build();
            testValidation(validator, invalidUser3, "User with age 200");
            
            // Test 5: Invalid user - too many phone numbers
            System.out.println("\nTest 5: Invalid User - Too Many Phone Numbers");
            User invalidUser4 = User.newBuilder(validUser)
                .clearPhoneNumbers()
                .addAllPhoneNumbers(Arrays.asList("+1234567890", "+1987654321", "+1122334455", "+1555666777"))
                .build();
            testValidation(validator, invalidUser4, "User with 4 phone numbers");
            
            // Test 6: Invalid user - duplicate phone numbers
            System.out.println("\nTest 6: Invalid User - Duplicate Phone Numbers");
            User invalidUser5 = User.newBuilder(validUser)
                .clearPhoneNumbers()
                .addAllPhoneNumbers(Arrays.asList("+1234567890", "+1234567890"))
                .build();
            testValidation(validator, invalidUser5, "User with duplicate phone numbers");
            
            // Test 7: Invalid user profile - neither bio nor website
            System.out.println("\nTest 7: Invalid User Profile - No Bio or Website");
            UserProfile invalidProfile = UserProfile.newBuilder()
                .addPreferences("coding")
                .build();
            User invalidUser6 = User.newBuilder(validUser)
                .setProfile(invalidProfile)
                .build();
            testValidation(validator, invalidUser6, "User with invalid profile");
            
            // Test 8: Valid user profile with bio only
            System.out.println("\nTest 8: Valid User Profile - Bio Only");
            UserProfile validProfile = UserProfile.newBuilder()
                .setBio("Software developer with 5 years of experience")
                .addPreferences("coding")
                .addPreferences("reading")
                .build();
            User validUser2 = User.newBuilder(validUser)
                .setProfile(validProfile)
                .build();
            testValidation(validator, validUser2, "User with bio in profile");
            
        } catch (Exception e) {
            System.err.println("Error initializing validator: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static User createValidUser() {
        UserProfile profile = UserProfile.newBuilder()
            .setBio("A sample user profile")
            .setWebsite("https://example.com")
            .addPreferences("technology")
            .addPreferences("books")
            .build();
            
        return User.newBuilder()
            .setId(1)
            .setName("John Doe")
            .setEmail("john.doe@example.com")
            .setAge(30)
            .addPhoneNumbers("+1234567890")
            .addPhoneNumbers("+1987654321")
            .setScore(85.5)
            .setIsActive(true)
            .setProfile(profile)
            .build();
    }
    
    private static void testValidation(Validator validator, User user, String description) {
        try {
            validator.validate(user);
            System.out.println("✅ " + description + " - VALID");
        } catch (ValidationException e) {
            System.out.println("❌ " + description + " - INVALID");
            System.out.println("   Validation errors:");
            e.getViolations().forEach(violation -> 
                System.out.println("   - " + violation.getFieldPath() + ": " + violation.getMessage())
            );
        }
    }
}