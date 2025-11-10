"""Repository for code review data access."""

from typing import Optional, List
from datetime import datetime
import uuid
import boto3
from botocore.exceptions import ClientError

from ..models import CodeReview, ReviewStatus
from ..utils.config import settings


class CodeReviewRepository:
    """Repository for managing code review data in DynamoDB."""
    
    def __init__(self):
        """Initialize the repository with DynamoDB client."""
        self.dynamodb = boto3.resource('dynamodb', region_name=settings.aws_region)
        self.table = self.dynamodb.Table(settings.dynamodb_table_reviews)
    
    async def create(self, review: CodeReview) -> CodeReview:
        """
        Create a new code review record.
        
        Args:
            review: CodeReview object to store
            
        Returns:
            The created CodeReview object
            
        Raises:
            ClientError: If DynamoDB operation fails
        """
        try:
            item = review.model_dump()
            # Convert datetime to ISO string for DynamoDB
            item['created_at'] = item['created_at'].isoformat()
            if item.get('approved_at'):
                item['approved_at'] = item['approved_at'].isoformat()
            
            self.table.put_item(Item=item)
            return review
        except ClientError as e:
            raise Exception(f"Failed to create code review: {e}")
    
    async def get(self, review_id: str) -> Optional[CodeReview]:
        """
        Get a code review by ID.
        
        Args:
            review_id: Unique identifier of the review
            
        Returns:
            CodeReview object if found, None otherwise
        """
        try:
            response = self.table.get_item(Key={'review_id': review_id})
            if 'Item' not in response:
                return None
            
            item = response['Item']
            # Convert ISO strings back to datetime
            if item.get('created_at'):
                item['created_at'] = datetime.fromisoformat(item['created_at'])
            if item.get('approved_at'):
                item['approved_at'] = datetime.fromisoformat(item['approved_at'])
            
            return CodeReview(**item)
        except ClientError as e:
            raise Exception(f"Failed to get code review: {e}")
    
    async def update(self, review: CodeReview) -> CodeReview:
        """
        Update an existing code review.
        
        Args:
            review: CodeReview object with updated data
            
        Returns:
            Updated CodeReview object
        """
        try:
            item = review.model_dump()
            item['created_at'] = item['created_at'].isoformat()
            if item.get('approved_at'):
                item['approved_at'] = item['approved_at'].isoformat()
            
            self.table.put_item(Item=item)
            return review
        except ClientError as e:
            raise Exception(f"Failed to update code review: {e}")
    
    async def list_pending(self, limit: int = 50) -> List[CodeReview]:
        """
        List all pending code reviews.
        
        Args:
            limit: Maximum number of reviews to return
            
        Returns:
            List of pending CodeReview objects
        """
        try:
            response = self.table.scan(
                FilterExpression='#status = :status',
                ExpressionAttributeNames={'#status': 'status'},
                ExpressionAttributeValues={':status': ReviewStatus.PENDING.value},
                Limit=limit
            )
            
            reviews = []
            for item in response.get('Items', []):
                if item.get('created_at'):
                    item['created_at'] = datetime.fromisoformat(item['created_at'])
                if item.get('approved_at'):
                    item['approved_at'] = datetime.fromisoformat(item['approved_at'])
                reviews.append(CodeReview(**item))
            
            return reviews
        except ClientError as e:
            raise Exception(f"Failed to list pending reviews: {e}")
    
    async def get_by_student(self, student_id: str, limit: int = 50) -> List[CodeReview]:
        """
        Get all reviews for a specific student.
        
        Args:
            student_id: Student identifier
            limit: Maximum number of reviews to return
            
        Returns:
            List of CodeReview objects for the student
        """
        try:
            response = self.table.scan(
                FilterExpression='student_id = :student_id',
                ExpressionAttributeValues={':student_id': student_id},
                Limit=limit
            )
            
            reviews = []
            for item in response.get('Items', []):
                if item.get('created_at'):
                    item['created_at'] = datetime.fromisoformat(item['created_at'])
                if item.get('approved_at'):
                    item['approved_at'] = datetime.fromisoformat(item['approved_at'])
                reviews.append(CodeReview(**item))
            
            return reviews
        except ClientError as e:
            raise Exception(f"Failed to get reviews for student: {e}")
