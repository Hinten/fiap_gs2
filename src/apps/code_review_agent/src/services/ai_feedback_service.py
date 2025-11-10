"""Service for AI-powered code review feedback using CrewAI."""

from typing import List, Optional
from crewai import Agent, Task, Crew

from ..models import AnalysisResults, CodeIssue
from ..utils.config import settings


class AIFeedbackService:
    """Service for generating AI-powered code review feedback."""
    
    def __init__(self):
        """Initialize AI feedback service."""
        self.code_reviewer_agent = self._create_code_reviewer_agent()
    
    def _create_code_reviewer_agent(self) -> Agent:
        """
        Create the code reviewer AI agent.
        
        Returns:
            Configured CrewAI Agent for code review
        """
        return Agent(
            role='Code Review Specialist',
            goal='Provide educational and constructive code reviews for students',
            backstory="""You are an experienced software engineer and educator at FIAP.
            You understand that students are learning and need guidance, not just criticism.
            You provide detailed explanations and examples to help students improve.
            You prioritize learning over perfection and adapt your tone to the student's level.""",
            verbose=True,
            allow_delegation=False
        )
    
    def generate_feedback(
        self,
        code_content: str,
        analysis_results: AnalysisResults,
        discipline: str,
        student_level: str = "intermediate"
    ) -> str:
        """
        Generate personalized feedback for code review.
        
        Args:
            code_content: The code being reviewed
            analysis_results: Results from static analysis
            discipline: Academic discipline (e.g., "Software Engineering")
            student_level: Student proficiency level (beginner, intermediate, advanced)
            
        Returns:
            Markdown-formatted feedback text
        """
        # Prepare issues summary
        issues_summary = self._format_issues_summary(analysis_results)
        
        # Create the review task
        review_task = Task(
            description=f"""
            Analyze the following code from a student in {discipline}.
            Student level: {student_level}
            
            CODE:
            ```
            {code_content[:2000]}  # Limit code length
            ```
            
            STATIC ANALYSIS RESULTS:
            {issues_summary}
            
            Generate a comprehensive code review with:
            1. **Summary**: Brief overview with positive points and areas for improvement
            2. **Critical Issues**: Security vulnerabilities and bugs (if any)
            3. **Code Quality**: Best practices, patterns, and refactoring suggestions
            4. **Learning Resources**: Links to documentation and tutorials
            5. **Encouragement**: Motivational closing remarks
            
            Format your response in clear Markdown. Be constructive and educational.
            """,
            agent=self.code_reviewer_agent,
            expected_output="A comprehensive code review in Markdown format"
        )
        
        # Execute the review
        crew = Crew(
            agents=[self.code_reviewer_agent],
            tasks=[review_task],
            verbose=False
        )
        
        try:
            result = crew.kickoff()
            return str(result)
        except Exception as e:
            # Fallback to template-based feedback if AI fails
            return self._generate_fallback_feedback(analysis_results, discipline)
    
    def _format_issues_summary(self, analysis_results: AnalysisResults) -> str:
        """
        Format analysis results into a readable summary.
        
        Args:
            analysis_results: Analysis results object
            
        Returns:
            Formatted string summary
        """
        summary_parts = []
        
        summary_parts.append(f"Total files analyzed: {analysis_results.total_files_analyzed}")
        summary_parts.append(f"Total issues found: {analysis_results.total_issues_found}")
        
        if analysis_results.security_issues:
            summary_parts.append(f"\nSecurity issues ({len(analysis_results.security_issues)}):")
            for issue in analysis_results.security_issues[:5]:
                summary_parts.append(
                    f"  - [{issue.severity.value}] {issue.file_path}:{issue.line_number} - {issue.message}"
                )
        
        if analysis_results.complexity_issues:
            summary_parts.append(f"\nComplexity issues ({len(analysis_results.complexity_issues)}):")
            for issue in analysis_results.complexity_issues[:3]:
                summary_parts.append(
                    f"  - [{issue.severity.value}] {issue.file_path}:{issue.line_number} - {issue.message}"
                )
        
        if analysis_results.linting_issues:
            summary_parts.append(f"\nCode quality issues ({len(analysis_results.linting_issues)}):")
            for issue in analysis_results.linting_issues[:5]:
                summary_parts.append(
                    f"  - [{issue.severity.value}] {issue.file_path}:{issue.line_number} - {issue.message}"
                )
        
        return "\n".join(summary_parts)
    
    def _generate_fallback_feedback(
        self, 
        analysis_results: AnalysisResults,
        discipline: str
    ) -> str:
        """
        Generate basic feedback when AI service is unavailable.
        
        Args:
            analysis_results: Analysis results object
            discipline: Academic discipline
            
        Returns:
            Template-based feedback in Markdown
        """
        feedback = f"""# Code Review - {discipline}

## 📊 Summary

Your code has been analyzed and {analysis_results.total_issues_found} issues were found across {analysis_results.total_files_analyzed} files.

"""
        
        if analysis_results.security_issues:
            feedback += """## 🔐 Security Issues (Critical)

"""
            for issue in analysis_results.security_issues[:5]:
                feedback += f"- **{issue.file_path}:{issue.line_number}** - {issue.message}\n"
            feedback += "\n⚠️ Please address security issues before proceeding.\n\n"
        
        if analysis_results.complexity_issues:
            feedback += """## 🧩 Complexity Issues

"""
            for issue in analysis_results.complexity_issues[:3]:
                feedback += f"- **{issue.file_path}:{issue.line_number}** - {issue.message}\n"
                if issue.suggestion:
                    feedback += f"  💡 {issue.suggestion}\n"
            feedback += "\n"
        
        if analysis_results.linting_issues:
            feedback += """## ✨ Code Quality Suggestions

"""
            for issue in analysis_results.linting_issues[:5]:
                feedback += f"- **{issue.file_path}:{issue.line_number}** - {issue.message}\n"
            feedback += "\n"
        
        feedback += """## 📚 Resources

- [Python Best Practices](https://docs.python-guide.org/)
- [Clean Code Principles](https://www.freecodecamp.org/news/clean-coding-for-beginners/)
- [OWASP Security Guidelines](https://owasp.org/)

## 💪 Keep Learning!

Code review is an opportunity to learn and improve. Address the issues step by step, and don't hesitate to ask for help!
"""
        
        return feedback
