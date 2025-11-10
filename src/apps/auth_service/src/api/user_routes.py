"""User management API routes."""
from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, status

from ..core.dependencies import get_current_user_id, require_role
from ..models.user import User, UserUpdate
from ..services.user_service import user_service

router = APIRouter(prefix="/api/v1/users", tags=["Users"])


@router.get("/me", response_model=User)
async def get_current_user(user_id: str = Depends(get_current_user_id)):
    """
    Get current authenticated user's profile.

    Requires valid JWT token.
    """
    user = await user_service.get_user(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return user


@router.put("/me", response_model=User)
async def update_current_user(
    update_data: UserUpdate, user_id: str = Depends(get_current_user_id)
):
    """
    Update current authenticated user's profile.

    - **full_name**: Optional new full name
    - **email**: Optional new email address

    Requires valid JWT token.
    """
    try:
        user = await user_service.update_user(user_id, update_data)

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        return user
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_current_user(user_id: str = Depends(get_current_user_id)):
    """
    Delete current user account (LGPD compliance - right to be forgotten).

    This performs a soft delete by setting is_active to False.

    Requires valid JWT token.
    """
    success = await user_service.delete_user(user_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return None


@router.get("/me/data-export", response_model=Dict[str, Any])
async def export_user_data(user_id: str = Depends(get_current_user_id)):
    """
    Export all user data (LGPD compliance - data portability).

    Returns all user information in a portable JSON format.

    Requires valid JWT token.
    """
    user = await user_service.get_user(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    # Return all user data
    return {
        "user_id": user.user_id,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role,
        "oauth_provider": user.oauth_provider,
        "created_at": user.created_at.isoformat(),
        "is_active": user.is_active,
    }


# Admin endpoints
@router.get("/{user_id}", response_model=User)
async def get_user_by_id(user_id: str, _: str = Depends(require_role("admin"))):
    """
    Get user by ID (admin only).

    Requires admin role.
    """
    user = await user_service.get_user(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return user


@router.put("/{user_id}/role", response_model=User)
async def update_user_role(
    user_id: str, role: str, _: str = Depends(require_role("admin"))
):
    """
    Update user role (admin only).

    - **role**: New role (user, recruiter, admin)

    Requires admin role.
    """
    try:
        user = await user_service.update_user_role(user_id, role)

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
            )

        return user
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
