"""Service for GitHub API integration."""

from typing import Optional, List, Dict, Any
from github import Github, GithubException
from github.PullRequest import PullRequest
from github.Repository import Repository

from ..utils.config import settings


class GitHubService:
    """Service for interacting with GitHub API."""
    
    def __init__(self):
        """Initialize GitHub service with authentication."""
        if not settings.github_token:
            raise ValueError("GitHub token not configured")
        self.client = Github(settings.github_token)
    
    def get_repository(self, repo_full_name: str) -> Repository:
        """
        Get a GitHub repository.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            
        Returns:
            GitHub Repository object
            
        Raises:
            GithubException: If repository not found or access denied
        """
        try:
            return self.client.get_repo(repo_full_name)
        except GithubException as e:
            raise Exception(f"Failed to get repository: {e}")
    
    def get_pull_request(self, repo_full_name: str, pr_number: int) -> PullRequest:
        """
        Get a specific pull request.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            pr_number: Pull request number
            
        Returns:
            GitHub PullRequest object
        """
        try:
            repo = self.get_repository(repo_full_name)
            return repo.get_pull(pr_number)
        except GithubException as e:
            raise Exception(f"Failed to get pull request: {e}")
    
    def get_pr_files(self, repo_full_name: str, pr_number: int) -> List[Dict[str, Any]]:
        """
        Get files changed in a pull request.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            pr_number: Pull request number
            
        Returns:
            List of file information dictionaries
        """
        try:
            pr = self.get_pull_request(repo_full_name, pr_number)
            files = []
            for file in pr.get_files():
                files.append({
                    'filename': file.filename,
                    'status': file.status,
                    'additions': file.additions,
                    'deletions': file.deletions,
                    'changes': file.changes,
                    'patch': file.patch if hasattr(file, 'patch') else None,
                    'raw_url': file.raw_url,
                })
            return files
        except GithubException as e:
            raise Exception(f"Failed to get PR files: {e}")
    
    def get_file_content(
        self, 
        repo_full_name: str, 
        file_path: str, 
        ref: Optional[str] = None
    ) -> str:
        """
        Get content of a file from repository.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            file_path: Path to file in repository
            ref: Git reference (branch, tag, or commit SHA)
            
        Returns:
            File content as string
        """
        try:
            repo = self.get_repository(repo_full_name)
            content = repo.get_contents(file_path, ref=ref)
            if isinstance(content, list):
                raise ValueError(f"{file_path} is a directory, not a file")
            return content.decoded_content.decode('utf-8')
        except GithubException as e:
            raise Exception(f"Failed to get file content: {e}")
    
    def post_pr_comment(
        self, 
        repo_full_name: str, 
        pr_number: int, 
        comment: str
    ) -> None:
        """
        Post a comment on a pull request.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            pr_number: Pull request number
            comment: Comment text (supports Markdown)
        """
        try:
            pr = self.get_pull_request(repo_full_name, pr_number)
            pr.create_issue_comment(comment)
        except GithubException as e:
            raise Exception(f"Failed to post PR comment: {e}")
    
    def post_review_comment(
        self,
        repo_full_name: str,
        pr_number: int,
        commit_sha: str,
        file_path: str,
        line: int,
        comment: str
    ) -> None:
        """
        Post a review comment on a specific line of code.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            pr_number: Pull request number
            commit_sha: SHA of the commit to comment on
            file_path: Path to the file
            line: Line number to comment on
            comment: Comment text
        """
        try:
            pr = self.get_pull_request(repo_full_name, pr_number)
            pr.create_review_comment(
                body=comment,
                commit_id=pr.get_commits()[0],  # Get the commit object
                path=file_path,
                line=line
            )
        except GithubException as e:
            raise Exception(f"Failed to post review comment: {e}")
    
    def list_pull_requests(
        self, 
        repo_full_name: str, 
        state: str = "open"
    ) -> List[Dict[str, Any]]:
        """
        List pull requests in a repository.
        
        Args:
            repo_full_name: Full repository name (owner/repo)
            state: PR state - "open", "closed", or "all"
            
        Returns:
            List of pull request information dictionaries
        """
        try:
            repo = self.get_repository(repo_full_name)
            pulls = repo.get_pulls(state=state)
            
            pr_list = []
            for pr in pulls:
                pr_list.append({
                    'number': pr.number,
                    'title': pr.title,
                    'state': pr.state,
                    'created_at': pr.created_at.isoformat(),
                    'updated_at': pr.updated_at.isoformat(),
                    'user': pr.user.login,
                    'head_sha': pr.head.sha,
                })
            
            return pr_list
        except GithubException as e:
            raise Exception(f"Failed to list pull requests: {e}")
