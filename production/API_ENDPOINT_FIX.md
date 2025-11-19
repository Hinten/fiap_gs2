# API Endpoint Configuration - Fix Summary

## Issues Found and Fixed

### 1. Research Management API Base URL
**Problem**: The research_dashboard service was using `http://localhost:8002` by default, but the unified backend runs on `http://localhost:8000`.

**Solution**: 
- Created `lib/src/config/api_config.dart` to centralize API configuration
- Override `researchServiceProvider` in `main.dart` with correct base URL (`http://localhost:8000`)
- Exported `service_providers.dart` from research_dashboard package

### 2. Approval Interface API Base URL  
**Problem**: The approval_interface service was using `http://localhost:8080` and the approval backend wasn't implemented.

**Solution**:
- Created `production/backend/mock_approval_api.py` - Mock API with demo data
- Integrated mock approval router into unified backend at `/api/v1/approvals/*`
- Override `approvalServiceProvider` in `main.dart` with correct base URL
- Mock API provides 3 sample approval items for demonstration

## API Endpoints Structure

### Unified Backend (http://localhost:8000)

#### Research Management
- `GET /api/v1/research/projects` - List research projects
- `POST /api/v1/research/projects` - Create project
- `GET /api/v1/research/projects/{id}` - Get project details
- `GET /api/v1/research/dashboard/coordinator` - Coordinator dashboard
- `GET /api/v1/research/dashboard/advisor` - Advisor dashboard (requires user_id param)
- `GET /api/v1/research/dashboard/student` - Student dashboard (requires user_id param)
- `GET /api/v1/research/alerts` - List alerts

#### Content Review
- `POST /api/v1/content-review/review` - Review content (with query param: review_type)

#### Approval Interface (Mock)
- `GET /api/v1/approvals/pending` - Get pending approvals
- `GET /api/v1/approvals/{id}` - Get approval by ID
- `POST /api/v1/approvals/{id}/approve` - Approve item
- `POST /api/v1/approvals/{id}/reject` - Reject item
- `PUT /api/v1/approvals/{id}/edit` - Edit item
- `POST /api/v1/approvals/bulk-approve` - Bulk approve
- `GET /api/v1/approvals/history` - Get approval history

## Changes Made

### Frontend (production/dashboard/)
1. **lib/src/config/api_config.dart** - New file
   - Centralized API configuration
   - Support for environment variables
   - Default: `http://localhost:8000` for all services

2. **lib/main.dart** - Updated
   - Import research and approval service providers
   - Override providers with correct base URLs
   - Providers now use `researchApiBaseUrl` and `approvalApiBaseUrl`

3. **packages_dashboard/research_dashboard/lib/research_dashboard.dart** - Updated
   - Export `src/providers/service_providers.dart`
   - Make `researchServiceProvider` accessible

### Backend (production/backend/)
1. **mock_approval_api.py** - New file
   - Mock approval API with demo data
   - 3 sample approval items (code_review, content_review, grading)
   - Full CRUD operations
   - Bulk approval support
   - History endpoint

2. **main.py** - Updated
   - Import mock_approval_router
   - Include mock approval router at `/api/v1` prefix
   - Update startup message to mention mock approval service
   - Update root endpoint to list approval service
   - Update health check to include approval service

## Testing

### Backend
```bash
cd production/backend
source .venv/bin/activate
python main.py
```

Access:
- API Docs: http://localhost:8000/docs
- Health: http://localhost:8000/health
- Root: http://localhost:8000/

### Frontend
```bash
cd production/dashboard
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

Test:
1. Navigate to "Gestão de Pesquisa" - Should load dashboards
2. Navigate to "Interface de Aprovação" - Should show 3 mock approval items
3. Try approving/rejecting items

## Environment Variables

Both services can be configured via environment variables:

```bash
# Backend - use default port 8000
python main.py

# Frontend - override backend URL if needed
flutter run \
  --dart-define=SKIP_AUTH=true \
  --dart-define=BACKEND_URL=http://localhost:8000 \
  -d chrome
```

## Notes

- **Mock Approval API**: The approval interface backend is not yet implemented. The mock API provides demo functionality for testing the UI.
- **Research Management**: Fully functional with real Firebase backend.
- **Content Review**: Fully functional with AI-powered review.
- **All APIs**: Now correctly point to unified backend at port 8000.
