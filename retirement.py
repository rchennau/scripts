import pandas as pd
# write code to capture args from the command line  
import argparse


def parse_args():
    parser = argparse.ArgumentParser(description='Calculate retirement income projections')
    parser.add_argument('--starting-amount', type=float, default=4100000,
                      help='Initial investment amount')
    parser.add_argument('--growth-rate', type=float, default=0.0703,
                      help='Annual investment growth rate (as decimal)')
    parser.add_argument('--withdrawal-rate', type=float, default=0.0781,
                      help='Initial withdrawal rate (as decimal)') 
    parser.add_argument('--tax-rate', type=float, default=0.24,
                      help='Initial tax rate (as decimal)')
    parser.add_argument('--ss-start-age', type=int, default=70,
                      help='Age to start Social Security benefits')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    
    
def calculate_retirement_income(starting_amount, annual_growth_rate, withdrawal_rate, tax_rate, social_security_start_age):
    """
    Calculates and projects retirement income year over year, adjusting for investment growth, 
    taxes, and Social Security benefits.

    Args:
      starting_amount: The initial investment amount.
      annual_growth_rate: The annual investment growth rate (as a decimal).
      withdrawal_rate: The initial withdrawal rate (as a decimal).
      tax_rate: The effective tax rate (as a decimal).
      social_security_start_age: The age at which Social Security benefits begin.

    Returns:
      A pandas DataFrame showing the projected income year over year.
    """

    current_age = 54
    retirement_year = 2025
    current_year = retirement_year
    end_age = 95
    social_security_benefit = 58476  # Estimated in today's dollars, adjusted for inflation and yearly benefit

    # Initialize lists to store data
    years = []
    ages = []
    starting_investments = []
    investment_growths = []
    withdrawals = []
    incomes_after_taxes = []
    social_security_benefits = []
    spouse_social_security_benefits = []  # Add list for spouse's benefit
    total_annual_incomes = []
    monthly_incomes = []

    current_amount = starting_amount
    while current_age <= end_age:
        # Calculate investment growth
        investment_growth = current_amount * annual_growth_rate

        # Calculate withdrawal amount
        withdrawal = current_amount * withdrawal_rate

        # Calculate income after taxes
        income_after_taxes = withdrawal * (1 - tax_rate)

        # Calculate Social Security benefit (if applicable)
        social_security = social_security_benefit if current_age >= social_security_start_age else 0
        spouse_social_security = social_security / 2 if current_age >= social_security_start_age else 0  # Spouse's benefit

        # Calculate total annual income
        total_annual_income = income_after_taxes + social_security + spouse_social_security  # Include spouse's benefit

        # Calculate monthly income
        monthly_income = total_annual_income / 12
        
        # Update tax rate based on new monthly income
        tax_rate = calculate_tax_rate(monthly_income)

        # Append data to lists
        years.append(current_year)
        ages.append(current_age)
        starting_investments.append(current_amount)
        investment_growths.append(investment_growth)
        withdrawals.append(withdrawal)
        incomes_after_taxes.append(income_after_taxes)
        social_security_benefits.append(social_security)
        spouse_social_security_benefits.append(spouse_social_security)
        total_annual_incomes.append(total_annual_income)
        monthly_incomes.append(monthly_income)

        # Update current amount for the next year
        current_amount = current_amount + investment_growth - withdrawal

        # Increment age and year
        current_age += 1
        current_year += 1

    # Create a pandas DataFrame with proper currency formatting
    df = pd.DataFrame({
        'Year': years,
        'Age': ages,
        'Starting Investment': [f'${value:,.2f} ' for value in starting_investments],
        'Investment Growth': [f'${value:,.2f} ' for value in investment_growths],
        'Withdrawal': [f'${value:,.2f} ' for value in withdrawals],
        'Income After Taxes': [f'${value:,.2f} ' for value in incomes_after_taxes],
        'Your Social Security': [f'${value:,.2f} ' for value in social_security_benefits],
        'Spouse\'s Social Security': [f'${value:,.2f} ' for value in spouse_social_security_benefits],
        'Total Annual Income': [f'${value:,.2f} ' for value in total_annual_incomes],
        'Monthly Income': [f'${value:,.2f} ' for value in monthly_incomes]
    })

    return df

def print_retirement_income(df):
    """
    Prints the retirement income year over year in a tabular format.

    Args:
      df: The pandas DataFrame containing the retirement income data.
    """
    pd.set_option('display.max_columns', None)  # Show all columns
    pd.set_option('display.width', None)  # Don't wrap wide tables
    pd.set_option('display.max_rows', None)  # Show all rows
    pd.set_option('display.float_format', lambda x: '{:,.2f}'.format(x))  # Add comma formatting for floats
    
    print(df.to_string(index=False))

def calculate_tax_rate(monthly_income):
    """
    Calculate the effective tax rate based on monthly income.
    Uses 2023 tax brackets for single filers.
    
    Args:
        monthly_income: Monthly income before taxes
        
    Returns:
        Effective tax rate as a decimal
    """
    # Convert monthly to annual income
    annual_income = monthly_income * 12
    
    # 2023 tax brackets for single filers
    brackets = [
        (0, 11000, 0.10),
        (11000, 44725, 0.12),
        (44725, 95375, 0.22),
        (95375, 182100, 0.24),
        (182100, 231250, 0.32),
        (231250, 578125, 0.35),
        (578125, float('inf'), 0.37)
    ]
    
    total_tax = 0
    remaining_income = annual_income
    
    # Calculate tax for each bracket
    for lower, upper, rate in brackets:
        if remaining_income <= 0:
            break
            
        # Calculate taxable amount in this bracket
        taxable_in_bracket = min(remaining_income, upper - lower)
        
        # Add tax for this bracket
        tax_in_bracket = taxable_in_bracket * rate
        total_tax += tax_in_bracket
        
        # Reduce remaining income
        remaining_income -= taxable_in_bracket
    
    # Calculate effective tax rate
    if annual_income > 0:
        effective_rate = total_tax / annual_income
    else:
        effective_rate = 0
        
    return effective_rate

def calculate_tax_amount(monthly_income):
    """
    Calculate the actual tax amount based on monthly income.
    
    Args:
        monthly_income: Monthly income before taxes
        
    Returns:
        Monthly tax amount in dollars
    """
    tax_rate = calculate_tax_rate(monthly_income)
    monthly_tax = monthly_income * tax_rate
    return monthly_tax


if __name__ == "__main__":
    args = parse_args()
 
       # Calculate retirement income using command line arguments
    df = calculate_retirement_income(
        args.starting_amount,
        args.growth_rate,
        args.withdrawal_rate,
        args.tax_rate,
        args.ss_start_age
    )
    print_retirement_income(df)

    # write code to export as html table  
    df.to_html('retirement_income.html', index=False, classes='table table-striped', bold_rows=True)    



