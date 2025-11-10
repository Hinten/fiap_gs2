"""Authentication API routes."""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from ..models.token import RefreshTokenRequest, Token
from ..models.user import User, UserCreate
from ..services.auth_service import auth_service

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])


@router.post("/register", response_model=User, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate):
    """
    Register a new user.

    - **email**: Valid email address
    - **full_name**: User's full name
    - **password**: Strong password (min 8 chars, 1 uppercase, 1 lowercase, 1 digit)

    Returns the created user (without password).
    """
    try:
        user = await auth_service.register_user(user_data)
        return user
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to register user: {str(e)}",
        )


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Login with email and password to get JWT tokens.

    - **username**: User's email address (OAuth2 standard uses 'username' field)
    - **password**: User's password

    Returns access and refresh tokens.
    """
    token = await auth_service.login(form_data.username, form_data.password)

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return token


@router.post("/refresh", response_model=Token)
async def refresh_token(token_request: RefreshTokenRequest):
    """
    Refresh access token using a valid refresh token.

    - **refresh_token**: Valid refresh token

    Returns new access and refresh tokens.
    """
    token = await auth_service.refresh_access_token(token_request.refresh_token)

    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return token


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout():
    """
    Logout user.

    Note: With stateless JWT tokens, logout is typically handled client-side
    by removing tokens. In a production system with a token blacklist or
    refresh token storage, this would revoke the tokens.

    For now, this is a placeholder endpoint.
    """
    # In a full implementation, this would:
    # 1. Add the access token to a blacklist (Redis/DynamoDB)
    # 2. Revoke the refresh token in the database
    # 3. Clear any server-side session data
    return None
