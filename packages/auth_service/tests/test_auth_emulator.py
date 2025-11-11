"""
Tests for Firebase Authentication using Firebase Emulator.

These tests run against the Firebase Auth Emulator and validate:
- User creation
- User authentication
- Token verification
- User management operations

Requirements:
- Firebase Auth Emulator must be running on localhost:9099
- Start with: firebase emulators:start --only auth --project demo-test-project
"""

import os
import pytest
import firebase_admin
from firebase_admin import auth, credentials
from auth_service.firebase_admin import init_firebase_admin, get_auth_client


# Configure emulator environment before importing firebase_admin
os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "localhost:9099"
os.environ["FIREBASE_PROJECT_ID"] = "demo-test-project"
os.environ["FIREBASE_SERVICE_ACCOUNT_JSON"] = ""


@pytest.fixture(scope="module")
def firebase_app():
    """Initialize Firebase Admin with emulator configuration."""
    # Clean up any existing Firebase apps
    try:
        firebase_admin.delete_app(firebase_admin.get_app())
    except ValueError:
        pass  # No app initialized yet
    
    # For emulator, we can use a simple initialization with just project ID
    # The emulator doesn't require actual credentials
    app = firebase_admin.initialize_app(options={
        'projectId': 'demo-test-project',
    })
    
    yield app
    
    # Cleanup
    firebase_admin.delete_app(app)


@pytest.fixture
def cleanup_users():
    """Cleanup test users after each test."""
    created_uids = []
    
    def track_user(uid):
        created_uids.append(uid)
        return uid
    
    yield track_user
    
    # Delete all created users
    for uid in created_uids:
        try:
            auth.delete_user(uid)
        except Exception:
            pass  # User might already be deleted


class TestFirebaseAuthEmulator:
    """Test Firebase Auth operations against the emulator."""
    
    def test_create_user(self, firebase_app, cleanup_users):
        """Test creating a user in the emulator."""
        # Create a user
        user = auth.create_user(
            email='test@example.com',
            password='password123',
            display_name='Test User',
            email_verified=False
        )
        
        cleanup_users(user.uid)
        
        # Verify user was created
        assert user.uid is not None
        assert user.email == 'test@example.com'
        assert user.display_name == 'Test User'
        assert user.email_verified is False
        
        # Retrieve the user to confirm
        fetched_user = auth.get_user(user.uid)
        assert fetched_user.email == 'test@example.com'
    
    def test_get_user_by_email(self, firebase_app, cleanup_users):
        """Test retrieving a user by email."""
        # Create a user
        user = auth.create_user(
            email='getbyemail@example.com',
            password='password123'
        )
        cleanup_users(user.uid)
        
        # Retrieve by email
        fetched_user = auth.get_user_by_email('getbyemail@example.com')
        assert fetched_user.uid == user.uid
        assert fetched_user.email == 'getbyemail@example.com'
    
    def test_update_user(self, firebase_app, cleanup_users):
        """Test updating user information."""
        # Create a user
        user = auth.create_user(
            email='update@example.com',
            password='password123'
        )
        cleanup_users(user.uid)
        
        # Update the user
        updated_user = auth.update_user(
            user.uid,
            display_name='Updated Name',
            email_verified=True
        )
        
        assert updated_user.display_name == 'Updated Name'
        assert updated_user.email_verified is True
    
    def test_delete_user(self, firebase_app):
        """Test deleting a user."""
        # Create a user
        user = auth.create_user(
            email='delete@example.com',
            password='password123'
        )
        
        # Delete the user
        auth.delete_user(user.uid)
        
        # Verify user was deleted
        with pytest.raises(auth.UserNotFoundError):
            auth.get_user(user.uid)
    
    def test_create_custom_token(self, firebase_app, cleanup_users):
        """Test creating a custom token for a user."""
        # Create a user
        user = auth.create_user(
            email='customtoken@example.com',
            password='password123'
        )
        cleanup_users(user.uid)
        
        # Create custom token
        custom_token = auth.create_custom_token(user.uid)
        
        assert custom_token is not None
        assert isinstance(custom_token, (str, bytes))
    
    def test_set_custom_user_claims(self, firebase_app, cleanup_users):
        """Test setting custom claims on a user."""
        # Create a user
        user = auth.create_user(
            email='claims@example.com',
            password='password123'
        )
        cleanup_users(user.uid)
        
        # Set custom claims
        auth.set_custom_user_claims(user.uid, {
            'role': 'admin',
            'tenant_id': 'test-tenant'
        })
        
        # Retrieve and verify claims
        updated_user = auth.get_user(user.uid)
        assert updated_user.custom_claims.get('role') == 'admin'
        assert updated_user.custom_claims.get('tenant_id') == 'test-tenant'
    
    def test_list_users(self, firebase_app, cleanup_users):
        """Test listing users."""
        # Create multiple users
        user1 = auth.create_user(email='list1@example.com', password='password123')
        user2 = auth.create_user(email='list2@example.com', password='password123')
        cleanup_users(user1.uid)
        cleanup_users(user2.uid)
        
        # List users
        page = auth.list_users()
        users = list(page.iterate_all())
        
        # Verify our users are in the list
        emails = [u.email for u in users]
        assert 'list1@example.com' in emails
        assert 'list2@example.com' in emails
    
    def test_verify_custom_token_fails_with_invalid_token(self, firebase_app):
        """Test that verifying an invalid token raises an error."""
        with pytest.raises(Exception):  # Will raise various auth exceptions
            auth.verify_id_token('invalid-token-string')


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
