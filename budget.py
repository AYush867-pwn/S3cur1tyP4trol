import boto3
import botocore.exceptions
from datetime import datetime, timezone, timedelta

client = boto3.client('budgets')
session = boto3.Session()
sts_client = session.client('sts')
account_id = sts_client.get_caller_identity()['Account']

#amount = '1' 
#unit = 'USD'
#threshold = 75.0 
#budget_name = 'Custom_Budget'

# List of emails
mail_addresses = ["joshiayush867@gmail.com", "elliothere867@gmail.com"]

# Creating subscriber list correctly
subscribers_list = [{"SubscriptionType": "EMAIL", "Address": email} for email in mail_addresses]
def budget_exists(budget_name):
    """Check if a budget with the given name already exists."""
    try:
        response = client.describe_budgets(AccountId=account_id)
        for budget in response.get('Budgets', []):
            if budget['BudgetName'] == budget_name:
                return True  # Budget already exists
        return False  # No matching budget found
    except Exception as e:
        print(f"Error checking budget existence: {e}")
        return False

def create_budget(budget_name,threshold,unit,amount):
    if budget_exists(budget_name):
        print(f"Budget with name '{budget_name}' already exists.")
        return
    start_time = datetime.now(timezone.utc)
    end_time = start_time + timedelta(days=180)
    response = client.create_budget(
        AccountId=account_id,
        Budget={
            'BudgetName': budget_name,
            'BudgetLimit': {
                'Amount': amount,
                'Unit': unit
            },
            'TimeUnit': 'MONTHLY',
            'TimePeriod': {
                'Start': start_time,
                'End': end_time
            },
            'BudgetType': 'COST'
        },
        NotificationsWithSubscribers=[
            {
                'Notification': {
                    'NotificationType': 'ACTUAL',
                    'ComparisonOperator': 'GREATER_THAN',
                    'Threshold': threshold,
                    'ThresholdType': 'PERCENTAGE',
                    'NotificationState': 'ALARM'
                },
                'Subscribers': subscribers_list
            }
        ]
    )

    print("Budget created successfully:", response)


def delete_budget(budget_name):
    try:
    
        response2 = client.delete_budget(
            AccountId = account_id,
            BudgetName = budget_name
        )
        print(f"Budget '{budget_name}' deleted successfully")
    except botocore.exceptions.ClientError as e:
        error_code = e.response['Error']['Code']
    
        if error_code == "NotFoundException":
            print(f"⚠️ Error: Budget '{budget_name}' does not exist or has already been deleted.")
        elif error_code == "AccessDeniedException":
            print("🚫 Error: Access denied! Check your AWS IAM permissions for 'budgets:DeleteBudget'.")
        else:
            print(f"❌ Unexpected error: {e}")
    except Exception as e:
        print(f"❌ An unknown error occurred: {e}")

#create_budget('test_budget',75.0,'USD','2')
delete_budget('test_budget')

