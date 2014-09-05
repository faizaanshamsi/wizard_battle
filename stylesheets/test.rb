require 'pry'
require 'csv'
class Transaction
  attr_reader :date, :amount, :desc, :account
  def initialize(date, amount, desc, account)
    @date = date
    @amount = amount.to_f
    @desc = desc
    @account = account
  end

  def deposit?
    amount > 0
  end

  def deposit_type
    if deposit?
      "DEPOSIT"
    else
      "WITHDRAWAL"
    end
  end

  def summary
    "$#{amount.abs} #{deposit_type} #{date} - #{desc}"
  end

  def self.filter(account_type, transactions)
    transactions.select { |transaction| transaction.account == account_type}
  end
end

class Account
  attr_reader :account_type, :starting_balance, :transactions
  def initialize(account_type, starting_balance, transactions)
    @account_type = account_type
    @starting_balance = starting_balance.to_f
    @transactions = transactions
  end

  def account_type
    @account_type
  end

  def current_balance
    starting_balance + transactions.inject(0) { |sum, transaction| sum + transaction.amount }
  end

  def summary
    summary = []
    transactions.each do |transaction|
      summary << transaction.summary
    end
    summary
  end

  def display
    puts "==============#{account_type}================"
    puts "Starting Balance: $#{starting_balance}"
    puts "Ending Balace: #{current_balance}"
    summary.each do |s|
      puts s
    end
    puts "========"
  end

end

transactions = []

CSV.foreach('bank_data.csv', headers: true) do |row|
  transactions << Transaction.new(row["Date"], row["Amount"], row["Description"], row["Account"])
end

accounts = []

CSV.foreach('balances.csv', headers: true) do |row|
  accounts << Account.new(row["Account"], row["Balance"], Transaction.filter(row["Account"], transactions))
end

binding.pry
