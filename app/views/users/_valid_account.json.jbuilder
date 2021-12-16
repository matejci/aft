json.valid_account user.valid_account?

user.finished_signup? # this method adds incomplete signup errors on user
json.account_errors user.errors
