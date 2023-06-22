#[contract]


mod ERC20 {

use starknet::ContractAddress;
use starknet::get_caller_address;
use zeroable::Zeroable;
use integer::BoundedInt;

    // State Variables
    struct Storage{
        _name: felt252,
        _symbol: felt252,
        _decimal: u8,
        _total_supply: u256,
        _balances: LegacyMap::<ContractAddress, u256>,
        _allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
    }

    // Events
    #[event]
    fn Transfer (_from: ContractAddress, _to: ContractAddress, _value: u256) {}

    #[event]
    fn Approval (_owner: ContractAddress, _spender: ContractAddress, _value: u256) {}

    // Constructor
    #[constructor]
    fn constructor(name: felt252, symbol: felt252, decimal: u8) {
        _name::write(name);
        _symbol::write(symbol);
        _decimal::write(decimal);
    }

    // View Functions

    #[view]
    fn get_name() -> felt252 {
        _name::read()
    }

    #[view]
    fn get_symbol() -> felt252 {
        _symbol::read()
    }

    #[view]
    fn get_decimal() -> u8 {
        _decimal::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        _total_supply::read()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        _balances::read(account)
    }

    #[view]
    fn get_allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        _allowances::read((owner,spender))
    }

    // External Functions
    #[external]
    fn mint(recipient: ContractAddress, amount: u256) {
        assert(!recipient.is_zero(), 'ERC20: Address zero');
        let prev_total_supply = _total_supply::read();
        let prev_recipient_balance = _balances::read(recipient);
        _total_supply::write(prev_total_supply + amount);
        _balances::write(recipient, prev_recipient_balance + amount);
        Transfer(Zeroable::zero(), recipient, amount);
    }

    #[external]
    fn transfer_from(from: ContractAddress, to: ContractAddress, amount: u256) -> bool {
        let msg_sender = get_caller_address();
        _spend_allowance(from, msg_sender, amount);
        _transfer(from, to, amount);
        true
    }

    #[external]
    fn transfer(from: ContractAddress, to: ContractAddress, amount: u256) -> bool {
        assert(!to.is_zero(), 'ERC20: Address zero');
        _transfer(from, to, amount);
        true
    }

    #[internal]
    fn burn(account: ContractAddress, amount: u256){
        assert(!account.is_zero(),'ERC20: Address zero');
        _total_supply::write(_total_supply::read() - amount);
        _balances::write(account, _balances::read(account) - amount);
        Transfer(account, Zeroable::zero(), amount);
    }

    #[internal]
    fn _transfer(from: ContractAddress, to: ContractAddress, amount: u256){
        assert(!from.is_zero(), 'ERC20: Address zero');
        assert(!to.is_zero(), 'ERC20: Address zero');
        _balances::write(from,_balances::read(from) - amount);
        _balances::write(to,_balances::read(to) + amount);
    }

    #[internal]
    fn _approve(owner: ContractAddress, spender: ContractAddress, amount: u256){
        assert(!owner.is_zero(), 'ERC20: Address zero');
        assert(!owner.is_zero(), 'ERC20: Address zero');
        _allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
    }

    #[internal]
    fn _spend_allowance(owner: ContractAddress, spender: ContractAddress, amount: u256){
        let current_allowance = _allowances::read((owner, spender));
        if current_allowance != BoundedInt::max(){
            _approve(owner, spender, current_allowance - amount);
        }
    }
}