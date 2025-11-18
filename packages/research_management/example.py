"""
Example usage of the Research Management API.

This script demonstrates how to use the Research Management service
programmatically without making HTTP requests.
"""

from datetime import datetime, timedelta

from research_management.models.alert import AlertCreate, AlertSeverity, AlertType
from research_management.models.member import MemberRole, ProjectMemberCreate
from research_management.models.project import ProjectCreate, ProjectUpdate
from research_management.models.update import ProjectUpdateCreate
from research_management.services import (
    AlertService,
    DashboardService,
    ProjectService,
    UpdateService,
)


def main():
    """Main example function."""
    print("=" * 60)
    print("Research Management System - Example Usage")
    print("=" * 60)

    # Initialize services
    project_service = ProjectService()
    update_service = UpdateService()
    alert_service = AlertService()
    dashboard_service = DashboardService()

    # 1. Create a research project
    print("\n1. Creating a new research project...")
    project_data = ProjectCreate(
        title="Machine Learning for Image Classification",
        description="Research project on applying ML techniques to image classification tasks",
        area="Machine Learning",
        start_date=datetime.utcnow(),
        expected_end_date=datetime.utcnow() + timedelta(days=180),
    )
    project = project_service.create_project(project_data)
    print(f"   ✓ Created project: {project.project_id} - {project.title}")
    print(f"   Status: {project.status.value}")
    print(f"   Health: {project.health_status.value}")

    # 2. Add members to the project
    print("\n2. Adding members to the project...")

    # Add an advisor
    advisor_member = ProjectMemberCreate(user_id="advisor-001", role=MemberRole.ADVISOR)
    advisor = project_service.add_member(project.project_id, advisor_member)
    print(f"   ✓ Added advisor: {advisor.user_id}")

    # Add students
    for i in range(1, 3):
        student_member = ProjectMemberCreate(
            user_id=f"student-00{i}", role=MemberRole.STUDENT
        )
        student = project_service.add_member(project.project_id, student_member)
        print(f"   ✓ Added student: {student.user_id}")

    # 3. Submit project updates
    print("\n3. Submitting project updates...")
    update_data = ProjectUpdateCreate(
        content="""
        ## Progress Update - Week 1
        
        - Completed literature review
        - Set up development environment
        - Started data collection
        
        **Next steps**: Continue data collection and begin preprocessing.
        """,
        milestone_completed="Literature Review",
        files_attached=["https://example.com/lit-review.pdf"],
    )
    update = update_service.submit_update(
        project.project_id, "student-001", update_data
    )
    print(f"   ✓ Submitted update: {update.update_id}")
    print(f"   Milestone: {update.milestone_completed}")

    # 4. Get project timeline
    print("\n4. Retrieving project timeline...")
    timeline = update_service.get_project_updates(project.project_id, limit=10)
    print(f"   ✓ Found {len(timeline)} updates")
    for upd in timeline:
        print(f"     - {upd.timestamp.strftime('%Y-%m-%d')}: {upd.milestone_completed}")

    # 5. Update project health status
    print("\n5. Updating project health status...")
    update_data = ProjectUpdate(health_status="on_track")
    updated_project = project_service.update_project(project.project_id, update_data)
    print(f"   ✓ Updated health status to: {updated_project.health_status.value}")

    # 6. Create an alert (simulating automated monitoring)
    print("\n6. Creating an alert...")
    alert_data = AlertCreate(
        type=AlertType.DEADLINE_SOON,
        project_id=project.project_id,
        message=f"🟢 INFO: Deadline for project '{project.title}' is in 7 days",
        severity=AlertSeverity.INFO,
    )
    alert = alert_service.create_alert(alert_data)
    print(f"   ✓ Created alert: {alert.alert_id}")
    print(f"   Type: {alert.type.value}")
    print(f"   Severity: {alert.severity.value}")

    # 7. Get coordinator dashboard
    print("\n7. Retrieving coordinator dashboard...")
    dashboard = dashboard_service.get_coordinator_dashboard()
    print(f"   ✓ Dashboard metrics:")
    print(f"     - Total projects: {dashboard['total_projects']}")
    print(f"     - Active projects: {dashboard['active_projects']}")
    print(f"     - Completion rate: {dashboard['completion_rate']}%")
    print(f"     - Avg students/advisor: {dashboard['avg_students_per_advisor']}")
    print(f"     - Projects in risk: {dashboard['projects_in_risk']}")
    print(f"     - Students without advisor: {dashboard['students_without_advisor']}")

    # 8. Get advisor dashboard
    print("\n8. Retrieving advisor dashboard...")
    advisor_dashboard = dashboard_service.get_advisor_dashboard("advisor-001")
    print(f"   ✓ Advisor dashboard:")
    print(f"     - Total projects: {advisor_dashboard['total_projects']}")
    print(f"     - Active projects: {advisor_dashboard['active_projects']}")
    print(f"     - Total students: {advisor_dashboard['total_students']}")

    # 9. Get student dashboard
    print("\n9. Retrieving student dashboard...")
    student_dashboard = dashboard_service.get_student_dashboard("student-001")
    print(f"   ✓ Student dashboard:")
    if student_dashboard["has_project"]:
        print(f"     - Project: {student_dashboard['project_title']}")
        print(f"     - Status: {student_dashboard['status']}")
        print(f"     - Health: {student_dashboard['health_status']}")
        print(f"     - Has advisor: {student_dashboard['has_advisor']}")
    else:
        print(f"     {student_dashboard['message']}")

    # 10. List all active alerts
    print("\n10. Listing active alerts...")
    active_alerts = alert_service.get_active_alerts()
    print(f"   ✓ Found {len(active_alerts)} active alerts")
    for a in active_alerts:
        emoji = (
            "🟢"
            if a.severity.value == "info"
            else "🟡" if a.severity.value == "warning" else "🔴"
        )
        print(f"     {emoji} [{a.type.value}] {a.message[:50]}...")

    print("\n" + "=" * 60)
    print("Example completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    # Note: This requires Firebase emulator to be running
    # Start emulator: firebase emulators:start --only firestore --project demo-test-project
    print("\n⚠️  Make sure Firebase emulator is running before executing this example!")
    print(
        "   Command: firebase emulators:start --only firestore --project demo-test-project\n"
    )

    try:
        main()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nMake sure:")
        print("  1. Firebase emulator is running")
        print("  2. FIRESTORE_EMULATOR_HOST environment variable is set")
