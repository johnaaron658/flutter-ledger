
class Account {
  final int? id;
  final double balance;
  final String name;
  final String currency;
  final AccountType accountType;
  final List<Account> subAccounts;
  final double limit;

  const Account({
    this.id,
    required this.balance,
    required this.name,
    required this.currency,
    required this.accountType,
    required this.subAccounts,
    required this.limit,
  });
}

enum AccountType {
  Asset,
  Liability,
  Expense,
  Income,
  Equity,
}