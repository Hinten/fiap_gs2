"""
Firebase Auth Emulator Example

This example demonstrates how to use Firebase Authentication with the Firebase Emulator.
It shows common operations like user creation, authentication, and token management.

Prerequisites:
1. Start Firebase Auth Emulator:
   firebase emulators:start --only auth --project demo-test-project

2. Set environment variable:
   export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"

3. Run this example:
   python -m example.firebase_emulator_example
"""

import os
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

import firebase_admin
from firebase_admin import auth


def setup_emulator():
    """Setup Firebase Admin SDK for emulator."""
    # Set emulator host
    os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "localhost:9099"
    
    # Initialize Firebase Admin (emulator doesn't need real credentials)
    try:
        app = firebase_admin.initialize_app(options={
            'projectId': 'demo-test-project',
        })
        print("✅ Firebase Admin SDK initialized for emulator")
        return app
    except ValueError:
        # Already initialized
        app = firebase_admin.get_app()
        print("✅ Firebase Admin SDK already initialized")
        return app


def example_create_user():
    """Example: Create a new user."""
    print("\n📝 Creating a new user...")
    
    user = auth.create_user(
        email='demo@example.com',
        password='demoPassword123',
        display_name='Demo User',
        email_verified=False
    )
    
    print(f"✅ User created successfully!")
    print(f"   UID: {user.uid}")
    print(f"   Email: {user.email}")
    print(f"   Display Name: {user.display_name}")
    
    return user.uid


def example_get_user(uid):
    """Example: Get user by UID."""
    print(f"\n🔍 Fetching user by UID: {uid}")
    
    user = auth.get_user(uid)
    
    print(f"✅ User retrieved:")
    print(f"   UID: {user.uid}")
    print(f"   Email: {user.email}")
    print(f"   Email Verified: {user.email_verified}")
    print(f"   Created: {user.user_metadata.creation_timestamp}")
    
    return user


def example_get_user_by_email(email):
    """Example: Get user by email."""
    print(f"\n🔍 Fetching user by email: {email}")
    
    user = auth.get_user_by_email(email)
    
    print(f"✅ User found:")
    print(f"   UID: {user.uid}")
    print(f"   Email: {user.email}")
    
    return user


def example_update_user(uid):
    """Example: Update user information."""
    print(f"\n✏️  Updating user: {uid}")
    
    updated_user = auth.update_user(
        uid,
        display_name='Demo User (Updated)',
        email_verified=True,
        phone_number='+1234567890'
    )
    
    print(f"✅ User updated:")
    print(f"   Display Name: {updated_user.display_name}")
    print(f"   Email Verified: {updated_user.email_verified}")
    print(f"   Phone: {updated_user.phone_number}")
    
    return updated_user


def example_set_custom_claims(uid):
    """Example: Set custom claims (roles, tenant, etc.)."""
    print(f"\n🔐 Setting custom claims for user: {uid}")
    
    auth.set_custom_user_claims(uid, {
        'role': 'admin',
        'tenant_id': 'tenant-123',
        'permissions': ['read', 'write', 'delete']
    })
    
    # Retrieve to verify
    user = auth.get_user(uid)
    
    print(f"✅ Custom claims set:")
    print(f"   Role: {user.custom_claims.get('role')}")
    print(f"   Tenant ID: {user.custom_claims.get('tenant_id')}")
    print(f"   Permissions: {user.custom_claims.get('permissions')}")
    
    return user


def example_create_custom_token(uid):
    """Example: Create a custom token for client-side authentication."""
    print(f"\n🎫 Creating custom token for user: {uid}")
    
    custom_token = auth.create_custom_token(uid)
    
    print(f"✅ Custom token created:")
    print(f"   Token: {custom_token.decode('utf-8')[:50]}...")
    print(f"   (Token can be used by client apps to sign in)")
    
    return custom_token


def example_list_users():
    """Example: List all users."""
    print("\n📋 Listing all users...")
    
    page = auth.list_users()
    users = list(page.iterate_all())
    
    print(f"✅ Found {len(users)} user(s):")
    for i, user in enumerate(users, 1):
        print(f"   {i}. {user.email} (UID: {user.uid})")
    
    return users


def example_delete_user(uid):
    """Example: Delete a user."""
    print(f"\n🗑️  Deleting user: {uid}")
    
    auth.delete_user(uid)
    
    print(f"✅ User deleted successfully")


def example_disable_enable_user(uid):
    """Example: Disable and then re-enable a user."""
    print(f"\n🔒 Disabling user: {uid}")
    
    # Disable user
    auth.update_user(uid, disabled=True)
    user = auth.get_user(uid)
    print(f"✅ User disabled: {user.disabled}")
    
    # Re-enable user
    print(f"\n🔓 Re-enabling user: {uid}")
    auth.update_user(uid, disabled=False)
    user = auth.get_user(uid)
    print(f"✅ User re-enabled: {not user.disabled}")


def run_examples():
    """Run all examples."""
    print("=" * 70)
    print("Firebase Auth Emulator - Example Application")
    print("=" * 70)
    
    try:
        # Setup
        app = setup_emulator()
        
        # Run examples
        uid = example_create_user()
        example_get_user(uid)
        example_get_user_by_email('demo@example.com')
        example_update_user(uid)
        example_set_custom_claims(uid)
        example_create_custom_token(uid)
        example_disable_enable_user(uid)
        example_list_users()
        
        # Cleanup
        example_delete_user(uid)
        
        print("\n" + "=" * 70)
        print("✅ All examples completed successfully!")
        print("=" * 70)
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    finally:
        # Cleanup Firebase app
        try:
            firebase_admin.delete_app(app)
        except:
            pass


if __name__ == '__main__':
    run_examples()
